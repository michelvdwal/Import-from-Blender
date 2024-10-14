Shader "Custom/BlackWhiteMultiplyWithBlurredEdges"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
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
                float3 localPos : TEXCOORD1; // To calculate distance
            };

            sampler2D _MainTex;
            float _EdgeDistance;
            float _EdgeTransparency;
            float _Smoothness;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;

                // Store the local position for distance calculation
                o.localPos = v.vertex.xyz;

                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                // Calculate the distance from the current fragment to the center of the mesh (local space)
                float distanceToCenter = length(i.localPos);

                // Calculate the edge factor using smoothstep to create a soft transition
                float edgeFactor = smoothstep(_EdgeDistance - _Smoothness, _EdgeDistance, distanceToCenter);

                // Sample the texture and extract the luminance (black & white only)
                float4 texColor = tex2D(_MainTex, i.uv);
                float luminance = texColor.r; // Assuming the texture is black and white

                // Determine the final alpha
                float alpha = 0.0;

                // Apply rules for alpha based on luminance
                if (luminance < 0.5) // Black (or darker)
                {
                    alpha = 1.0; // Fully opaque for black pixels
                }
                else if (luminance >= 0.5 && luminance < 1.0) // Gray
                {
                    alpha = luminance; // Set alpha based on luminance for gray pixels
                }
                // White pixels will remain transparent (alpha = 0.0)

                // If the fragment is within the edge distance, use smooth transition
                if (distanceToCenter <= _EdgeDistance)
                {
                    // Use edge factor to control the transparency smoothly at the edges
                    alpha *= (1.0 - edgeFactor); // Fade out based on edge factor
                }
                else
                {
                    alpha = 0.0; // Fully transparent outside edge distance
                }

                // Calculate final color
                // Use the luminance value to set the RGB components
                float3 baseColor = float3(luminance, luminance, luminance); // Black to white base color
                float4 finalColor = float4(baseColor, alpha); // Combine base color with calculated alpha

                return finalColor; // Return the final color
            }
            ENDCG
        }
    }
    FallBack "Unlit/Transparent"
}
