import { LambdaClient, InvokeCommand } from "@aws-sdk/client-lambda";

const lambdaClient = new LambdaClient({});
const S3_SERVICE_FUNCTION_NAME = process.env.S3_SERVICE_FUNCTION_NAME || "S3Service";

export async function finalizeImage({ s3Key, imageId, barcode }) {
    const payload = {
        action: "finalize_upload",
        s3Key,
        imageId,
        barcode,
    };

    const command = new InvokeCommand({
        FunctionName: S3_SERVICE_FUNCTION_NAME,
        InvocationType: "RequestResponse",
        Payload: JSON.stringify(payload),
    });

    const result = await lambdaClient.send(command);
    const responsePayload = JSON.parse(Buffer.from(result.Payload).toString());

    if (result.FunctionError) {
        console.error("S3Service invocation error:", responsePayload);
        throw new Error(`S3Service invocation failed: ${result.FunctionError}`);
    }

    return responsePayload;
}
