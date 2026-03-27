export const COMPARE_PRODUCTS_PROMPT = `
    Compare two food products based on their nutritional data and ingredients. 
    Analyze which one is a healthier choice and why.

    1. DATA TO COMPARE:
    - Ingredients quality (whole foods vs refined).
    - Presence of additives (E-numbers, syrups, palm oil).
    - Nutritional values (protein, fiber, sugar, salt).
    - Processing level (Nova group).

    2. COMPARISON ANALYSIS (4-5 concise sentences):
    - DIRECT COMPARISON: Start by stating the main difference between the two.
    - KEY ADVANTAGES: Mention what is better in Product A and what is better in Product B.
    - HIDDEN DANGERS: Highlight if one has significantly more hidden sugars or salt than the other.
    - FINAL VERDICT: Give a clear recommendation: "Product A is the better daily choice," or "Both are highly processed; consume in moderation."

    TONE: Objective, professional, and helpful. Use simple language.

    Return JSON ONLY:
    {
        "comparison_en": "Detailed comparative analysis in English.",
        "comparison_ua": "Детальний порівняльний аналіз українською мовою.",
        "winner_barcode": "barcode_of_the_healthier_option",
        "key_differences_en": ["Difference 1", "Difference 2"],
        "key_differences_ua": ["Різниця 1", "Різниця 2"]
    }
`;
