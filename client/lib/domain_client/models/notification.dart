/// One line in a member's own inbox (`GET /v1/me/notifications`).
class AppNotification {
  const AppNotification({
    required this.id,
    required this.dynamicId,
    required this.eventType,
    required this.title,
    required this.body,
    required this.neutralBody,
    required this.deepLink,
    required this.createdAt,
    this.readAt,
    this.muted = false,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) => AppNotification(
        id: json['id'] as String,
        dynamicId: json['dynamicId'] as String,
        eventType: json['eventType'] as String,
        title: json['title'] as String? ?? '',
        body: json['body'] as String? ?? '',
        neutralBody: json['neutralBody'] as String? ?? '',
        deepLink: json['deepLink'] as String? ?? '/today',
        createdAt: DateTime.parse(json['createdAt'] as String),
        readAt: (json['readAt'] as String?) == null ? null : DateTime.parse(json['readAt'] as String),
        muted: json['muted'] as bool? ?? false,
      );

  final String id;
  final String dynamicId;
  final String eventType;
  final String title;
  final String body;

  /// What the lockscreen may say when the person asked for nothing personal.
  final String neutralBody;

  /// Server-relative, without the Dynamic: `/today`, `/rules`, `/points`,
  /// `/record/{day}`, `/occurrences/{id}`.
  final String deepLink;
  final DateTime createdAt;
  final DateTime? readAt;
  final bool muted;

  bool get unread => readAt == null;

  /// The body a device notification carries: neutral when asked, else the
  /// real one. Pure, so the choice is testable without a device.
  String bodyFor({required bool neutralLockscreen}) =>
      neutralLockscreen ? neutralBody : body;
}

class NotificationInbox {
  const NotificationInbox({required this.items, required this.unreadCount});

  factory NotificationInbox.fromJson(Map<String, dynamic> json) => NotificationInbox(
        items: ((json['items'] as List<dynamic>?) ?? const [])
            .cast<Map<String, dynamic>>()
            .map(AppNotification.fromJson)
            .toList(growable: false),
        unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
      );

  final List<AppNotification> items;
  final int unreadCount;
}

/// `GET/PUT /v1/me/notification-mute-settings`. The person's own; no role
/// and no partner sees it.
class NotificationMuteSettings {
  const NotificationMuteSettings({
    this.neutralLockscreen = false,
    this.deliverDigestHours,
    this.mutedTypes = const {},
  });

  factory NotificationMuteSettings.fromJson(Map<String, dynamic> json) =>
      NotificationMuteSettings(
        neutralLockscreen: json['neutralLockscreen'] as bool? ?? false,
        deliverDigestHours: (json['deliverDigestHours'] as num?)?.toInt(),
        mutedTypes: ((json['mutedTypes'] as List<dynamic>?) ?? const []).cast<String>().toSet(),
      );

  final bool neutralLockscreen;

  /// Null: every delivery is announced at once. Otherwise `s 交付` is folded
  /// into one notice every N hours.
  final int? deliverDigestHours;
  final Set<String> mutedTypes;

  /// The event types a person may mute, in the order of the 通知 table
  /// (product/02-surfaces.md).
  static const mutableTypes = <String>[
    'occurrence_delivered',
    'occurrence_flagged',
    'disposition_set',
    'day_comment',
    'd_award',
    'redemption_requested',
    'd_note_reminder',
  ];

  NotificationMuteSettings copyWith({
    bool? neutralLockscreen,
    int? deliverDigestHours,
    bool clearDigest = false,
    Set<String>? mutedTypes,
  }) =>
      NotificationMuteSettings(
        neutralLockscreen: neutralLockscreen ?? this.neutralLockscreen,
        deliverDigestHours: clearDigest ? null : (deliverDigestHours ?? this.deliverDigestHours),
        mutedTypes: mutedTypes ?? this.mutedTypes,
      );
}
