# 🌍 TerraScope Firestore Schema

## 📋 Overview & User Scoping

**User-related data** (scoped to `/users/{userId}` or `user_id` field):

- `users` - Profiles + subcollections (emergency_contacts, etc. - **ACTIVE**)
- `user_devices` - Device tokens
- `prediction` - User-specific crop predictions

**Global/Shared data** (location-based, no direct user link):

- `weather_history` - All locations history
- `weather_data` - Live weather (query by location)
- `historical_data` - Aggregated trends
- `anomalies` - Detected events (query near user)
- `alerts` - Broadcast (link to anomaly + send to nearby user_devices)

**Status:** User data active; globals proposed (current APIs).

## 📊 Collections (8 Core)

### 1. `weather_history` - Historical Weather Data

Historical records for trend analysis and anomaly detection.

| Field      | Type      | Description                |
| ---------- | --------- | -------------------------- |
| humidity   | Number    | Humidity (%)               |
| lat        | Number    | Latitude                   |
| lon        | Number    | Longitude                  |
| pressure   | Number    | Atmospheric pressure (hPa) |
| rainfall   | Number    | Rainfall (mm)              |
| temp       | Number    | Temperature (°C)           |
| timestamp  | Timestamp | Record time                |
| wind_speed | Number    | Wind speed (km/h)          |

### 2. `weather_data` - Real-time Weather

Live weather snapshots from API.

| Field       | Type      | Description       |
| ----------- | --------- | ----------------- |
| humidity    | Number    | Humidity (%)      |
| location    | String    | Location name     |
| pressure    | Number    | Pressure (hPa)    |
| rainfall    | Number    | Rainfall (mm)     |
| temparature | Number    | Temperature (°C)  |
| timestamp   | Timestamp | Update time       |
| wind_speed  | Number    | Wind speed (km/h) |

### 3. `user_devices` - Device Registration

For push notifications.

| Field        | Type      | Description |
| ------------ | --------- | ----------- |
| last_updated | Timestamp | Last update |
| lat          | Number    | Device lat  |
| lon          | Number    | Device lon  |
| token        | String    | FCM token   |

### 4. `prediction` - AI Forecasts

Crop yields and weather predictions.

| Field             | Type      | Description         |
| ----------------- | --------- | ------------------- |
| created_at        | Timestamp | Creation time       |
| crop              | String    | Crop type           |
| lat               | Number    | Lat                 |
| lon               | Number    | Lon                 |
| predicted_yield   | Number    | Expected yield      |
| recommended_month | Number    | Best planting month |
| user_id           | String    | User ID             |

### 5. `historical_data` - Aggregated Analytics

Long-term summaries for ML training.

| Field         | Type   | Description    |
| ------------- | ------ | -------------- |
| avg_temp      | Number | Avg temp       |
| crop_grown    | String | Crop           |
| humidity      | Number | Avg humidity   |
| lat           | Number | Lat            |
| lon           | Number | Lon            |
| month         | Number | Month (1-12)   |
| rainfall_mm   | Number | Total rainfall |
| soil_moisture | Number | Soil moisture  |
| year          | Number | Year           |
| yield         | Number | Crop yield     |

### 6. `anomalies` - Detected Events

Unusual weather conditions (rules already exist).

| Field             | Type      | Description          |
| ----------------- | --------- | -------------------- |
| level             | String    | low/medium/high      |
| location          | String    | Area                 |
| message           | String    | Description          |
| timestamp         | Timestamp | Detection time       |
| type              | String    | heavy_rain/heat/etc. |
| value             | Number    | Anomaly magnitude    |
| verified_by_admin | Boolean   | Admin confirmed      |

### 7. `alerts` - User Notifications

Generated from anomalies.

| Field      | Type      | Description    |
| ---------- | --------- | -------------- |
| anomaly_id | String    | Source anomaly |
| body       | String    | Alert text     |
| timestamp  | Timestamp | Sent time      |
| title      | String    | Alert title    |

### 8. `users` - User Profiles **(ACTIVE)**

Path: `/users/{userId}`

**Top-level Fields:** (table from code)

| Field             | Type       | Description        | Links To                                                 |
| ----------------- | ---------- | ------------------ | -------------------------------------------------------- |
| userId            | String     | Firebase UID       | -                                                        |
| name              | String     | Full name          | -                                                        |
| email             | String     | Login email        | -                                                        |
| gender            | String     | M/F/Other          | -                                                        |
| userMode          | String     | farmer/safety/etc. | -                                                        |
| age               | int        | User age           | -                                                        |
| phoneNumber       | String     | Contact phone      | -                                                        |
| address           | String     | Home address       | -                                                        |
| preferences       | Map        | Settings           | enableNotifications (bool), enableLocationSharing (bool) |
| emergencyContacts | Array<Map> | Contacts array     | emergency_contacts subcoll.                              |
| createdAt         | Timestamp  | Signup time        | -                                                        |
| lastUpdated       | Timestamp  | Last edit          | -                                                        |

**Connections:** emergencyContacts → `/users/{userId}/emergency_contacts` subcollection (detailed per-contact docs).

**Subcollections (implemented):**
| Subcollection | Purpose |
|---------------|---------|
| weather/current | User-specific weather cache |
| health_reminders | Care mode reminders |
| daily_activities | Date-based activities |
| medications | Medication tracking |
| emergency_contacts | Per-user contacts |
| location_history | GPS logs |
| sync_status | Feature sync times |

Full CRUD in `lib/Services/firebase_user_service.dart`.

**Rules:** `match /users/{userId} { allow read, write: if request.auth.uid == userId; }`

## 🔄 Data Flow (User Context)

```
User lat/lon → Query weather_data (live)
             ↓
API → Write to users/{uid}/weather/current (user cache)
             ↓
Background → Append to weather_history (global)
             ↓ + Compare history → anomalies (global)
                           ↓
User devices near anomaly → alerts → FCM push
ML (history + crop) → prediction (user-scoped)
```

**Relation:** Alerts/predictions query globals → personalize per user/location/device.

## ⚙️ Security Rules

See `firestore.rules` for current rules (add for new collections):

```
match /anomalies/{doc} { allow read: if request.auth != null; }
match /weather_data/{doc} { allow read, write: if request.auth != null; }
# etc.
```

## 🚀 Implementation Status

- ✅ Rules partial (users, anomalies)
- 🔄 User data active (/users/{uid}/subcollections)
- ⏳ Weather collections: Plan to replace API caching
- 📚 Integrate with services (weather_services.dart → Firestore writes)

**Last Updated:** $(date)
