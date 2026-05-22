import { getProduct } from './handlers/getProduct.mjs';
import { createProduct } from './handlers/createProduct.mjs';
import { getCompareProducts } from './handlers/getCompareProducts.mjs';
import { addProductsFavorites } from './handlers/addProductsFavorites.mjs';
import { showProductsFavorites } from './handlers/showProductsFavorites.mjs';
import { removeProductFromFavorites } from './handlers/removeProductFromFavorites.mjs';
import { response, optionsResponse } from './helpers/response.mjs';

export const handler = async (event) => {
    const method = event.httpMethod || event.requestContext?.http?.method;
    const path = event.path || event.rawPath || '';

    const pathParts = path.split('/').filter(part => part !== '');

    console.log(`Request: ${method} ${path}`);

    try {
        if (method === 'OPTIONS') {
            return optionsResponse();
        }

        if (method === 'GET') {
            if (pathParts.includes('compare')) {
                return await getCompareProducts(event);
            }

            if (path.endsWith('/product/favorites')) {
                return await showProductsFavorites(event);
            }

            if (pathParts[pathParts.length - 2] === 'product') {
                return await getProduct(event);
            }
        }

        if (method === 'POST') {
            if (path.endsWith('/product')) {
                return await createProduct(event);
            }

            if (pathParts[pathParts.length - 1] === 'favorite') {
                return await addProductsFavorites(event);
            }
        }

        if (method === 'DELETE' && pathParts[pathParts.length - 1] === 'favorite') {
            return await removeProductFromFavorites(event);
        }

        return response(404, {
            error: "Route not found"
        });
    } catch (error) {
        console.error("Error:", error);
        return response(500, {
            error: "Internal server error"
        });
    }
};
