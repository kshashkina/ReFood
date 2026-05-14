import { fetchNewsFromPubMed } from '../services/fetchPubMedApi.mjs';
import { checkNewsExists, saveNewsToDb } from '../services/newsDatabase.mjs';
import { processNewsWithAI } from '../services/aiService.mjs';

export const fetchNewsHandler = async () => {
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

        await saveNewsToDb({
            id: processedItem.id,
            date: original?.date || new Date().toISOString().split('T')[0],
            resource: original?.resource || "PubMed",
            ai_processed: processedItem
        });
    }

    return { message: `Successfully processed new articles` };
};