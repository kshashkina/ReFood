import { LambdaClient, InvokeCommand } from "@aws-sdk/client-lambda";

const lambdaClient = new LambdaClient({});
const AI_FUNCTION_NAME = process.env.AI_SERVICE_FUNCTION_NAME || "AIService";

export async function processNewsWithAI(researches) {
    const payload = {
        action: "process_research",
        data: researches.map(r => ({
            id: r.id,
            title: r.title,
            abstract: r.abstract
        }))
    };

    const command = new InvokeCommand({
        FunctionName: AI_FUNCTION_NAME,
        InvocationType: "RequestResponse",
        Payload: JSON.stringify(payload),
    });

    const result = await lambdaClient.send(command);
    const responsePayload = JSON.parse(Buffer.from(result.Payload).toString());

    if (result.FunctionError) {
        console.error("AIService error:", responsePayload);
        throw new Error(`AIService invocation failed: ${result.FunctionError}`);
    }

    return responsePayload;
}
