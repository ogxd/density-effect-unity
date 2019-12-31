Shader "Ogxd/Density"
{
	Properties
	{
		_PointSize("Point Size", Float) = 0.0025
		_Offset("Offset", Float) = 0.01
		_Contribution("Contribution", Float) = 0.05
		_Slices("Slices", Int) = 6
	}

	SubShader
	{
		Tags { "RenderType" = "Opaque" }

		//Pass {
		//	ZWrite On
		//	Cull Back
		//	Colormask 0
		//}

		Pass
		{
			Cull Off
			//Offset -1000, -1000
			ZTest Always
			ZWrite On
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM

			#pragma vertex Vertex
			#pragma geometry Geometry
			#pragma fragment Fragment
           
			#include "UnityCG.cginc"

			float _PointSize;
			float _Offset;
			float _Contribution;
			int _Slices;

			struct Attributes
			{
				float4 position : POSITION;
				float3 normal : NORMAL;
			};

			struct Varyings
			{
				float4 pos_clip : SV_POSITION;
				float3 pos_local : VECTOR3;
				float3 normal : NORMAL;
			};

			Varyings Vertex(Attributes input)
			{
				Varyings o;
				o.pos_clip = UnityObjectToClipPos(input.position);
				o.pos_local = input.position;
				o.normal = input.normal;
				return o;
			}

			[maxvertexcount(36)]
			void Geometry(point Varyings input[1], inout TriangleStream<Varyings> outStream)
			{
				float3 origin = input[0].pos_local;
				float3 normal = input[0].normal;
				float3 camdir = UNITY_MATRIX_IT_MV[2].y;
				float3 camtan = normalize(cross(camdir, normal));
				float3 tangent = normalize(cross(camtan, normal));

				Varyings o = input[0];

				float radius = _PointSize;// * _ScreenParams.y;

				float sn = 0;
				float cs = 1;

				UNITY_LOOP for (uint i = 0; i <= _Slices; i++)
				{
					// Previous
					o.pos_local = origin + normal * _Offset + radius * (camtan * sn + tangent * cs);
					o.pos_clip = UnityObjectToClipPos(o.pos_local);
					outStream.Append(o);

					sincos(2 * UNITY_PI / _Slices * i, sn, cs);

					// Next
					o.pos_local = origin + normal * _Offset + radius * (camtan * sn + tangent * cs);
					o.pos_clip = UnityObjectToClipPos(o.pos_local);
					outStream.Append(o);

					// Center
					o.pos_local = origin + normal * _Offset;
					o.pos_clip = UnityObjectToClipPos(o.pos_local);
					outStream.Append(o);
				}

				outStream.RestartStrip();
			}

			half4 Fragment(Varyings input) : SV_Target
			{
				return half4(1, 1, 1, _Contribution);;
			}

			ENDCG
		}
	}
}