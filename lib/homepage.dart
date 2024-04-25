import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_app/Login/widgets/text_feild.dart';
import 'package:social_app/feed_post.dart';

class HomePage extends StatefulWidget{
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final textController = TextEditingController();
  final currentUser = FirebaseAuth.instance.currentUser!;

  void postMessage(){
    if(textController.text.isNotEmpty){
      FirebaseFirestore.instance.collection("User Posts").add({
        'UserEmail':currentUser.email,
        'Message' : textController.text,
        'TimeStamp' : Timestamp.now(),
      });
    }
    setState(() {
      textController.clear();
    });
  }
  void signOut(){
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade900,
        title: Center(child: const Text('Social App',style: TextStyle(color: Colors.white70),)),
        actions: [
          IconButton(onPressed: signOut, icon: Icon(Icons.logout))
        ],
      ),
      body: Column(
        children: [
          Expanded(child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection("User Posts").
            orderBy("TimeStamp",descending: false).
            snapshots(),
            builder: (context,snapshot){
              if(snapshot.hasData){
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context,index){
                  final post = snapshot.data!.docs[index];
                  return FeedPost(user:post["UserEmail"] ,
                      post: post["Message"]);
                });
              }else if(snapshot.hasError){
                return Center(
                  child: Text("Error: $snapshot.error"),
                );
              }return Center(
                child: CircularProgressIndicator(),
              );
            },
          )),
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Row(children: [
              Expanded(
                child: MyTextFeild(controller: textController
                    , hintText: 'write something to post',
                    obscureText: false),
              ),
              IconButton(onPressed: postMessage, icon: Icon(Icons.arrow_circle_up))
            ],),
          ),
    Text("Logged in as - ${currentUser.email}"),
        ],
      ),
    );
  }
}