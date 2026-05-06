import 'package:cloud_firestore/cloud_firestore.dart';

class SubjectModel {
  final String id;
  final String name;
  final String code;
  final String teacherId;
  final String classId;
  final String institutionId;
  final int totalClassesHeld;
  final String schedule; // e.g. "Mon, Wed, Fri - 10:00 AM"

  SubjectModel({
    required this.id,
    required this.name,
    required this.code,
    required this.teacherId,
    required this.classId,
    required this.institutionId,
    this.totalClassesHeld = 0,
    this.schedule = '',
  });

  factory SubjectModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SubjectModel(
      id: doc.id,
      name: data['name'] ?? '',
      code: data['code'] ?? '',
      teacherId: data['teacherId'] ?? '',
      classId: data['classId'] ?? '',
      institutionId: data['institutionId'] ?? '',
      totalClassesHeld: data['totalClassesHeld'] ?? 0,
      schedule: data['schedule'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'code': code,
      'teacherId': teacherId,
      'classId': classId,
      'institutionId': institutionId,
      'totalClassesHeld': totalClassesHeld,
      'schedule': schedule,
    };
  }
}
