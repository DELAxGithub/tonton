# Food Image Analysis Integration

This document describes the integration of food image analysis capabilities from the ImagePoc project into the Tonton health tracking application.

## Overview

The integration adds the ability to analyze food images using Google's Gemini AI model through a Supabase Edge Function. This feature enhances the meal tracking functionality by providing automatic nutritional information from food photos.

## Components

### 1. Supabase Edge Function

The functionality relies on the `process-image-gemini` Edge Function deployed to Supabase. This function:

- Accepts a base64-encoded image and MIME type
- Sends the image to the Gemini API for analysis
- Returns structured nutritional data

**Edge Function Location:** `/supabase/functions/process-image-gemini/index.ts`

### 2. AI Service

The `AIService` class in Tonton handles the communication with the Edge Function and processes the results:

**File Location:** `/lib/services/ai_service.dart`

Key methods:
- `estimateNutritionFromImageFile(File imageFile)`: Processes an image file and returns nutrition data
- `estimateNutritionFromText(String mealDescription)`: Processes a text description (existing functionality)

### 3. Provider

The `aiEstimationProvider` manages the state for AI estimations and provides methods for the UI to interact with:

**File Location:** `/lib/providers/ai_estimation_provider.dart`

### 4. Models

The returned data is mapped to these model classes:
- `EstimatedMealNutrition`: Main model for nutrition data
- `NutrientInfo`: Model for macronutrient information

**File Locations:** 
- `/lib/models/estimated_meal_nutrition.dart`
- `/lib/models/nutrient_info.dart`

### 5. UI Components

The image analysis functionality is integrated into the meal input screen:

**File Location:** `/lib/screens/meal_input_screen.dart`

## Testing

### Automated Tests

Basic unit and integration tests are available in:
- `/test/ai_service_test.dart`: Unit tests for the AI service
- `/test_scripts/test_image_analysis.dart`: Standalone test script for end-to-end testing

### Manual Testing

To manually test the image analysis functionality:

1. Start the Tonton app
2. Navigate to Add New Meal screen
3. Tap "From Gallery" or "From Camera" to select or take a food photo
4. Observe the analysis in progress and the resulting nutritional data

## Configuration

### Environment Variables

The Edge Function requires configuration in Supabase:

- `GEMINI_API_KEY`: API key for Google's Gemini AI model

### Deployment

To deploy the Edge Function to Supabase:

1. Install the Supabase CLI
2. Navigate to the `/supabase/functions/process-image-gemini` directory
3. Run: `supabase functions deploy process-image-gemini`
4. Set the required secrets: `supabase secrets set GEMINI_API_KEY=your_api_key`

## Troubleshooting

### Common Issues

1. **Edge Function Not Found (404)**
   - Verify that the Edge Function is deployed to Supabase
   - Check the function name in the AI service (should be `process-image-gemini`)

2. **Authorization Error**
   - Ensure the app is properly authenticated with Supabase
   - Check API keys and permissions

3. **Timeout or Connection Issues**
   - Verify internet connectivity
   - Check if the image is too large (should be under 10MB)

4. **Invalid Response Format**
   - Ensure the Gemini API is returning the expected format
   - Check for changes in the API response structure

### Logging

The AI service includes extensive logging that can help diagnose issues:
- Look for logs with the prefix `TonTon.AIService` in the console
- More detailed logs for errors use the prefix `TonTon.AIService.Error`

## Documentation

Additional documentation:
- [AI Image Analysis Guide](/docs/ai_image_analysis_guide.md): User-facing guide for the feature
- [Integration Plan](/integration_plan.md): Original integration plan and analysis