import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_app/Login/widgets/text_feild.dart';
import 'package:social_app/Homepage/widgets/feed_post.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:social_app/Profile/profile_page.dart';


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
        'Likes' : [],
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
      bottomNavigationBar: GNav(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        gap: 10,
        backgroundColor: Colors.grey.shade900,
        color: Colors.white70,
        activeColor: Colors.white70,
        tabs: [
          GButton(icon: Icons.home,onPressed: (){Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>const HomePage()));}),
          GButton(icon: Icons.person,onPressed: (){Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>const ProfilePage()));}),

        ],
      ),
      backgroundColor: Colors.grey.shade300,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade900,
        title: const Center(child: Text('Social App',style: TextStyle(color: Colors.white70),)),
        actions: [
          IconButton(onPressed: signOut, icon: const Icon(Icons.logout,color: Colors.white70,))
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 18.0,left: 18,right: 18),
            child: Row(children: [
              Expanded(
                child: MyTextFeild(controller: textController
                    , hintText: 'write something to post',
                    obscureText: false),
              ),
              IconButton(onPressed: postMessage, icon: const Icon(Icons.arrow_circle_up))
            ],),
          ),
          Expanded(child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection("User Posts").
            orderBy("TimeStamp",descending: true).
            snapshots(),
            builder: (context,snapshot){
              if(snapshot.hasData){
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context,index){
                  final post = snapshot.data!.docs[index];
                  return FeedPost(user:post["UserEmail"] ,
                      post: post["Message"],
                      postId: post.id,
                      likes: List<String>.from(post['Likes']??[]));
                });
              }else if(snapshot.hasError){
                return Center(
                  child: Text("Error: $snapshot.error"),
                );
              }return const Center(
                child: CircularProgressIndicator(),
              );
            },
          )),
    Text("Logged in as - ${currentUser.email}",style: TextStyle(color: Colors.grey.shade700),),
        ],
      ),
    );
  }
}