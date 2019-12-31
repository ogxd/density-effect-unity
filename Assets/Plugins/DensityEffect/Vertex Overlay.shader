Shader "Ogxd/Vertices"
{
	Properties
	{
		_Tint("Tint", Color) = (0.0, 0.0, 0.0, 1)
		_PointSize("Point Size", Float) = 0.0025
	}
   SubShader
   {
      Tags { "RenderType" = "Opaque" }
      Cull Off
		ZTest Always

      Pass
      {
         CGPROGRAM

         #pragma vertex Vertex
         #pragma geometry Geometry
         #pragma fragment Fragment
           
         #include "UnityCG.cginc"

         half4 _Tint;
         half _PointSize;
         float4x4 _Transform;

         struct Attributes
         {
               float4 position : POSITION;
         };

         struct Varyings
         {
               float4 position : SV_POSITION;
               half3 color : COLOR;
			   float3 worldSpacePos : FLOAT3;
         };

         Varyings Vertex(Attributes input)
         {
               float4 pos = input.position;
               half3 col = _Tint.rgb;
               Varyings o;
               o.position = UnityObjectToClipPos(pos);

			   o.worldSpacePos = mul(unity_ObjectToWorld, input.position);

               //float viewDepth = -UnityObjectToViewPos(pos).z;
               //float pixelToWorldScale = viewDepth * unity_CameraProjection._m00 * _ScreenParams.x;

               //o.position.z *= pixelToWorldScale;

               o.color = col;
               return o;
         }

         [maxvertexcount(36)]
         void Geometry(point Varyings input[1], inout TriangleStream<Varyings> outStream)
         {
               float4 origin = input[0].position;
               float2 extent = abs(UNITY_MATRIX_P._11_22 * _PointSize);

               // Copy the basic information.
               Varyings o = input[0];
			   extent *= o.position.w;

               // Determine the number of slices based on the radius of the
               // point on the screen.
               float radius = extent.y / origin.w * _ScreenParams.y;
               uint slices = min((radius + 1) / 5, 4) + 2;

               // Slightly enlarge quad points to compensate area reduction.
               // Hopefully this line would be complied without branch.
               if (slices == 2) extent *= 1.2;

			   o.worldSpacePos = input[0].worldSpacePos;
               // Top vertex
               o.position.y = origin.y + extent.y;
               o.position.xzw = origin.xzw;
               outStream.Append(o);

               UNITY_LOOP for (uint i = 1; i < slices; i++)
               {
                  float sn, cs;
                  sincos(UNITY_PI / slices * i, sn, cs);

				  o.worldSpacePos = input[0].worldSpacePos;
                  // Right side vertex
                  o.position.xy = origin.xy + extent * float2(sn, cs);
                  outStream.Append(o);

				  o.worldSpacePos = input[0].worldSpacePos;
                  // Left side vertex
                  o.position.x = origin.x - extent.x * sn;
                  outStream.Append(o);
               }

			   o.worldSpacePos = input[0].worldSpacePos;
               // Bottom vertex
               o.position.x = origin.x;
               o.position.y = origin.y - extent.y;
               outStream.Append(o);

               outStream.RestartStrip();
         }

         half4 Fragment(Varyings input) : SV_Target
         {
               half4 c = half4(input.color, _Tint.a);

               return c;
         }

         ENDCG
      }
   }
}