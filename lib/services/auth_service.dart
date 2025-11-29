import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:akdeniz_cep/models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  CollectionReference get _usersCollection => _firestore.collection('users');

  Stream<User?> get authStateChanges => _auth.authStateChanges();


  User? get currentUser => _auth.currentUser;

  Future<UserModel?> getUserData(String uid) async {
    try {
      final doc = await _usersCollection.doc(uid).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Stream<UserModel?> getUserDataStream(String uid) {
    return _usersCollection.doc(uid).snapshots().map((doc) {
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    });
  }


  Future<UserCredential?> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );


      final fullName = '$firstName $lastName';
      await result.user?.updateDisplayName(fullName);

 
      if (result.user != null) {
        final userModel = UserModel(
          uid: result.user!.uid,
          firstName: firstName,
          lastName: lastName,
          email: email,
          ppUrl: null,
          createdAt: DateTime.now(),
        );
        await _usersCollection.doc(result.user!.uid).set(userModel.toMap());
      }

      return result;
    } on FirebaseException catch (e) {
      throw _getErrorMessage(e.code);
    }
  }


  Future<UserCredential?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result;
    } on FirebaseException catch (e) {
      throw _getErrorMessage(e.code);
    }
  }


  Future<void> updateUserProfile({
    required String uid,
    String? firstName,
    String? lastName,
    String? ppUrl,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (firstName != null) updates['firstName'] = firstName;
      if (lastName != null) updates['lastName'] = lastName;
      if (ppUrl != null) updates['ppUrl'] = ppUrl;

      if (updates.isNotEmpty) {
        await _usersCollection.doc(uid).update(updates);


        if (firstName != null || lastName != null) {
          final userData = await getUserData(uid);
          if (userData != null) {
            final newFirstName = firstName ?? userData.firstName;
            final newLastName = lastName ?? userData.lastName;
            await _auth.currentUser
                ?.updateDisplayName('$newFirstName $newLastName');
          }
        }
      }
    } on FirebaseException catch (e) {
      throw _getErrorMessage(e.code);
    }
  }


  Future<void> updateProfilePhoto(String uid, String photoUrl) async {
    try {
      await _usersCollection.doc(uid).update({'ppUrl': photoUrl});
      await _auth.currentUser?.updatePhotoURL(photoUrl);
    } on FirebaseException catch (e) {
      throw _getErrorMessage(e.code);
    }
  }


  Future<void> signOut() async {
    await _auth.signOut();
  }


  Future<void> followCategory(String userId, String categoryId) async {
    try {
      await _usersCollection.doc(userId).update({
        'followedCategories': FieldValue.arrayUnion([categoryId]),
      });
    } on FirebaseException catch (e) {
      throw _getErrorMessage(e.code);
    }
  }


  Future<void> unfollowCategory(String userId, String categoryId) async {
    try {
      await _usersCollection.doc(userId).update({
        'followedCategories': FieldValue.arrayRemove([categoryId]),
      });
    } on FirebaseException catch (e) {
      throw _getErrorMessage(e.code);
    }
  }

 
  Future<bool> toggleCategoryFollow(String userId, String categoryId) async {
    final userData = await getUserData(userId);
    if (userData == null) return false;

    if (userData.isFollowingCategory(categoryId)) {
      await unfollowCategory(userId, categoryId);
      return false;
    } else {
      await followCategory(userId, categoryId);
      return true;
    }
  }


  String _getErrorMessage(String code) {
    switch (code) {
      case 'weak-password':
        return 'Şifre çok zayıf.';
      case 'email-already-in-use':
        return 'Bu e-mail adresi zaten kullanımda.';
      case 'invalid-email':
        return 'Geçersiz e-mail adresi.';
      case 'user-not-found':
        return 'Bu e-mail ile kayıtlı kullanıcı bulunamadı.';
      case 'wrong-password':
        return 'Yanlış şifre.';
      case 'user-disabled':
        return 'Bu kullanıcı hesabı devre dışı bırakılmış.';
      case 'too-many-requests':
        return 'Çok fazla deneme yapıldı. Lütfen daha sonra tekrar deneyin.';
      case 'operation-not-allowed':
        return 'Bu işlem şu anda kullanılamıyor.';
      case 'invalid-credential':
        return 'E-mail veya şifre hatalı.';
      default:
        return 'Bir hata oluştu. Lütfen tekrar deneyin.';
    }
  }
}
