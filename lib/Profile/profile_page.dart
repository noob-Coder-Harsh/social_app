

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:social_app/Profile/textbox.dart';

import '../Homepage/homepage.dart';

class ProfilePage extends StatefulWidget{
  const ProfilePage({super.key,});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  final userCollections = FirebaseFirestore.instance.collection("Users");

  Future<void> editFeild(String field)async{
    String newValue = "";
    await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.grey [900],
          title: Text(
            "Edit $field",
            style:  const TextStyle(color: Colors.white),
          ), // Text
          content: TextField(
            autofocus: true,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Enter new $field",
              hintStyle: const TextStyle(color:Colors.grey),
              ),
            onChanged: (value){
              newValue = value;
            },
            ),
          actions: [
            TextButton(onPressed: (){Navigator.pop(context);},
                child: const Text('cancel')),
            TextButton(onPressed: (){Navigator.of(context).pop(newValue);},
                child: const Text('Save')),
          ],
          ),
        );

    if(newValue.isNotEmpty){
      await userCollections.doc(currentUser.email).update({field: newValue});
    }
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
          GButton(icon: Icons.home,
              onPressed: (){Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>const HomePage()));}),
          GButton(icon: Icons.person,
              onPressed: (){Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>const ProfilePage()));}),
        ],
      ),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.grey.shade900,
        title: const Text('Profile',style: TextStyle(color: Colors.white70),),
      ),
      backgroundColor: Colors.grey.shade300,
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection("Users").doc(currentUser.email).snapshots(),
        builder: (context,snapshot){
          if(snapshot.hasData){
            final userData = snapshot.data!.data() as Map<String,dynamic>;
            return ListView(
              children: [
                const SizedBox(height: 50,),
                const Icon(Icons.person,size: 72,),
                Text(currentUser.email.toString(),
                  textAlign: TextAlign.center,style: TextStyle(color: Colors.grey.shade700),),
                const SizedBox(height: 50,),
                Padding(
                  padding: const EdgeInsets.only(left: 25.0),
                  child: Text('My Profile',style: TextStyle(color: Colors.grey.shade800),),
                ),
                MyTextBox(text: userData['username'],
                    sectionName: 'username',
                    onPressed:(){editFeild('username');}),

                MyTextBox(text: userData['bio'],
                    sectionName: 'bio',
                    onPressed:(){editFeild('bio');}),
                const SizedBox(height: 10,),

                MyTextBox(text: userData['contact'].toString(),
                    sectionName: 'contact',
                    onPressed:(){editFeild('contact');}),
                const SizedBox(height: 10,),

                Padding(
                  padding: const EdgeInsets.only(left: 25.0),
                  child: Text('My Posts',style: TextStyle(color: Colors.grey.shade800),),
                ),
              ],
            );
          }else if(snapshot.hasError){
            return Center(child: Text(snapshot.error.toString()),);
          }
          return const Center(child: CircularProgressIndicator(),);
        },
      )
    );
  }
}