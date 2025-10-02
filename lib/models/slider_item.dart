class SliderItem {
  final String? headline;
  final String imageUrl;
  final String? subheadline;
  final String type;
  final int order;
  final int? autoplay;
  final double? slideInterval;
  final String? subheadlineColor;

  SliderItem({
    this.headline,
    required this.imageUrl,
    this.subheadline,
    required this.type,
    required this.order,
    this.autoplay,
    this.slideInterval,
    this.subheadlineColor,
  });

  factory SliderItem.fromFirestore(Map<String, dynamic> data) {
    return SliderItem(
      headline: data['headline'],
      imageUrl: data['src'] ?? '',
      subheadline: data['subheadline'],
      type: data['type'] ?? 'image',
      order: data['order'] ?? 0,
      autoplay: data['autoplay'],
      slideInterval: (data['slideInterval'] as num?)?.toDouble(),
      subheadlineColor: data['subheadlineColor'],
    );
  }
}
