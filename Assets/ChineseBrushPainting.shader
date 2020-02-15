Shader "Unlit/ChineseBrushPainting"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_Thred("Edge Thred" , Range(0.01,1)) = 0.25
		_Range("Edge Range" , Range(1,10)) = 1
		_Pow("Edge Intensity",Range(0,10)) = 1
		_BrushTex("Brush Texture", 2D) = "white" {}

		[Enum(Opacity,1,Darken,2,Lighten,3,Multiply,4,Screen,5,Overlay,6,SoftLight,7)]
		_BlendType("Blend Type", Int) = 1
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

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv_main : TEXCOORD0;
				float2 uv_brush : TEXCOORD1;
                float4 vertex : SV_POSITION;
				float3 worldPos : TEXCOORD2;
				float vdotn : TEXCOORD3;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
			float _Thred;
			float _Range;
			float _Pow;
			sampler2D _BrushTex;
			float4 _BrushTex_ST;
			float _BlendType;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv_main = TRANSFORM_TEX(v.uv, _MainTex);
				o.uv_brush = TRANSFORM_TEX(v.uv, _BrushTex);
				float3 viewDir = mul(unity_WorldToObject, float4(_WorldSpaceCameraPos.xyz, 1)).xyz - v.vertex;
				o.vdotn = dot(normalize(viewDir), v.normal);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
				fixed4 mainTex = tex2D(_MainTex, i.uv_main);

				fixed4 brushTex = tex2D(_BrushTex, i.uv_brush);

				fixed texGrey = (mainTex.r + mainTex.g + mainTex.b)*0.33;
				texGrey = pow(texGrey, 0.3);
				texGrey *= 1 - cos(texGrey * 3.14);
				fixed brushGrey = (brushTex.r + brushTex.g + brushTex.b)*0.33;

				fixed blend;
				if (_BlendType == 1)
					blend = texGrey * 0.5 + brushGrey * 0.5;
				else if (_BlendType == 2)
					blend = texGrey < brushGrey ? texGrey : brushGrey;
				else if (_BlendType == 3)
					blend = texGrey > brushGrey ? texGrey : brushGrey;
				else if (_BlendType == 4)
					blend = texGrey * brushGrey;
				else if (_BlendType == 5)
					blend = 1 - (1 - texGrey)*(1 - brushGrey);
				else if (_BlendType == 6)
					blend = brushGrey > 0.5 ? 1 - 2 * (1 - texGrey)*(1 - brushGrey) : 2 * texGrey * brushGrey;
				else if (_BlendType == 7)
					blend = texGrey > 0.5 ? (2 * texGrey - 1)*(brushGrey - brushGrey * brushGrey) + brushGrey : (2 * texGrey - 1)*(sqrt(brushGrey) - brushGrey) + brushGrey;
				fixed4 col = fixed4(blend, blend, blend, 1);

				fixed edge = pow(i.vdotn, 1) / _Range;
				edge = edge > _Thred ? 1 : edge;
				edge = pow(edge, _Pow);
				fixed4 edgeColor = fixed4(edge, edge, edge, edge);

				col = edgeColor * (1 - edgeColor.a) + col * (edgeColor.a);

                return col;
            }
            ENDCG
        }
    }
}
