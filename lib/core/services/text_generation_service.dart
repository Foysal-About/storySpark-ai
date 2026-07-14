/// Common interface for the LLM backends that write stories
/// (Gemini, Claude), so the repository doesn't care which one is active.
abstract class TextGenerationService {
  Future<String> generateContent({
    required String systemPrompt,
    required String userPrompt,
  });
}
