🌦️ Terrascope — Smart Weather & Safety Assistant

Terrascope is a next-gen weather and anomaly-detection app built using Flutter with a cloud-powered backend.
It goes beyond basic weather reports — Terrascope actually predicts anomalies, alerts users, and adapts to different lifestyles using specialized modes.

🚀 Features
🔹 🌤️ Real-Time Weather

Live temperature, humidity, wind, rainfall

Accurate geolocation

Auto-refresh system

🔹 🔍 AI-Powered Predictions

Backend ML model detects anomalies

Spike detection for rainfall, storms, unusual temperatures

Instant predictive alerts

🔹 📢 Cloud Notifications

Push notifications via FCM

Location-based alerts

Alerts stored inside an “Alerts” section

🔹 🎛 Modes

Terrascope adapts depending on who’s using it:

Default Mode → simple weather + AI predictions

Traveller Mode → route safety, travel weather, warnings

Farmer Mode → crop-friendly insights, rainfall alerts, soil moisture forecasting

Safety Mode → emergency features + SOS integration

Kids/Senior Mode → simplified UI, clear alerts

Commute Mode → daily travel weather, bus/train safety

Each mode shows different UI elements & functionalities.

🧠 Tech Stack
📱 Frontend

Flutter

Clean UI

Multiple dashboards

Location services

Mode-based navigation

☁️ Backend

Python (depending on the module)

Weather API integration

AI anomaly detection engine

MongoDB / Firebase / MySQL (your choice)

Firebase Cloud Messaging for push notifications

📡 How Terrascope Works

User opens Terrascope

App fetches current location

Backend fetches real-time + historical weather

ML engine checks for anomalies

If anomaly detected → send FCM notification

User sees live alerts + AI predictions

🛠 Project Structure (Flutter)
lib/
 ├── Screens/
 │    ├── default/
 │    ├── traveller/
 │    ├── farmer/
 │    ├── commute/
 │    ├── safety/
 │    └── care/
 ├── services/
 │    ├── weather_api.dart
 │    ├── ai_predict_service.dart
 │    └── location_service.dart
 ├── popups/
 ├── widgets/
 └── main.dart

🔥 Upcoming Features

Radar + live weather maps

Travel/farming/commute modes with personalised insights

Offline mode

Air quality monitoring (AQI)

Admin panel for anomaly management


📲 Installation
Clone the repo:
git clone https://github.com/yourusername/terrascope.git

Install packages:
flutter pub get

Run:
flutter run

🧪 Backend Setup

Deploy backend on Render / Railway / Fly.io

Get your production URL

Update API base URL in ai_predict_service.dart and weather service

Configure Firebase for push notifications

🤝 Contributing

Pull requests are welcome!
Make sure to:

git pull origin main
git checkout -b feature-name


Submit your PR with a clean commit message.

📄 License

MIT License — free to use, modify, and build on.
