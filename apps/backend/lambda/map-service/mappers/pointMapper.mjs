export function pointMapper(data, requestedMaterials) {
    const features = data?.features;
    if (!features) return null;

    const isAll = requestedMaterials.includes('all');

    return features.map(point => {
        const props = point.properties || {};
        const options = props.recycling_options || {};

        const acceptedMaterials = Object.keys(options).filter(key => options[key] === true);
        const matchesMaterial = isAll || requestedMaterials.some(material => acceptedMaterials.includes(material));
        if (!matchesMaterial) return null;

        return {
            id: props.place_id,
            lat: props.lat,
            lon: props.lon,
            name: props.name || "Recycling Point",

            info: {
                address: props.address_line1 || props.address_line2 || "No address",
                operator: props.operator || null,
                brand: props.brand || null,
                website: props.operator_details?.website || props.website || null,
                opening_hours: props.opening_hours || null,
                wheelchair: props.facilities?.wheelchair || null,
                postcode: props.postcode || null
            },

            details: {
                accepted_materials: acceptedMaterials,
                description: props.description || null
            }
        };
    }).filter(Boolean);
}
