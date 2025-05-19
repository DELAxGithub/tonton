import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as developer;
import '../models/ai_advice_request.dart';
import '../models/ai_advice_response.dart';

class AiAdviceService {
  final SupabaseClient _supabaseClient;

  AiAdviceService(this._supabaseClient);

  Future<AiAdviceResponse> getMealAdvice(AiAdviceRequest request) async {
    try {
      final response = await _supabaseClient.functions.invoke(
        'generate-meal-advice', // Ensure this matches your Edge Function name
        body: request.toJson(),
      );

      if (response.status != 200) {
        // Attempt to parse error message from function
        String errorMessage = "Failed to get meal advice. Status code: ${response.status}";
        if (response.data != null && response.data['error'] != null) {
          errorMessage = response.data['error'].toString();
        } else if (response.data != null) {
          errorMessage = response.data.toString();
        }
        throw Exception(errorMessage);
      }
      
      if (response.data == null) {
        throw Exception("Received null data from meal advice function.");
      }

      return AiAdviceResponse.fromJson(response.data as Map<String, dynamic>);

    } on FunctionException catch (e) {
      // This can catch more specific Supabase function errors
      final errorMessage = e.details?.toString() ?? e.toString();
      developer.log('Supabase FunctionException: $errorMessage', name: 'TonTon.AiAdviceService');
      developer.log('Details: ${e.details}', name: 'TonTon.AiAdviceService'); // Log details which might contain response info
      // print('Response: ${e.response}'); // REMOVE THIS LINE or comment out

      String detailedMessage = "Error calling meal advice function";
      if (e.details != null) {
        detailedMessage += " Details: ${e.details}";
      } else {
        detailedMessage += " Details: ${e.toString()}"; // Fallback to e.toString() if details is null
      }
      throw Exception("Supabase function error: $detailedMessage");
    } catch (e) {
      developer.log('Error in AiAdviceService.getMealAdvice: $e', name: 'TonTon.AiAdviceService', error: e);
      throw Exception("An unexpected error occurred while fetching meal advice: ${e.toString()}");
    }
  }
}
