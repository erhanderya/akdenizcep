import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String firstName;
  final String lastName;
  final String email;
  final String? ppUrl;
  final DateTime createdAt;
  final List<String> followedCategories;

  UserModel({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.ppUrl,
    required this.createdAt,
    this.followedCategories = const [],
  });

  bool isFollowingCategory(String categoryId) =>
      followedCategories.contains(categoryId);

  String get fullName => '$firstName $lastName';

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      email: data['email'] ?? '',
      ppUrl: data['ppUrl'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      followedCategories: List<String>.from(data['followedCategories'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'ppUrl': ppUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'followedCategories': followedCategories,
    };
  }

  UserModel copyWith({
    String? uid,
    String? firstName,
    String? lastName,
    String? email,
    String? ppUrl,
    DateTime? createdAt,
    List<String>? followedCategories,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      ppUrl: ppUrl ?? this.ppUrl,
      createdAt: createdAt ?? this.createdAt,
      followedCategories: followedCategories ?? this.followedCategories,
    );
  }
}

