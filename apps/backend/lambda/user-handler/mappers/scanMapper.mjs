export const toScanResponse = (scan) => {
    return {
        barcode: scan.barcode,
        name: scan.productName,
        image: scan.image,
        date: scan.timestamp
    };
};

export const toScanListResponse = (scans) => {
    return scans.map(toScanResponse);
};
