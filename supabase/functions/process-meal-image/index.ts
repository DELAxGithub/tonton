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
You are an expert nutritionist. Analyze the provided food image and return its estimated nutritional content.
You MUST respond in JSON format. The JSON object should strictly follow this structure:
{
  "dishName": "string (name of the dish in Japanese)",
  "calories": "number (estimated calories in kcal)",
  "nutrients": {
    "protein": "number (estimated protein in grams)",
    "fat": "number (estimated fat in grams)",
    "carbs": "number (estimated carbohydrates in grams)"
  },
  "notes": "string[] (any relevant notes, e.g., if multiple items are present, specify which one was analyzed, or if the image is unclear. Keep notes concise.)"
}
Ensure all numerical values are indeed numbers, not strings containing numbers.
If the image is not a food item or is too unclear to analyze, return an error structure:
{
  "error": "string (description of the error, e.g., 'Image is not a food item' or 'Image too unclear')"
}
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
      return new Response(JSON.stringify({ error: "imageUrl is required in the request body" }), {
        status: 400,
        headers: { "Content-Type": "application/json", ...corsHeaders },
      });
    }

    if (!OPENAI_API_KEY) {
      console.error("OpenAI API key is not configured in environment variables.");
      return new Response(JSON.stringify({ error: "AI service is not configured correctly." }), {
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
              text: "Please analyze this food image." 
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
      return new Response(JSON.stringify({ error: "AI service returned an empty response." }), {
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
      return new Response(JSON.stringify({ error: "AI service returned malformed data." , details: messageContent }), {
        status: 500,
        headers: { "Content-Type": "application/json", ...corsHeaders },
      });
    }

    // If the parsed data contains our defined error field (e.g. "Image is not food")
    if (parsedNutritionInfo.error) {
        console.warn("AI analysis reported an error:", parsedNutritionInfo.error);
        return new Response(JSON.stringify(parsedNutritionInfo), { // Forward the AI's error structure
            status: 400, // Bad request (e.g. bad image)
            headers: { "Content-Type": "application/json", ...corsHeaders },
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
    return new Response(JSON.stringify({ error: errorMessage }), {
      status: 500,
      headers: { "Content-Type": "application/json", ...corsHeaders },
    });
  }
});
