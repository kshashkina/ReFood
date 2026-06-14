import { describe, it, expect, vi } from 'vitest';

vi.mock('../helpers/formatters/cleanValue.mjs', () => ({
    cleanValue: vi.fn((value) => {
        if (value === null || value === undefined) return null;
        if (Array.isArray(value)) return value.filter(Boolean);
        if (typeof value === 'string' && ['', 'unknown', 'null', 'undefined'].includes(value.toLowerCase())) return null;
        return value;
    })
}));

vi.mock('../helpers/nutriments/extractNutriments.mjs', () => ({
    extractNutriments: vi.fn(() => ({ energy_kcal_100g: 250, fat_100g: 10 }))
}));

vi.mock('../helpers/nutriments/parseToGrams.mjs', () => ({
    parseToGrams: vi.fn((value) => {
        if (!value) return null;
        if (typeof value === 'number') return value;
        return parseFloat(value) || null;
    })
}));

import { offProductToProduct, toProductResponse } from '../mappers/productMapper.mjs';

const fakeOffProduct = {
    product_name: 'Test Product',
    product_name_en: 'Test Product EN',
    brands: 'TestBrand',
    categories_tags: ['snacks'],
    ingredients_text: 'sugar, water',
    ingredients_analysis_tags: ['palm-oil-free'],
    allergens_tags: ['gluten'],
    traces_tags: ['milk'],
    nutriscore_grade: 'b',
    nutriscore_score: 5,
    ecoscore_grade: 'c',
    ecoscore_score: 42,
    nova_group: 3,
    nutriments: { 'energy-kcal_100g': 250, 'fat_100g': 10 },
    quantity: '200g',
    serving_size: '50g',
    image_url: 'https://example.com/img.jpg',
    _id: 'off-example-12345'
};

const fakeDbProduct = {
    product_name: 'DB Product',
    brands: 'DBBrand',
    categories_tags_en: ['snacks'],
    categories_tags_ua: ['снеки'],
    nutriscore_grade: 'a',
    ecoscore_grade: 'b',
    ingredients_en: 'water, sugar',
    ingredients_ua: 'вода, цукор',
    allergens_en: ['gluten'],
    allergens_ua: ['глютен'],
    packaging_en: ['plastic bottle'],
    packaging_ua: ['пластикова пляшка'],
    nutriments: { energy_kcal_100g: 100 },
    nova_group: 1,
    quantity: '500ml',
    image_url: 'https://img.com/img.jpg',
    analysis_ua: 'Аналіз продукту',
    analysis_en: 'Product analysis',
    source: 'openfoodfacts'
};

describe('productMapper', () => {

    describe('offProductToProduct', () => {

        it('should map all fields from offProduct correctly', () => {
            const result = offProductToProduct('1234567890', fakeOffProduct);

            expect(result.barcode).toBe('1234567890');
            expect(result.product_name).toBe('Test Product');
            expect(result.product_name_en).toBe('Test Product EN');
            expect(result.brands).toBe('TestBrand');
            expect(result.source).toBe('openfoodfacts');
        });

        it('should map packaging from ecoscore_data', () => {
            const product = {
                ...fakeOffProduct,
                ecoscore_data: {
                    adjustments: {
                        packaging: {
                            packagings: [
                                { material: 'plastic', number_of_units: 1, shape: 'bottle', recycling: 'recycle' }
                            ]
                        }
                    }
                }
            };
            const result = offProductToProduct('1234567890', product);

            expect(result.packaging).toHaveLength(1);
            expect(result.packaging[0].material).toBe('plastic');
            expect(result.packaging[0].shape).toBe('bottle');
        });
    });

    describe('toProductResponse', () => {

        it('should return only response fields', () => {
            const result = toProductResponse(fakeDbProduct);

            expect(result.product_name).toBe('DB Product');
            expect(result.brands).toBe('DBBrand');
            expect(result.nutriscore_grade).toBe('a');
            expect(result.ecoscore_grade).toBe('b');
            expect(result.nova_group).toBe(1);
            expect(result.nutriments).toEqual({ energy_kcal_100g: 100 });
            expect(result.quantity).toBe('500ml');
            expect(result.image_url).toBe('https://img.com/img.jpg');
            expect(result.analysis_ua).toBe('Аналіз продукту');
            expect(result.analysis_en).toBe('Product analysis');
            expect(result.source).toBe('openfoodfacts');
        });

        it('should not expose internal fields like barcode or updated_at', () => {
            const result = toProductResponse({ ...fakeDbProduct, barcode: '1234567890', updated_at: 123 });

            expect(result.barcode).toBeUndefined();
            expect(result.updated_at).toBeUndefined();
        });
    });
});
