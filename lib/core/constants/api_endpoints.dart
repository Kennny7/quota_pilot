// lib/core/constants/api_endpoints.dart

class ApiEndpoints {
  ApiEndpoints._();

  // OpenAI
  static const String openAiBase = 'https://api.openai.com/v1';
  static const String openAiUsage = '$openAiBase/usage';
  static const String openAiModels = '$openAiBase/models';

  // Google AI Studio (Gemini)
  static const String googleAiBase = 'https://generativelanguage.googleapis.com/v1beta';
  static const String googleAiModels = '$googleAiBase/models';

  // Anthropic Claude
  static const String anthropicBase = 'https://api.anthropic.com/v1';

  // xAI Grok
  static const String grokBase = 'https://api.x.ai/v1';

  // OpenRouter
  static const String openRouterBase = 'https://openrouter.ai/api/v1';
  static const String openRouterAuthKey = '$openRouterBase/auth/key';

  // Antigravity (Custom API / Free tier proxy)
  static const String antigravityBase = 'https://api.antigravity.dev/v1';
  static const String antigravityQuota = '$antigravityBase/user/quota';
}
