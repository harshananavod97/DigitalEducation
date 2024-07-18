class Subcategory {
  const Subcategory({
    required this.isPlayed,
    required this.requiredCoins,
    this.id,
    this.image,
    this.languageId,
    this.mainCatId,
    this.maxLevel,
    this.noOfQue,
    this.rowOrder,
    this.status,
    this.subcategoryName,
    this.isPremium = false,
    this.hasUnlocked = false,
  });

  Subcategory.fromJson(Map<String, dynamic> json)
      : id = json['id'] as String?,
        image = json['image'] as String?,
        isPlayed = (json['is_play'] as String? ?? '1') == '1',
        languageId = json['language_id'] as String,
        mainCatId = json['maincat_id'] as String? ?? '',
        maxLevel = json['maxlevel'] as String? ?? '',
        noOfQue = json['no_of_que'] as String? ?? '',
        rowOrder = json['row_order'] as String?,
        status = json['status'] as String?,
        subcategoryName = json['subcategory_name'] as String? ?? '',
        isPremium = (json['is_premium'] ?? '0') == '1',
        hasUnlocked = (json['has_unlocked'] ?? '0') == '1',
        requiredCoins = int.parse(json['coins'] as String? ?? '0');

  final String? id;
  final String? image;
  final String? languageId;
  final String? mainCatId;
  final String? maxLevel;
  final String? noOfQue;
  final String? rowOrder;
  final String? status;
  final String? subcategoryName;
  final bool isPlayed;
  final bool isPremium;
  final bool hasUnlocked;
  final int requiredCoins;

  Subcategory copyWith({bool? hasUnlocked}) => Subcategory(
        isPlayed: isPlayed,
        requiredCoins: requiredCoins,
        id: id,
        image: image,
        languageId: languageId,
        mainCatId: mainCatId,
        maxLevel: maxLevel,
        noOfQue: noOfQue,
        rowOrder: rowOrder,
        status: status,
        subcategoryName: subcategoryName,
        isPremium: isPremium,
        hasUnlocked: hasUnlocked ?? this.hasUnlocked,
      );
}
