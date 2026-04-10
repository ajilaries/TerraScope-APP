# Terrascope App - Complete Input-Output Design Documentation Prompt

Generate a comprehensive input-output design document for the Terrascope Flutter app. The app is a multi-mode safety and utility application with the following key features:

## App Overview

- **Name**: Terrascope
- **Platform**: Flutter (iOS/Android)
- **Purpose**: Multi-mode app for safety monitoring, farming assistance, care management, travel planning, and daily planning
- **Key Technologies**: Firebase, Location Services, Weather APIs, AI/ML predictions

## Core Architecture

- **State Management**: Provider pattern
- **Authentication**: Firebase Auth with OTP verification
- **Data Sources**: Weather APIs, Location services, Firebase Firestore, Local storage
- **Modes**: Default, Farmer, Safety, Care, Traveler, Daily Planner

## Screen-by-Screen Input-Output Specifications

### 1. Splash Screen

**Purpose**: App initialization and loading screen

**Inputs:**

- App launch trigger
- Firebase initialization status
- Environment loading (.env file)

**Outputs:**

- Animated logo display
- Loading progress indicator
- Navigation to login screen after initialization
- Error handling for initialization failures

**UI Elements:**

- Centered logo with animation
- Loading spinner
- Background gradient
- App version display (optional)

### 2. Login Screen

**Purpose**: User authentication entry point

**Inputs:**

- Email address (text field, required, email validation)
- Password (text field, required, min 6 characters, obscured)
- Login button tap
- "Forgot Password" button tap
- "Create New Account" button tap
- Selected mode parameter (optional, from previous screen)

**Outputs:**

- Form validation messages
- Loading state during authentication
- Success: Navigation to main app with mode activation
- Failure: Error snackbar with message
- Password visibility toggle
- Navigation to forgot password screen
- Navigation to signup screen

**UI Elements:**

- Gradient background
- Logo/icon display
- Email input field with validation
- Password input field with show/hide toggle
- Login button (disabled during loading)
- Forgot password text button
- Sign up prompt with button
- Loading indicator overlay

### 3. Signup Screen

**Purpose**: New user registration with comprehensive profile setup

**Inputs:**

- Name (text field, required)
- Email (text field, required, email validation)
- Password (text field, required, min 6 characters)
- Age (text field, required, numeric)
- Phone (text field, required)
- Address (text field, required)
- Gender (dropdown: male/female/other)
- Emergency contacts (dynamic list):
  - Name, Phone, Email, Type, Notes, Primary flag
- Preferences:
  - Enable notifications (switch)
  - Enable location sharing (switch)
- OTP verification (text field, required after sending)
- Send OTP button tap
- Verify OTP button tap
- Add emergency contact button tap
- Remove emergency contact button tap
- Signup button tap

**Outputs:**

- Form validation messages for each field
- OTP sending confirmation
- OTP verification success/failure
- Emergency contact list management
- Loading states for async operations
- Success: Auto-login and navigation to main app
- Failure: Error messages for validation/server issues
- Dynamic contact form expansion

**UI Elements:**

- Multi-step scrollable form
- Progress indicator for signup steps
- Emergency contacts section with add/remove
- OTP input section (appears after sending)
- Preferences switches
- Back navigation button
- Loading indicators for each async operation

### 4. Main Home Screen (Default Mode)

**Purpose**: Weather dashboard and quick access to app features

**Inputs:**

- Location permission request
- Pull-to-refresh gesture
- Navigation button taps (AI Predict, Safety Mode, Theme toggle)
- Quick access button taps (Radar, Anomalies, Forecast)

**Outputs:**

- Current location display (city name)
- Real-time weather data:
  - Temperature, condition, humidity, wind speed, pressure, visibility
- 7-day weather forecast (day, max/min temp)
- 24-hour weather forecast (time, temperature)
- Air Quality Index (mock data)
- Quick access grid navigation
- Auto-refresh every 30 seconds
- Theme switching (light/dark mode)
- Loading states during data fetch
- Error handling for location/weather API failures

**UI Elements:**

- App bar with theme toggle and action buttons
- Current weather card (large display)
- 7-day forecast horizontal scroll
- 24-hour forecast horizontal scroll
- Weather metrics grid (humidity, wind, pressure, visibility)
- AQI card with color coding
- Quick access grid (3x1 layout)
- Refresh indicator
- Loading spinners for each data section

### 5. Safety Mode Screen

**Purpose**: Real-time safety monitoring with emergency features

**Inputs:**

- Safety mode toggle (switch)
- Tab navigation (Status/Contacts/History/Settings)
- Emergency contact management:
  - Add contact dialog trigger
  - Delete contact confirmation
- Refresh weather data button
- Clear history button

**Outputs:**

- Safety status assessment based on weather parameters
- Real-time weather monitoring (rain, wind, visibility, temperature, humidity)
- Safety alerts and recommendations
- Emergency contacts list display
- Safety history log
- Weather parameter cards (rainfall, wind speed, visibility, temperature, humidity)
- Status change notifications
- Loading states for data operations

**UI Elements:**

- Tab bar navigation (4 tabs)
- Safety mode toggle with status indicator
- Detailed safety status card
- Emergency contacts list with management
- Safety history timeline
- Weather parameters display cards
- Recommendations list based on hazard level
- Alert dialogs for safety warnings

### 6. Farmer Dashboard

**Purpose**: Agricultural assistance with weather, soil, and crop data

**Inputs:**

- Location coordinates (latitude/longitude)
- Drawer navigation menu taps
- Quick action button taps (Crop Health, Recommendations)
- Weather details view tap
- Soil analysis view tap
- Crop suitability view tap
- Alerts view tap

**Outputs:**

