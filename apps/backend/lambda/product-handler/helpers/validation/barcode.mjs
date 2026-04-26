export function normalizeBarcode(barcode) {
    if (!barcode || !/^\d{7,14}$/.test(barcode)) return null;

    const cleanCode = barcode.replace(/^0+/, '');
    if (cleanCode.length <= 7) return cleanCode.padStart(8, '0');
    if (cleanCode.length >= 9 && cleanCode.length <= 12) return cleanCode.padStart(13, '0');

    return barcode;
}
