Shader "Ogxd/Density"
{
	Properties
	{
		_Scale("Scale", Float) = 45.0
		_Nuance("Nuance", Range(0.0, 1.0)) = 1.0
		_Transparency("Transparency", Range(0.0, 1.0)) = 0.0
	}

	SubShader
	{
		Tags { "RenderType" = "Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM

			//#pragma target 3.5
			//#pragma require 2darray
			#pragma vertex vert
			#pragma fragment frag
			#pragma geometry geom
			#include "UnityCG.cginc"

			float _Scale;
			float _Nuance;
			float4 _Plane;
			float areas[256];// [20];

			struct v2g
			{
				float4 vertex : POSITION;
				float3 worldPos : TEXCOORD1;
				//uint id : SV_VertexID;
			};

			struct g2f
			{
				float4 pos : SV_POSITION;
				fixed4 col : COLOR;
				float3 normal : NORMAL;
				float3 worldSpacePos : TEXCOORD1;
			};

			v2g vert(appdata_base v)
			{
				v2g o;
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				o.vertex = UnityObjectToClipPos(v.vertex);

				return o;
			}


			float3 hsv_to_rgb(float3 HSV)
			{
				float3 RGB = HSV.z;

				float var_h = HSV.x * 6;
				float var_i = floor(var_h);   // Or ... var_i = floor( var_h )
				float var_1 = HSV.z * (1.0 - HSV.y);
				float var_2 = HSV.z * (1.0 - HSV.y * (var_h - var_i));
				float var_3 = HSV.z * (1.0 - HSV.y * (1 - (var_h - var_i)));
				if (var_i == 0) { RGB = float3(HSV.z, var_3, var_1); }
				else if (var_i == 1) { RGB = float3(var_2, HSV.z, var_1); }
				else if (var_i == 2) { RGB = float3(var_1, HSV.z, var_3); }
				else if (var_i == 3) { RGB = float3(var_1, var_2, HSV.z); }
				else if (var_i == 4) { RGB = float3(var_3, var_1, HSV.z); }
				else { RGB = float3(HSV.z, var_1, var_2); }

				return (RGB);
			}

			[maxvertexcount(3)]
			void geom(triangle v2g IN[3], inout TriangleStream<g2f> tristream)
			{
				g2f o;

				float3 AB = IN[1].worldPos.xyz - IN[0].worldPos.xyz;
				float3 AC = IN[2].worldPos.xyz - IN[0].worldPos.xyz;
				float3 BC = IN[2].worldPos.xyz - IN[1].worldPos.xyz;
				float3 normal = normalize(cross(AB, AC));

				float angle = acos(dot(AB, AC) / (length(AC) * length(AB)));
				float area = 0.5 * length(AC) * length(AB) * sin(angle);
				float perimeter = length(AC) + length(AB) + length(BC);

				for (int i = 0; i < 3; i++)
				{
						o.pos = IN[i].vertex;
						o.normal = normal;
						float c = _Scale * (0.01 + sqrt(area));
						float3 rgb = hsv_to_rgb(float3(clamp(c, 0, 0.65), 1.0, 1.0));
						o.col = fixed4(rgb.r, rgb.g, rgb.b, 1);
						o.worldSpacePos = IN[i].worldPos;
						//o.col += area;
						tristream.Append(o);
				}
			}

			float _Transparency;

			fixed4 frag(g2f input, fixed facing : VFACE) : SV_Target
			{
				float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
				float lightDot = clamp(dot(input.normal, lightDir), -1, 1);
				lightDot = exp(-pow(2 * (1 - lightDot), 1.3));
				float4 albedo = input.col;
				float3 rgb = albedo.rgb; // *lightDot;

				return float4(rgb, _Transparency);
			}
			ENDCG
		}
	}

	FallBack "Diffuse"
}