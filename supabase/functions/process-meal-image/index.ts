import { serve } from "https://deno.land/std@0.168.0/http/server.ts"; // Ensure this version is suitable or update as needed
import { OpenAI } from "https://esm.sh/openai@4.20.0"; // Ensure this version is suitable or update as needed

// OpenAI APIキーを環境変数から安全に読み込み
const OPENAI_API_KEY = Deno.env.get("OPENAI_API_KEY");
if (!OPENAI_API_KEY) {
  console.error("FATAL: OPENAI_API_KEY is not set in environment variables.");
  // Consider how the function should behave if the key is missing at startup.
  // For now, it will proceed and fail at the API call.
}
const openai = new OpenAI({ apiKey: OPENAI_API_KEY });

// From docs/ai-config.md (structure)
// {
//   "dishName": string,
//   "calories": number,
//   "nutrients": {
//     "protein": number,
//     "fat": number,
//     "carbs": number
//   },
//   "notes": string[]
// }
// The prompt below is simplified to get core nutrients first, can be expanded.

const FOOD_ANALYSIS_PROMPT_SYSTEM_MESSAGE = `
あなたは栄養士の専門家です。提供された食事画像を分析し、その推定栄養成分を返してください。
必ず日本語で回答し、以下の厳密なJSON形式で応答する必要があります：

{
  "dishName": "文字列（必ず日本語で料理名を記入）",
  "calories": "数値（推定カロリー、kcal単位）",
  "nutrients": {
    "protein": "数値（タンパク質、グラム単位）",
    "fat": "数値（脂質、グラム単位）",
    "carbs": "数値（炭水化物、グラム単位）"
  },
  "notes": "文字列配列（関連するメモ、例：複数の食品がある場合はどれを分析したか、または画像が不明確な場合など。メモは簡潔に。すべて日本語で記述。）"
}

すべての数値は必ず数値型であり、数値を含む文字列ではないことを確認してください。
画像が食品でない、または分析するには不明確すぎる場合は、以下のエラー構造を返してください：

{
  "error": "文字列（エラーの説明、例：「画像に食品が写っていません」または「画像が不明瞭です」など。必ず日本語で記述。）"
}

すべての文字列フィールド（料理名、説明、メモ、エラーメッセージなど）は必ず日本語で記述してください。英語での回答は不可です。
`;

