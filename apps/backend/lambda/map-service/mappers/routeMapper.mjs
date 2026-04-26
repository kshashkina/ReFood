export function routeMapper(data) {
    const features = data?.features?.[0];
    if (!features) return null;

    const props = features.properties;
    const geometry = features.geometry;

    const steps = props.legs?.[0]?.steps?.map(step => ({
        distance: step.distance,
        time: step.time,
        instruction: step.instruction?.text || ''
    })) ?? [];

    const coordinates = geometry?.coordinates?.flat().map(([lon, lat]) => ({ lat, lon })) ?? [];

    return {
        mode: props.mode,
        distance: props.distance,
        distanceUnits: props.distance_units,
        time: Math.round(props.time),
        steps,
        coordinates
    };
}
