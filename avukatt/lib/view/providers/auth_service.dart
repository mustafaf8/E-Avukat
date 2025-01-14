import 'package:avukatt/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final userCollection = FirebaseFirestore.instance.collection("users");

  Future<void> registerUser({
    required String name,
    required String surname,
    required String email,
    required String password,
  }) async {
    await userCollection.doc().set({
      "email": email,
      "name": name,
      "password": password,
      "status": "Unavalible",
    });
  }
}

class AuthManager {
  static final AuthManager _instance = AuthManager._internal();

  factory AuthManager() {
    return _instance;
  }

  AuthManager._internal();

  Future<bool> isLoggedIn() async {
    return prefs.getBool('isLoggedIn') ?? false;
  }

  Future<void> login() async {
    await prefs.setBool('isLoggedIn', true);
  }

  Future<void> logout() async {
    await prefs.setBool('isLoggedIn', false);
  }
}
