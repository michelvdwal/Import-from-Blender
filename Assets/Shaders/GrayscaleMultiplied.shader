Shader "Custom/GradientOverlayShader"
{
    Properties
    {
        _MainTex ("Gradient Texture", 2D) = "white" {}
        _BackgroundTex ("Background Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        Pass
        {
            ZWrite On
            ZTest LEqual

            Cull Front // Cull front faces of the foreground quad

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

            sampler2D _MainTex;
            sampler2D _BackgroundTex;
            float4 _MainTex_ST;

            v2f vert (appdata_t v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 gradientColor = tex2D(_MainTex, i.uv);
                fixed4 backgroundColor = tex2D(_BackgroundTex, i.uv);
                
                // Calculate the darkened background color
                float darkeningFactor = gradientColor.r; // Use red channel for darkening
                backgroundColor.rgb *= (1.0 - darkeningFactor); // Darken based on gradient value

                return backgroundColor; // Return the modified background color
            }
            ENDHLSL
        }
    }
    FallBack "Diffuse"
}
