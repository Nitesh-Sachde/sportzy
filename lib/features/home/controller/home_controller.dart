import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeController {
  Future<Map<String, String>> fetchUserDetails() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final data = doc.data();
      if (data != null) {
        return {'name': data['name'] ?? '', 'userId': data['id'] ?? ''};
      }
    }
    return {'name': '', 'userId': ''};
  }
}
