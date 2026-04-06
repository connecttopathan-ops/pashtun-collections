class CollectionHandles {
  CollectionHandles._();

  static const String bridal = 'bridal-collection';
  static const String casualWear = 'casual-wear';
  static const String festive = 'festive-collection';
  static const String salwarKameez = 'salwar-kameez';
  static const String luxuryZari = 'luxury-zari';
}

class CollectionMeta {
  final String handle;
  final String title;
  final String emoji;

  const CollectionMeta({
    required this.handle,
    required this.title,
    required this.emoji,
  });
}

const List<CollectionMeta> allCollections = [
  CollectionMeta(
    handle: CollectionHandles.bridal,
    title: 'Bridal',
    emoji: '💍',
  ),
  CollectionMeta(
    handle: CollectionHandles.casualWear,
    title: 'Casual Wear',
    emoji: '👗',
  ),
  CollectionMeta(
    handle: CollectionHandles.festive,
    title: 'Festive',
    emoji: '✨',
  ),
  CollectionMeta(
    handle: CollectionHandles.salwarKameez,
    title: 'Salwar Kameez',
    emoji: '🪡',
  ),
  CollectionMeta(
    handle: CollectionHandles.luxuryZari,
    title: 'Luxury Zari',
    emoji: '🌟',
  ),
];
