using UnityEngine;

namespace Ogxd
{
    [RequireComponent(typeof(Camera))]
    [ExecuteInEditMode]
	public class DensityEffect : MonoBehaviour
	{
		public BlurKernelSize kernelSize = BlurKernelSize.Small;

		[Range(0f, 1f)]
		public float interpolation = 1f;

		[Range(0, 4)]
		public int downsample = 1;

		[Range(1, 8)]
		public int iterations = 1;

		public bool gammaCorrection = true;

		public Material blurMaterial;

        public Material heatMapMaterial;

		protected void Blur (RenderTexture source, RenderTexture destination)
		{
			if (gammaCorrection)
			{
				Shader.EnableKeyword("GAMMA_CORRECTION");
			}
			else
			{
				Shader.DisableKeyword("GAMMA_CORRECTION");
			}

			int kernel = 0;

			switch (kernelSize)
			{
			case BlurKernelSize.Small:
				kernel = 0;
				break;
			case BlurKernelSize.Medium:
				kernel = 2;
				break;
			case BlurKernelSize.Big:
				kernel = 4;
				break;
			}

			var rt2 = RenderTexture.GetTemporary(source.width, source.height, 0, source.format);

			for (int i = 0; i < iterations; i++)
			{
				// helps to achieve a larger blur
				float radius = (float)i * interpolation + interpolation;
				blurMaterial.SetFloat("_Radius", radius);

				Graphics.Blit(source, rt2, blurMaterial, 1 + kernel);
				source.DiscardContents();

				Graphics.Blit(rt2, source, blurMaterial, 2 + kernel);
				rt2.DiscardContents();
			}

            Graphics.Blit(rt2, destination, heatMapMaterial, 0);

            RenderTexture.ReleaseTemporary(rt2);
		}

        void OnRenderImage(RenderTexture source, RenderTexture destination) {

            if (blurMaterial == null)
                return;

            int tw = source.width >> downsample;
            int th = source.height >> downsample;

            var rt = RenderTexture.GetTemporary(tw, th, 0, source.format);

            Graphics.Blit(source, rt);

            Blur(rt, destination);

            RenderTexture.ReleaseTemporary(rt);
        }
    }
	
	public enum BlurKernelSize
	{
		Small,
		Medium,
		Big
	}
}