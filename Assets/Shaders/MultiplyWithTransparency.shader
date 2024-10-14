Shader "Custom/MultiplyWithTransparency"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _TransparencyControl ("Transparency Control", Range(0, 1)) = 0.5 // Control how much luminance affects transparency
        _OpacityControl ("Opacity Control", Range(0, 1)) = 1.0 // Control overall opacity of the texture
        _EdgeSmoothness ("Edge Smoothness", Range(0, 1)) = 0.1 // Control the smoothness of edges
    }
    SubShader
    {
        Tags { "Queue" = "Transparent" "RenderType" = "Transparent" }
        LOD 200

        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha  // Standard transparency blend
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

            sampler2D _MainTex;
            float _TransparencyControl; // Slider for transparency control
            float _OpacityControl; // Slider for overall opacity control
            float _EdgeSmoothness; // Slider for edge smoothness

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                // Sample the texture
                float4 texColor = tex2D(_MainTex, i.uv);
                float luminance = texColor.r; // Assuming black and white texture

                // Calculate alpha based on luminance
                float alpha;
                if (luminance < 0.1) // Near black
                {
                    alpha = 1.0; // Fully opaque
                }
                else if (luminance > 0.9) // Near white
                {
                    alpha = 0.0; // Fully transparent
                }
                else // Gray pixels
                {
                    // Adjust the alpha for gray pixels
                    float baseAlpha = 1.0 - (luminance * (1.0 - _TransparencyControl));
                    // Apply smoothstep for smoother edges
                    alpha = baseAlpha * (1.0 - smoothstep(0.1, 0.1 + _EdgeSmoothness, luminance));
                }

                // Final color is multiplied by luminance
                float3 finalColor = texColor.rgb * luminance * _OpacityControl; // Adjust color by opacity

                // Construct the final output color
                return float4(finalColor, alpha * _OpacityControl);
            }
            ENDCG
        }
    }
    FallBack "Unlit/Transparent"
}
