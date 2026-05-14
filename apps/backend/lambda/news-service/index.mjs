import { fetchNewsHandler } from "./handlers/fetchNewsHandler.mjs";
import { response } from "./helpers/response.mjs";

export const handler = async (event) => {
    if (event['detail-type'] === 'Scheduled Event' || event.source === 'aws.events') {
        console.log("Triggered by EventBridge: starting background fetch");
        return await fetchNewsHandler();
    }
};
