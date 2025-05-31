import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
// CORS headers
const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type"
};
// Initialize Supabase client if needed for other operations (e.g., fetching user preferences)
// const supabaseClient = createClient(
//   Deno.env.get("SUPABASE_URL") ?? "",
//   Deno.env.get("SUPABASE_ANON_KEY") ?? "",
//   { global: { headers: { Authorization: `Bearer ${Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")}` } } }
// );
serve(async (req)=>{
  // Handle OPTIONS request for CORS preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", {
      headers: corsHeaders
    });
  }
  try {
    // 1. Parse incoming request data
    // Expected data:
    // - targetCalories: number (e.g., 2000)
    // - targetPfcRatio: { protein: number, fat: number, carbohydrate: number } (e.g., { protein: 0.3, fat: 0.2, carbohydrate: 0.5 })
    // - consumedMealsPfc: { protein: number, fat: number, carbohydrate: number, calories: number } (sum of at least 2 meals)
    // - activeCalories: number (calories burned through activity)
    // - lang: 'ja' or 'en'
    const { targetCalories, targetPfcRatio, consumedMealsPfc, activeCalories, lang } = await req.json();
    const language = lang === 'ja' ? 'ja' : 'en';
    // --- Input Validation (Basic) ---
    if (!targetCalories || !targetPfcRatio || !consumedMealsPfc || activeCalories === undefined // Can be 0
    ) {
      const errorMessage = language === 'ja'
        ? "必要なパラメータが不足しています。"
        : "Missing required input parameters.";
        
      return new Response(JSON.stringify({
        error: errorMessage
      }), {
        headers: {
          ...corsHeaders,
          "Content-Type": "application/json"
        },
        status: 400
      });
    }
    if (typeof targetPfcRatio.protein !== 'number' || typeof targetPfcRatio.fat !== 'number' || typeof targetPfcRatio.carbohydrate !== 'number' || Math.abs(targetPfcRatio.protein + targetPfcRatio.fat + targetPfcRatio.carbohydrate - 1.0) > 0.01 // Allow for small floating point inaccuracies
    ) {
      const errorMessage = language === 'ja'
        ? "PFC比率が無効です。値は数値でなければならず、合計が1.0になる必要があります。"
        : "Invalid PFC ratio. Values must be numbers and sum to 1.0.";
        
      return new Response(JSON.stringify({
        error: errorMessage
      }), {
        headers: {
          ...corsHeaders,
          "Content-Type": "application/json"
        },
        status: 400
      });
    }
    // 2. Calculate remaining calories and PFC for the "last meal"
    //    - Calculate total daily calorie allowance: targetCalories + activeCalories
    //    - Calculate remaining calories: totalDailyCalorieAllowance - consumedMealsPfc.calories
    //    - Calculate target PFC grams for the day based on totalDailyCalorieAllowance and targetPfcRatio
    //        - Protein (g) = (totalDailyCalorieAllowance * targetPfcRatio.protein) / 4
    //        - Fat (g) = (totalDailyCalorieAllowance * targetPfcRatio.fat) / 9
    //        - Carbohydrate (g) = (totalDailyCalorieAllowance * targetPfcRatio.carbohydrate) / 4
    //    - Calculate remaining PFC grams for the "last meal"
    //        - Remaining Protein (g) = Target Protein (g) - consumedMealsPfc.protein
    //        - Remaining Fat (g) = Target Fat (g) - consumedMealsPfc.fat
    //        - Remaining Carbohydrate (g) = Target Carbohydrate (g) - consumedMealsPfc.carbohydrate
    const totalDailyCalorieAllowance = targetCalories + activeCalories;
    const remainingCaloriesForLastMeal = totalDailyCalorieAllowance - consumedMealsPfc.calories;
    // Ensure remaining calories are not negative or too low for a meaningful meal
    if (remainingCaloriesForLastMeal <= 0) {
      return new Response(JSON.stringify({
        advice: language === 'ja'
          ? "すでに1日のカロリー目標を達成または超過しています！"
          : "You have already met or exceeded your calorie goal for the day!",
        remainingCalories: remainingCaloriesForLastMeal,
        menuSuggestions: []
      }), {
        headers: {
          ...corsHeaders,
          "Content-Type": "application/json"
        },
        status: 200
      });
    }
    const targetProteinGrams = totalDailyCalorieAllowance * targetPfcRatio.protein / 4;
    const targetFatGrams = totalDailyCalorieAllowance * targetPfcRatio.fat / 9;
    const targetCarbohydrateGrams = totalDailyCalorieAllowance * targetPfcRatio.carbohydrate / 4;
    const remainingProteinGrams = targetProteinGrams - consumedMealsPfc.protein;
    const remainingFatGrams = targetFatGrams - consumedMealsPfc.fat;
    const remainingCarbohydrateGrams = targetCarbohydrateGrams - consumedMealsPfc.carbohydrate;
    // 3. Construct prompt for AI (Gemini Pro)
    //    - Include: remainingCaloriesForLastMeal, remainingProteinGrams, remainingFatGrams, remainingCarbohydrateGrams
    //    - Ask for: menu name, simple description, estimated calories & PFC (g) for the menu, and recommendation reason.
    const promptEn = `
Based on the following nutritional targets for a single meal:
- Maximum Calories: ${remainingCaloriesForLastMeal.toFixed(0)} kcal
- Target Protein: ${remainingProteinGrams.toFixed(1)} g
- Target Fat: ${remainingFatGrams.toFixed(1)} g
- Target Carbohydrates: ${remainingCarbohydrateGrams.toFixed(1)} g

Please suggest one specific meal menu.
For the suggested menu, provide:
1. Menu Name (e.g., "Grilled Chicken Salad with Quinoa")
2. Simple Description (e.g., "A light and protein-rich salad with grilled chicken breast, mixed greens, quinoa, and a lemon vinaigrette.")
3. Estimated Nutritional Information for the suggested menu:
    - Calories (kcal)
    - Protein (g)
    - Fat (g)
    - Carbohydrates (g)
4. Recommendation Reason (e.g., "This meal is high in protein, helping you meet your protein target, while staying within the calorie limit. The complex carbohydrates from quinoa provide sustained energy.")

Format the output as a JSON object with the following keys: "menuName", "description", "estimatedNutrition", "recommendationReason".
The "estimatedNutrition" should be an object with keys: "calories", "protein", "fat", "carbohydrates".
Ensure the suggested meal's estimated calories are less than or equal to the 'Maximum Calories' provided above.
Prioritize meeting the protein target, then carbohydrate, then fat, while staying within the calorie limit.
If the targets are difficult to meet precisely, aim for a balanced meal that is as close as possible to the targets and within the calorie limit.
Suggest a common, generally healthy meal. Avoid overly complex or niche suggestions.
`;

    const promptJa = `
以下の栄養目標を参考に、1食分の具体的なメニューを1つ提案してください。
- 最大カロリー: ${remainingCaloriesForLastMeal.toFixed(0)} kcal
- タンパク質目標: ${remainingProteinGrams.toFixed(1)} g
- 脂質目標: ${remainingFatGrams.toFixed(1)} g
- 炭水化物目標: ${remainingCarbohydrateGrams.toFixed(1)} g

次の項目を英語のキー名でJSON形式にまとめてください。
1. menuName  - メニュー名（日本語で書いてください）
2. description - 簡単な説明（日本語で書いてください）
3. estimatedNutrition - 推定栄養情報オブジェクト（calories, protein, fat, carbohydrates）
4. recommendationReason - おすすめ理由（日本語で書いてください）

推定カロリーは上記の「最大カロリー」を超えないようにしてください。
タンパク質、炭水化物、脂質の順に目標値に近づけつつ、カロリー内に収めてください。
正確な数値が難しい場合は、できる限りバランスの取れた一般的で健康的なメニューを提案してください。
複雑すぎる料理やニッチな食材は避けてください。

JSONの文字列フィールドは必ず日本語で記述してください。英語での回答は不可です。
`;

    const prompt = language === 'ja' ? promptJa : promptEn;
    // 4. Call Gemini Pro API
    //    - This part requires setting up the API call to Google's Gemini Pro.
    //    - You'll need an API key and the correct endpoint.
    //    - For now, we'll return a mock response.
    //    - Ensure GEMINI_API_KEY is set in Supabase Edge Function environment variables.
    const GEMINI_API_KEY = Deno.env.get("GEMINI_API_KEY");
    if (!GEMINI_API_KEY) {
      const errorMessage = language === 'ja'
        ? "GEMINI_API_KEYが設定されていません。管理者にお問い合わせください。"
        : "GEMINI_API_KEY is not set.";
        
      return new Response(JSON.stringify({
        error: errorMessage
      }), {
        headers: {
          ...corsHeaders,
          "Content-Type": "application/json"
        },
        status: 500
      });
    }
    const geminiUrl = `https://generativelanguage.googleapis.com/v1/models/gemini-1.5-pro:generateContent?key=${GEMINI_API_KEY}`;
    const requestBody = {
      contents: [
        {
          role: "user",
          parts: [
            {
              text: prompt
            }
          ]
        }
      ],
      generationConfig: {
        // Ensure JSON output if model supports it directly, or parse carefully
        // responseMimeType: "application/json", // This might not be supported by gemini-pro directly for text prompts
        temperature: 0.7,
        maxOutputTokens: 500
      },
      systemInstruction: {
        parts: [
          {
            text: language === 'ja' 
              ? "あなたは料理の専門家です。必ず日本語で回答してください。JSONフォーマットで返答する際も、すべてのテキスト値は日本語で記述してください。" 
              : "You are a culinary expert who provides advice in English."
          }
        ]
      }
    };
    const geminiResponse = await fetch(geminiUrl, {
      method: "POST",
      headers: {
        "Content-Type": "application/json"
      },
      body: JSON.stringify(requestBody)
    });
    if (!geminiResponse.ok) {
      const errorBody = await geminiResponse.text();
      console.error("Gemini API Error:", errorBody);
      const errorMessage = language === 'ja'
        ? "Gemini APIからの応答の取得に失敗しました。"
        : "Failed to get a response from Gemini API.";
        
      return new Response(JSON.stringify({
        error: errorMessage,
        details: errorBody
      }), {
        headers: {
          ...corsHeaders,
          "Content-Type": "application/json"
        },
        status: geminiResponse.status
      });
    }
    const geminiResult = await geminiResponse.json();
    // Extract the text content and parse it as JSON
    // Gemini's response structure can be nested.
    // Example path: result.candidates[0].content.parts[0].text
    let mealSuggestionJson;
    try {
      const rawJsonText = geminiResult.candidates[0].content.parts[0].text.replace(/```json\n?|\n?```/g, '').trim();
      mealSuggestionJson = JSON.parse(rawJsonText);
    } catch (parseError) {
      console.error("Failed to parse Gemini response:", parseError);
      console.error("Raw Gemini response text:", geminiResult.candidates[0].content.parts[0].text);
      const errorMessage = language === 'ja'
        ? "AIからの食事提案の解析に失敗しました。"
        : "Failed to parse meal suggestion from AI.";
        
      return new Response(JSON.stringify({
        error: errorMessage,
        details: parseError.message,
        rawResponse: geminiResult.candidates[0].content.parts[0].text
      }), {
        headers: {
          ...corsHeaders,
          "Content-Type": "application/json"
        },
        status: 500
      });
    }
    // 5. Format and return the response
    return new Response(JSON.stringify({
      advice: language === 'ja'
        ? 'こちらが次の食事の提案です:'
        : "Here's a suggestion for your next meal:",
      remainingCaloriesForLastMeal: remainingCaloriesForLastMeal.toFixed(0),
      calculatedTargetPfcForLastMeal: {
        protein: remainingProteinGrams.toFixed(1),
        fat: remainingFatGrams.toFixed(1),
        carbohydrate: remainingCarbohydrateGrams.toFixed(1)
      },
      menuSuggestion: mealSuggestionJson
    }), {
      headers: {
        ...corsHeaders,
        "Content-Type": "application/json"
      },
      status: 200
    });
  } catch (error) {
    console.error("Error in Edge Function:", error);
    
    // Since we're in the catch block, language might not be defined
    // Try to extract it from the request if possible, otherwise default to Japanese
    let lang = 'ja';
    try {
      if (req.headers.get('Accept-Language')?.startsWith('en')) {
        lang = 'en';
      }
    } catch (e) {
      // Ignore error and use default language
    }
    
    const errorMessage = lang === 'en' 
      ? "Error in Edge Function."
      : "エッジ関数でエラーが発生しました。";
      
    return new Response(JSON.stringify({
      error: errorMessage,
      details: error.message
    }), {
      headers: {
        ...corsHeaders,
        "Content-Type": "application/json"
      },
      status: 500
    });
  }
});