serve(async (req) => {
  // CORSヘッダーの設定
  const corsHeaders = {
    'Access-Control-Allow-Origin': '*', // 本番環境ではより厳密なオリジンを指定
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
    'Access-Control-Allow-Methods': 'POST, OPTIONS', // Allow POST and OPTIONS
  };

  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }
  
  if (req.method !== "POST") {
    return new Response(JSON.stringify({ error: "Method Not Allowed. Please use POST." }), { 
      status: 405, 
      headers: { "Content-Type": "application/json", ...corsHeaders }
    });
  }

  try {
    const body = await req.json();
    const imageUrl = body.imageUrl;

    if (!imageUrl) {
      return new Response(JSON.stringify({ error: "画像URLが必要です。リクエストに画像URLを含めてください。" }), {
        status: 400,
        headers: { "Content-Type": "application/json", ...corsHeaders },
      });
    }

    if (!OPENAI_API_KEY) {
      console.error("OpenAI API key is not configured in environment variables.");
      return new Response(JSON.stringify({ error: "AIサービスが正しく設定されていません。管理者にお問い合わせください。" }), {
        status: 500, // Internal Server Error
        headers: { "Content-Type": "application/json", ...corsHeaders },
      });
    }
    
    console.log(`Received image URL for analysis: ${imageUrl}`);

    const gptResponse = await openai.chat.completions.create({
      model: "gpt-4o", 
      messages: [
        {
          role: "system",
          content: FOOD_ANALYSIS_PROMPT_SYSTEM_MESSAGE,
        },
        {
          role: "user",
          content: [
            { 
              type: "text", 
              text: "この食事画像を分析して、必ず日本語で回答してください。料理名も説明も全て日本語で記述してください。" 
            },
            {
              type: "image_url",
              image_url: {
                url: imageUrl,
                // detail: "low" // Consider "low" or "auto" for cost/speed vs detail. Default is "auto".
              },
            },
          ],
        },
      ],
      response_format: { type: "json_object" }, 
      max_tokens: 500, // Adjusted for potentially more detailed notes or complex dishes
      temperature: 0.2, // Lower temperature for more deterministic output
    });

    const messageContent = gptResponse.choices[0].message.content;
    if (!messageContent) {
      console.error("OpenAI API response content is null or empty.");
      return new Response(JSON.stringify({ error: "AIサービスが空の応答を返しました。もう一度お試しください。" }), {
        status: 500,
        headers: { "Content-Type": "application/json", ...corsHeaders },
      });
    }
    
    console.log("OpenAI response:", messageContent);

    // Attempt to parse the JSON. If it's an error structure from our prompt, or malformed, handle it.
    let parsedNutritionInfo;
    try {
      parsedNutritionInfo = JSON.parse(messageContent);
    } catch (parseError) {
      console.error("Failed to parse OpenAI response JSON:", parseError, "Raw content:", messageContent);
      return new Response(JSON.stringify({ error: "AIサービスが正しい形式のデータを返しませんでした。もう一度お試しください。", details: messageContent }), {
        status: 500,
        headers: { "Content-Type": "application/json", ...corsHeaders },
      });
    }

    // If the parsed data contains our defined error field (e.g. "Image is not food")
    if (parsedNutritionInfo.error) {
        console.warn("AI analysis reported an error:", parsedNutritionInfo.error);
        
        // Check if error message is in English and provide Japanese fallback
        if (parsedNutritionInfo.error && 
            /^[a-zA-Z\s\-',.()]+$/.test(parsedNutritionInfo.error) && 
            !/[ぁ-んァ-ン一-龯]/.test(parsedNutritionInfo.error)) {
          console.warn("Error response is in English instead of Japanese:", parsedNutritionInfo.error);
          // Replace with generic Japanese error message
          parsedNutritionInfo.error = "画像の解析ができませんでした。別の画像を試してください。";
        }
        
        return new Response(JSON.stringify(parsedNutritionInfo), { // Forward the AI's error structure
            status: 400, // Bad request (e.g. bad image)
            headers: { "Content-Type": "application/json", ...corsHeaders },
        });
    }
    
    // Check if any string fields are in English instead of Japanese
    if (parsedNutritionInfo.dishName && 
        /^[a-zA-Z\s\-',.()]+$/.test(parsedNutritionInfo.dishName) && 
        !/[ぁ-んァ-ン一-龯]/.test(parsedNutritionInfo.dishName)) {
      console.warn("Response contains English dish name instead of Japanese:", parsedNutritionInfo.dishName);
      // Add a note about the English response
      parsedNutritionInfo.notes = parsedNutritionInfo.notes || [];
      parsedNutritionInfo.notes.push("料理名が英語で返されました。アプリで修正してください。");
    }

    // Check for English descriptions
    if (parsedNutritionInfo.description && 
        /^[a-zA-Z\s\-',.()]+$/.test(parsedNutritionInfo.description) && 
        !/[ぁ-んァ-ン一-龯]/.test(parsedNutritionInfo.description)) {
      console.warn("Response contains English description instead of Japanese");
      // Add Japanese fallback description
      parsedNutritionInfo.description = "AIが英語で説明を返しました。写真の食事の内容をご確認ください。";
    }
    
    // Check for English notes
    if (Array.isArray(parsedNutritionInfo.notes)) {
      parsedNutritionInfo.notes = parsedNutritionInfo.notes.map(note => {
        if (/^[a-zA-Z\s\-',.()]+$/.test(note) && !/[ぁ-んァ-ン一-龯]/.test(note)) {
          console.warn("Response contains English note instead of Japanese:", note);
          return "AIが英語でメモを返しました。";
        }
        return note;
      });
    }


    return new Response(
      JSON.stringify(parsedNutritionInfo),
      {
        headers: { "Content-Type": "application/json", ...corsHeaders },
        status: 200,
      }
    );
  } catch (error) {
    console.error("Error processing image in Edge Function:", error);
    // Check if error is an OpenAI API error to provide more specific feedback
    let errorMessage = "Failed to process image due to an internal error.";
    if (error.response && error.response.data && error.response.data.error) { // OpenAI specific error structure
        errorMessage = `AI service error: ${error.response.data.error.message}`;
    } else if (error.message) {
        errorMessage = error.message;
    }
    // Provide a generic Japanese error message for the user
    return new Response(JSON.stringify({ error: "画像処理中にエラーが発生しました。もう一度お試しください。", details: errorMessage }), {
      status: 500,
      headers: { "Content-Type": "application/json", ...corsHeaders },
    });
  }
});
