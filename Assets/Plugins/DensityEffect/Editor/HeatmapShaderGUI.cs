using UnityEngine;
using UnityEditor;

public class HeatmapShaderGUI : ShaderGUI {

    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties) {

        Material targetMat = materialEditor.target as Material;

        EditorGUI.BeginChangeCheck();

        float min = targetMat.GetFloat("_MinHue");
        float max = targetMat.GetFloat("_MaxHue");
        float cutoff = targetMat.GetFloat("_Cutoff");
        int steps = targetMat.GetInt("_Steps");

        EditorGUILayout.MinMaxSlider("Color Range", ref min, ref max, 0, 1f);
        cutoff = EditorGUILayout.Slider("Cutoff Low", cutoff, 0, max - min);
        steps = EditorGUILayout.IntField("Steps", steps);

        if (EditorGUI.EndChangeCheck()) {
            targetMat.SetFloat("_MinHue", min);
            targetMat.SetFloat("_MaxHue", max);
            targetMat.SetFloat("_Cutoff", cutoff);
            targetMat.SetInt("_Steps", steps);
        }
    }
}