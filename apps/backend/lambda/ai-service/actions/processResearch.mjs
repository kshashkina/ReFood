import { getModel } from '../services/vertexai.mjs';
import { PROCESS_RESEARCH_PROMPT } from '../prompts/processResearch.mjs';

const model = getModel();

export const processResearch = async (data) => {
    const fullPrompt = `${PROCESS_RESEARCH_PROMPT}\n\nInput JSON:\n${JSON.stringify(data)}`;
    const result = await model.generateContent(fullPrompt);
    const responseText = result.response.candidates[0].content.parts[0].text;

    return JSON.parse(responseText);
};