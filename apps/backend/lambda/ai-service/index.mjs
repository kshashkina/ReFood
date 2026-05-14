import { translateProduct } from './actions/translateProduct.mjs';
import { checkUserProduct } from './actions/checkUserProduct.mjs';
import { compareTwoProducts } from './actions/compareTwoProducts.mjs';
import { checkUserPhoto } from './actions/checkUserPhoto.mjs';
import { processResearch } from './actions/processResearch.mjs';

const actions = {
    translate_product: translateProduct,
    check_product: checkUserProduct,
    compare_products: compareTwoProducts,
    check_photo: checkUserPhoto,
    process_research: processResearch
};

export const handler = async (event) => {
    try {
        console.log("Input data:", JSON.stringify(event));

        const { action, data } = event;

        if (!action || !actions[action]) {
            return {
                statusCode: 400,
                body: JSON.stringify({
                    error: "Unknown action",
                    message: `Action "${action}" is not supported. Available: ${Object.keys(actions).join(', ')}`
                })
            };
        }

        return await actions[action](data);
    } catch (error) {
        return {
            statusCode: 500,
            body: JSON.stringify({ 
                error: "AI Processing failed", 
                message: error.message 
            })
        };
    }
};
