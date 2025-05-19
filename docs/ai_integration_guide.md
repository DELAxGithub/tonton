# AI Nutrition Estimation Integration Guide

## Overview

This document describes how the Tonton app implements AI-powered nutrition estimation using Supabase Edge Functions and OpenAI's GPT-4o model.

## Architecture

1. **Client-Side (Flutter App)**
   - User enters meal description text
   - AIService sends request to Supabase Edge Function
   - Results are processed and displayed in the meal input form

2. **Server-Side (Supabase Edge Function)**
   - Edge Function securely stores OpenAI API key
   - Processes meal description from client
   - Makes API call to OpenAI with carefully crafted prompt
   - Returns structured nutrition data to client

## Setup Instructions

### Supabase Project Setup

1. Create a Supabase project at https://supabase.com/
2. Note your project URL and anon key from Project Settings > API

### Edge Function Deployment

1. Install Supabase CLI:
```bash
brew install supabase/tap/supabase
```

2. Login to Supabase:
```bash
supabase login
```

3. Initialize and link to your project:
```bash
supabase init
supabase link --project-ref your-project-reference
```

4. Add OpenAI API key as a secret:
```bash
supabase secrets set OPENAI_API_KEY=your-openai-api-key
```

5. Create and deploy the estimate-nutrition function:
```typescript
// Nutrition estimation Edge Function code
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

const openaiApiKey = Deno.env.get('OPENAI_API_KEY') || ''

serve(async (req) => {
  try {
    // Parse request body
    const { mealDescription } = await req.json()
    
    if (!mealDescription) {
      return new Response(
        JSON.stringify({ error: 'Meal description is required' }),
        { headers: { 'Content-Type': 'application/json' }, status: 400 }
      )
    }

    // Call OpenAI API
    const openAIResponse = await fetch('https://api.openai.com/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${openaiApiKey}`
      },
      body: JSON.stringify({
        model: 'gpt-4o',
        messages: [
          {
            role: 'system',
            content: 'You are a nutrition expert that analyzes food descriptions and estimates their nutritional content. Respond ONLY with valid JSON with no explanation or commentary.'
          },
          {
            role: 'user',
            content: `Analyze this meal description and provide nutritional estimates: "${mealDescription}"
            
            Please provide the analysis in this exact JSON format:
            {
              "dishName": "Name of the dish based on the description",
              "calories": estimated_calories_as_number,
              "nutrients": {
                "protein": estimated_protein_grams_as_number,
                "fat": estimated_fat_grams_as_number,
                "carbs": estimated_carbs_grams_as_number
              }
            }`
          }
        ],
        temperature: 0.3,
        response_format: { type: 'json_object' }
      })
    })

    const openAIData = await openAIResponse.json()
    const nutritionData = JSON.parse(openAIData.choices[0].message.content)

    return new Response(
      JSON.stringify(nutritionData),
      { headers: { 'Content-Type': 'application/json' } }
    )
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { headers: { 'Content-Type': 'application/json' }, status: 500 }
    )
  }
})
```

6. Deploy the function:
```bash
supabase functions deploy estimate-nutrition --no-verify-jwt
```

### Flutter App Integration

1. Add the Supabase Flutter package:
```yaml
dependencies:
  supabase_flutter: ^2.0.0
```

2. Initialize Supabase in your Flutter app:
```dart
// In main.dart
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://your-project-ref.supabase.co',
    anonKey: 'your-anon-key',
  );
  
  runApp(const ProviderScope(child: MyApp()));
}
```

3. Implement the AIService:
```dart
// In lib/services/ai_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/estimated_meal_nutrition.dart';

class AIService {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  Future<EstimatedMealNutrition?> estimateNutritionFromText(String mealDescription) async {
    try {
      final response = await _supabaseClient.functions.invoke(
        'estimate-nutrition',
        body: {'mealDescription': mealDescription},
      );

      if (response.status != 200) {
        throw Exception('Error: ${response.status}');
      }

      return EstimatedMealNutrition.fromJson(response.data);
    } catch (e) {
      print('Error estimating nutrition: $e');
      return null;
    }
  }
}
```

## Notes for Future Development

- **Environment Management**: Currently using development Supabase project. For production, consider creating a separate project and implementing environment switching.
- **API Key Rotation**: Implement a strategy for regular rotation of the OpenAI API key.
- **Prompt Refinement**: Continue testing with diverse meal descriptions to improve estimation accuracy.
- **Cost Management**: Monitor API usage to manage costs effectively.
- **Error Handling**: Enhance error handling to provide more specific user feedback.

## References

- [Supabase Edge Functions Documentation](https://supabase.com/docs/guides/functions)
- [OpenAI API Reference](https://platform.openai.com/docs/api-reference)
- [Flutter Supabase SDK Documentation](https://supabase.com/docs/reference/dart/introduction)