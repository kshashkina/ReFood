import { XMLParser } from 'fast-xml-parser';

const NCBI_API_KEY = process.env.NCBI_API_KEY;
const SEARCH_URL = "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi";
const FETCH_URL = "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi";
const parser = new XMLParser();

export async function fetchNewsFromPubMed() {
    const searchTerm = encodeURIComponent("nutrition food science");
    const searchParams = `db=pubmed&term=${searchTerm}&retmode=json&retmax=10&sort=date&api_key=${NCBI_API_KEY}`;

    try {
        const results = await fetch(`${SEARCH_URL}?${searchParams}`, {
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

        if (!ids || ids.length === 0) return [];

        const fetchParams = `db=pubmed&id=${ids.join(",")}&retmode=xml&api_key=${NCBI_API_KEY}`;
        const fullResults = await fetch(`${FETCH_URL}?${fetchParams}`);

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
            const pmid = art.MedlineCitation.PMID.toString();

            return {
                id: pmid,
                date: `${pubDate.Year}-${pubDate.Month || '01'}-${pubDate.Day || '01'}`,
                resource: journal.Title,
                title: medline.ArticleTitle,
                abstract: medline.Abstract?.AbstractText || ""
            };
        });
    } catch (error) {
        console.error("PubMed API Error:", error);
        return [];
    }
}
