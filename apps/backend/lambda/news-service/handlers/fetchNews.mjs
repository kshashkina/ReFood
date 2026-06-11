import { fetchNewsFromPubMed } from '../services/fetchPubMedApi.mjs';
import { checkNewsExists, saveNewsToDb } from '../services/newsDatabase.mjs';
import { processNewsWithAI } from '../services/aiService.mjs';

export const fetchNews = async () => {
    const rawResearches = await fetchNewsFromPubMed();
    console.log(`Step 1: Found in PubMed: ${rawResearches.length}`);

    if (rawResearches.length === 0) {
        return { message: "No researches found" };
    }

    const newResearches = [];
    for (const item of rawResearches) {
        const alreadyExists = await checkNewsExists(item.id);
        if (!alreadyExists) {
            newResearches.push(item);
        }
    }

    if (newResearches.length === 0) {
        return { message: "All fetched news already exist in database" };
    }

    console.log(`Step 2: New articles to process: ${newResearches.length}`);

    const aiResponse = await processNewsWithAI(newResearches);
    const processedArticles = Array.isArray(aiResponse) ? aiResponse : (aiResponse.processed_news || []);

    console.log(`Step 3: AI responded with: ${JSON.stringify(aiResponse)}`);

    for (const processedItem of processedArticles) {
        const original = newResearches.find(r => r.id === processedItem.id);

        const simplified_title_en = processedItem.simplified_title_en?.trim() || processedItem.original_title_en || "";
        const simplified_title_ua = processedItem.simplified_title_ua?.trim() || processedItem.original_title_ua || "";

        await saveNewsToDb({
            id: processedItem.id,
            date: original?.date || new Date().toISOString().split('T')[0],
            resource: original?.resource || "PubMed",
            ai_processed: {
                ...processedItem,
                simplified_title_en,
                simplified_title_ua
            }
        });
    }

    return { message: `Successfully processed new articles` };
};