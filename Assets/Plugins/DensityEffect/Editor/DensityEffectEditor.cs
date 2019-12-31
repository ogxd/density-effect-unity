using UnityEditor;

namespace Ogxd {

    [CustomEditor(typeof(DensityEffect))]
    public class DensityEffectEditor : Editor {

        private DensityEffect effect => target as DensityEffect;

        public override void OnInspectorGUI() {

            EditorGUI.BeginChangeCheck();

            EditorGUILayout.MinMaxSlider("Color Range", ref effect.min, ref effect.max, 0, 1f);
            effect.cutoff = EditorGUILayout.Slider("Cutoff Low", effect.cutoff, 0, effect.max - effect.min);
            effect.steps = EditorGUILayout.IntField("Steps", effect.steps);
            effect.pointSize = EditorGUILayout.FloatField("Point Size", effect.pointSize);
            effect.contribution = EditorGUILayout.Slider("Contribution", effect.contribution, 0.01f, 0.5f);

            if (EditorGUI.EndChangeCheck()) {
                effect.ApplyProperties();
            }

            EditorGUI.BeginChangeCheck();

            effect.iterations = EditorGUILayout.IntSlider("Iterations", effect.iterations, 0, 5);
            effect.interpolation = EditorGUILayout.Slider("Interpolation", effect.interpolation, 0f, 1f);
            effect.downsample = EditorGUILayout.IntSlider("Downsample", effect.downsample, 0, 4);

            if (EditorGUI.EndChangeCheck()) {
                effect.RefreshCommandBuffer();
            }
        }
    }
}