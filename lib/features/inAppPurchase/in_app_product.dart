class InAppProduct {
  InAppProduct({
    required this.id,
    required this.title,
    required this.coins,
    required this.productId,
    required this.image,
    required this.desc,
    required this.isActive,
    required this.isRemoveAds,
  });

  factory InAppProduct.fromJson(Map<String, dynamic> json) => InAppProduct(
        id: json['id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        coins: int.parse(json['coins'] as String? ?? '0'),
        productId: json['product_id'] as String? ?? '',
        image: json['image'] as String? ?? '',
        desc: json['description'] as String? ?? '',
        isActive: (json['status'] ?? '0') == '1',
        isRemoveAds: (json['type'] ?? '0') == '1',
      );

  final String id;
  final String title;
  final int coins;
  final String productId;
  final String image;
  final String desc;
  final bool isActive;
  final bool isRemoveAds;

  @override
  String toString() => '\n{ '
      'id: $id, '
      'title : $title, '
      'coins : $coins, '
      'product_id : $productId, '
      'image : $image, '
      'desc : $desc, '
      'isActive : $isActive, '
      'isRemoveAds: $isRemoveAds'
      ' }';
}
