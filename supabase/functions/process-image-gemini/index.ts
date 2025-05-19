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
        JSON.stringify({ error: 'Invalid JSON request body' }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 400 }
      );
    }
    
    if (!imageData || !mimeType) {
      return new Response(
        JSON.stringify({ error: 'Image data and MIME type are required' }),
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
                  text: "Analyze this food image and provide the following information in valid JSON format. For a Japanese dish, use both Japanese and English names. Include: 1) food_name: Name of the dish or food item, 2) description: Brief description of what it is, 3) calories: Estimated calories per serving (number only), 4) protein_g: Protein in grams (number only), 5) fat_g: Fat in grams (number only), 6) carbs_g: Carbohydrates in grams (number only)"
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
          }
        })
      }
    );
    
    if (!geminiResponse.ok) {
      const errorBody = await geminiResponse.text();
      console.error(`Gemini API error: ${geminiResponse.status}`, errorBody);
      return new Response(
        JSON.stringify({ error: `Gemini API request failed with status ${geminiResponse.status}`, details: errorBody }),
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
        parsedResult = JSON.parse(textContent);
      } catch (jsonParseError) {
         console.error('Failed to parse textContent as JSON:', textContent, jsonParseError);
         // Fallback parsing strategies from FINDINGS.md could be implemented here if needed.
         // For now, re-throw or return error indicating parsing failure.
         throw new Error(`Failed to parse AI's text response as JSON. Raw text: ${textContent}`);
      }

      return new Response(
        JSON.stringify(parsedResult),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    } catch (error) {
      console.error('Failed to parse or process Gemini response:', error.message, result);
      return new Response(
        JSON.stringify({ 
          error: `Failed to parse or process AI response: ${error.message}`, 
          raw_gemini_response: result // Include raw Gemini response for debugging
        }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 500 }
      );
    }
  } catch (error) {
    console.error('Critical edge function error:', error.message, error.stack);
    return new Response(
      // Avoid exposing detailed internal error messages like stack traces to the client
      JSON.stringify({ error: 'An unexpected error occurred in the edge function.' }),
      // CORS headers might be missing here if error happens before they are set.
      { headers: { 'Content-Type': 'application/json' }, status: 500 }
    );
  }
})
