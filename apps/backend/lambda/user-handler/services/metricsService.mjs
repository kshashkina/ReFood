import { LambdaClient, InvokeCommand } from "@aws-sdk/client-lambda";

const lambda = new LambdaClient({});
const METRICS_LAMBDA = process.env.METRICS_SERVICE_FUNCTION_NAME || "MetricsService";

export const invokeMetrics = async (action, userId) => {
    if (!userId) return;

    const command = new InvokeCommand({
        FunctionName: METRICS_LAMBDA,
        InvocationType: "Event",
        Payload: Buffer.from(JSON.stringify({ action, userId }))
    });

    await lambda.send(command);
};

export const invokeMetricsSync = async (action, userId) => {
    if (!userId) return null;

    const command = new InvokeCommand({
        FunctionName: METRICS_LAMBDA,
        InvocationType: "RequestResponse",
        Payload: Buffer.from(JSON.stringify({ action, userId }))
    });

    const result = await lambda.send(command);
    return JSON.parse(Buffer.from(result.Payload).toString());
};
