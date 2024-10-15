Shader "Custom/URPGrayscaleMultiplyBlend"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}  // Your grayscale texture
    }
    SubShader
    {
        Tags { "Queue" = "Transparent" }

        Pass
        {
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
                float4 screenPos : TEXCOORD1;
            };

            sampler2D _MainTex;
            sampler2D _CameraOpaqueTexture;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                // Transform object position to homogeneous clip space using URP's function
                o.pos = TransformObjectToHClip(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.screenPos = ComputeScreenPos(o.pos);  // Calculate screen position for opaque texture sampling
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                // Sample the texture
                float4 texColor = tex2D(_MainTex, i.uv);

                // Convert to grayscale (luminance)
                float grayscale = dot(texColor.rgb, float3(0.299, 0.587, 0.114));

                // Sample the opaque background texture from _CameraOpaqueTexture
                float2 screenUV = i.screenPos.xy / i.screenPos.w;  // Convert to screen space UV
                float4 backgroundColor = tex2D(_CameraOpaqueTexture, screenUV);

                // Use grayscale value to blend between the texture and background
                // Invert grayscale value so that white becomes fully transparent and black is opaque
                float alpha = 1.0 - grayscale;

                // Final color is a blend between texture and background, modulated by alpha
                float4 finalColor = lerp(backgroundColor, texColor, alpha);

                // Set the alpha channel to control transparency based on the grayscale
                finalColor.a = alpha;

                return finalColor;
            }
            ENDHLSL
        }
    }
    FallBack "Diffuse"
}
