# jan_aushadhi_sarthak

an app to find generic medicine

## Getting Started

# Jan Aushadhi Sarthak

A Flutter mobile application that helps patients find generic medicine alternatives from Jan Aushadhi stores by parsing medical prescriptions.

## Features

### 🔍 Prescription Parsing

- Upload prescription images (JPG, PNG, JPEG) or PDF files
- Extract medicine names using OCR technology
- User verification and editing of extracted medicines

### 💊 Medicine Database

- Find generic alternatives for commercial medicines
- Check availability in Jan Aushadhi stores
- Compare prices between branded and generic medicines
- Calculate potential savings

### 🏪 Store Locator

- Find nearby Jan Aushadhi stores
- Get contact information and directions
- Check medicine availability at specific stores

### 📱 User-Friendly Interface

- Clean, intuitive design
- Step-by-step workflow
- Real-time processing feedback
- Error handling and validation

## Project Structure

```
lib/
├── main.dart                    # App entry point
├── splashscreen.dart           # Initial splash screen
├── filepicker_page.dart        # Prescription upload page
├── medicine_extraction_page.dart # Medicine verification page
├── models/
│   └── medicine_model.dart     # Data models
└── services/
    └── prescription_service.dart # OCR and database services
```

## Current Status

### ✅ Completed

- [x] Splash screen with app branding
- [x] File picker for prescription upload
- [x] Medicine extraction and verification UI
- [x] Basic navigation flow
- [x] Data models and service structure

### 🚧 In Progress

- [ ] OCR integration for image processing
- [ ] PDF text extraction
- [ ] Medicine database integration
- [ ] Jan Aushadhi API integration

### 📋 Planned Features

- [ ] Generic alternatives search
- [ ] Price comparison
- [ ] Store locator with maps
- [ ] Savings calculator
- [ ] User preferences and history
- [ ] Offline mode support

## Technical Implementation

### OCR Integration Options

- **Google ML Vision**: For image text recognition
- **Firebase ML Kit**: Cloud-based OCR
- **Tesseract OCR**: Open-source OCR engine
- **Custom API**: Backend OCR service

### Database Options

- **Local SQLite**: For offline medicine database
- **Firebase Firestore**: Real-time cloud database
- **REST API**: Custom backend integration
- **CSV/JSON**: Static data files

### Jan Aushadhi Integration

- Official Jan Aushadhi API (if available)
- Web scraping (with appropriate permissions)
- Manual database creation
- Government data sources

## Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Android Studio / VS Code
- Android SDK for Android development
- Xcode for iOS development (Mac only)

### Installation

1. Clone the repository
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run the app:
   ```bash
   flutter run
   ```

### Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  file_picker: ^10.2.0
  cupertino_icons: ^1.0.8

  # Future dependencies for OCR and database
  # google_ml_vision: ^0.0.13
  # firebase_ml_vision: ^0.12.0
  # sqflite: ^2.3.0
  # http: ^1.1.0
```

## Screenshots

[Add screenshots here showing the app workflow]

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## Roadmap

### Phase 1: Core Functionality

- Complete OCR integration
- Basic medicine database
- Generic name lookup

### Phase 2: Enhanced Features

- Jan Aushadhi store integration
- Price comparison
- Savings calculator

### Phase 3: Advanced Features

- Store locator with maps
- User accounts and history
- Push notifications
- Offline mode

## Impact

This app aims to:

- **Reduce Healthcare Costs**: Help patients save money on medicines
- **Increase Accessibility**: Make generic medicines more discoverable
- **Support Government Initiative**: Promote Jan Aushadhi scheme
- **Improve Healthcare**: Make medicines more affordable for all

## License

[Add your license here]

## Contact

[Add your contact information]

---

**Jan Aushadhi Sarthak** - Making healthcare affordable through technology.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
