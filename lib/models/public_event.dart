import 'package:cloud_firestore/cloud_firestore.dart';

class EventCategory {
  final String id;
  final String name;
  final String icon;

  const EventCategory({
    required this.id,
    required this.name,
    required this.icon,
  });

  static const List<EventCategory> defaultCategories = [
    EventCategory(id: 'eglence', name: 'Eğlence', icon: '🎉'),
    EventCategory(id: 'spor', name: 'Spor', icon: '⚽'),
    EventCategory(id: 'bulusma', name: 'Buluşma', icon: '☕'),
    EventCategory(id: 'ders', name: 'Ders', icon: '📚'),
    EventCategory(id: 'oyun', name: 'Oyun', icon: '🎮'),
  ];

  static EventCategory? findById(String id) {
    try {
      return defaultCategories.firstWhere((cat) => cat.id == id);
    } catch (e) {
      return null;
    }
  }

  static String getNameById(String id) {
    return findById(id)?.name ?? id;
  }

  static String getIconById(String id) {
    return findById(id)?.icon ?? '📌';
  }
}

class PublicEvent {
  final String? id;
  final String name;
  final String category;
  final String description;
  final int capacity;
  final List<String> attendedUsers;
  final DateTime eventDate;
  final DateTime createDate;
  final String createdBy;

  PublicEvent({
    this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.capacity,
    this.attendedUsers = const [],
    required this.eventDate,
    required this.createDate,
    required this.createdBy,
  });

  String get categoryName => EventCategory.getNameById(category);
  String get categoryIcon => EventCategory.getIconById(category);

  bool get isFull => attendedUsers.length >= capacity;

  int get remainingCapacity => capacity - attendedUsers.length;

  int get attendeeCount => attendedUsers.length;

  bool isUserAttending(String userId) => attendedUsers.contains(userId);

  factory PublicEvent.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PublicEvent(
      id: doc.id,
      name: data['name'] ?? '',
      category: data['category'] ?? 'eglence',
      description: data['description'] ?? '',
      capacity: data['capacity'] ?? 0,
      attendedUsers: List<String>.from(data['attended_users'] ?? []),
      eventDate: (data['eventDate'] as Timestamp).toDate(),
      createDate: (data['createDate'] as Timestamp).toDate(),
      createdBy: data['createdBy'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'category': category,
      'description': description,
      'capacity': capacity,
      'attended_users': attendedUsers,
      'eventDate': Timestamp.fromDate(eventDate),
      'createDate': Timestamp.fromDate(createDate),
      'createdBy': createdBy,
    };
  }

  PublicEvent copyWith({
    String? id,
    String? name,
    String? category,
    String? description,
    int? capacity,
    List<String>? attendedUsers,
    DateTime? eventDate,
    DateTime? createDate,
    String? createdBy,
  }) {
    return PublicEvent(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      description: description ?? this.description,
      capacity: capacity ?? this.capacity,
      attendedUsers: attendedUsers ?? this.attendedUsers,
      eventDate: eventDate ?? this.eventDate,
      createDate: createDate ?? this.createDate,
      createdBy: createdBy ?? this.createdBy,
    );
  }
}
