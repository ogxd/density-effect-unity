using UnityEngine;
using UnityEngine.Rendering;

namespace Ogxd
{
    [DisallowMultipleComponent]
    [RequireComponent(typeof(Camera))]
    public class DensityEffect : MonoBehaviour
    {
        public float min = 0;
        public float max = 0.7f;
        public float cutoff = 0f;
        public int steps = 10;
        public float pointSize = 0.001f;
        public float contribution = 0.05f;

        public int iterations = 1;
        public int kernel = 4;
        public float interpolation = 1;
        public int downsample = 1;

        private Material densityMaterial;
        public Material DensityMaterial => densityMaterial ?? (densityMaterial = new Material(Shader.Find("Ogxd/Density")));

        private Material heatmapMaterial;
        public Material HeatmapMaterial => heatmapMaterial ?? (heatmapMaterial = new Material(Shader.Find("Ogxd/Heatmap")));

        private Material blurMaterial;
        public Material BlurMaterial => blurMaterial ?? (blurMaterial = new Material(Shader.Find("Ogxd/Blur")));

        private Camera sourceCamera;
        private Camera SourceCamera => sourceCamera ?? (sourceCamera = GetComponent<Camera>());

        private RenderTexture effectTexture;
        private RenderTexture swapTexture;
        private CommandBuffer effectCommands;

        public void RefreshCommandBuffer()
        {
            ApplyProperties();

            effectTexture = RenderTexture.GetTemporary(SourceCamera.pixelWidth, SourceCamera.pixelHeight, 0, UnityEngine.Experimental.Rendering.GraphicsFormat.B8G8R8A8_UNorm);
            int swapWidth = SourceCamera.pixelWidth >> downsample;
            int swapHeight = SourceCamera.pixelHeight >> downsample;
            swapTexture = RenderTexture.GetTemporary(swapWidth, swapHeight, 0, UnityEngine.Experimental.Rendering.GraphicsFormat.B8G8R8A8_UNorm);

            if (effectCommands == null) {
                effectCommands = new CommandBuffer();
                effectCommands.name = "Density Effect";
                sourceCamera.AddCommandBuffer(CameraEvent.AfterImageEffects, effectCommands);
            }

            effectCommands.Clear();
            effectCommands.SetRenderTarget(effectTexture);
            effectCommands.ClearRenderTarget(true, true, Color.black);

            Renderer[] renderers = FindObjectsOfType<Renderer>();
            for (int i = 0; i < renderers.Length; i++) {
                effectCommands.DrawRenderer(renderers[i], DensityMaterial);
            }

            for (int i = 0; i < iterations; i++) {
                // helps to achieve a larger blur
                float radius = (float)i * interpolation + interpolation;
                BlurMaterial.SetFloat("_Radius", radius);

                effectCommands.Blit(effectTexture, swapTexture, blurMaterial, 1 + kernel);
                effectTexture.DiscardContents();

                effectCommands.Blit(swapTexture, effectTexture, blurMaterial, 2 + kernel);
                swapTexture.DiscardContents();
            }

            effectCommands.Blit(effectTexture, sourceCamera.targetTexture, HeatmapMaterial);
        }

        public void ApplyProperties() {
            HeatmapMaterial.SetFloat("_MinHue", min);
            HeatmapMaterial.SetFloat("_MaxHue", max);
            HeatmapMaterial.SetFloat("_Cutoff", cutoff);
            HeatmapMaterial.SetInt("_Steps", steps);
            DensityMaterial.SetFloat("_Contribution", contribution);
            DensityMaterial.SetFloat("_PointSize", pointSize);
        }

        public void OnPreRender()
        {
            // Updates render texture if viewport size changed
            if (effectTexture == null || effectTexture.width != sourceCamera.pixelWidth || effectTexture.height != sourceCamera.pixelHeight) {
                RefreshCommandBuffer();
            }
        }

        private void Start()
        {
            RefreshCommandBuffer();
        }

        private void OnDisable()
        {
            RefreshCommandBuffer();
        }

        void OnDestroy()
        {
            if (effectCommands == null)
                return;

            sourceCamera.RemoveCommandBuffer(CameraEvent.AfterImageEffects, effectCommands);
            effectCommands.Clear();
        }
    }
}