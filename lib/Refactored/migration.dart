import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';


class Migration extends StatelessWidget {
  const Migration({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: migrateData,
          child: Text('Migrate Data'),
        ),
      ),
    );
  }
}


void migrateData() async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;

  // Fetch all documents identified by email
  QuerySnapshot querySnapshot = await firestore.collection('Users').get();

  for (QueryDocumentSnapshot doc in querySnapshot.docs) {
    String email = doc.id; // assuming email is used as document ID

    try {
      // Fetch user by email
      List<UserRecord> userRecords = await fetchUserByEmail(auth, email);

      // Check if user exists
      if (userRecords.isNotEmpty) {
        String uid = userRecords.first.uid;

        // Create new document with UID
        DocumentReference newDocRef = firestore.collection('UserData').doc(uid);
        await newDocRef.set(doc.data());

        // Optionally delete the old document
        await doc.reference.delete();
      } else {
        print("No user found for email $email");
      }
    } catch (e) {
      print("Error processing email $email: $e");
    }
  }
}

Future<List<UserRecord>> fetchUserByEmail(FirebaseAuth auth, String email) async {
  List<UserRecord> users = [];

  try {
    // Attempt to fetch user by email
    User user = (await auth.fetchSignInMethodsForEmail(email)).first as User;
    users.add(UserRecord(uid: user.uid));
  } catch (e) {
    print("Error fetching user with email $email: $e");
  }

  return users;
}

class UserRecord {
  final String uid;

  UserRecord({required this.uid});
}
