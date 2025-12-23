# 🌍 TeraScope - Advanced Weather & Safety App

**TeraScope Pro** is a comprehensive Flutter mobile application designed to provide real-time weather monitoring, environmental intelligence, and location-based services. The app features intelligent AI-powered predictions, farmer-specific agricultural insights, traveler safety tools, and commute optimization.

---

## ✨ Key Features

### 🏠 **Core Dashboard**

- Real-time weather data with live updates (auto-refresh every 30 seconds)
- Current temperature, humidity, air quality index (AQI), and weather conditions
- 24-hour and 7-day weather forecasts with interactive charts
- Location-based weather data with automatic city detection

### 🚜 **Farmer Mode**

- **Crop Health Monitoring** – Track crop conditions and health status
- **Crop Recommendations** – AI-driven suggestions based on weather and soil data
- **Soil Analysis** – Detailed soil composition and fertility insights
- **Crop Suitability** – Find optimal crops for your region
- **Weather Alerts** – Receive critical weather notifications for agricultural safety
- **Farmer-specific Weather Details** – Wind speed, soil moisture, and agricultural metrics

### 🧳 **Traveler Mode**

- Safe route recommendations with hazard alerts
- Location-based travel safety information
- Weather impact on travel routes

### 🚗 **Commute Mode**

- Commute optimization based on weather conditions
- Real-time traffic and weather integration
- Safe departure time recommendations

### 🤖 **AI Predictions**

- Machine learning-based weather forecasting
- Anomaly detection for unusual environmental patterns
- AI-powered crop disease prediction

### 📡 **Advanced Features**

- Weather radar integration for precipitation tracking
- Anomaly detection for unusual weather patterns
- Device-specific optimizations
- Notification service with Firebase Cloud Messaging
- Dark mode support with automatic theme switching
- Google Maps integration for location services

---

## 🛠 Tech Stack

| Component            | Technology                          |
| -------------------- | ----------------------------------- |
| **Framework**        | Flutter                             |
| **Language**         | Dart (3.0+)                         |
| **State Management** | Provider                            |
| **Backend**          | Custom REST API + Firebase          |
| **Database**         | Firestore (Cloud)                   |
| **Authentication**   | Firebase Auth                       |
| **Notifications**    | Firebase Cloud Messaging            |
| **Maps**             | Google Maps, Flutter Map            |
| **Location**         | Geolocator, Geocoding               |
| **Charts**           | FL Chart                            |
| **Storage**          | Firebase Storage, SharedPreferences |

---

## 📁 Project Structure

```
lib/
├── main.dart                 # App entry point & Firebase setup
├── Screens/                  # UI Screens
│   ├── home_screen.dart      # Main dashboard
│   ├── farmer/               # Farmer mode screens
│   ├── traveler/             # Traveler mode screens
│   ├── commute/              # Commute mode screens
│   ├── ai_mode/              # AI prediction screens
│   ├── radar_screen.dart     # Weather radar
│   ├── anomalies_screen.dart # Anomaly detection
│   └── settings_screen.dart  # User preferences
├── Services/                 # API & Business Logic
│   ├── weather_services.dart       # Weather data fetching
│   ├── crop_service.dart           # Crop recommendations
│   ├── soil_service.dart           # Soil analysis
│   ├── ai_predict_service.dart     # AI predictions
│   ├── anomaly_service.dart        # Anomaly detection
│   ├── aqi_service.dart            # Air quality index
│   ├── location_service.dart       # Location services
│   ├── notification_service.dart   # Push notifications
│   └── radar_service.dart          # Weather radar
├── models/                   # Data Models
│   ├── weather_model.dart
│   └── forecast_model.dart
├── providers/                # State Management
│   └── mode_provider.dart    # Theme & mode switching
├── Widgets/                  # Reusable UI Components
├── pages/                    # Detailed pages
├── popups/                   # Dialog & popup components
├── utils/                    # Utilities & helpers
└── assets/                   # Images, JSON, and resources
```

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.0+
- Dart 3.0+
- Android SDK or iOS SDK
- Firebase project with Firestore, Auth, and Cloud Messaging enabled

### Installation

1. **Clone the repository**

   ```bash
   git clone https://github.com/ajilaries/TerraScope-APP.git
   cd terra_scope_apk
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Configure Firebase**

   - Add your `google-services.json` to `android/app/`
   - Add your Firebase project configuration to `lib/firebase_options.dart`

4. **Set up environment variables**

   - Create a `.env` file in the project root
   - Add required API keys and backend URLs:
     ```
     BACKEND_URL=http://your-backend-url:8000
     WEATHER_API_KEY=your-api-key
     MAPS_API_KEY=your-google-maps-key
     ```

5. **Run the app**
   ```bash
   flutter run
   ```

---

## 🔑 Key Services

### Weather Service

- Fetches real-time weather with 20-second caching
- Returns temperature, humidity, AQI, and forecast data
- Handles location-based requests with automatic city detection

### Crop Service

- Provides crop recommendations based on location
- Stores and retrieves crop suitability data from Firestore
- Supports India-focused crop database (crops_india.json)

### AI Prediction Service

- Machine learning-based weather forecasting
- Crop disease and weather anomaly detection
- Backend integration for complex computations

### Location Service

- GPS-based location tracking
- Reverse geocoding for city name retrieval
- Permission handling for location access

---

## 🎨 UI/UX Features

- **Responsive Design** – Optimized for various screen sizes
- **Dynamic Theming** – Seamless light/dark mode switching
- **Real-time Updates** – Auto-refresh with timer-based polling
- **Interactive Charts** – FL Chart for weather trends visualization
- **Weather Icons** – Comprehensive weather condition icons
- **Smooth Navigation** – Intuitive bottom navigation and page navigation

---

## 🔐 Security & Permissions

- Firebase Authentication for user management
- Firestore security rules for data protection
- Location permissions with user consent
- Secure API communication with token-based authentication
- Environment variables for sensitive configuration

---

## 📱 Supported Platforms

- ✅ Android (Primary)
- ✅ iOS
- 🔄 Web (Partial Support)

---

## 🌟 Future Enhancements

- Real-time weather alerts with push notifications
- Historical weather data and trend analysis
- User preferences and favorite locations
- Offline mode with cached data
- Multi-language support
- Advanced analytics dashboard

---

## 🤝 Contributing

Contributions are welcome! To contribute:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License – see the LICENSE file for details.

---

## 👨‍💻 Author

**Ajilaries**  
[GitHub](https://github.com/ajilaries) | [Email](mailto:your-email@example.com)

---

## 📞 Support

For issues, suggestions, or feedback, please open an [issue](https://github.com/ajilaries/TerraScope-APP/issues) or contact the development team.

---

## 🙏 Acknowledgments

- Flutter and Dart communities
- Firebase for backend services
- OpenWeatherMap and weather data providers
- Google Maps for location services
- Contributors and testers
