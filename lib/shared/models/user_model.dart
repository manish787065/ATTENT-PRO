import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role; // admin | teacher | student
  final String institutionId;
  final String? profilePhotoUrl;
  final List<String> enrolledSubjectIds; // for students
  final String? parentEmail;
  final String? parentPhone;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.institutionId,
    this.profilePhotoUrl,
    this.enrolledSubjectIds = const [],
    this.parentEmail,
    this.parentPhone,
    required this.createdAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'student',
      institutionId: data['institutionId'] ?? '',
      profilePhotoUrl: data['profilePhotoUrl'],
      enrolledSubjectIds: List<String>.from(data['enrolledSubjectIds'] ?? []),
      parentEmail: data['parentEmail'],
      parentPhone: data['parentPhone'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'role': role,
      'institutionId': institutionId,
      'profilePhotoUrl': profilePhotoUrl,
      'enrolledSubjectIds': enrolledSubjectIds,
      'parentEmail': parentEmail,
      'parentPhone': parentPhone,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  UserModel copyWith({
    String? name,
    String? profilePhotoUrl,
    List<String>? enrolledSubjectIds,
    String? parentEmail,
    String? parentPhone,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      email: email,
      role: role,
      institutionId: institutionId,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      enrolledSubjectIds: enrolledSubjectIds ?? this.enrolledSubjectIds,
      parentEmail: parentEmail ?? this.parentEmail,
      parentPhone: parentPhone ?? this.parentPhone,
      createdAt: createdAt,
    );
  }
}
