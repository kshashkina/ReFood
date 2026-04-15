import { normalizeBarcode } from '../helpers/validation/barcode.mjs';
import { response } from '../helpers/response.mjs';
import { getLatestProductFromDB } from '../services/database.mjs';
import { compareProducts } from '../services/aiService.mjs';

export async function getCompareProducts(event) {
    try {
        const barcodeA = event.queryStringParameters?.barcodeA;
        const barcodeB = event.queryStringParameters?.barcodeB;

        const normBarcodeA = normalizeBarcode(barcodeA);
        const normBarcodeB = normalizeBarcode(barcodeB);

        if (!normBarcodeA || !normBarcodeB) {
            return response(400, { 
                error: "Both barcodeA and barcodeB query parameters are required" 
            });
        }

        console.log(`Comparing products: ${normBarcodeA} and ${normBarcodeB}`);

        const [productA, productB] = await Promise.all([
            getLatestProductFromDB(normBarcodeA),
            getLatestProductFromDB(normBarcodeB)
        ]);

        if (!productA || !productB) {
            return response(404, { 
                error: "One or both products not found. Please scan them first." 
            });
        }

        const comparisonResult = await compareProducts(productA, productB);

        return response(200, {
            analysis: comparisonResult
        });

    } catch (error) {
        console.error("Comparison Error:", error);
        return response(500, {
            error: "Failed to compare products" 
        });
    }
}