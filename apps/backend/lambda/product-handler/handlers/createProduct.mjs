import { saveProductToDB } from '../services/databases/productDatabase.mjs';
import { normalizeBarcode } from '../helpers/validation/barcode.mjs';
import { validateProductInput } from '../helpers/validation/validator.mjs';
import { cleanProductData } from '../helpers/formatters/cleanProductData.mjs';
import { response } from '../helpers/response.mjs';
import { translateProduct, checkProduct } from '../services/aiService.mjs';
import { finalizeImage } from '../services/s3Service.mjs';
import { findUserIdByAnyMethod } from '../services/databases/usersDatabase.mjs';
import { invokeMetrics } from '../services/metricsService.mjs';
import { getRequestIdentity } from '../helpers/auth/identity.mjs';

export async function createProduct(event) {
    let body;
    try {
        body = JSON.parse(event.body || '{}');
    } catch {
        return response(400, { error: "Invalid JSON body" });
    }

    const validation = validateProductInput(body);
    if (!validation.valid) {
        return response(400, {
            error: "Validation failed",
            details: validation.errors
        });
    }

    const barcode = normalizeBarcode(body.barcode);
    if (!barcode) {
        return response(400, {
            error: "Invalid barcode format"
        });
    }

    const productData = cleanProductData(body);

    try {
        const aiCheck = await checkProduct(productData);

        if (!aiCheck.canBeSaved) {
            return response(400, {
                error: "AI Validation failed",
                details: aiCheck.errors,
                isSafetyViolation: aiCheck.isSafetyViolation
            });
        }

        const translatedParts = await translateProduct(productData);

        const translatedKeys = new Set(Object.keys(translatedParts));
        const fieldsToDrop = new Set([
            'ingredients_text',
            'ingredients_analysis_tags',
            'categories_tags',
            'allergens_tags'
        ]);

        const baseProductData = Object.fromEntries(
            Object.entries(productData).filter(([key]) => !translatedKeys.has(key) && !fieldsToDrop.has(key))
        );

        let imageUrl = null;
        const { imageId, s3Key } = body;

        if (imageId && s3Key) {
            const imageResult = await finalizeImage({ s3Key, imageId, barcode });

            if (!imageResult.success) {
                return response(400, {
                    error: "Image finalization failed",
                    code: imageResult.code,
                    details: imageResult.message,
                });
            }

            imageUrl = imageResult.publicUrl;
        }

        const now = Date.now();
        const finalProduct = {
            ...baseProductData,
            ...translatedParts,
            barcode,
            checkAI: true,
            checkHuman: false,
            image_url: imageUrl || null,
            source: "user",
            updated_at: now
        };

        await saveProductToDB(finalProduct);
        console.log(`Added new product from client: ${barcode}`);

        const identity = getRequestIdentity(event);
        const userId = await findUserIdByAnyMethod(identity);
        invokeMetrics('increment_product', userId);

        return response(201, {
            message: "Product verified and created successfully"
        });
    } catch (error) {
        console.error("Workflow Error:", error);
        return response(500, {
            error: "Failed to process product with AI services"
        });
    }
}
