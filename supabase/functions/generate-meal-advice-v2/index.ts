import { serve } from "https://deno.land/std@0.131.0/http/server.ts";
import { corsHeaders } from "../_shared/cors.ts";

const GEMINI_API_KEY = Deno.env.get("GEMINI_API_KEY");

interface MealAdviceRequest {
  targetCalories: number;
  targetPfcRatio: {
    protein: number;
    fat: number;
    carbohydrate: number;
  };
  consumedMealsPfc: {
    protein: number;
    fat: number;
    carbohydrate: number;
    calories: number;
  };
  activeCalories: number;
  lang: string;
  userContext?: {
    timeOfDay: string;
    gender?: string;
    ageGroup?: string;
    weight?: number;
    weeklyTrend?: {
      hasData: boolean;
      averageCalorieAchievement: number;
      averageProteinAchievement: number;
      averageFatAchievement: number;
      averageCarbsAchievement: number;
      trend: string;
      daysWithData?: number;
    };
  };
}

function generatePrompt(request: MealAdviceRequest): string {
  const { targetCalories, targetPfcRatio, consumedMealsPfc, activeCalories, lang, userContext } = request;
  
  // 残りの栄養素を計算
  const remainingCalories = targetCalories - consumedMealsPfc.calories + activeCalories;
  const targetProtein = (targetCalories * targetPfcRatio.protein) / 4;
  const targetFat = (targetCalories * targetPfcRatio.fat) / 9;
  const targetCarbs = (targetCalories * targetPfcRatio.carbohydrate) / 4;
  
  const remainingProtein = targetProtein - consumedMealsPfc.protein;
  const remainingFat = targetFat - consumedMealsPfc.fat;
  const remainingCarbs = targetCarbs - consumedMealsPfc.carbohydrate;
  
  // 時間帯別のアドバイスタイプ
  const timeBasedAdvice = {
    morning: "朝食または昼食",
    lunch: "昼食または間食",
    dinner: "夕食",
    evening: "軽い夜食または明日の準備"
  };
  
  const mealContext = timeBasedAdvice[userContext?.timeOfDay || 'dinner'];
  
  // ユーザープロフィールに基づくパーソナライズ
  let profileContext = "";
  if (userContext?.gender && userContext?.ageGroup) {
    const ageGroupText = {
      young: "若い世代",
      middle: "中年世代",
      senior: "シニア世代"
    };
    const genderText = userContext.gender === 'male' ? '男性' : '女性';
    profileContext = `\nユーザーは${ageGroupText[userContext.ageGroup] || ''}の${genderText}です。`;
  }
  
  // 週間トレンドに基づくアドバイス
  let trendContext = "";
  if (userContext?.weeklyTrend?.hasData) {
    const trend = userContext.weeklyTrend;
    if (trend.trend === 'improving') {
      trendContext = "\n最近の食事管理は改善傾向にあります。この調子を維持しましょう。";
    } else if (trend.trend === 'declining') {
      trendContext = "\n最近の食事管理が少し乱れがちです。基本に立ち返りましょう。";
    }
    
    // 特定の栄養素の不足を指摘
    if (trend.averageProteinAchievement < 80) {
      trendContext += "\n特にタンパク質が不足傾向です。";
    }
  }
  
  const prompt = `あなたは優秀な栄養アドバイザーです。以下の情報に基づいて、${mealContext}の具体的なアドバイスを提供してください。

現在の状況:
- 目標カロリー: ${targetCalories}kcal
- 消費済みカロリー: ${consumedMealsPfc.calories}kcal
- 運動消費カロリー: ${activeCalories}kcal
- 残りカロリー: ${remainingCalories}kcal

栄養バランス:
- タンパク質: 消費${consumedMealsPfc.protein}g / 目標${targetProtein.toFixed(0)}g (残り${remainingProtein.toFixed(0)}g)
- 脂質: 消費${consumedMealsPfc.fat}g / 目標${targetFat.toFixed(0)}g (残り${remainingFat.toFixed(0)}g)
- 炭水化物: 消費${consumedMealsPfc.carbohydrate}g / 目標${targetCarbs.toFixed(0)}g (残り${remainingCarbs.toFixed(0)}g)
${profileContext}${trendContext}

以下の形式でJSONレスポンスを返してください:
{
  "advice": "具体的で実践的なアドバイス（${lang === 'ja' ? '日本語' : '英語'}で）",
  "suggestions": [
    "具体的な食品やメニューの提案1",
    "具体的な食品やメニューの提案2",
    "具体的な食品やメニューの提案3"
  ],
  "warning": "注意すべき点があれば記載（なければnull）"
}

注意事項:
- 残りカロリーが少ない場合は、軽めの食事を提案
- 特定の栄養素が大幅に不足している場合は、それを補う食品を優先的に提案
- 時間帯に適した現実的な提案をする
- ユーザーのプロフィールを考慮した提案をする`;

  return prompt;
}

