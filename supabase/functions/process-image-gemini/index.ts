import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
// Note: createClient import was present in PoC but not used in the provided PoC index.ts.
// If it's needed for auth or other Supabase interactions within the function, it should be kept.
// For now, mirroring the provided PoC's used imports.
// import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.7.1'

const GEMINI_API_KEY = Deno.env.get('GEMINI_API_KEY')
const GEMINI_API_URL = 'https://generativelanguage.googleapis.com/v1beta/models'
const GEMINI_MODEL_NAME = 'gemini-1.5-flash-latest' // PoC uses gemini-1.5-flash-latest

serve(async (req) => {
  try {
    // Ensure CORS headers are set for local development and deployed functions
    // This is a common requirement, though Supabase might handle some of this via project settings.
    // Adding them here explicitly for robustness.
    const corsHeaders = {
      'Access-Control-Allow-Origin': '*', // Or specific origins
      'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
    };

    // Handle OPTIONS preflight requests
    if (req.method === 'OPTIONS') {
      return new Response('ok', { headers: corsHeaders });
    }

    let imageData, mimeType;
    try {
      const body = await req.json();
      imageData = body.imageData;
      mimeType = body.mimeType;
    } catch (e) {
      console.error('Failed to parse request body:', e);
      return new Response(
        JSON.stringify({ error: 'リクエストの形式が正しくありません。正しいJSON形式で送信してください。' }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 400 }
      );
    }
    
    if (!imageData || !mimeType) {
      return new Response(
        JSON.stringify({ error: '画像データとMIMEタイプが必要です。両方をリクエストに含めてください。' }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 400 }
      );
    }
    
    // Call Gemini API
    const geminiResponse = await fetch(
      `${GEMINI_API_URL}/${GEMINI_MODEL_NAME}:generateContent?key=${GEMINI_API_KEY}`, // API key in query param
      {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          // 'x-goog-api-key': GEMINI_API_KEY, // Alternative: API key as header
        },
        body: JSON.stringify({
          contents: [
            {
              parts: [
                {
                  text: "この食事画像を分析し、以下の情報を有効なJSON形式で提供してください。日本食の場合は、日本語の名前を使用してください。以下を含めてください：1) food_name: 料理や食品の名前（日本語で）, 2) description: その料理の簡単な説明（日本語で）, 3) calories: 1食分の推定カロリー（数値のみ）, 4) protein_g: タンパク質（グラム単位、数値のみ）, 5) fat_g: 脂質（グラム単位、数値のみ）, 6) carbs_g: 炭水化物（グラム単位、数値のみ）。必ず日本語で回答してください。"
                },
                {
                  inline_data: {
                    mime_type: mimeType,
                    data: imageData
                  }
                }
              ]
            }
          ],
          generation_config: {
            temperature: 0.4, // As per PoC FINDINGS.md
            response_mime_type: "application/json"
          },
          systemInstruction: {
            parts: [
              {
                text: "あなたは料理の専門家です。必ず日本語で回答してください。料理名や説明文も必ず日本語で記述してください。提供する情報は正確なJSON形式にする必要がありますが、すべての文字列値は日本語で提供してください。"
              }
            ]
          }
        })
      }
    );
    
    if (!geminiResponse.ok) {
      const errorBody = await geminiResponse.text();
      console.error(`Gemini API error: ${geminiResponse.status}`, errorBody);
      return new Response(
        JSON.stringify({ error: `画像の解析に失敗しました。後ほど再度お試しください。`, details: errorBody }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: geminiResponse.status }
      );
    }

    const result = await geminiResponse.json();
    
    // Extract the JSON response from Gemini
    try {
      const textContent = result.candidates?.[0]?.content?.parts?.[0]?.text;
      if (!textContent) {
        console.error('No text content in Gemini response:', result);
        throw new Error('No text content in Gemini response');
      }
      
      // Attempt to parse as JSON
      // PoC FINDINGS.md mentions robust parsing for markdown etc.
      // For simplicity here, direct parsing is used. If issues arise, implement advanced parsing.
      let parsedResult;
      try {
        // Remove any markdown formatting if present
        const jsonText = textContent.replace(/```json\n?|\n?```/g, '').trim();
        parsedResult = JSON.parse(jsonText);
      } catch (jsonParseError) {
         console.error('Failed to parse textContent as JSON:', textContent, jsonParseError);
         // Fallback parsing strategies from FINDINGS.md could be implemented here if needed.
         // For now, re-throw or return error indicating parsing failure.
         throw new Error(`AIの応答をJSONとして解析できませんでした。`);
      }
      
      // Check if any string fields in the response are in English when they should be in Japanese
      if (parsedResult.food_name && 
          /^[a-zA-Z\s\-',.()]+$/.test(parsedResult.food_name) && 
          !/[ぁ-んァ-ン一-龯]/.test(parsedResult.food_name)) {
        console.warn("Response contains English food name instead of Japanese:", parsedResult.food_name);
        // Add a note about the English response
        parsedResult.notes = parsedResult.notes || [];
        parsedResult.notes.push("料理名が英語で返されました。アプリで修正してください。");
      }

      if (parsedResult.description && 
          /^[a-zA-Z\s\-',.()]+$/.test(parsedResult.description) && 
          !/[ぁ-んァ-ン一-龯]/.test(parsedResult.description)) {
        console.warn("Response contains English description instead of Japanese");
        // Add Japanese fallback description
        parsedResult.description = "AIが英語で説明を返しました。写真の食事の内容をご確認ください。";
      }

      return new Response(
        JSON.stringify(parsedResult),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    } catch (error) {
      console.error('Failed to parse or process Gemini response:', error.message, result);
      return new Response(
        JSON.stringify({ 
          error: `画像の解析結果を処理できませんでした。もう一度お試しください。`, 
          raw_gemini_response: result // Include raw Gemini response for debugging
        }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 500 }
      );
    }
  } catch (error) {
    console.error('Critical edge function error:', error.message, error.stack);
    
    // Determine if we should attempt to include CORS headers
    let headers = { 'Content-Type': 'application/json' };
    try {
      if (corsHeaders) {
        headers = { ...corsHeaders, 'Content-Type': 'application/json' };
      }
    } catch (e) {
      // Ignore error and use default headers
    }
    
    return new Response(
      // Avoid exposing detailed internal error messages like stack traces to the client
      JSON.stringify({ 
        error: '予期せぬエラーが発生しました。後ほど再度お試しください。',
        details: error.message 
      }),
      { headers, status: 500 }
    );
  }
})
