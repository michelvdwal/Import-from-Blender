Shader "Custom/BlurredEdgesWithColor"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color", Color) = (1,1,1,1)
        _EdgeDistance ("Edge Distance", Range(0.0, 1.0)) = 0.5
        _EdgeTransparency ("Edge Transparency", Range(0, 1)) = 0.0
        _Smoothness ("Smoothness", Range(0.0, 1.0)) = 0.1
    }
    SubShader
    {
        Tags { "Queue" = "Transparent" "RenderType" = "Transparent" }
        LOD 200

        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
                float3 localPos : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _Color;
            float _EdgeDistance;
            float _EdgeTransparency;
            float _Smoothness;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                // Transform vertex position to local space for distance calculation
                o.localPos = v.vertex.xyz;
                
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                // Calculate the distance from the current fragment to the center of the mesh (local space)
                float distanceToCenter = length(i.localPos);

                // Normalize the distance based on the provided edge distance
                float edgeFactor = smoothstep(_EdgeDistance - _Smoothness, _EdgeDistance, distanceToCenter);

                // Calculate alpha based on the edge transparency and distance
                float alpha = lerp(1.0, _EdgeTransparency, edgeFactor);

                // Sample the texture
                float4 texColor = tex2D(_MainTex, i.uv);

                // Apply color tint
                float4 finalColor = texColor * _Color;

                // Set the final color's alpha
                finalColor.a *= alpha;

                return finalColor;
            }
            ENDCG
        }
    }
    FallBack "Transparent/Diffuse"
}
