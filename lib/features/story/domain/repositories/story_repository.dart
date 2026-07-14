import '../entities/generated_story.dart';
import '../entities/story_request.dart';

abstract class StoryRepository {
  Future<GeneratedStory> generateStory(StoryRequest request);
}
