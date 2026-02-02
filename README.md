# 🌍 TerraScope - Advanced Weather & Safety App

**TerraScope Pro** is a comprehensive Flutter mobile application designed to provide real-time weather monitoring, environmental intelligence, and location-based services. The app features intelligent AI-powered predictions, farmer-specific agricultural insights, traveler safety tools, commute optimization, daily planner functionality, and kids/senior care mode.

---

## 📋 Recent Updates

### 🔗 Navigation Improvements (Latest)

- **Login/Signup Navigation**: Added reciprocal navigation links between login and signup pages for improved user experience, allowing seamless switching between authentication screens

### 🚜 Farmer Mode Enhancements (Latest)

- **Fixed Frame Overflow Issues**: Resolved bottom overflow problems in the weekly forecast section by optimizing the SizedBox height from 110px to 170px
- **Real Soil Type Integration**: Implemented ISRIC SoilGrids API integration to fetch actual soil texture data based on user location coordinates
- **Dynamic Soil Type Display**: Soil type now displays real data (Clay, Loam, Sand, etc.) instead of static "Unknown" placeholder
- **Enhanced UI Layout**: Improved weekly forecast layout with better spacing and responsive design

### 👶 Kids/Senior Care Mode (Latest)

- **Complete Implementation**: Successfully implemented comprehensive care mode with 8 screens including dashboard, emergency contacts, SOS functionality, health reminders, medication tracker, hydration tracker, daily activities, nearby services, and family contacts
- **Accessibility Features**: Large, accessible UI elements with high contrast colors and clear icons for ease of use
- **Emergency SOS**: Large-button SOS screen with location sharing capabilities
- **Health Tracking**: Medication schedules, water intake monitoring, and activity reminders
- **Offline Persistence**: Data stored using SharedPreferences for offline functionality

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
- **Soil Analysis** – Detailed soil composition and fertility insights with real-time soil type detection
- **Crop Suitability** – Find optimal crops for your region
- **Weather Alerts** – Receive critical weather notifications for agricultural safety
- **Farmer-specific Weather Details** – Wind speed, soil moisture, and agricultural metrics
- **Weekly Forecast** – 7-day weather forecast with optimized UI layout (fixed frame overflow issues)
- **Real Soil Type Integration** – Uses ISRIC SoilGrids API to fetch actual soil texture data based on location coordinates

### 🧳 **Traveler Mode**

- Safe route recommendations with hazard alerts
- Location-based travel safety information
- Weather impact on travel routes

### 📅 **Daily Planner Mode**

- Daily activity planning based on weather conditions
- Real-time weather integration for outdoor activities
- Safe timing recommendations for daily tasks
- Weather-optimized scheduling for work and leisure

### 🚗 **Commute Mode**

- Real-time commute alerts and notifications
- Interactive commute dashboard with route planning
- Quick actions for emergency situations during commute
- Route preview with weather integration
- Mini weather display for commute planning

### 🚨 **Safety Mode**

- **Emergency Contacts Management** – Add, edit, and manage emergency contacts with quick dial functionality
- **Real-time Safety Monitoring** – Continuous monitoring of user safety status based on location and environmental factors
- **Safety Recommendations** – AI-driven safety suggestions and alerts based on weather, location, and user activity
- **Firebase Cloud Messaging (FCM)** – Push notifications for safety alerts and emergency communications
- **Offline Safety Features** – Emergency functionality available without internet connection
- **Safety History & Status Tracking** – Log and review past safety incidents and current safety status
- **Emergency Service Integration** – Direct access to emergency services and providers

### 👶 **Kids/Senior Care Mode**

- **Care Dashboard** – Simplified weather display with safety alerts and health reminders
- **Emergency Contacts** – Dedicated emergency contact management for caregivers
- **SOS Functionality** – Large-button SOS screen with location sharing capabilities
- **Health Reminders** – Medication schedules, hydration tracking, and exercise reminders
- **Medication Tracker** – Track medication schedules and dosages
- **Hydration Tracker** – Monitor daily water intake
- **Daily Activities** – Activity tracking and reminders for daily routines
- **Nearby Services** – Find hospitals, pharmacies, and clinics nearby
- **Family Contacts** – Quick communication with family members
- **Accessibility Features** – Large, accessible UI elements with high contrast colors and clear icons

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
  Displays essential weather & climate information at a glance with auto-refresh every 30 seconds

