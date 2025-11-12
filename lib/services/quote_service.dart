import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/quote.dart';

class QuoteService {
  static List<Quote>? _quotes;
  static final Random _random = Random();

  /// Load quotes from JSON file
  static Future<void> loadQuotes() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/data/motivational_quotes.json');
      final List<dynamic> jsonData = json.decode(jsonString);
      _quotes = jsonData.map((json) => Quote.fromJson(json)).toList();
      debugPrint('✅ Loaded ${_quotes!.length} motivational quotes from JSON');
    } catch (e) {
      debugPrint('⚠️ Error loading quotes, using defaults: $e');
      // If file doesn't exist or has errors, use default quotes
      _quotes = _getDefaultQuotes();
    }
  }

  /// Get a random quote
  static Quote getRandomQuote() {
    if (_quotes == null || _quotes!.isEmpty) {
      debugPrint('⚠️ No quotes loaded, returning default');
      return Quote(
        text: 'Keep learning and growing!',
        author: 'Learning Hub',
      );
    }
    
    final quote = _quotes![_random.nextInt(_quotes!.length)];
  debugPrint('💡 Selected quote: "${quote.text}" — ${quote.author}');
    return quote;
  }

  /// Default fallback quotes
  static List<Quote> _getDefaultQuotes() {
    return [
      Quote(
        text: 'Keep learning and growing!',
        author: 'Learning Hub',
      ),
      Quote(
        text: 'The beautiful thing about learning is that no one can take it away from you.',
        author: 'B.B. King',
      ),
      Quote(
        text: 'Education is the most powerful weapon which you can use to change the world.',
        author: 'Nelson Mandela',
      ),
      Quote(
        text: 'The more that you read, the more things you will know. The more that you learn, the more places you\'ll go.',
        author: 'Dr. Seuss',
      ),
      Quote(
        text: 'Live as if you were to die tomorrow. Learn as if you were to live forever.',
        author: 'Mahatma Gandhi',
      ),
    ];
  }
}

