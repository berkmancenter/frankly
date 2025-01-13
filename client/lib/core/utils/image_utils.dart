import 'dart:math';

String generateRandomImageUrl({int? seed, int? resolution}) =>
    'https://picsum.photos/seed/${seed ?? Random().nextInt(1000)}/${resolution ?? 512}';