- Current location and soil type display
- Real-time weather data (temperature, condition, humidity, wind)
- 7-day weather forecast with humidity
- AI crop recommendations with suitability scores
- Soil analysis data
- Weather alerts and warnings
- Navigation to specialized screens

**UI Elements:**

- Animated header with location/weather
- Quick action buttons (2-column grid)
- AI recommendations list with progress bars
- Weekly forecast horizontal scroll
- Soil status card with tap navigation
- Alerts section with warning icons
- Drawer menu with navigation options

### 7. Care Dashboard

**Purpose**: Health and care management for elderly/disabled users

**Inputs:**

- Daily activities management
- Emergency contacts management
- Health reminders setup
- Medication tracking
- Nearby services search
- SOS button activation

**Outputs:**

- Daily activities list with completion status
- Emergency contacts display
- Health reminders notifications
- Medication schedule and tracking
- Nearby services (hospitals, pharmacies, etc.)
- SOS emergency activation

**UI Elements:**

- Dashboard cards for different care aspects
- Activity lists with checkboxes
- Contact management interface
- Reminder scheduling interface
- Medication tracker with time indicators
- Services map/location display

### 8. Traveler Dashboard

**Purpose**: Travel planning and safety for travelers

**Inputs:**

- Destination location input
- Travel dates and preferences
- Safety alerts for travel areas
- Weather forecasts for destinations
- Emergency contacts for travel

**Outputs:**

- Destination weather and safety information
- Travel route planning
- Safety recommendations for travel
- Emergency contact management
- Travel alerts and notifications

**UI Elements:**

- Destination search and selection
- Weather forecast for travel period
- Safety status indicators
- Route planning interface
- Emergency contact setup

### 9. Daily Planner Dashboard

**Purpose**: Personal daily planning and task management

**Inputs:**

- Task creation and editing
- Schedule management
- Reminder settings
- Location-based planning

**Outputs:**

- Daily task lists
- Schedule display
- Reminder notifications
- Progress tracking
- Location-based suggestions

**UI Elements:**

- Calendar view
- Task lists with priorities
- Time scheduling interface
- Progress indicators
- Reminder management

### 10. Additional Screens

#### Radar Screen

**Inputs:** Location coordinates, zoom level, map interactions
**Outputs:** Weather radar overlay on map, precipitation data visualization

#### Anomalies Screen

**Inputs:** Location coordinates, date range selection
**Outputs:** Weather anomaly detection, historical data analysis

#### Forecast Dashboard

**Inputs:** Location selection, date picker, forecast type selection
**Outputs:** Detailed weather forecasts, charts and graphs

#### Emergency Contacts Screen

**Inputs:** Contact information forms, contact type selection
**Outputs:** Contact list management, emergency calling interface

#### Settings Screen

**Inputs:** User preferences, notification settings, privacy controls
**Outputs:** Settings persistence, UI theme changes

## Data Flow Specifications

### Input Validation Rules

- Email: Standard email regex validation
- Password: Minimum 6 characters
- Phone: Country-specific format validation
- Age: Numeric, reasonable range (1-120)
- Location: GPS coordinates validation
- Weather data: API response validation

### Output Data Structures

#### Weather Data

```json
{
  "temperature": 25.5,
  "condition": "Partly Cloudy",
  "humidity": 65,
  "wind_speed": 12.5,
  "pressure": 1013,
  "visibility": 10000,
  "rain_mm": 0.0
}
```

#### Safety Status

```json
{
  "level": "safe|caution|danger",
  "message": "Current safety assessment",
  "recommendations": ["Stay indoors", "Prepare emergency kit"]
}
```

#### Emergency Contact

```json
{
  "id": "unique_id",
  "name": "John Doe",
  "phone": "+1234567890",
  "email": "john@example.com",
  "type": "family|friend|medical",
  "notes": "Primary contact",
  "isPrimary": true
}
```

### Error Handling

- Network connectivity issues
- API failures with retry mechanisms
- Location permission denials
- Invalid input data
- Authentication failures

### Performance Considerations

- Auto-refresh intervals (30 seconds for weather)
- Data caching strategies
- Loading states for all async operations
- Progressive data loading
- Memory management for large datasets

## User Interaction Patterns

### Navigation Flow

1. App Launch → Splash → Login/Signup
2. Authentication → Mode Selection → Dashboard
3. Dashboard → Feature Screens → Back Navigation
4. Emergency → Direct SOS activation

### Gesture Support

- Pull-to-refresh on main screens
- Swipe gestures for tab navigation
- Tap interactions for buttons and cards
- Long-press for context menus

### Accessibility Features

- Screen reader support
- High contrast mode
- Large text options
- Voice commands for emergency features

## API Integration Points

### Weather Services

- Current weather endpoint
- Forecast endpoint (7-day, 24-hour)
- Historical data for anomalies

### Location Services

- GPS coordinate retrieval
- Geocoding (coordinates to place names)
- Reverse geocoding

### Firebase Services

- Authentication (login/signup)
- Firestore for user data
- Cloud Messaging for notifications
- Storage for user files

### AI/ML Services

- Crop recommendation models
- Anomaly detection algorithms
- Safety assessment models

## Security Considerations

### Data Protection

- Encrypted local storage
- Secure API communications
- User permission management
- Privacy controls for location sharing

### Emergency Features

- Direct emergency calling
- Location sharing in emergencies
- Offline functionality for critical features

Please generate a detailed INPUT-OUTPUT DESIGN document that covers all these aspects with:

1. Detailed screen-by-screen specifications
2. Input validation rules and error handling
3. Output data structures and formats
4. User interaction flows
5. API integration details
6. Security and privacy considerations
7. Performance optimization guidelines

Include code examples, data flow diagrams descriptions, and implementation guidelines for each major component.
