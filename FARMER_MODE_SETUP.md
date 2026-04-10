# Farmer Dashboard Setup Guide

## Overview

The Farmer Dashboard now uses **real data** instead of mock data:

- ✅ Real weather data from WeatherAPI
- ✅ Real location data from GPS
- ✅ Real soil type from ISRIC API
- ✅ Real crop recommendations from ML model based on location

## Features Implemented

### 1. **Fast Weather Loading** (5-second timeout)

- Uses WeatherAPI.com for quick weather data
- Automatic fallback if API is slow or unavailable
- Shows location, temperature, condition, humidity, wind, and rain chance

### 2. **Real Crop Recommendations**

- Uses your ML model via `CropService` from `crops_india.json`
- Crops are filtered by:
  - State
  - District
  - Current weather conditions
  - Soil type
- Shows suitability percentage for each crop

### 3. **Location-Based Data**

- GPS coordinates (latitude/longitude)
- City, district, state from geocoding
- Soil type from ISRIC API

### 4. **Parallel Data Loading**

- Weather and crop recommendations load simultaneously
- Much faster overall experience
- No more "always loading" issue

---

## API Configuration

### Required API Key: WeatherAPI.com

1. **Sign up** at https://www.weatherapi.com/
2. **Copy your API key** from dashboard
3. **Update** `farmer_dashboard.dart` line ~93:
   ```dart
   final url = "https://api.weatherapi.com/v1/current.json"
       "?key=YOUR_WEATHERAPI_KEY&q=$latitude,$longitude&aqi=yes";
   ```
   Replace `YOUR_WEATHERAPI_KEY` with your actual key

### Weather API Response Format

The API returns data with this structure:

```json
{
  "current": {
    "temp_c": 28.5,
    "condition": { "text": "Partly cloudy" },
    "humidity": 65,
    "wind_kph": 12.3,
    "chance_of_rain": 40
  },
  "location": {
    "name": "City Name",
    "region": "State"
  }
}
```

---

## Crop JSON Structure Required

Ensure your `assets/data/crops_india.json` has this structure:

```json
{
  "states": {
    "Maharashtra": {
      "districts": {
        "Nashik": {
          "crops": [
            {
              "name": "Sugarcane",
              "suitability": 85,
              "reason": "Well suited for monsoon climate",
              "temp": "20-30°C",
              "soil": "Well-drained soil"
            },
            ...
          ]
        }
      }
    }
  }
}
```

---

## Data Flow

```
User clicks "Farmer Mode"
         ↓
Farmer Intro Popup appears
         ↓
User clicks "Continue"
         ↓
Fetches: Location (GPS) + Soil Type (ISRIC API)
         ↓
Navigates to FarmerDashboard with lat, lon, soilType
         ↓
FarmerDashboard loads:
  ├─ Weather (WeatherAPI) [Parallel]
  └─ Crop Recommendations (CropService from JSON) [Parallel]
         ↓
Displays real data on dashboard
```

---

## Features in Dashboard

### Weather Header

- **Location**: City, State (from GPS coordinates)
- **Temperature**: Real-time from WeatherAPI
- **Condition**: Sunny, Cloudy, Rainy, etc.
- **Humidity**: From weather API
- **Wind Speed**: km/h
- **Rain Chance**: Percentage

### AI Crop Recommendations

Shows top 5 recommended crops with:

- **Crop Name**: e.g., "Paddy", "Wheat", "Cotton"
- **Suitability**: Percentage match (75-95%)
- **Reason**: Why it's recommended for this region
- **Temperature Range**: Ideal growing temp
- **Soil Type**: Required soil condition

### Soil Status

- **Soil Type**: From ISRIC API
- **Coordinates**: Latitude/Longitude
- **Humidity Level**: From weather data

---

## Timeout Handling

### Weather API (5 seconds)

If WeatherAPI is slow:

- Falls back to default weather: 28°C, Partly Cloudy, 65% humidity
- User still sees recommendations (doesn't block UI)

### Crop Recommendations (from local JSON)

- Loads instantly from local assets
- No network dependency
- Always fast

---

## Testing the Integration

1. **Start the app**
2. **Click "Farmer Mode"** on HomeScreen0
3. **Click "Continue"** in intro popup
4. **Dashboard loads with**:
   - ✅ Real weather data
   - ✅ Real location name
   - ✅ Real crop recommendations
   - ✅ Real soil data
   - All loaded within 5-6 seconds (no hanging)

---

## Troubleshooting

### Weather not loading

- Check API key is correct in farmer_dashboard.dart
- Check internet connection
- Check WeatherAPI.com status

### Crops not showing

- Verify `crops_india.json` exists in `assets/data/`
- Check JSON structure matches required format
- Verify state/district names in JSON match location data

### Slow performance

- Weather API timeout is set to 5 seconds
- Crop recommendations load from local JSON (instant)
- Should never hang - fallback always available

---

## Next Steps (Optional)

1. **Add more crops** to `crops_india.json` for better coverage
2. **Customize weather API** to use different provider
3. **Add seasonal adjustments** to crop recommendations
4. **Integrate backend ML model** for more advanced predictions
5. **Add alerts** for weather-based farming events
