import { XMLParser } from 'fast-xml-parser';

const NCBI_API_KEY = process.env.NCBI_API_KEY;
const SEARCH_URL = "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi";
const FETCH_URL = "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi";

const parser = new XMLParser({
    ignoreAttributes: false,
    parseAttributeValue: true
});

function extractAbstract(abstractText) {
    if (!abstractText) return "";
    if (typeof abstractText === 'string') return abstractText;

    if (Array.isArray(abstractText)) {
        return abstractText.map(node => typeof node === 'string' ? node : (node['#text'] || '')).join(' ');
    }

    if (typeof abstractText === 'object') {
        return abstractText['#text'] || "";
    }

    return "";
}

export async function fetchNewsFromPubMed() {
    const query = `("food waste"[Title/Abstract] OR "food recycling"[Title/Abstract] OR "food packaging"[Title/Abstract] OR "upcycled food"[Title/Abstract]) AND ("food products"[Title/Abstract] OR "nutrition"[Title/Abstract]) NOT ("patients"[Title/Abstract] OR "clinical"[Title/Abstract] OR "disease"[Title/Abstract] OR "bovine"[Title/Abstract] OR "veterinary"[Title/Abstract])`;
    const searchParams = new URLSearchParams({
        db: 'pubmed',
        term: query,
        retmode: 'json',
        retmax: '10',
        reldate: '30',
        datetype: 'pdat',
        tool: 'refood',
        email: 'refood.dev@ukr.net'
    });

    if (NCBI_API_KEY && NCBI_API_KEY !== 'undefined') {
        searchParams.append('api_key', NCBI_API_KEY);
    }

    try {
        const queryString = searchParams.toString().replaceAll('+', '%20');
        const fullSearchUrl = `${SEARCH_URL}?${queryString}`;
        const results = await fetch(fullSearchUrl, {
            headers: {
                Accept: "application/json"
            }
        });

        if (!results.ok) {
            console.error(`PubMed Search returned ${results.status}`);
            return [];
        }

        const data = await results.json();
        const ids = data.esearchresult?.idlist;

        console.log(`Step 1: Found IDs in PubMed:`, ids ? ids.length : 0);

        if (!ids || ids.length === 0) return [];

        const fetchParams = new URLSearchParams({
            db: 'pubmed',
            id: ids.join(","),
            retmode: 'xml'
        });

        if (NCBI_API_KEY && NCBI_API_KEY !== 'undefined') {
            fetchParams.append('api_key', NCBI_API_KEY);
        }

        const fullResults = await fetch(`${FETCH_URL}?${fetchParams.toString()}`);

        if (!fullResults.ok) {
            console.error(`PubMed Fetch returned ${fullResults.status}`);
            return [];
        }

        const xmlData = await fullResults.text();
        const jsonObj = parser.parse(xmlData);

        const articles = jsonObj.PubmedArticleSet?.PubmedArticle;
        if (!articles) return [];

        const items = Array.isArray(articles) ? articles : [articles];

        return items.map(art => {
            const medline = art.MedlineCitation.Article;
            const journal = medline.Journal;
            const pubDate = journal.JournalIssue.PubDate;
            const pmid = art.MedlineCitation.PMID?.['#text']?.toString() || art.MedlineCitation.PMID?.toString() || "";

            const dateCompleted = art.MedlineCitation.DateCompleted;
            const dateRevised = art.MedlineCitation.DateRevised;

            const year = pubDate.Year || dateCompleted?.Year || dateRevised?.Year || new Date().getFullYear();
            let month = pubDate.Month || dateCompleted?.Month || dateRevised?.Month || '01';
            if (isNaN(month)) {
                const months = { Jan: '01', Feb: '02', Mar: '03', Apr: '04', May: '05', Jun: '06', Jul: '07', Aug: '08', Sep: '09', Oct: '10', Nov: '11', Dec: '12' };
                month = months[month.toString().substring(0, 3)] || '01';
            } else {
                month = month.toString().padStart(2, '0');
            }

            const day = (pubDate.Day || dateCompleted?.Day || dateRevised?.Day || '01').toString().padStart(2, '0');

            const abstract = extractAbstract(medline.Abstract?.AbstractText);

            return {
                id: pmid,
                date: `${year}-${month}-${day}`,
                resource: journal.Title,
                title: medline.ArticleTitle,
                abstract: abstract
            };
        }).filter(item => item.title);
    } catch (error) {
        console.error("PubMed API Error:", error);
        return [];
    }
}
