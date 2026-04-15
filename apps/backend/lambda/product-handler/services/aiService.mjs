import { LambdaClient, InvokeCommand } from "@aws-sdk/client-lambda";

const lambdaClient = new LambdaClient({});
const AI_FUNCTION_NAME = process.env.AI_SERVICE_FUNCTION_NAME || "AIService";

export async function translateProduct(product) {
    const payload = {
        action: "translate_product",
        data: {
            ingredients_text: product.ingredients_text || product.ingredients_text_en || product.ingredients_text_ua ||  "",
            ingredients_analysis_tags: product.ingredients_analysis_tags || [],
            allergens_tags: product.allergens_tags || product.allergens_tags_en || product.allergens_tags_ua || [],
            categories_tags: product.categories_tags || product.categories_tags_en || product.categories_tags_ua || [],
            packaging: product.packaging || product.packaging_en || product.packaging_ua || [],
            traces_tags: product.traces_tags || [],
            nutriments: product.nutriments || {}
        },
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

export async function checkProduct(product) {
    const payload = {
        action: "check_product",
        data: product
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

export async function compareProducts(productA, productB) {
    const payload = {
        action: "compare_products",
        data: {
            productA,
            productB
        }
    };

    const command = new InvokeCommand({
        FunctionName: AI_FUNCTION_NAME,
        InvocationType: "RequestResponse",
        Payload: JSON.stringify(payload),
    });

    const result = await lambdaClient.send(command);
    const responsePayload = JSON.parse(Buffer.from(result.Payload).toString());
    
    if (result.FunctionError) {
        console.error("AIService compare error:", responsePayload);
        throw new Error(`AIService invocation failed: ${result.FunctionError}`);
    }

    return responsePayload;
}
