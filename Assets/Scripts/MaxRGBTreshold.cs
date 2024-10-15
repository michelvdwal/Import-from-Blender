using UnityEngine;

[RequireComponent(typeof(Renderer))]
public class MaxRGBThreshold : MonoBehaviour
{
    public Texture2D texture;  // Your grayscale texture
    private Material material;

    void Start()
    {
        material = GetComponent<Renderer>().material;
        float maxRGB = FindMaxRGBValue(texture);
        material.SetFloat("_MaxRGBValue", maxRGB);  // Pass max value to the shader
    }

    // Function to find the max RGB value in the texture
    float FindMaxRGBValue(Texture2D tex)
    {
        float maxRGB = 0f;
        Color[] pixels = tex.GetPixels();

        foreach (Color pixel in pixels)
        {
            float maxComponent = Mathf.Max(pixel.r, pixel.g, pixel.b);  // Get the maximum of the RGB values
            if (maxComponent > maxRGB)
                maxRGB = maxComponent;
        }

        return maxRGB;
    }
}