serve(async (req) => {
  // CORS対応
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    if (!GEMINI_API_KEY) {
      throw new Error("GEMINI_API_KEY is not configured");
    }

    const requestData: MealAdviceRequest = await req.json();
    
    // 入力データのバリデーション
    if (!requestData.targetCalories || !requestData.targetPfcRatio || !requestData.consumedMealsPfc) {
      throw new Error("Missing required fields in request");
    }

    const prompt = generatePrompt(requestData);

    // Gemini APIを呼び出し
    const response = await fetch(
      `https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=${GEMINI_API_KEY}`,
      {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          contents: [
            {
              parts: [
                {
                  text: prompt,
                },
              ],
            },
          ],
          generationConfig: {
            temperature: 0.7,
            topK: 40,
            topP: 0.95,
            maxOutputTokens: 1024,
            responseMimeType: "application/json",
          },
        }),
      }
    );

    if (!response.ok) {
      const errorData = await response.text();
      console.error("Gemini API error:", errorData);
      throw new Error(`Gemini API error: ${response.status}`);
    }

    const data = await response.json();
    
    // レスポンスからテキストを抽出
    const generatedText = data.candidates?.[0]?.content?.parts?.[0]?.text;
    if (!generatedText) {
      throw new Error("No response generated from Gemini");
    }

    // JSONを抽出してパース
    let adviceData;
    try {
      // responseMimeTypeを使用した場合、直接JSONオブジェクトが返される
      if (typeof generatedText === 'string') {
        // 文字列の場合は、JSONを抽出
        const jsonMatch = generatedText.match(/\{[\s\S]*?\}/);
        if (!jsonMatch) {
          throw new Error("Failed to extract JSON from response");
        }
        adviceData = JSON.parse(jsonMatch[0]);
      } else {
        // すでにオブジェクトの場合
        adviceData = generatedText;
      }
    } catch (parseError) {
      console.error("JSON parse error:", parseError);
      console.error("Generated text:", generatedText);
      
      // フォールバックとして、基本的なアドバイスを返す
      adviceData = {
        advice: "栄養バランスを考慮した食事を心がけましょう。",
        suggestions: ["野菜を多めに摂取しましょう", "タンパク質を意識して摂りましょう"],
        warning: null
      };
    }

    // レスポンスフォーマットを統一
    const formattedResponse = {
      advice: adviceData.advice || "栄養バランスを考慮した食事を心がけましょう。",
      suggestions: adviceData.suggestions || [],
      warning: adviceData.warning || null,
      metadata: {
        generatedAt: new Date().toISOString(),
        userContext: requestData.userContext,
      }
    };

    return new Response(JSON.stringify(formattedResponse), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
      status: 200,
    });

  } catch (error) {
    console.error("Error in generate-meal-advice-v2:", error);
    
    return new Response(
      JSON.stringify({
        error: error.message || "An unexpected error occurred",
        advice: "申し訳ございません。アドバイスの生成中にエラーが発生しました。",
        suggestions: [],
        warning: null,
      }),
      {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status: 500,
      }
    );
  }
});