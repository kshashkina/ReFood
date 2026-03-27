export const TRANSLATE_ANALYZE_PROMPT = `
    Translate to EN and UA, and perform a nutritional analysis.

    1. NORMALIZE & TRANSLATE:
    - ingredients_text -> Array of strings, flatten all groups.
    - allergens_tags -> Array of simple names.
    - categories_tags -> Array of readable tags.
    - packaging -> allowed values: Plastic, Glass, Metal, Paper, Cardboard, Mixed.
    - Remove empty/null/duplicates. Capitalize first letter.

    2. INTELLIGENT & FRIENDLY ANALYSIS (3-4 concise sentences):
    Structure the analysis to answer: "What am I actually eating?"
    - PROTAGONIST INGREDIENT: Start by mentioning the base of the product (the first ingredient). Is it a high-quality whole food or just refined flour/sugar?
    - THE "HIDDEN" TRUTH: Identify hidden sugars (syrups, maltodextrin), unhealthy fats (palm oil, hydrogenated oils) or heavy processing (E-numbers). Don't just list them—explain their presence briefly (e.g., "contains maltodextrin, which can spike blood sugar").
    - NUTRITIONAL VALUE: Mention if it's a good source of protein/fiber or if it's "empty calories." 
    - VERDICT: Give a clear, friendly takeaway. Is it a "great nutritious choice," a "fine occasional treat," or "highly processed with excessive salt/sugar"?

    TONE: Helpful, direct, and professional. Avoid "medical" jargon where simple words work better. If a nutrient (like sugar) is at a normal level, don't mention it—focus only on what stands out.

    Return JSON ONLY:
    {
        "ingredients_en": [],
        "ingredients_ua": [],
        "allergens_en": [],
        "allergens_ua": [],
        "categories_tags_en": [],
        "categories_tags_ua": [],
        "packaging_en": [{"material":"","shape":"","recycling":"","number_of_units":0}],
        "packaging_ua": [{"material":"","shape":"","recycling":"","number_of_units":0}],
        "analysis_en": "Clear, high-value analysis for the user.",
        "analysis_ua": "Чіткий, корисний аналіз для користувача."
    }
`;
