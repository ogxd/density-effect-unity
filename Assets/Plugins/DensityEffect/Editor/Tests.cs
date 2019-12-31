using UnityEditor;
using UnityEngine;

public static class Tests
{
    [MenuItem("Tests/Set Vertex Colors")]
    private static void SetVertexColors()
    {
        Mesh mesh = Selection.activeGameObject.GetComponent<MeshFilter>().sharedMesh;
        int[] triangles = mesh.triangles;
        Vector3[] vertices = mesh.vertices;
        float[] areas = new float[vertices.Length];
        int[] areasC = new int[vertices.Length];
        Color[] colors = new Color[vertices.Length];

        float min = float.MaxValue;
        float max = float.MinValue;

        for (int t = 0; t < triangles.Length; t+=3) {

            Vector3 AB = vertices[triangles[t + 1]] - vertices[triangles[t]];
            Vector3 AC = vertices[triangles[t + 2]] - vertices[triangles[t]];
            Vector3 BC = vertices[triangles[t + 2]] - vertices[triangles[t + 1]];
            Vector3 normal = Vector3.Cross(AB, AC).normalized;

            float angle = Mathf.Acos(Vector3.Dot(AB, AC) / (AC.magnitude * AB.magnitude));
            float area = 0.5f * AC.magnitude * AB.magnitude * Mathf.Sin(angle);
            float perimeter = AC.magnitude + AB.magnitude + BC.magnitude;

            areas[triangles[t]] += area;
            areas[triangles[t + 1]] += area;
            areas[triangles[t + 2]] += area;

            areasC[triangles[t]] ++;
            areasC[triangles[t + 1]] ++;
            areasC[triangles[t + 2]] ++;
        }

        for (int v = 0; v < vertices.Length; v++) {
            areas[v] = areas[v] / areasC[v];
            if (areas[v] < min)
                min = areas[v];
            if (areas[v] > max)
                max = areas[v];
        }

        for (int v = 0; v < vertices.Length; v++) {
            float hue = Remap(areas[v], min, max, 0f, 1f);
            hue = Mathf.Pow(hue, 0.2f);
            hue = Remap(hue, 0f, 1f, 0f, 0.7f);
            colors[v] = Color.HSVToRGB(hue, 1f, 1f);
        }

        mesh.colors = colors;
    }

    private static float Remap(float value, float low1, float high1, float low2, float high2) {
        return low2 + (value - low1) * (high2 - low2) / (high1 - low1);
    }
}