import { GoogleGenAI } from "@google/genai";

const ai = new GoogleGenAI({ apiKey: process.env.API_KEY });

export async function generateLevelName(
  gridSize: { rows: number; cols: number },
  blockTypes: string[]
): Promise<string> {
  const uniqueBlockTypes = [...new Set(blockTypes)];
  const prompt = `Generate a short, creative, and fun name for a puzzle game level.
- The grid is ${gridSize.rows}x${gridSize.cols}.
- It uses these block shapes: ${uniqueBlockTypes.join(", ")}.
- The name MUST be in Turkish.
- The name must be 1 to 3 words.
- Respond with ONLY the name. Do not use quotes or any other markdown.

Example names: Kristal Labirent, Gökyüzü Kalesi, Zümrüt Bahçesi.`;

  try {
    const response = await ai.models.generateContent({
      model: "gemini-2.5-flash",
      contents: prompt,
      config: {
        temperature: 0.9,
        maxOutputTokens: 20,
        thinkingConfig: { thinkingBudget: 0 }
      },
    });
    
    const text = response.text.trim().replace(/["']/g, "");
    
    if (text && text.length > 2 && text.length < 40) {
      return text;
    }
    return 'Gizemli Arena';
  } catch (error) {
    console.error("Failed to generate level name with Gemini:", error);
    return 'Gizemli Arena';
  }
}