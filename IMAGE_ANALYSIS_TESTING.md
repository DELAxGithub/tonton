# Image Analysis Testing Guide

This guide explains how to test the AI-powered food image analysis functionality in the Tonton app.

## Overview

The Tonton app includes image analysis capabilities that:
1. Accept images of food from camera or gallery
2. Process and send them to a Supabase Edge Function
3. Call Google's Gemini AI for analysis
4. Return structured nutrition information (calories, protein, fat, carbs)

## Test Images

Sample test images are provided in the `test_images/` directory:
- `apple.jpg` - A simple apple image (tests single food item recognition)
- `meal.jpg` - A colorful meal with vegetables (tests complex food recognition)
- `dark_meal.jpg` - A meal in lower lighting (tests AI robustness)

If the test images are missing, you can recreate them by running:
```bash
cd /Users/hiroshikodera/repos/_active/apps/Tonton_suites/Tonton/test_images
./download_images.sh
```

## Running the Test App

A standalone test app has been created specifically for testing the image analysis functionality:

```bash
cd /Users/hiroshikodera/repos/_active/apps/Tonton_suites/Tonton
flutter run -t test_image_analysis.dart
```

The test app provides:
- Buttons to select images from gallery or camera
- Quick access buttons for the sample test images
- An option to automatically analyze images after selection
- A display of the analysis results with all nutritional information
- Error handling and debug information

## Expected Results

When testing with the provided sample images:

1. `apple.jpg` should return:
   - Food name: Apple (or similar)
   - Calories: ~80-100 kcal
   - Nutritional breakdown for a typical apple

2. `meal.jpg` should return:
   - Food name: Something like "Vegetable Bowl" or "Mixed Vegetables"
   - Calories: Will vary based on AI's interpretation
   - Nutritional breakdown including protein, fat, and carbs

3. `dark_meal.jpg` tests the AI's ability to analyze lower-light images

## Debugging Issues

If analysis fails or returns unexpected results:

1. Check the console output in the test app for detailed error messages
2. Verify that the Supabase configuration in `test_image_analysis.dart` is correct
3. Make sure the Supabase Edge Function is properly deployed
4. Try with different images to determine if it's an image-specific issue
5. Check network connectivity

## Implementation Details

The image analysis functionality is implemented across several files:

- `lib/services/ai_service.dart` - Main service for image analysis
- `lib/models/estimated_meal_nutrition.dart` - Model for nutrition data
- `lib/models/nutrient_info.dart` - Supporting model for macronutrients
- `lib/providers/ai_estimation_provider.dart` - State management
- `supabase/functions/process-image-gemini/index.ts` - Supabase Edge Function

The test app `test_image_analysis.dart` uses the same core functionality as the main app but in a standalone environment for easier testing.