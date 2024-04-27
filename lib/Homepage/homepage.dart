import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_app/Homepage/New%20Post/new_post.dart';
import 'package:social_app/Homepage/helper_methods.dart';
import 'package:social_app/Homepage/Post/feed_post.dart';


class HomePage extends StatefulWidget{

  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final textController = TextEditingController();
  final currentUser = FirebaseAuth.instance.currentUser!;

  Future<String> getUsername(String email) async{
    final userCollection = FirebaseFirestore.instance.collection("Users");
    final userDoc = await userCollection.doc(email).get();
    final username = userDoc.data()?['username'];
    return username ?? '';

  }


  void signOut(){
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Colors.grey,
      body: Column(
        children: [
          const NewPosts(),
          FutureBuilder<String>(
            future: getUsername(currentUser.email!), // Fetch username asynchronously
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final username = snapshot.data!;
                return Text(
                  "Logged in as - $username",
                  style: TextStyle(color: Colors.grey.shade900),
                );
              } else if (snapshot.hasError) {
                return Text("Error: ${snapshot.error}");
              } else {
                return Text(" ");
              }
            },
          ),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("User Posts")
                  .orderBy("TimeStamp", descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final post = snapshot.data!.docs[index];
                      return FutureBuilder<String>(
                        future: getUsername(post["UserEmail"]), // Fetch username asynchronously
                        builder: (context, usernameSnapshot) {
                          if (usernameSnapshot.hasData) {
                            final username = usernameSnapshot.data!;
                            return FeedPost(
                              user: username, // Pass username instead of email
                              post: post["Message"],
                              postId: post.id,
                              likes: List<String>.from(post['Likes'] ?? []),
                              time: formatDate(post['TimeStamp']),
                            );
                          } else if (usernameSnapshot.hasError) {
                            return Text("Error: ${usernameSnapshot.error}");
                          } else {
                            return Text(" ");
                          }
                        },
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text("Error: $snapshot.error"),
                  );
                }
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          ),

        ],
      ),
    );
  }
}