# Plowee
![version](https://img.shields.io/badge/version-0.7.0-blue)    [![Devpost](https://img.shields.io/badge/Devpost-View_Project-blue)](https://devpost.com/software/plowee?ref_content=my-projects-tab&ref_feature=my_projects)

A set of mobile applications geared for community implementation to solve a massive danger: ice.

![Plowee Logo](packages/plowee/assets/image.png)

## Project Overview
Plowee is a comprehensive snow plow management system that combines mobile applications, IoT devices, and cloud services to provide real-time snow plow tracking and management solutions.

## Technology Stack

### Mobile Applications (Flutter/Dart)
- **Main App (packages/plowee)**
  - Flutter SDK ^3.6.0
  - Features:
    - Real-time GPS tracking
    - Google Maps integration
    - Route management
    - Ice spot detection
    - Search functionality
  
- **Manager App (packages/plowee_manager)**
  - Separate Flutter application for plow operators and managers
  - Fleet management capabilities

### Key Dependencies
- **Frontend**
  - google_maps_flutter: ^2.10.0 (Maps integration)
  - geolocator: ^13.0.2 (Location services)
  - supabase_flutter: ^2.8.3 (Backend integration)
  - http: ^0.13.0 (API communication)

### Backend Services
- **Supabase**
  - Real-time database
  - User authentication
  - Location data storage
  - Fleet management

### IoT Implementation
- **Raspberry Pi**
  - Location tracking module
  - Python-based location sender
  - Real-time GPS data transmission
  - 60-second update intervals

### Core Services
- **Location Service**: Real-time GPS tracking
- **Directions Service**: Route optimization
- **Ice Spot Service**: Hazard detection
- **Places Service**: Location management
- **Plow Service**: Plow operation management

### Project Structure
```bash
packages/
├── plowee/               # Main mobile application
├── plowee_manager/       # Fleet management application
└── raspberry_pi/         # IoT implementation
```

## Features
- Real-time plow tracking
- Route optimization
- Ice spot detection and reporting
- Fleet management dashboard
- GPS location tracking
- Map visualization
- Search and navigation
- ETA calculations

## Getting Started
1. Install Flutter SDK
2. Clone the repository
3. Run `flutter pub get` in both app directories
4. Configure Supabase credentials
5. Set up Raspberry Pi with location sender script

## Development Setup
- Flutter development environment
- Supabase account and credentials
- Google Maps API key
- Raspberry Pi with Python environment

## Contributing
Please refer to individual package documentation for specific contribution guidelines.

## License
[License information pending]