import { getModel } from '../services/vertexai.mjs';
import { TRANSLATE_ANALYZE_PROMPT } from '../prompts/translateAnalyze.mjs';

const model = getModel();

export const translateProduct = async (data) => {
    const fullPrompt = `${TRANSLATE_ANALYZE_PROMPT}\n\nInput JSON:\n${JSON.stringify(data)}`;
    const result = await model.generateContent(fullPrompt);
    const responseText = result.response.candidates[0].content.parts[0].text;
    
    return JSON.parse(responseText);
};
