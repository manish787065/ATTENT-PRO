class AppConstants {
  // Roles
  static const String roleAdmin = 'admin';
  static const String roleTeacher = 'teacher';
  static const String roleStudent = 'student';

  // Attendance Status
  static const String statusPresent = 'present';
  static const String statusAbsent = 'absent';
  static const String statusLate = 'late';
  static const String statusFlagged = 'flagged';

  // Face Recognition Thresholds
  static const double faceMatchThresholdConfirm = 0.80;
  static const double faceMatchThresholdFlag = 0.60;

  // Enrollment
  static const int faceEnrollmentSteps = 5;

  // Attendance
  static const double minAttendancePercent = 75.0;
  static const double warningAttendancePercent = 80.0;

  // Firestore collections
  static const String colUsers = 'users';
  static const String colSubjects = 'subjects';
  static const String colAttendance = 'attendance';
  static const String colFaceEmbeddings = 'face_embeddings';
  static const String colCourses = 'courses';
}
