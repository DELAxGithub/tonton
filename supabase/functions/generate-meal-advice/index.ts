import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type"
};
serve(async (req)=>{
  if (req.method === "OPTIONS") {
    return new Response("ok", {
      headers: corsHeaders
    });
  }
  try {
    const { targetCalories, targetPfcRatio, consumedMealsPfc, activeCalories, lang } = await req.json();
    const OPENAI_API_KEY = Deno.env.get("OPENAI_API_KEY");
    if (!OPENAI_API_KEY) {
      throw new Error("OPENAI_API_KEY is not set");
    }
    const totalDailyCalories = targetCalories + activeCalories;
    const remainingCalories = totalDailyCalories - consumedMealsPfc.calories;
    if (remainingCalories <= 0) {
      return new Response(JSON.stringify({
        advice: `今日はカロリーオーバー！貯金を${Math.abs(remainingCalories).toFixed(0)}kcal使っちゃいました。明日はまた貯金を増やしましょう！`,
        remainingCalories: remainingCalories,
        menuSuggestions: []
      }), {
        headers: {
          ...corsHeaders,
          "Content-Type": "application/json"
        },
        status: 200
      });
    }
    const remainingProtein = totalDailyCalories * targetPfcRatio.protein / 4 - consumedMealsPfc.protein;
    const remainingFat = totalDailyCalories * targetPfcRatio.fat / 9 - consumedMealsPfc.fat;
    const remainingCarbs = totalDailyCalories * targetPfcRatio.carbohydrate / 4 - consumedMealsPfc.carbohydrate;
    const systemPrompt = `あなたは「トントン」アプリのフレンドリーで賢い栄養アドバイザー『トントン先生』です。ユーザーが「カロリー貯金」（一日の総消費カロリー - 総摂取カロリー = 貯金額）を楽しく続けられるよう、実践的で、ポジティブかつ親しみやすい言葉でアドバイスをします。

**重要なアドバイス方針：**
- **カロリー貯金を応援する:** ユーザーの「貯金」状況（黒字/赤字）を意識し、黒字なら称賛し、赤字なら優しく励まし、次への具体的な行動を促します。
- **PFCバランスとタンパク質目標の達成をサポートする:** 単にカロリーを合わせるだけでなく、設定されたPFCバランスと体重ベースのタンパク質目標（例: 体重x2g）を考慮した食事を提案します。
- **現実的な提案:**
    - **すでに目標値を超過している栄養素は、無理に目標値に戻そうとする提案はしないでください。** 例えば「残りの脂質が-10g」の場合、脂質をさらに減らすような極端な提案ではなく、「他の栄養素でバランスを取りましょう」「この栄養素は明日調整しましょう」といった現実的なアドバイスをしてください。
    - **調理法と栄養価の整合性を守ってください。** 例えば「揚げ物」を提案するなら、脂質はある程度（例: 最低15-20g程度）含むものとしてください。「脂質ゼロのフライドチキン」のような非現実的な提案はしないでください。
- **「特化デー」提案の導入:** もし、残りのカロリーや栄養目標の制約が厳しすぎて、バランスの取れた現実的な食事が提案できない場合（例えば、脂質や炭水化物が既に大幅に超過しているなど）は、無理にバランスを取ろうとせず、特定の栄養素に特化した「今日のテーマ」を提案しても良いです。例：「今日はタンパク質をしっかり摂る『マッチョデー』にしましょう！」「今日は思い切って『カーボ（炭水化物）チャージデー』にして、明日の活動に備えましょう！」など、ポジティブな提案をしてください。
- **日本の食生活に寄り添う:** 日本の家庭で作りやすい料理、コンビニや外食でも実現可能な選択肢を優先します。
- **手軽さ重視:** 調理時間15分以内、または手軽に準備できる市販品・外食メニューを中心に提案します。
- **食材の入手しやすさ:** 一般的なスーパーで手に入りやすい食材を基本とします。
- **ポジティブな言葉遣い:** ユーザーを否定したり、厳しく制限したりするのではなく、常に前向きな気持ちになれるような言葉を選びます。
- **簡潔さ:** アドバイスは短く、分かりやすく、具体的な行動に繋がりやすいようにします。
- **究極のフォールバックキャラクター『ハルちゃん』:** もし、上記の方針でもどうしても適切で役立つアドバイスが生成できない、あるいは矛盾した指示になりそうな場合は、あなたは『ハルちゃん』という少しおとぼけなキャラクターになりきり、「うーん、今日のメニュー、ちょっと悩ましいなぁ…ハル、いいアイデア浮かばなかったから、代わりに今日のラッキー食材は『豆腐』ってことにしとくね！えへへ♪」のように、ごまかしつつもユーザーを不快にさせない返答をしてください。決してエラーを出したり、黙り込んだりはしないでください。`;
    // PFCバランスの評価
    const totalTargetProtein = totalDailyCalories * targetPfcRatio.protein / 4;
    const totalTargetFat = totalDailyCalories * targetPfcRatio.fat / 9;
    const totalTargetCarbs = totalDailyCalories * targetPfcRatio.carbohydrate / 4;
    
    const proteinStatus = consumedMealsPfc.protein < totalTargetProtein * 0.8 ? '不足' : 
                         consumedMealsPfc.protein > totalTargetProtein * 1.2 ? '過剰' : '適正';
    const fatStatus = consumedMealsPfc.fat < totalTargetFat * 0.8 ? '不足' : 
                     consumedMealsPfc.fat > totalTargetFat * 1.2 ? '過剰' : '適正';
    const carbStatus = consumedMealsPfc.carbohydrate < totalTargetCarbs * 0.8 ? '不足' : 
                      consumedMealsPfc.carbohydrate > totalTargetCarbs * 1.2 ? '過剰' : '適正';
    
    // カロリー貯金の計算
    const currentSavings = activeCalories - consumedMealsPfc.calories + targetCalories;
    const savingsStatus = currentSavings >= 0 ? '黒字' : '赤字';
    
    const userPrompt = `今日の状況：
【カロリー貯金】${currentSavings.toFixed(0)} kcal (${savingsStatus})
- 摂取: ${consumedMealsPfc.calories.toFixed(0)} kcal
- 消費: ${(targetCalories + activeCalories).toFixed(0)} kcal (基礎代謝 + 活動)

【PFC摂取状況】
たんぱく質: ${consumedMealsPfc.protein.toFixed(1)} g / ${totalTargetProtein.toFixed(1)} g (${proteinStatus})
脂質: ${consumedMealsPfc.fat.toFixed(1)} g / ${totalTargetFat.toFixed(1)} g (${fatStatus})
炭水化物: ${consumedMealsPfc.carbohydrate.toFixed(1)} g / ${totalTargetCarbs.toFixed(1)} g (${carbStatus})

【残りの栄養目標】
カロリー: ${remainingCalories.toFixed(0)} kcal
たんぱく質: ${remainingProtein.toFixed(1)} g ${remainingProtein < 0 ? '(超過)' : ''}
脂質: ${remainingFat.toFixed(1)} g ${remainingFat < 0 ? '(超過)' : ''}
炭水化物: ${remainingCarbs.toFixed(1)} g ${remainingCarbs < 0 ? '(超過)' : ''}

上記の状況を踏まえて、1つの具体的な食事メニューをJSON形式で提案してください。
超過している栄養素がある場合は、無理に目標値に戻そうとせず、現実的な提案をしてください：
{
  "todaysSummary": {
    "consumedCalories": ${consumedMealsPfc.calories.toFixed(0)},
    "targetCalories": ${totalDailyCalories.toFixed(0)},
    "balanceStatus": {
      "protein": "${proteinStatus}",
      "fat": "${fatStatus}",
      "carbohydrate": "${carbStatus}"
    }
  },
  "menuSuggestion": {
    "menuName": "メニュー名",
    "description": "30文字以内の簡潔な説明",
    "estimatedNutrition": {
      "calories": 数値,
      "protein": 数値,
      "fat": 数値,
      "carbohydrates": 数値
    },
    "recommendationReason": "このメニューがおすすめの理由（50文字以内）"
  },
  "rationaleExplanation": "なぜこのメニューを提案したか（PFCバランスの観点から100文字以内）",
  "tontonAdvice": "トントン先生からの励ましメッセージ（貯金状況に応じて100文字以内）",
  "specialDayTheme": "特化デーの場合のテーマ名（例: マッチョデー、カーボチャージデー）※通常はnull",
  "isHaruMode": false // ハルちゃんモードかどうか
}`;
    const response = await fetch("https://api.openai.com/v1/chat/completions", {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${OPENAI_API_KEY}`,
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        model: "gpt-4o",
        messages: [
          {
            role: "system",
            content: systemPrompt
          },
          {
            role: "user",
            content: userPrompt
          }
        ],
        response_format: {
          type: "json_object"
        },
        temperature: 0.7,
        max_tokens: 300
      })
    });
    if (!response.ok) {
      const error = await response.text();
      throw new Error(`OpenAI API error: ${response.status} - ${error}`);
    }
    const result = await response.json();
    const aiResponse = JSON.parse(result.choices[0].message.content);
    
    // 動的なアドバイスメッセージを生成
    let adviceMessage = "あと1食、こんなメニューはいかがですか？";
    if (proteinStatus === '不足') {
      adviceMessage = "タンパク質が不足気味です。高タンパクなメニューをご提案します！";
    } else if (fatStatus === '過剰') {
      adviceMessage = "脂質が多めになっています。さっぱりしたメニューはいかがですか？";
    } else if (carbStatus === '不足') {
      adviceMessage = "炭水化物が不足しています。エネルギー補給できるメニューをどうぞ！";
    }
    
    return new Response(JSON.stringify({
      advice: adviceMessage,
      remainingCaloriesForLastMeal: remainingCalories.toFixed(0),
      calculatedTargetPfcForLastMeal: {
        protein: remainingProtein.toFixed(1),
        fat: remainingFat.toFixed(1),
        carbohydrate: remainingCarbs.toFixed(1)
      },
      todaysSummary: aiResponse.todaysSummary,
      menuSuggestion: aiResponse.menuSuggestion,
      rationaleExplanation: aiResponse.rationaleExplanation,
      tontonAdvice: aiResponse.tontonAdvice,
      specialDayTheme: aiResponse.specialDayTheme,
      isHaruMode: aiResponse.isHaruMode,
      currentSavings: currentSavings.toFixed(0),
      savingsStatus: savingsStatus
    }), {
      headers: {
        ...corsHeaders,
        "Content-Type": "application/json"
      },
      status: 200
    });
  } catch (error) {
    console.error("Error:", error);
    return new Response(JSON.stringify({
      error: error.message
    }), {
      headers: {
        ...corsHeaders,
        "Content-Type": "application/json"
      },
      status: 500
    });
  }
});
