Shader "Custom/EdgeBorderShader"
{
    Properties
    {
        _BorderWidth ("Border Width", Range(0.0, 100.0)) = 0.0 // Control the width of the border
        _BorderColor ("Border Color", Color) = (0, 0, 0, 1) // Color of the border (black by default)
        _MeshColor ("Mesh Color", Color) = (1, 1, 1, 1) // Color of the mesh (white by default)
        _BlurAmount ("Blur Amount", Range(0.0, 100.0)) = 0.0 // Amount of blur applied to the border
    }
    SubShader
    {
        Tags { "Queue" = "Transparent" "RenderType" = "Transparent" }
        LOD 200

        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha // Standard transparency blend
            ZWrite Off
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
            };

            float _BorderWidth; // Width of the border
            float4 _BorderColor; // Color of the border
            float4 _MeshColor; // Color of the mesh
            float _BlurAmount; // Amount of blur applied to the border

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                // Define the width in UV space (assuming the mesh is normalized)
                float borderWidthUV = _BorderWidth / 100.0; // Scale from 0-100 to 0-1

                // Calculate the distance to the nearest edge (UV space)
                float edgeDistance = min(min(i.uv.x, 1.0 - i.uv.x), min(i.uv.y, 1.0 - i.uv.y));

                // Calculate the blur effect based on the border width and blur amount
                float blurFactor = smoothstep(borderWidthUV - _BlurAmount * 0.01, borderWidthUV, edgeDistance);

                // Determine the color based on the edge distance with blur
                float4 finalColor = lerp(_MeshColor, _BorderColor, blurFactor); // Blend based on distance

                return finalColor; // Return the final color
            }
            ENDCG
        }
    }
    FallBack "Unlit/Transparent"
}
