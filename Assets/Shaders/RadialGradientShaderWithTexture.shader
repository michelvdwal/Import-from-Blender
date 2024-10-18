Shader "Custom/RadialGradientShaderWithTexture"
{
    Properties
    {
        _CenterColor ("Center Color", Color) = (1, 1, 1, 1)
        _EdgeColor ("Edge Color", Color) = (0, 0, 0, 1)
        _GradientSize ("Gradient Size", Float) = 1.0
        _GradientCenter ("Gradient Center", Vector) = (0.5, 0.5, 0, 0)

        _MainTex ("Albedo Texture", 2D) = "white" {}
        _NormalMap ("Normal Map", 2D) = "bump" {}
        _OcclusionMap ("Ambient Occlusion map", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 100

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata_t
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            float4 _CenterColor;
            float4 _EdgeColor;
            float _GradientSize;
            float4 _GradientCenter;

            sampler2D _MainTex;
            sampler2D _NormalMap;
            sampler2D _OcclusionMap;

            // Use Tiling and Offset
            float4 _MainTex_ST; // Tiling and Offset for main texture
            float4 _NormalMap_ST; // Tiling and Offset for normal map
            float4 _OcclusionMap_ST; // Tiling and Offset for occlusion map

            v2f vert(appdata_t v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv; // Pass the original UV coordinates
                return o;
            }

            float4 frag(v2f i) : SV_Target
            {
                // Adjust UV coordinates for radial gradient
                float2 uv = i.uv * 2.0 - 1.0; // Scale and center UV coordinates
                uv.y = -uv.y; // Invert Y-axis for proper orientation

                // Calculate distance from the specified center point
                float2 center = _GradientCenter.xy; // Use the GradientCenter property
                float dist = distance(uv, center); // Calculate distance in the UV space

                // Normalize distance based on gradient size
                float gradientFactor = smoothstep(0.0, _GradientSize, dist);

                // Calculate color based on distance
                float4 gradientColor = lerp(_CenterColor, _EdgeColor, gradientFactor);

                // Sample the albedo texture using Tiling and Offset
                float2 mainTexUV = i.uv * _MainTex_ST.xy + _MainTex_ST.zw; // Apply Tiling and Offset
                float4 albedoColor = tex2D(_MainTex, mainTexUV);

                // Sample the normal map using Tiling and Offset
                float2 normalMapUV = i.uv * _NormalMap_ST.xy + _NormalMap_ST.zw; // Apply Tiling and Offset
                float4 normalColor = tex2D(_NormalMap, normalMapUV);

                // Sample the ambient occlusion map using Tiling and Offset
                float2 occlusionMapUV = i.uv * _OcclusionMap_ST.xy + _OcclusionMap_ST.zw; // Apply Tiling and Offset
                float occlusion = tex2D(_OcclusionMap, occlusionMapUV).r;

                // Combine the gradient color with the albedo color and occlusion
                return gradientColor * albedoColor * occlusion;
            }
            ENDHLSL
        }
    }
    FallBack "Diffuse"
}
