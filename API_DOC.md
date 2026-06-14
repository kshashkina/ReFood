# ReFood API v1 Specifications

> All serverless microservices and infrastructure components are geographically deployed within the **AWS `eu-north-1` (Stockholm)** region.  

## General Principles

### Response Data Format

All responses are returned in JSON format with the header `Content-Type: application/json`.

### CORS

All endpoints support CORS:
```
Access-Control-Allow-Origin: *
Access-Control-Allow-Headers: Content-Type, Authorization
```

### Error Structure

In all Lambda functions (except `ai-service`), errors have a unified format:
```json
{
  "error": "Error description"
}
```

For errors with details (validation):
```json
{
  "error": "Validation failed",
  "details": ["Reason 1", "Reason 2"]
}
```

### HTTP Status Codes

| Code | Meaning |
|---|---|
| `200` | Success |
| `201` | Resource created successfully |
| `400` | Invalid parameters or request body |
| `404` | Resource not found |
| `500` | Internal server error |

---

## Product Handler

Lambda: `ProductHandler`  
Handles product-related operations: retrieving by barcode (from DB or [OpenFoodFacts](https://ua.openfoodfacts.org/)), creation and comparison.

---

### `GET /product/{barcode}`

Retrieves a product by barcode. First searches in DynamoDB, if not found - search in OpenFoodFacts API and saves the result.

**Path Parameters**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `barcode` | string | + | Product barcode (EAN-8, EAN-13) |

**Success Response `200`**

Required fields are always present.
Optional fields are present only if the data is available.

```json
{
  "source": "local",
  "product": {
    "product_name": "Product name",
    "brands": "Brand",
    "categories_tags_en": ["Snacks", "Chips"],
    "categories_tags_ua": ["Снеки", "Чипси"],
    "nutriscore_grade": "c",
    "ecoscore_grade": "b",
    "ingredients_en": ["Potato", "Sunflower oil", "Salt"],
    "ingredients_ua": ["Картопля", "Соняшникова олія", "Сіль"],
    "allergens_en": ["Gluten"],
    "allergens_ua": ["Глютен"],
    "packaging_en": [{ "material": "Plastic", "shape": "Bag", "recycling": "Recycle", "number_of_units": 1 }],
    "packaging_ua": [{ "material": "Пластик", "shape": "Пакет", "recycling": "Переробляється", "number_of_units": 1 }],
    "nutriments": {
      "energy_kcal": 536,
      "fat": 31.0,
      "saturated_fat": 3.0,
      "carbohydrates": 55.0,
      "sugars": 1.5,
      "fiber": 4.0,
      "proteins": 6.5,
      "salt": 1.2,
      "sodium": null
    },
    "nova_group": 4,
    "quantity": "200g",
    "serving_size": "30g",
    "serving_quantity": 30,
    "image_url": "https://...",
    "image_small_url": "https://...",
    "analysis_ua": "Це чипси з картоплі...",
    "analysis_en": "These are potato chips...",
    "source": "local"
  }
}
```

**Field "source" in product:**

- `local`: product was found in DynamoDB (already saved)
- `openfoodfacts`: product was newly obtained from OpenFoodFacts API and saved

**Errors**

| Status | Body | Reason |
|---|---|---|
| `400` | `{ "error": "Invalid barcode format" }` | Barcode did not pass normalization |
| `404` | `{ "error": "Product not found" }` | Not found in DB and/or OpenFoodFacts |
| `500` | `{ "error": "Internal server error" }` | AWS or AI service error |

---

### `POST /product`

Creates a new product entered by the user. Before saving, it goes through AI validation (content check) and AI translation.

**Request Body** (`application/json`)
```json
{
  "barcode": "1234567890123",
  "product_name": "Product Name",
  "product_name_en": "Product Name",
  "product_name_ua": "Назва продукту",
  "brands": "Brand",
  "ingredients_text": "Ingredient 1, Ingredient 2",
  "allergens_tags": ["gluten"],
  "categories_tags": ["snacks"],
  "nutriments": {
    "energy_kcal": 200,
    "fat": 5.0,
    "saturated_fat": 1.0,
    "carbohydrates": 30.0,
    "sugars": 10.0,
    "fiber": 2.0,
    "proteins": 4.0,
    "salt": 0.5
  },
  "nova_group": 3,
  "nutriscore_grade": "b",
  "quantity": "100g",
  "image_url": "https://..."
}
```

**Success Response `201`**
```json
{
  "message": "Product verified and created successfully"
}
```

**Errors**

| Status | Body | Reason |
|---|---|---|
| `400` | `{ "error": "Invalid JSON body" }` | Invalid JSON body |
| `400` | `{ "error": "Validation failed", "details": ["..."] }` | Failed local schema validation |
| `400` | `{ "error": "Invalid barcode format" }` | Barcode format invalid |
| `400` | `{ "error": "AI Validation failed", "details": ["..."], "isSafetyViolation": true }` | AI detected inappropriate/unsafe content or invalid data |
| `500` | `{ "error": "Failed to process product with AI services" }` | AI service error |

---

### `POST /product/{barcode}/favorite`

Toggle a product as favorite for the current user. If the product is not yet favorited - adds it. If already favorited - removes it (toggle behavior).

**Path Parameters**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `barcode` | string | + | Product barcode |

**Authentication:** required (IAM / Cognito identity)

**Success Response `200`**
```json
{ "liked": true }
```
or
```json
{ "liked": false }
```

**Errors**

| Status | Body | Reason |
|---|---|---|
| `400` | `{ "error": "Invalid barcode" }` | Barcode normalization failed |
| `401` | `{ "error": "Unauthorized" }` | User identity not resolved |
| `404` | `{ "error": "Product not found in database" }` | Product does not exist in DB |

---

### `DELETE /product/{barcode}/favorite`

Explicitly remove a product from the user's favorites.

**Path Parameters**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `barcode` | string | + | Product barcode |

**Authentication:** required

**Success Response `200`**
```json
{ "liked": false }
```

**Errors**

| Status | Body | Reason |
|---|---|---|
| `400` | `{ "error": "Invalid barcode" }` | Barcode normalization failed |
| `401` | `{ "error": "Unauthorized" }` | User identity not resolved |

---

### `GET /product/compare?barcodeA={barcodeA}&barcodeB={barcodeB}`

Compare two products using AI. Both products must already exist in the database.

**Query Parameters**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `barcodeA` | string | + | Barcode of the first product |
| `barcodeB` | string | + | Barcode of the second product |

**Success Response `200`**
```json
{
  "analysis": {
    "comparison_en": "Product A is higher in protein but contains palm oil...",
    "comparison_ua": "Продукт A містить більше білка, але має пальмову олію...",
    "winner_barcode": "1234567890123",
    "key_differences_en": ["Product A has more fiber", "Product B is less processed"],
    "key_differences_ua": ["Продукт A містить більше клітковини", "Продукт B менш оброблений"]
  }
}
```

**Errors**

| Status | Body | Reason |
|---|---|---|
| `400` | `{ "error": "Both barcodeA and barcodeB query parameters are required" }` | One or both parameters are missing |
| `404` | `{ "error": "One or both products not found. Please scan them first." }` | Product not found in DB |
| `500` | `{ "error": "Failed to compare products" }` | AI service error |

---

## Map Service

Lambda: `MapService`  
Handles geolocation: searching for recycling collection points and building routes via [Geoapify API](https://www.geoapify.com/).

---

### `GET /map/locations`

Find recycling collection points within a specified radius.

**Query Parameters**

| Parameter | Type | Required | Default | Description |
|---|---|---|---|---|
| `lat` | number | + | — | Latitude of the search center |
| `lon` | number | + | — | Longitude of the search center |
| `materials` | string | + | — | Materials separated by comma: `glass,paper,plastic` or `all` |
| `radius` | number | - | `2000` | Search radius in meters |

*Available materials for "materials" field:* glass, paper, plastic, metal, clothes, batteries, electronics, all.

**Success Response `200`**
```json
{
  "count": 3,
  "points": [
    {
      "id": "513b5646c4504e7d9a25e62143afdaec4840f00",
      "lat": 50.4501,
      "lon": 30.5234,
      "name": "Recycling Point",
      "info": {
        "address": "вул. Хрещатик, 1",
        "operator": "EkoUA",
        "brand": null,
        "website": "https://ekoua.com",
        "opening_hours": "Mo-Fr 09:00-18:00",
        "wheelchair": "yes",
        "postcode": "01001"
      },
      "details": {
        "accepted_materials": ["glass", "paper", "plastic"],
        "description": null
      }
    }
  ]
}
```

**Errors**

| Status | Body | Reason |
|---|---|---|
| `400` | `{ "error": "Missing required parameters: lat, lon and materials are required." }` | Missing required parameter |
| `404` | `{ "error": "Points not found" }` | No points found within the specified radius |
| `500` | `{ "error": "Internal Server Error" }` | Geoapify or internal error |

---

### `GET /map/route`

Build a walking/cycling/driving route between two points.

**Query Parameters**

| Parameter | Type | Required | Default | Description |
|---|---|---|---|---|
| `fromLat` | number | + | — | Latitude of the start point |
| `fromLon` | number | + | — | Longitude of the start point |
| `toLat` | number | + | — | Latitude of the end point |
| `toLon` | number | + | — | Longitude of the end point |
| `mode` | string | - | `walk` | Mode: `walk`, `bicycle`, `drive` |

**Success Response `200`**
```json
{
  "mode": "walk",
  "distance": 1250.5,
  "distanceUnits": "meters",
  "time": 900,
  "steps": [
    {
      "distance": 145.2,
      "time": 104,
      "instruction": "Head north on vul. Khreshchatyk"
    },
    {
      "distance": 300.0,
      "time": 216,
      "instruction": "Turn left onto prov. Shevchenka"
    }
  ],
  "coordinates": [
    { "lat": 50.4501, "lon": 30.5234 },
    { "lat": 50.4512, "lon": 30.5245 }
  ]
}
```

**Fields:**
- `distance` — distance in meters
- `time` — time in seconds (rounded)
- `coordinates` — array of route geometry points for polyline display on the map

**Errors**

| Status | Body | Reason |
|---|---|---|
| `400` | `{ "error": "Missing required parameters: fromLat, fromLon, toLat, toLon" }` | Missing required parameters |
| `404` | `{ "error": "Route not found" }` | Geoapify could not build the route |
| `500` | `{ "error": "Internal Server Error" }` | Geoapify or internal error |

---

### `POST /map/sort-metrics`

Track that the user visited a recycling point and sorted waste. Triggers two metric increments: `increment_sorted` and `track_map_check`.

**Request Body:** none

**Authentication:** required

**Success Response `200`**
```json
{ "message": "Sorted metrics tracked successfully" }
```

**Errors**

| Status | Body | Reason |
|---|---|---|
| `401` | `{ "error": "Unauthorized" }` | User identity not resolved |
| `500` | `{ "error": "Internal Server Error" }` | Metrics service error |

---

## S3 Service

Lambda: `S3Service`  
Handles user product image uploads: generate presigned URL → client upload → AI validation → finalization (move to `/public`).  

---

### `GET /s3/upload-url`

Get a temporary presigned URL for direct client upload to S3.

**Request Body:** none

**Success Response `200`**
```json
{
  "uploadUrl": "https://bucket-name.s3.amazonaws.com/temp/uuid.jpg?X-Amz-...",
  "imageId": "550e8400-e29b-41d4-a716-446655440000",
  "s3Key": "temp/550e8400-e29b-41d4-a716-446655440000.jpg",
  "imageUrl": "https://bucket-name.s3.amazonaws.com/temp/550e8400-e29b-41d4-a716-446655440000.jpg",
  "expiresIn": 300
}
```

*Important:* `uploadUrl` is a URL for a `PUT` request directly to S3 with `Content-Type: image/jpeg`. Valid for 300 seconds (5 minutes). After upload, the client saves `imageId` and `s3Key` for the next steps.

**Errors**

| Status | Body | Reason |
|---|---|---|
| `500` | `{ "error": "Storage configuration error" }` | S3_BUCKET_NAME variable not configured |

---

## Job Status Checker

Lambda: `JobStatusChecker`  
Provides polling for async image validation results.

---

### `GET /status-check/image-validation/{imageId}`

Check the current validation status of an uploaded image. Used for polling after an S3 upload event triggers background AI validation.

**Path Parameters**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `imageId` | string | + | Image ID returned from `GET /s3/upload-url` |

**Success Response `200`**

While processing or on success:
```json
{ "status": "PENDING" }
```
or
```json
{ "status": "APPROVED" }
```

If validation failed:
```json
{
  "status": "REJECTED",
  "error_en": "The image does not show a food product.",
  "error_ua": "Зображення не містить харчового продукту."
}
```

Possible `status` values: `PENDING`, `APPROVED`, `REJECTED`.

**Errors**

| Status | Body | Reason |
|---|---|---|
| `400` | `{ "error": "Missing imageId" }` | imageId not provided |
| `404` | `{ "error": "Job not found" }` | No job found for this imageId |

---

## User Handler

Lambda: `UserHandler`  
Handles user lifecycle: registration, Apple Sign-In linking, profile data, scan history, favorites, achievements and account deletion.

**Authentication note:** Most endpoints resolve the user via device identity (`identityId` from AWS Cognito IAM) or Apple JWT (`cognitoSub`). The system supports both anonymous and authenticated users.

---

### `POST /users/register`

Register or recognize a user by device. If the user already exists, updates their `identityId` if it changed. If new - creates the user record.

**Request Body** (`application/json`)
```json
{
  "identityId": "eu-north-1:0000-0000-0000-0000",
  "deviceId": "0000-0000-0000-0000"
}
```

**Success Response `200`** (existing user)
```json
{ "message": "User recognized" }
```

**Success Response `201`** (new user)
```json
{ "message": "New user created" }
```

**Errors**

| Status | Body | Reason |
|---|---|---|
| `400` | `{ "error": "Invalid JSON body" }` | Invalid JSON |
| `400` | `{ "error": "Validation failed", "details": ["..."] }` | Missing required fields |
| `500` | `{ "error": "Failed to register user" }` | DynamoDB error |

---

### `POST /users/register/link-account`

Link an anonymous device session to an authenticated Apple Sign-In account. Requires a valid Cognito JWT. Merges the anonymous user record with the Apple identity.

**Authentication:** Bearer token (Apple/Cognito JWT) required

**Request Body** (`application/json`)
```json
{
  "deviceId": "0000-0000-0000-0000"
}
```

**Success Response `200`** (returning Apple user)
```json
{ "message": "Welcome back" }
```

**Success Response `200`** (anonymous linked to Apple)
```json
{ "message": "Account linked" }
```

**Errors**

| Status | Body | Reason |
|---|---|---|
| `400` | `{ "error": "Invalid JSON body" }` | Invalid JSON |
| `400` | `{ "error": "Missing or invalid deviceId" }` | deviceId missing or wrong type |
| `401` | `{ "error": "Missing or invalid authorization token" }` | JWT missing or invalid |
| `409` | `{ "error": "No user session found for this device. Call /users/register first." }` | No anonymous session exists for device |
| `500` | `{ "error": "Failed to link account" }` | DynamoDB error |

---

### `GET /users/dashboard`

Returns the user's personal dashboard: scan/sort counts and 5 most recent scans. Also triggers a daily streak update in the background.

**Authentication:** required

**Success Response `200`**
```json
{
  "profile": {
    "scannedCount": 42,
    "sortedCount": 10
  },
  "recentScans": [
    {
      "barcode": "1234567890123",
      "productName": "Product name",
      "productBrand": "Brand",
      "image": "https://...",
      "scannedAt": "2026-06-14T12:00:00.000Z"
    }
  ]
}
```

**Errors**

| Status | Body | Reason |
|---|---|---|
| `401` | `{ "error": "User not recognized" }` | Identity not found |
| `404` | `{ "error": "User data not found" }` | No metrics or scans found |
| `500` | `{ "error": "Failed to load dashboard data" }` | Internal error |

---

### `GET /users/scans`

Returns paginated scan history for the current user.

**Authentication:** required

**Query Parameters**

| Parameter | Type | Required | Default | Description |
|---|---|---|---|---|
| `limit` | number | - | `20` | Number of items per page (max 100) |
| `nextToken` | string | - | - | Pagination cursor from previous response |

**Success Response `200`**
```json
{
  "scans": [
    {
      "barcode": "1234567890123",
      "productName": "Product name",
      "productBrand": "Brand",
      "image": "https://...",
      "scannedAt": "2026-06-14T12:00:00.000Z"
    }
  ],
  "nextToken": "eyJ1c2VySWQiOiJ..." 
}
```

`nextToken` is omitted if there are no more pages.

**Errors**

| Status | Body | Reason |
|---|---|---|
| `400` | `{ "error": "Invalid nextToken" }` | nextToken could not be decoded |
| `401` | `{ "error": "User not recognized" }` | Identity not found |

---

### `POST /users/scans`

Record a product scan event for the current user.

**Authentication:** required

**Request Body** (`application/json`)
```json
{
  "barcode": "1234567890123",
  "productName": "Product name",
  "productBrand": "Brand",
  "image": "https://...",
  "productVersion": "openfoodfacts"
}
```

Only `barcode` is required field other are optional.

**Success Response `201`**
```json
{ "success": true }
```

**Errors**

| Status | Body | Reason |
|---|---|---|
| `400` | `{ "error": "barcode is required" }` | barcode missing |
| `401` | `{ "error": "User not recognized" }` | Identity not found |
| `500` | `{ "error": "Failed to record scan" }` | DynamoDB error |

---

### `GET /users/favorites`

Returns paginated list of the user's favorite products.

**Authentication:** required

**Query Parameters**

| Parameter | Type | Required | Default | Description |
|---|---|---|---|---|
| `limit` | number | - | `20` | Items per page (max 100) |
| `nextToken` | string | - | - | Pagination cursor |

**Success Response `200`**
```json
{
  "favorites": [
    {
      "barcode": "1234567890123",
      "product_name": "Product name",
      "brands": "Brand",
      "image_url": "https://...",
      "nutriscore_grade": "b"
    }
  ],
  "nextToken": "eyJ1c2VySWQiOiJ..."
}
```

**Errors**

| Status | Body | Reason |
|---|---|---|
| `400` | `{ "error": "Invalid nextToken" }` | nextToken could not be decoded |
| `401` | `{ "error": "Unauthorized" }` | Identity not found |

---

### `GET /users/achievements`

Returns the user's gamification achievements and progress.

**Authentication:** required

**Success Response `200`**
```json
{
  "achievements": [
    {
      "id": "first_scan",
      "title_en": "First Scan",
      "title_ua": "Перше сканування",
      "description_en": "Scan your first product",
      "description_ua": "Відскануйте перший продукт",
      "isUnlocked": true,
      "progress": 1,
      "goal": 1
    }
  ],
  "totalUnlocked": 3,
  "total": 12
}
```

**Errors**

| Status | Body | Reason |
|---|---|---|
| `401` | `{ "error": "User not recognized" }` | Identity not found |
| `500` | `{ "error": "Failed to load achievements" }` | Metrics service error |

---

### `GET /users/id?deviceId={deviceId}`

Resolve the internal `userId` for a given `deviceId`. Validates that the authenticated identity matches the device.

**Authentication:** required

**Query Parameters**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `deviceId` | string | + | Device UUID |

**Success Response `200`**
```json
{ "userId": "0000-0000-0000-0000" }
```

**Errors**

| Status | Body | Reason |
|---|---|---|
| `400` | `{ "error": "Missing required query parameter: deviceId" }` | deviceId not provided |
| `401` | `{ "error": "Unauthorized" }` | Identity not found |
| `403` | `{ "error": "Identity mismatch" }` | Device belongs to a different user |
| `404` | `{ "error": "User not found" }` | No user for this deviceId |

---

### `DELETE /users`

Permanently delete all data for the authenticated Apple user: user record, scan history, favorites and metrics.

**Authentication:** Bearer token (Apple/Cognito JWT) required

**Success Response `200`**
```json
{ "message": "All user data deleted" }
```

**Errors**

| Status | Body | Reason |
|---|---|---|
| `401` | `{ "error": "Authorization required" }` | JWT missing |
| `404` | `{ "error": "User not found" }` | No Apple-linked user for this JWT |
| `500` | `{ "error": "Failed to delete account" }` | DynamoDB error |

---

## News Service

Lambda: `NewsService`  
Serves daily food/nutrition news and health tips. Also triggered by AWS EventBridge on a schedule to fetch and store fresh news from PubMed.

---

### `GET /daily-dashboard`

Returns today's daily health tip and the latest news articles. No authentication required.

**Success Response `200`**
```json
{
  "date_utc": "2026-06-14",
  "tip": {
    "date": "14.06",
    "text_en": "Drink at least 8 glasses of water a day.",
    "text_ua": "Пийте щонайменше 8 склянок води на день."
  },
  "news": [
    {
      "title": "Benefits of Mediterranean Diet",
      "simplified": "Eating Mediterranean-style reduces heart disease risk.",
      "url": "https://pubmed.ncbi.nlm.nih.gov/...",
      "publishedAt": "2026-06-13"
    }
  ]
}
```

**Errors**

| Status | Body | Reason |
|---|---|---|
| `500` | `{ "error": "Internal server error" }` | DynamoDB read error |

---

## Summary Table

| Method | Path | Lambda | Description |
|---|---|---|---|
| `GET` | `/product/{barcode}` | ProductHandler | Get product by barcode |
| `GET` | `/product/compare` | ProductHandler | Compare two products via AI |
| `POST` | `/product` | ProductHandler | Create product (with AI validation) |
| `POST` | `/product/{barcode}/favorite` | ProductHandler | Toggle product favorite (add/remove) |
| `DELETE` | `/product/{barcode}/favorite` | ProductHandler | Remove product from favorites |
| `GET` | `/map/locations` | MapService | Find recycling collection points |
| `GET` | `/map/route` | MapService | Build route to a recycling point |
| `POST` | `/map/sort-metrics` | MapService | Track waste sorting event |
| `GET` | `/s3/upload-url` | S3Service | Get presigned URL for image upload |
| `GET` | `/status-check/image-validation/{imageId}` | JobStatusChecker | Poll image validation status |
| `GET` | `/users/dashboard` | UserHandler | Get user dashboard (counts + recent scans) |
| `GET` | `/users/scans` | UserHandler | Get paginated scan history |
| `GET` | `/users/favorites` | UserHandler | Get paginated favorite products |
| `GET` | `/users/achievements` | UserHandler | Get achievements and progress |
| `GET` | `/users/id` | UserHandler | Get userId by deviceId |
| `POST` | `/users/register` | UserHandler | Register or recognize a user |
| `POST` | `/users/register/link-account` | UserHandler | Link device session to Apple account |
| `POST` | `/users/scans` | UserHandler | Record a product scan |
| `DELETE` | `/users` | UserHandler | Delete all user data |
| `GET` | `/daily-dashboard` | NewsService | Get daily tip and news feed |
s