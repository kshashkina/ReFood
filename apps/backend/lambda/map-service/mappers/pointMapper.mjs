export function pointMapper(elements) {
    if (!Array.isArray(elements)) return [];

    const points = elements.map(el => {
        const tags = el.tags || {};

        const recyclingTypes = Object.keys(tags)
            .filter(key => key.startsWith('recycling:') && tags[key] === 'yes')
            .map(key => key.replace('recycling:', ''));

        const combinedDescription = [tags.note, tags.description]
            .filter(Boolean)
            .join('. ');

        const mappedPoint = {
            id: el.id,
            type: el.type,
            lat: el.lat || el.center?.lat,
            lon: el.lon || el.center?.lon,
            name: tags.name || "No name",
            
            info: {
                operator: tags.operator || null,
                website: tags["operator:website"] || tags.website || null,
                recycling_type: tags.recycling_type || null,
                location: tags.location || null,
                opening_hours: tags.opening_hours || null,
                wheelchair: tags.wheelchair || null,
                level: tags.level || null,
            },

            details: {
                accepted_materials: recyclingTypes,
                description: combinedDescription || "No additional description"
            }
        };

        return mappedPoint;
    });

    return points;
}
