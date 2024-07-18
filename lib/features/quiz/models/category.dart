class Category {
  const Category({
    required this.isPlayed,
    required this.requiredCoins,
    this.languageId,
    this.categoryName,
    this.image,
    this.rowOrder,
    this.noOf,
    this.noOfQues,
    this.maxLevel,
    this.isPremium = false,
    this.hasUnlocked = false,
    this.id,
  });

  Category.fromJson(Map<String, dynamic> json)
      : isPlayed = (json['is_play'] as String? ?? '1') == '1',
        id = json['id'] as String?,
        languageId = json['language_id'] as String?,
        categoryName = json['category_name'] as String?,
        image = json['image'] as String?,
        rowOrder = json['row_order'] as String?,
        noOf = json['no_of'] as String?,
        noOfQues = json['no_of_que'] as String?,
        maxLevel = json['maxlevel'] as String?,
        isPremium = (json['is_premium'] ?? '0') == '1',
        hasUnlocked = (json['has_unlocked'] ?? '0') == '1',
        requiredCoins = int.parse(json['coins'] as String? ?? '0');

  final String? id;
  final String? languageId;
  final String? categoryName;
  final String? image;
  final String? rowOrder;
  final String? noOf;
  final String? noOfQues;
  final String? maxLevel;
  final bool isPlayed;
  final bool isPremium;
  final bool hasUnlocked;
  final int requiredCoins;

  Category copyWith({bool? hasUnlocked}) {
    return Category(
      isPlayed: isPlayed,
      id: id,
      languageId: languageId,
      categoryName: categoryName,
      image: image,
      rowOrder: rowOrder,
      noOf: noOf,
      noOfQues: noOfQues,
      maxLevel: maxLevel,
      isPremium: isPremium,
      hasUnlocked: hasUnlocked ?? this.hasUnlocked,
      requiredCoins: requiredCoins,
    );
  }
}
