# Food Image Analysis Implementation

## Overview

The food image analysis functionality in Tonton allows users to take photos of their meals and automatically analyze them for nutritional content. This feature uses Google's Gemini AI model through a Supabase Edge Function to provide fast and accurate estimates of calories, protein, fat, and carbohydrates.

## Architecture

### 1. Client-Side Components

#### Services
- **AIService** (`lib/services/ai_service.dart`): Handles communication with Supabase Edge Functions
  - `estimateNutritionFromImageFile(File imageFile)`: Processes image files directly
  - `estimateNutritionFromText(String mealDescription)`: Processes text descriptions (existing feature)
  - `uploadImageToSupabase(File imageFile, String userId)`: Stores images in Supabase Storage

#### Models
- **EstimatedMealNutrition** (`lib/models/estimated_meal_nutrition.dart`): Represents nutritional data
  - Maps from Gemini AI response to a structured object
  - Includes food name, description, calories, and macronutrients
- **NutrientInfo** (`lib/models/nutrient_info.dart`): Contains macronutrient details
  - Stores protein, fat, and carbs values

#### Providers
- **aiEstimationProvider** (`lib/providers/ai_estimation_provider.dart`): Manages state for AI estimations
  - Handles loading, success, and error states
  - Provides methods for interacting with the AIService

#### UI Components
- **MealInputScreen** (`lib/screens/meal_input_screen.dart`): Main UI for meal input
  - Includes image selection UI
  - Shows loading state during analysis
  - Displays analysis results
  - Allows user to edit AI-provided values

### 2. Backend Components

#### Supabase Edge Function
- **process-image-gemini** (`supabase/functions/process-image-gemini/index.ts`)
  - Receives base64-encoded images from clients
  - Calls Gemini API for analysis
  - Processes and validates responses
  - Returns structured nutritional data

#### Gemini AI Integration
- Uses the Gemini 1.5 Flash model for image analysis
- Structured prompt requesting specific nutrition data fields
- Response formatting as JSON for easy parsing

## Implementation Details

### Image Processing Flow

1. **Image Selection**:
   - User selects image via gallery or camera
   - Image is compressed and resized using ImagePicker parameters
   - Selected image is displayed in UI

2. **Image Analysis**:
   - Image is converted to base64 format
   - MIME type is determined
   - Request is sent to Supabase Edge Function
   - Loading indicator shown during processing

3. **Response Handling**:
   - Response is parsed into EstimatedMealNutrition object
   - UI is updated with nutritional data
   - User can edit values if needed
   - Errors are displayed with user-friendly messages

### Error Handling

The implementation includes robust error handling at multiple levels:

1. **Client-Side**:
   - Network errors during API calls
   - Image format or size issues
   - JSON parsing errors
   - Timeouts and rate limits

2. **Edge Function**:
   - Request validation
   - Gemini API error handling
   - Response format validation
   - Proper error codes and messages

### Testing Tools

Several tools have been created to test and debug the implementation:

1. **Standalone Testing App**:
   - `tools/standalone_image_analysis_app.dart`: A mini Flutter app for testing the full flow
   - Can be run separately from main app

2. **Edge Function Tester**:
   - `tools/test_edge_function.dart`: Tests Edge Function directly
   - Can bypass app to test backend in isolation

3. **Image Processing Tester**:
   - `tools/test_image_processing.dart`: Tests image compression and format handling
   - Helps optimize image size and quality

4. **Configuration Checker**:
   - `tools/verify_config.dart`: Verifies all required configuration is in place
   - Checks dependencies, environment variables, and Edge Function access

5. **Automated Tests**:
   - `test/image_analysis_integration_test.dart`: Integration tests for the feature
   - `tools/run_image_analysis_tests.sh`: Script to run all tests in sequence

## Performance Optimizations

1. **Image Compression**:
   - Images are resized to max 1800x1800 pixels
   - JPEG quality set to 85-88% for good balance of quality and size
   - Typical processed image size is 200-500KB

2. **Response Caching**:
   - Gemini API responses could be cached for identical or similar images
   - Supabase Edge Function could implement caching layer

3. **UI Responsiveness**:
   - Asynchronous processing to keep UI responsive
   - Clear loading indicators with progress updates
   - Background processing where possible

## Security Considerations

1. **API Keys**:
   - Gemini API key stored in Supabase secrets, not in client app
   - All requests authenticated with Supabase

2. **Data Privacy**:
   - Image data is processed but not permanently stored (unless explicitly uploaded)
   - No personally identifiable information sent to Gemini API

3. **Rate Limiting**:
   - Edge Function can implement rate limiting to prevent abuse
   - Error handling for rate limit responses

## Future Improvements

1. **Advanced Parsing**:
   - More robust JSON parsing for varied Gemini responses
   - Handling for multi-item meals

2. **Feedback Mechanism**:
   - Allow users to provide feedback on AI accuracy
   - Use feedback to improve future analyses

3. **Offline Support**:
   - Implement offline queuing for analysis requests
   - Cache recent analyses for offline viewing

4. **Performance Monitoring**:
   - Add telemetry for response times and error rates
   - Set up alerting for Edge Function failures