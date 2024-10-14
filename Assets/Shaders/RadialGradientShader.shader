Shader "Custom/RadialGradientShader"
{
    Properties
    {
        _CenterColor ("Center Color", Color) = (1, 1, 1, 1)
        _EdgeColor ("Edge Color", Color) = (0, 0, 0, 1)
        _GradientSize ("Gradient Size", Float) = 1.0
        _GradientCenter ("Gradient Center", Vector) = (0.5, 0.5, 0, 0)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
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
            float4 _GradientCenter; // This holds the center of the gradient

            v2f vert (appdata_t v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.vertex.xy; // Pass the world position as UV
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                // Calculate distance from the specified center point
                float2 center = _GradientCenter.xy; // Use the GradientCenter property
                float dist = distance(i.uv, center);

                // Normalize distance based on gradient size
                float gradientFactor = smoothstep(0.0, _GradientSize, dist);

                // Calculate color based on distance
                float4 gradientColor = lerp(_CenterColor, _EdgeColor, gradientFactor);

                return gradientColor;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
