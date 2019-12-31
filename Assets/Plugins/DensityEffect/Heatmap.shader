Shader "Ogxd/Heatmap"
{
	Properties
	{
		[HideInInspector]
		_MainTex("", 2D) = "white" {}
		_MinHue("Min Hue", Float) = 0.3
		_MaxHue("Max Hue", Float) = 1.0
		_Cutoff("Cutoff", Float) = 0.1
		_Steps("Steps", Int) = 10
	}

	SubShader
	{
		Tags { "RenderType" = "Opaque" }

		Blend SrcAlpha OneMinusSrcAlpha

		Pass
		{
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile _ UNITY_SINGLE_PASS_STEREO STEREO_INSTANCING_ON STEREO_MULTIVIEW_ON
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				float2 uv : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct v2f
			{
				float4 color : COLOR;
				float4 pos : SV_POSITION;
				float3 worldSpacePos : FLOAT3;
				float2 uv : TEXCOORD0;
				UNITY_VERTEX_OUTPUT_STEREO
			};

			v2f vert(appdata v)
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				o.pos = UnityObjectToClipPos(v.vertex);
				o.color = v.color;
				o.worldSpacePos = mul(unity_ObjectToWorld, v.vertex);
				o.uv = v.uv;
				return o;
			}

			sampler2D _MainTex;
			float4 _MainTex_ST;
			int _Steps;
			float _MinHue;
			float _MaxHue;
			float _Cutoff;

			float3 HUEtoRGB(in float H)
			{
				float R = abs(H * 6 - 3) - 1;
				float G = 2 - abs(H * 6 - 2);
				float B = 2 - abs(H * 6 - 4);
				return saturate(float3(R, G, B));
			}

			float remap(float value, float low1, float high1, float low2, float high2) {
				return low2 + (value - low1) * (high2 - low2) / (high1 - low1);
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed4 color = tex2D(_MainTex, i.uv);
				color = saturate(ceil(color * _Steps) / _Steps);
				float hue = remap(color.r, 0, 1, 1 - _MinHue + _Cutoff, 1 - _MaxHue);
				hue = clamp(hue, 1 - _MaxHue, 1 - _MinHue);
				color = fixed4(HUEtoRGB(hue), 1.0);
				return color;
			}

			ENDCG
		}
	}

	CustomEditor "HeatmapShaderGUI"
}