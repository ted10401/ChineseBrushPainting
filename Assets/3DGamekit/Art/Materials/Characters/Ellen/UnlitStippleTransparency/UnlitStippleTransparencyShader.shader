Shader "Unlit/UnlitStippleTransparencyShader"
{
    Properties
    {
		_Alpha("Alpha", Range(0, 1)) = 1
        _MainTex ("Texture", 2D) = "white" {}
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

            struct a2v
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
				float4 screenPos : TEXCOORD0;
				float2 uv : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
			float _Alpha;

            v2f vert (a2v v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
				o.screenPos = ComputeScreenPos(o.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
				const float4x4 thresholdMatrix =
				{ 1,  9,  3, 11,
				  13,  5, 15,  7,
				   4, 12,  2, 10,
				  16,  8, 14,  6
				};

				float2 pixelPos = i.screenPos.xy / i.screenPos.w * _ScreenParams.xy;
				float threshold = thresholdMatrix[pixelPos.x % 4][pixelPos.y % 4] / 17;
				clip(_Alpha - threshold);

                fixed4 col = tex2D(_MainTex, i.uv);
                return col;
            }
            ENDCG
        }
    }
}
