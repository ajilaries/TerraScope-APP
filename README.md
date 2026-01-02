# 🌍 TerraScope - Advanced Weather & Safety App

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

### 🚨 **Safety Mode**

- **Emergency Contacts Management** – Add, edit, and manage emergency contacts with quick dial functionality
- **Real-time Safety Monitoring** – Continuous monitoring of user safety status based on location and environmental factors
- **Safety Recommendations** – AI-driven safety suggestions and alerts based on weather, location, and user activity
- **Firebase Cloud Messaging (FCM)** – Push notifications for safety alerts and emergency communications
- **Offline Safety Features** – Emergency functionality available without internet connection
- **Safety History & Status Tracking** – Log and review past safety incidents and current safety status
- **Emergency Service Integration** – Direct access to emergency services and providers

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

<div align="center">

<img src="https://readme-typing-svg.demolab.com?font=Fira+Code&size=28&duration=3000&pause=800&color=3DDC84&center=true&vCenter=true&width=800&lines=TerraScope+🌍;Explore+Earth+%7C+Understand+Climate;Flutter-powered+Climate+Intelligence+App" />

<br/>

<img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" />
<img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" />
<img src="https://img.shields.io/badge/Platform-Android-green?style=for-the-badge" />
<img src="https://img.shields.io/badge/Status-Active%20Development-orange?style=for-the-badge" />

<br/><br/>

**Explore Earth. Understand Climate. Stay Ahead.**

TerraScope is a **Flutter-powered mobile app** that lets users explore and monitor Earth’s climate and environmental data through a **clean, intuitive, and modern UI**. It delivers **real-time, location-aware insights** with smooth interactions and scalable architecture.

</div>

---

## ✨ Highlights

- 🚀 Fast, smooth Flutter UI
- 📍 Smart location-based environmental data
- ☁️ Real-time API-driven weather insights
- 🎨 Minimal, modern design language
- 🧩 Built to scale with advanced features

---

## 🖼️ Live Preview & Animations

<div align="center">

<img src="https://user-images.githubusercontent.com/placeholder/app-demo.gif" width="260" />
<img src="https://user-images.githubusercontent.com/placeholder/weather-card.gif" width="260" />
<img src="https://user-images.githubusercontent.com/placeholder/location-fetch.gif" width="260" />

</div>

> 🎞️ Smooth transitions, animated weather cards, live location loading, and gesture-based navigation

---

## 🚀 Features (Animated UX)

✨ Designed with motion-first UI principles

### ✅ Current

- 🏠 **Home Dashboard**
  Displays essential weather & climate information at a glance

- 📍 **Location-Based Data**
  Automatically fetches environmental stats for the user’s current location

- ☁️ **Live API Integration**
  Real-time data such as:

  - Temperature
  - Humidity
  - Weather conditions
  - Air quality (API dependent)

- 🚨 **Safety Mode**
  Comprehensive safety features including emergency contacts, real-time monitoring, and offline capabilities

- 🎨 **Minimal UI/UX**
  Clean layouts, smooth animations, and responsive design

---

### 🔮 Planned Features

- 📊 Interactive climate graphs & historical trends
- 🌙 Dark mode support
- ⭐ Favorite & saved locations
- 📴 Offline mode for cached locations
- 🔔 Climate anomaly alerts & notifications
- 🗺️ Advanced maps & radar layers

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
│   ├── saftey/               # Safety mode screens
│   ├── ai_mode/              # AI prediction screens
│   ├── radar_screen.dart     # Weather radar
│   ├── anomalies_screen.dart # Anomaly detection
│   ├── emergency_contacts_screen.dart # Emergency contacts management
│   └── settings_screen.dart  # User preferences
├── Services/                 # API & Business Logic
│   ├── weather_services.dart             # Weather data fetching
│   ├── crop_service.dart                 # Crop recommendations
│   ├── soil_service.dart                 # Soil analysis
│   ├── ai_predict_service.dart           # AI predictions
│   ├── anomaly_service.dart              # Anomaly detection
│   ├── aqi_service.dart                  # Air quality index
│   ├── location_service.dart             # Location services
│   ├── notification_service.dart         # Push notifications
│   ├── radar_service.dart                # Weather radar
│   ├── safety_monitoring_service.dart    # Real-time safety monitoring
│   ├── safety_recommendation_service.dart # Safety recommendations
│   ├── saftey_service.dart               # Safety services
│   ├── fcm_service.dart                  # Firebase Cloud Messaging
│   ├── offline_service.dart              # Offline functionality
│   └── auth_service.dart                 # Authentication services
├── models/                   # Data Models
│   ├── weather_model.dart
│   ├── forecast_model.dart
│   ├── safety_alert.dart
│   ├── saftey_status.dart
│   └── emergency_contact.dart
├── providers/                # State Management
│   ├── mode_provider.dart    # Theme & mode switching
│   ├── safety_provider.dart  # Safety state management
│   └── emergency_provider.dart # Emergency contacts provider
├── Widgets/                  # Reusable UI Components
│   ├── safety_history_card.dart
│   ├── saftey_card.dart
│   ├── detailed_safety_card.dart
│   ├── emergency_contact_card.dart
│   └── add_contact_dialog.dart
├── pages/                    # Detailed pages
├── popups/                   # Dialog & popup components
├── utils/                    # Utilities & helpers
│   ├── safety_notification_manager.dart
│   ├── safety_utils.dart
│   └── background_helper.dart
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

### Safety Monitoring Service

- Real-time safety status monitoring based on location and environmental data
- Continuous background safety checks and alerts
- Integration with emergency services for rapid response

### Safety Recommendation Service

- AI-driven safety suggestions based on weather, location, and user activity
- Personalized safety alerts and recommendations
- Risk assessment for various scenarios

### FCM Service

- Firebase Cloud Messaging for push notifications
- Safety alerts and emergency notifications
- Real-time communication for critical updates

### Offline Service

- Emergency functionality without internet connectivity
- Cached safety data and offline emergency contacts
- Background safety monitoring in offline mode

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
