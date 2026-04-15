import { getModel } from '../services/vertexai.mjs';
import { CHECK_PHOTO_PROMPT } from '../prompts/checkPhotoForProduct.mjs';

const model = getModel();

export const checkUserPhoto = async (input, mimeType = 'image/jpeg') => {
    let imageBuffer;

    if (typeof input === 'string' && input.startsWith('http')) {
        const response = await fetch(input);
        if (!response.ok) throw new Error(`Failed to fetch image from S3: ${response.statusText}`);
        const arrayBuffer = await response.arrayBuffer();
        imageBuffer = Buffer.from(arrayBuffer);
        mimeType = response.headers.get('content-type') || mimeType;
    } else {
        imageBuffer = input;
    }

    if (!imageBuffer) throw new Error("No image data available");

    const promptParts = [
        { text: CHECK_PHOTO_PROMPT },
        {
            inlineData: {
                data: imageBuffer.toString('base64'),
                mimeType: mimeType
            }
        }
    ];

    const result = await model.generateContent({
        contents: [{ role: 'user', parts: promptParts }]
    });

    const responseText = result.response.candidates[0].content.parts[0].text;
    const parsed = JSON.parse(responseText);

    return {
        ...parsed,
        canBeSaved: Boolean(parsed?.isValid)
    };
};
