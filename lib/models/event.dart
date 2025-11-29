import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String? id;
  final String title;
  final String description;
  final DateTime date;
  final String imageUrl;
  final String societyId;
  final String createdBy;
  final List<String> attendedUsers;

  Event({
    this.id,
    required this.title,
    required this.description,
    required this.date,
    this.imageUrl = '',
    required this.societyId,
    required this.createdBy,
    this.attendedUsers = const [],
  });

  factory Event.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Event(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      imageUrl: data['image_url'] ?? '',
      societyId: data['societyId']?.toString() ?? '',
      createdBy: data['createdBy']?.toString() ?? '',
      attendedUsers: List<String>.from(data['attended_users'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'date': Timestamp.fromDate(date),
      'image_url': imageUrl,
      'societyId': societyId,
      'createdBy': createdBy,
      'attended_users': attendedUsers,
    };
  }

  bool isUserAttending(String userId) {
    return attendedUsers.contains(userId);
  }

  int get attendeeCount => attendedUsers.length;
}

class Society {
  final String id;
  final String name;
  final String presidentId;

  Society({
    required this.id,
    required this.name,
    required this.presidentId,
  });

  factory Society.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Society(
      id: doc.id,
      name: data['name'] ?? '',
      presidentId: data['president_id'] ?? '',
    );
  }
}

