import { getModel } from '../services/vertexai.mjs';
import { COMPARE_PRODUCTS_PROMPT } from '../prompts/compareProducts.mjs';

const model = getModel();

export const compareTwoProducts = async (productA, productB) => {
    const inputData = {
        product_a: productA,
        product_b: productB
    };

    const fullPrompt = `${COMPARE_PRODUCTS_PROMPT}\n\nInput JSON:\n${JSON.stringify(inputData)}`;
    const result = await model.generateContent(fullPrompt);
    const responseText = result.response.candidates[0].content.parts[0].text;
    
    return JSON.parse(responseText);
};
