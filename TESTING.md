# Testing Guide for Jan Aushadhi Sarthak

## Complete User Flow Testing

### Step 1: Launch App

- App starts with splash screen
- Automatically navigates to file picker after 3 seconds

### Step 2: Upload Prescription

- Tap "Choose Prescription" button
- Select an image file (JPG, PNG, JPEG) or PDF
- See file name displayed
- Tap "Parse Prescription" button

### Step 3: Medicine Extraction

- App processes the file using OCR
- Shows loading indicator with "Extracting medicines from prescription..."
- Displays extracted medicine names
- Shows confidence score and number of medicines found

### Step 4: Verify Medicines

- Review each extracted medicine name
- Use checkmark ✓ to verify correct names
- Use edit ✏️ to modify incorrect names
- Progress shows "X/Y medicines verified"

### Step 5: Find Generic Alternatives

- Tap "Find Generic Alternatives" (enabled only when medicines are verified)
- App searches for generic names
- Shows loading: "Searching for generic alternatives..."
- Displays commercial name → generic name mapping

### Step 6: Check Jan Aushadhi Availability

- Tap "Check Jan Aushadhi Availability"
- Shows placeholder message (feature coming soon)

## Test Cases

### Valid Image Input

- Upload a clear prescription image
- Should extract medicine names with good confidence (>70%)
- User can verify and proceed

### Poor Quality Image

- Upload blurry or unclear image
- Should show low confidence warning
- User needs to manually verify/edit names

### PDF Input

- Upload PDF prescription
- Should use PDF text extraction
- Higher confidence expected for typed text

### Error Handling

- Try uploading unsupported file format
- Should show appropriate error message
- App should remain stable

### Navigation Flow

- Back button should work at each step
- App state should be preserved
- No crashes during navigation

## Expected Behavior

### File Picker Page

- ✅ Clean medical-themed UI
- ✅ File validation (PDF, JPG, PNG, JPEG only)
- ✅ Process button enabled only after file selection
- ✅ Loading state during processing

### Medicine Extraction Page

- ✅ OCR processing with real ML Kit integration
- ✅ Confidence score display
- ✅ Individual medicine verification
- ✅ Edit functionality with dialog
- ✅ Progress tracking

### Generic Alternatives Page

- ✅ Database lookup for generic names
- ✅ Clear commercial → generic mapping
- ✅ Preparation for Jan Aushadhi integration

## Performance Expectations

### OCR Processing

- Image processing: 2-5 seconds
- PDF processing: 1-3 seconds
- Confidence: 70-95% for clear images

### Database Lookup

- Generic name search: <1 second per medicine
- Dummy data provides instant results
- Real database will add slight delay

### Memory Usage

- ML Kit model: ~10MB download (one-time)
- Image processing: Temporary memory spike
- Should not cause app crashes

## Known Limitations (Current Implementation)

### OCR Accuracy

- Handwritten text: Limited accuracy
- Complex layouts: May miss medicines
- Small text: Reduced recognition

### Database Coverage

- Currently using dummy medicine database
- Limited medicine name mappings
- Jan Aushadhi data not yet integrated

### Features Not Yet Implemented

- Real Jan Aushadhi API integration
- Price comparison
- Store locator
- User accounts/history

## Next Development Steps

1. **Enhance OCR accuracy**

   - Add preprocessing (image enhancement)
   - Improve medicine name extraction patterns
   - Add medical vocabulary training

2. **Integrate real databases**

   - Connect to medicine database
   - Add Jan Aushadhi official data
   - Implement price comparison

3. **Add advanced features**
   - Store locator with maps
   - Savings calculator
   - User preferences
   - Offline mode
