import { getModel } from '../services/vertexai.mjs';
import { CHECK_PRODUCT_PROMPT } from '../prompts/checkProduct.mjs';
import { isPromptInjection } from '../tools/guardrails.mjs';

const model = getModel();

const extractTextValues = (value, results = []) => {
    if (typeof value === 'string') {
        const trimmed = value.trim();
        if (trimmed) {
            results.push(trimmed);
        }
        return results;
    }

    if (Array.isArray(value)) {
        value.forEach((item) => extractTextValues(item, results));
        return results;
    }

    if (value && typeof value === 'object') {
        Object.values(value).forEach((item) => extractTextValues(item, results));
    }

    return results;
};

export const checkUserProduct = async (data = {}) => {
    const textValues = extractTextValues(data);
    const hasPromptInjection = textValues.some((text) => isPromptInjection(text));

    if (hasPromptInjection) {
        return {
            isValid: false,
            isSafetyViolation: true,
            canBeSaved: false,
            errors: ['Potential prompt injection was detected in the submitted fields.']
        };
    }

    const fullPrompt = `${CHECK_PRODUCT_PROMPT}\n\nInput JSON:\n${JSON.stringify(data)}`;

    const promptParts = [{ text: fullPrompt }];

    const result = await model.generateContent({
        contents: [{ role: 'user', parts: promptParts }]
    });
    const responseText = result.response.candidates[0].content.parts[0].text;
    const parsed = JSON.parse(responseText);;

    return {
        ...parsed,
        canBeSaved: Boolean(parsed?.isValid) && !Boolean(parsed?.isSafetyViolation)
    };
};
