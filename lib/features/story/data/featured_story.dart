import '../domain/entities/saved_story.dart';

/// The bundled story shown on the home "Featured tonight" card, so the app
/// has something delightful to read before the first story is generated.
abstract final class FeaturedStory {
  static const id = 'featured_dragon_roar';
  static const title = 'The Dragon Who Lost His Roar';
  static const hero = 'Dragon';
  static const location = 'Castle';
  static const mood = '😊';
  static const lengthMinutes = 7;

  static SavedStory build() => SavedStory(
        id: id,
        title: title,
        content: _content,
        hero: hero,
        location: location,
        mood: mood,
        lengthMinutes: lengthMinutes,
        savedAt: DateTime.now(),
      );

  static const _content = '''
High on a hill, in a castle with towers like birthday candles, lived a young dragon named Ember. Ember had shiny copper scales, wings that folded like umbrellas, and — until last Tuesday — the most magnificent roar in the whole kingdom.

But on Tuesday morning, Ember opened his mouth to greet the sun and out came... a squeak. A tiny, squeaky squeak, like a mouse stepping on a rubber duck.

"Oh no," whispered Ember. "I've lost my roar!"

He looked under his bed of warm river stones. He looked inside his treasure chest, between the golden coins and his collection of extra-crunchy pinecones. He even looked in the pantry, behind the jars of toasted marshmallows. No roar anywhere.

So Ember set off through the castle to find it.

First he met Greta, the castle cook, who was stirring a pot of pumpkin soup taller than Ember himself. "Greta, have you seen my roar?"

Greta tapped her wooden spoon. "Hmm. I once lost my whistle in a pot of soup. Maybe you swallowed your roar with your breakfast! Try a spoonful of something warm."

Ember sipped the pumpkin soup. It was cozy and delicious — but when he opened his mouth, out came a squeak with a hiccup on top.

Next he found Sir Pemberton, the bravest knight in the castle, polishing his armor until it sparkled. "Sir Pemberton, have you seen my roar?"

The knight thought hard. "When I lose my courage, I stand very tall and count to three. Perhaps your roar is hiding because you're worried. Try standing tall!"

Ember stood as tall as he could. He counted one, two, three. He opened his mouth wide and... squeak-squeak. Even quieter than before.

Ember's wings drooped all the way down the spiral stairs and into the courtyard, where little Princess Poppy was sitting under the apple tree, hugging her knees. She looked as droopy as Ember felt.

"Hello, Ember," she sniffled. "I'm sad today. My kite flew over the wall, and everyone is too busy to help me find it."

Ember forgot all about his roar. "I'm not too busy," he said. "I don't have my roar, but I still have my wings."

Princess Poppy climbed onto Ember's back, and up they swooped, over the towers and past the flags, until they spotted the runaway kite tangled in a berry bush beyond the wall. Ember untangled it gently with his claws, careful not to tear even one corner.

"You found it!" Poppy cheered, hugging his neck. "You're the kindest dragon in the whole kingdom!"

And something warm and fizzy filled Ember up from his toes to his ears — like sunshine and soup and birthday cake all at once. He was so happy that he threw back his head and laughed.

But it didn't come out as a laugh.

ROOOOOOAAAAARRRR!

The magnificent sound rolled over the castle like friendly thunder. The flags fluttered. The apples wobbled. Greta cheered from the kitchen window, and Sir Pemberton saluted with his shiniest glove.

"My roar!" Ember gasped. "It came back!"

Princess Poppy giggled. "It never left, silly. It was just waiting for your heart to feel big again. Roars don't come from tummies or from standing tall. They come from happiness."

From that day on, whenever anyone in the castle lost something — a kite, a whistle, or even a smile — Ember the dragon was the first to help. And every single time, his roar boomed louder than ever, because helping was the thing that made his heart the biggest.

And at night, when the stars came out over the candle-shaped towers, Ember curled up on his warm river stones and practiced his very quietest, happiest roar — which sounded, just a little, like a purr.

The end.
''';
}