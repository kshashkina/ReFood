export function pointMapper(features, requestedMaterials) {
    if (!Array.isArray(features)) return [];

    const isAll = requestedMaterials.includes('all');

    return features.map(el => {
        const props = el.properties || {};
        const rawTags = props.datasource?.raw || {};

        const acceptedMaterials = Object.keys(rawTags)
            .filter(key => key.startsWith('recycling:') && rawTags[key] === 'yes')
            .map(key => key.replace('recycling:', ''));

        const matchesMaterial = isAll || requestedMaterials.some(m => acceptedMaterials.includes(m));

        if (!matchesMaterial) return null;

        return {
            id: props.place_id || props.osm_id,
            lat: props.lat,
            lon: props.lon,
            name: props.name || rawTags.operator || "No name",
            
            info: {
                address: props.address_line2 || "No address",
                operator: rawTags.operator || props.operator || null,
                website: props.website || rawTags.website || null,
                opening_hours: rawTags.opening_hours || null,
                wheelchair: rawTags.wheelchair || null,
                postcode: props.postcode || null
            },

            details: {
                accepted_materials: acceptedMaterials,
                description: rawTags.note || rawTags.description || "No description"
            }
        };
    }).filter(Boolean);
}
