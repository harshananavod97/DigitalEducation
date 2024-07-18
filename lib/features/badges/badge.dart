class Badges {
  Badges({
    required this.id,
    required this.type,
    required this.badgeLabel,
    required this.badgeNote,
    required this.badgeReward,
    required this.badgeIcon,
    required this.badgeCounter,
    required this.status,
  });

  Badges.fromJson(Map<String, dynamic> json) {
    id = json['id'] as String? ?? '';
    type = json['type'] as String? ?? '';
    badgeLabel = json['badge_label'] as String? ?? '';
    badgeNote = json['badge_note'] as String? ?? '';
    badgeReward = json['badge_reward'] as String? ?? '';
    badgeIcon = json['badge_icon'] as String? ?? '';
    badgeCounter = json['badge_counter'] as String? ?? '';
    status = json['status'] as String? ?? '0';
  }

  late final String id;
  late final String type;
  late final String badgeLabel;
  late final String badgeNote;
  late final String badgeReward;
  late final String badgeIcon;
  late final String badgeCounter;

  // Status ; 0: Locked, 1: Unlocked, 2: Reward Unlocked
  late final String status;

  Badges copyWith({String? updatedStatus}) {
    return Badges(
      id: id,
      type: type,
      badgeLabel: badgeLabel,
      badgeNote: badgeNote,
      badgeReward: badgeReward,
      badgeIcon: badgeIcon,
      badgeCounter: badgeCounter,
      status: updatedStatus ?? status,
    );
  }
}
