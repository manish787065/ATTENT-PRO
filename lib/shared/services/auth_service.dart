import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../shared/models/user_model.dart';
import '../../core/constants/app_constants.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<UserModel?> getUserModel(String uid) async {
    final doc = await _firestore
        .collection(AppConstants.colUsers)
        .doc(uid)
        .get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  Future<UserCredential> signInWithEmail(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<UserModel> registerStudent({
    required String name,
    required String email,
    required String password,
    required String institutionId,
    String? parentEmail,
    String? parentPhone,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    await credential.user!.updateDisplayName(name);

    final user = UserModel(
      uid: credential.user!.uid,
      name: name.trim(),
      email: email.trim(),
      role: AppConstants.roleStudent,
      institutionId: institutionId,
      parentEmail: parentEmail,
      parentPhone: parentPhone,
      createdAt: DateTime.now(),
    );

    await _firestore
        .collection(AppConstants.colUsers)
        .doc(user.uid)
        .set(user.toFirestore());

    return user;
  }

  Future<UserModel> registerTeacher({
    required String name,
    required String email,
    required String password,
    required String institutionId,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    await credential.user!.updateDisplayName(name);

    final user = UserModel(
      uid: credential.user!.uid,
      name: name.trim(),
      email: email.trim(),
      role: AppConstants.roleTeacher,
      institutionId: institutionId,
      createdAt: DateTime.now(),
    );

    await _firestore
        .collection(AppConstants.colUsers)
        .doc(user.uid)
        .set(user.toFirestore());

    return user;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }
}