- 📍 **Location-Based Data**
  Automatically fetches environmental stats for the user’s current location with GPS tracking

- ☁️ **Live API Integration**
  Real-time data such as:
  - Temperature, humidity, and weather conditions
  - Air quality index (AQI) with color-coded indicators
  - 24-hour and 7-day forecasts with interactive charts

- 🚜 **Farmer Mode**
  Complete agricultural interface with:
  - Real soil type detection using ISRIC SoilGrids API
  - Optimized weekly forecast layout (fixed overflow issues)
  - Dynamic crop recommendations and health monitoring
  - Enhanced UI with better spacing and responsive design

- 👶 **Kids/Senior Care Mode**
  Comprehensive care interface featuring:
  - 8 dedicated screens for health tracking and safety
  - Large, accessible UI elements with high contrast
  - Emergency SOS with location sharing capabilities
  - Medication and hydration trackers with offline persistence
  - Family contacts and nearby services integration

- 🚨 **Safety Mode**
  Professional 4-tab safety interface including:
  - Real-time monitoring with risk scoring (0-100)
  - Interactive parameter sliders for hazard assessment
  - Emergency contacts management with quick dial
  - Safety history tracking with 50-record limit
  - Animated SOS screen with countdown timer

- 🎨 **Advanced UI/UX**
  Motion-first design with:
  - Smooth animations and gesture-based navigation
  - Responsive layouts optimized for all screen sizes
  - Dark mode support with automatic theme switching
  - Interactive FL Chart visualizations for weather trends
  - Comprehensive weather icons and status indicators

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
├── Screens/                  # UI Screens
│   ├── care/                 # Kids/Senior care mode screens
│   ├── farmer/               # Farmer mode screens
│   ├── traveler/             # Traveler mode screens
│   ├── daily_planner/        # Daily planner mode screens
│   ├── safety/               # Safety mode screens
│   ├── commute/              # Commute mode screens
│   ├── ai_mode/              # AI prediction screens
│   └── radar/                # Weather radar and anomalies
├── Services/                 # API & Business Logic
│   ├── weather_services.dart # Weather-related services
│   ├── crop_service.dart     # Crop and soil services
│   ├── ai_predict_service.dart # AI prediction services
│   ├── location_service.dart # Location services
│   ├── safety_monitoring_service.dart # Safety monitoring services
│   ├── notification_service.dart # Notification services
│   ├── auth_service.dart     # Authentication services
│   └── more...               # Additional services
├── models/                   # Data Models
├── providers/                # State Management
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

- **Responsive Design** – Optimized for various screen sizes (phones, tablets, landscape/portrait)
- **Dynamic Theming** – Seamless light/dark mode switching with automatic theme detection
- **Real-time Updates** – Auto-refresh with timer-based polling (30-second intervals)
- **Interactive Charts** – FL Chart for weather trends with gesture-based interactions
- **Weather Icons** – Comprehensive weather condition icons with animated states
- **Smooth Navigation** – Intuitive bottom navigation with gesture-based page transitions
- **Motion-First Design** – Smooth animations and micro-interactions throughout the app
- **Accessibility Features** – Large UI elements, high contrast colors, and clear icons for care mode
- **Professional Safety Interface** – 4-tab layout with interactive sliders and status indicators
- **Agricultural UI Enhancements** – Fixed overflow issues, optimized layouts, and real soil data integration
- **Care Mode Accessibility** – Large-button SOS, simplified dashboards, and offline persistence
- **Multi-Mode Architecture** – Seamless switching between farmer, safety, care, and other modes

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
[GitHub](https://github.com/ajilaries) | [Email](ajilaries20@gmail.com)

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
