# AI Food Image Analysis Guide

## Overview

Tonton includes an AI-powered food image analysis feature that allows users to:

1. Take a photo of their food or select an image from their gallery
2. Automatically analyze the image to determine:
   - Food name
   - Description of the dish
   - Nutritional information (calories, protein, fat, carbohydrates)

This feature uses Google's Gemini AI model to analyze food images and extract nutritional information.

## How It Works

### Technical Components

1. **Mobile App**:
   - Uses the device camera or photo library to capture food images
   - Processes and compresses images for efficient upload
   - Displays the analysis results in a user-friendly format

2. **Supabase Edge Function**:
   - Receives the image as base64-encoded data
   - Calls the Gemini API to analyze the image
   - Processes the Gemini API response into structured data
   - Returns the nutrition data to the mobile app

3. **Gemini AI**:
   - Analyzes food images using computer vision
   - Identifies the type of food
   - Estimates nutritional content

### Data Flow

1. User selects or takes a photo of their food
2. The image is processed locally (compressed and converted to base64)
3. The app sends the image data to the Supabase Edge Function
4. The Edge Function calls the Gemini API with the image
5. Gemini AI analyzes the image and returns structured data
6. The Edge Function formats the data and returns it to the app
7. The app displays the nutrition information to the user

## User Guide

### Taking a Food Photo

1. From the **Add New Meal** screen, tap one of the photo buttons:
   - **From Gallery**: Select a food photo from your device
   - **From Camera**: Take a new photo of your food

2. Position your food clearly in the frame when taking a photo:
   - Ensure good lighting
   - Capture the entire dish
   - Avoid extreme angles

3. Once selected, the image will appear in the preview area, and analysis will begin automatically.

### Understanding the Results

After analysis, the following fields will be automatically populated:

- **Meal Name**: The identified food item (e.g., "Grilled Salmon with Vegetables")
- **Description**: A brief description of the dish
- **Calories**: Estimated calories per serving
- **Protein**: Protein content in grams
- **Fat**: Fat content in grams
- **Carbs**: Carbohydrate content in grams

### Editing Results

The AI estimation provides a good starting point, but you can:

- Edit any field if you have more accurate information
- Adjust values based on your specific portion size
- Add more details to the description

### Best Practices

For the most accurate results:

1. Take clear, well-lit photos
2. Capture individual dishes rather than full meals with multiple items
3. Include a common object for scale if possible (like a fork or plate)
4. Try to capture the food from directly above for best recognition

### Limitations

The AI analysis has some limitations:

- Accuracy may vary depending on image quality
- Some regional or uncommon dishes may not be recognized precisely
- Nutritional estimates are approximations
- Very complex or multi-component meals may be less accurate

## Troubleshooting

### Common Issues

1. **"Analysis failed" error**:
   - Ensure you have a stable internet connection
   - Try taking a clearer photo with better lighting
   - Check that the image shows recognizable food items

2. **Inaccurate nutritional values**:
   - The AI provides estimates; adjust values if you have more accurate information
   - Consider the portion size in your photo vs. the portion you consumed

3. **Slow analysis**:
   - Large images take longer to process
   - Check your internet connection speed
   - Try again with a smaller or more compressed image

### Getting Help

If you encounter persistent issues with the food image analysis feature, please:

1. Check that you're using the latest version of the app
2. Report specific issues through the app's feedback feature
3. Include details about the food item and the specific problem encountered

## Privacy Information

- Food images are processed securely and are not permanently stored
- Analysis is performed using industry-standard encryption
- Your food data is only used to provide nutritional information within the app