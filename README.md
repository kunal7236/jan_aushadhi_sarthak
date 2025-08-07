# Jan Aushadhi Sarthak

A comprehensive Flutter mobile application that helps patients find generic medicine alternatives from Jan Aushadhi stores by parsing medical prescriptions using advanced OCR technology.

## 📺 Demo Video

[![Jan Aushadhi Sarthak Demo](https://img.youtube.com/vi/bdGntc3mU3g/0.jpg)](https://youtu.be/bdGntc3mU3g)

🎥 **Watch the full demo**: [https://youtu.be/bdGntc3mU3g](https://youtu.be/bdGntc3mU3g)

## ✨ Currently Available Features

### � **Prescription Processing**

- ✅ **Image & PDF Upload**: Support for JPG, PNG, JPEG, and PDF files
- ✅ **Advanced OCR Integration**: Real Google ML Kit Text Recognition v0.13.0
- ✅ **Smart Medicine Extraction**: Automatic extraction of medicine names from prescriptions
- ✅ **User Verification System**: Manual editing and verification of extracted medicines
- ✅ **Responsive UI**: SingleChildScrollView with keyboard overflow protection

### � **Medicine Search & Database**

- ✅ **Real Jan Aushadhi API Integration**: Live medicine database search
- ✅ **Manual Search Control**: User-controlled prescription medicine searching
- ✅ **Smart 404 Handling**: User-friendly "not available" messages instead of error codes
- ✅ **Visual Search Progress**: Color-coded chips showing search results
  - 🟢 Green: Medicine found in Jan Aushadhi stores
  - 🔴 Red: Medicine not available
  - 🟠 Orange: Currently being searched
  - 🔵 Blue: Not searched yet
- ✅ **Detailed Medicine Information**: Drug codes, generic names, unit sizes, and MRP
- ✅ **Search Results Summary**: Found vs not available count

### 🏪 **Store Locator & Navigation**

- ✅ **Comprehensive Store Search**: Search by pincode, location name, or Kendra code
- ✅ **Real Kendra API Integration**: Live Jan Aushadhi store database
- ✅ **Smart Address Enhancement**: Combines address, pincode, district, and state
- ✅ **Call Functionality**: Direct phone dialer integration with proper permissions
- ✅ **Google Maps Integration**:
  - Get directions with fallback support
  - Start navigation with geo URI
  - Show location on maps
- ✅ **Flexible Address Validation**: Works with various Indian address formats
- ✅ **User Feedback System**: Loading states, error handling, and success messages

### 🎨 **User Experience**

- ✅ **Medical-Themed UI**: Green color scheme with healthcare iconography
- ✅ **Error Handling**: Comprehensive API error handling with user-friendly messages
- ✅ **Loading States**: Visual feedback during API calls and processing
- ✅ **Responsive Design**: Adapts to different screen sizes and orientations
- ✅ **Accessibility**: Clear icons, readable fonts, and intuitive navigation

## 📋 Version History

### Version 1.0.0 (Current) - Optimized Release

**Release Date**: December 2024

#### 🚀 **Major Optimizations**

- **APK Size Reduced**: From 122MB to 17.5-19MB per architecture (85% reduction)
- **Architecture Splitting**: Split APKs for different CPU architectures
- **Dependency Cleanup**: Removed unused packages for better performance
- **Build Configuration**: Simplified build process for stability
- **Proper App Signing**: Production-ready signed APKs for release

#### 🔧 **Technical Improvements**

- Removed `cupertino_icons` dependency (reduced size)
- Removed `image_picker` dependency (not used in current version)
- Optimized build.gradle configuration
- Implemented split-per-ABI APK generation
- Added proper release signing configuration

#### 📱 **APK Variants Available** (All Properly Signed)

**Naming Convention**: `Jan-Aushadhi-Sarthak-v1.0.0-[architecture]-release.apk`

- `Jan-Aushadhi-Sarthak-v1.0.0-arm64-release.apk` - For modern 64-bit ARM devices (18.8 MB)
  - **Best for**: Most modern Android phones (2019+), Samsung Galaxy, Google Pixel, OnePlus, etc.
  - **Architecture**: ARM64-v8a (64-bit ARM)
  
- `Jan-Aushadhi-Sarthak-v1.0.0-arm32-release.apk` - For older 32-bit ARM devices (17.5 MB)  
  - **Best for**: Older Android phones and budget devices
  - **Architecture**: ARMv7a (32-bit ARM)
  
- `Jan-Aushadhi-Sarthak-v1.0.0-x86_64-release.apk` - For x86_64 emulators/devices (19.0 MB)
  - **Best for**: Android emulators on PC, Intel-based tablets
  - **Architecture**: x86_64 (64-bit Intel/AMD)
  
- `Jan-Aushadhi-Sarthak-v1.0.0-universal-release.apk` - Universal APK (all architectures) (44.3 MB)
  - **Best for**: When unsure about device architecture, includes all CPU types
  - **Architecture**: Universal (ARM32, ARM64, x86, x86_64)

## 🏗️ Technical Architecture

### **Dependencies & Integrations**

```yaml
dependencies:
  flutter: sdk
  file_picker: ^10.2.0 # File upload functionality
  google_mlkit_text_recognition: ^0.13.0 # OCR processing
  http: ^1.1.0 # API communication
  url_launcher: ^6.2.0 # Phone calls & navigation
  # Optimized: Removed unused dependencies (cupertino_icons, image_picker)
```

### **API Integrations**

- **Jan Aushadhi Medicine API**: `https://medicine-api-m176.onrender.com`
- **Kendra Store Locator API**: `https://kendra-api.onrender.com`
- **Google Maps Integration**: Directions, navigation, and location display

### **Project Structure**

```
lib/
├── main.dart                           # App entry point
├── splashscreen.dart                  # Splash screen with branding
├── filepicker_page.dart               # Prescription upload interface
├── medicine_extraction_page.dart      # OCR processing & verification
├── medicine_search_page.dart          # Jan Aushadhi medicine search
├── store_locator_page.dart           # Store finder with call/directions
├── services/
│   ├── janaushadhi_api_service.dart  # Medicine database API
│   └── kendra_api_service.dart       # Store locator API
└── utils/
    ├── phone_utils.dart              # Phone call functionality
    ├── directions_utils.dart         # Google Maps integration
    └── action_utils.dart             # Centralized action handling
```

## 🚀 Future Planned Features

### � **Enhanced Medicine Management**

- [ ] Medicine cart/wishlist functionality
- [ ] Medicine alternatives suggestions
- [ ] Medicine interaction warnings

### � **Cost Analysis**

- [ ] Savings calculator (branded vs generic)

### 🗺️ **Advanced Location Features**

- [ ] Store ratings and reviews
- [ ] Real-time store hours
- [ ] Route optimization for multiple stores

### 👤 **User Profile & History**

- [ ] User account system
- [ ] Search history
- [ ] Prescription history

### 🔧 **Advanced Features**

- [ ] Offline mode support
- [ ] Multi-language support
- [ ] Voice search capability
- [ ] Barcode scanning

### 🤖 **AI & ML Enhancements**

- [ ] Improved OCR accuracy with custom models
- [ ] Medicine name auto-correction
- [ ] Prescription validity checking
- [ ] Doctor handwriting recognition

## 📱 Getting Started

### Prerequisites

- Flutter SDK (3.0 or higher)
- Android Studio / VS Code
- Android SDK (API level 21+)
- Internet connection for API services
- **Recommended**: Download the optimized architecture-specific APK for your device

### Installation

#### Option 1: Install Pre-built APK (Recommended)

**📋 How to Choose the Right APK:**

1. **Check your device architecture** (Settings → About Phone → Processor)
2. **Download the appropriate APK:**

   - **Most Android devices (2019+)**: `Jan-Aushadhi-Sarthak-v1.0.0-arm64-release.apk` (18.8 MB)
   - **Older/Budget devices**: `Jan-Aushadhi-Sarthak-v1.0.0-arm32-release.apk` (17.5 MB)
   - **If unsure**: `Jan-Aushadhi-Sarthak-v1.0.0-universal-release.apk` (44.3 MB - works on all devices)

3. **Enable "Install from Unknown Sources"** in Android Settings
4. **Install the APK** and enjoy the optimized performance

**📱 Quick Device Guide:**
- **Samsung Galaxy S9+, Google Pixel 3+, OnePlus 6+**: Use ARM64 version
- **Older Samsung, Xiaomi, Oppo devices**: Try ARM32 if ARM64 doesn't work
- **Android Emulator**: Use x86_64 version
- **Not sure?**: Use Universal version (larger but works everywhere)

#### Option 2: Build from Source

1. **Clone the repository**

   ```bash
   git clone https://github.com/kunal7236/jan_aushadhi_sarthak.git
   cd jan_aushadhi_sarthak
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Run the application**
   ```bash
   flutter run --debug
   ```

### Android Permissions

The app requires the following permissions:

- `INTERNET`: For API communications
- `CALL_PHONE`: For direct calling functionality
- `READ_EXTERNAL_STORAGE`: For file picker access

## 🎯 Usage Workflow

1. **Upload Prescription**: Take photo or select file (PDF/Image)
2. **OCR Processing**: Automatic medicine name extraction
3. **Verify Results**: Edit and confirm extracted medicines
4. **Search Medicines**: Manual control over prescription medicine search
5. **Find Stores**: Locate nearby Jan Aushadhi stores
6. **Get Directions**: Call stores or navigate using Google Maps

## 🌟 Key Achievements

- ✅ **Real OCR Integration**: Successfully implemented Google ML Kit
- ✅ **Live API Integration**: Connected to actual Jan Aushadhi databases
- ✅ **Complete User Journey**: From prescription to store navigation
- ✅ **Cross-Platform**: Works on Android with iOS support ready
- ✅ **Optimized Performance**: 85% APK size reduction (v1.0.0)
- ✅ **Architecture Splitting**: Multiple optimized APK variants
- ✅ **Dependency Management**: Streamlined for better performance
- ✅ **Production Ready**: Properly signed APKs for release

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes and test thoroughly
4. Commit your changes (`git commit -m 'Add amazing feature'`)
5. Push to the branch (`git push origin feature/amazing-feature`)
6. Open a Pull Request

## 🎉 Impact & Vision

**Jan Aushadhi Sarthak** aims to:

- **Reduce Healthcare Costs**: Save 50-90% on medicine expenses
- **Increase Accessibility**: Make generic medicines easily discoverable
- **Support Government Initiative**: Promote the Jan Aushadhi scheme
- **Bridge Technology Gap**: Bring digital solutions to healthcare
- **Empower Patients**: Provide tools for informed healthcare decisions

---

**Jan Aushadhi Sarthak** - Making healthcare affordable through technology 💊📱

_Built with ❤️ using Flutter_
