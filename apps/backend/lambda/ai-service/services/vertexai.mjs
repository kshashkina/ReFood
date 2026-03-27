import { VertexAI } from '@google-cloud/vertexai';

const gcpKey = JSON.parse(process.env.GCP_SERVICE_ACCOUNT_KEY);

const vertexAI = new VertexAI({
    project: gcpKey.project_id,
    location: 'us-central1',
    googleAuthOptions: { credentials: gcpKey }
});

export const getModel = (config = {}) => {
    return vertexAI.getGenerativeModel({
        model: 'gemini-2.5-flash-lite',
        generationConfig: { response_mime_type: 'application/json', ...config }
    });
};
