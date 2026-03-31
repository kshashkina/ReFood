function cleanMaterial(material) {
	return material.replace(/[^a-z0-9_]/gi, '').toLowerCase();
}

export function buildOverpassQuery({ materials, lat, lon, radius }) {
	const safeMaterials = materials
		.map(cleanMaterial)
		.filter(Boolean);

	const elementTypes = ['node', 'way'];
	const lines = [];

	for (const type of elementTypes) {
		for (const material of safeMaterials) {
			lines.push(
				`  ${type}["amenity"="recycling"]["recycling:${material}"="yes"](around:${radius}, ${lat}, ${lon});`
			);
		}
	}

	return `[out:json][timeout:25];\n(\n${lines.join('\n')}\n);\nout center;`;
}
