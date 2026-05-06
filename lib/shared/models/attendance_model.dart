import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceModel {
  final String id;
  final String studentId;
  final String subjectId;
  final String classId;
  final DateTime date;
  final String status; // present | absent | late | flagged
  final String markedBy; // camera | manual
  final double confidence; // face match score
  final String teacherId;

  AttendanceModel({
    required this.id,
    required this.studentId,
    required this.subjectId,
    required this.classId,
    required this.date,
    required this.status,
    required this.markedBy,
    required this.confidence,
    required this.teacherId,
  });

  factory AttendanceModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AttendanceModel(
      id: doc.id,
      studentId: data['studentId'] ?? '',
      subjectId: data['subjectId'] ?? '',
      classId: data['classId'] ?? '',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: data['status'] ?? 'absent',
      markedBy: data['markedBy'] ?? 'manual',
      confidence: (data['confidence'] ?? 0.0).toDouble(),
      teacherId: data['teacherId'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'studentId': studentId,
      'subjectId': subjectId,
      'classId': classId,
      'date': Timestamp.fromDate(date),
      'status': status,
      'markedBy': markedBy,
      'confidence': confidence,
      'teacherId': teacherId,
    };
  }

  bool get isPresent => status == 'present' || status == 'late';
}
