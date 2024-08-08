import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_app/Firebase/firebase_services.dart';
import 'package:social_app/Profile/post_grid.dart';
import 'package:social_app/Utility/utils.dart';

class OtherProfilePage extends StatefulWidget {
  final String userId;
  const OtherProfilePage({Key? key, required this.userId}) : super(key: key);

  @override
  State<OtherProfilePage> createState() => _OtherProfilePageState();
}

class _OtherProfilePageState extends State<OtherProfilePage> {
  final FirebaseService firebaseService = FirebaseService();
  Map<String, dynamic>? _userData;

  Future<void> _fetchUserData() async {
    _userData = await firebaseService.getUserDataById(widget.userId);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade300,
        title: const Text('Profile'),
        actions: [
          IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: _userData != null
          ? Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 100,
                  height: 100,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: _userData!['profile_picture'] != null
                        ? Image.network(
                      _userData!['profile_picture'],
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    )
                        : const Icon(
                      Icons.person,
                      size: 75,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _userData!['username'] ?? 'No Username',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade900,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            Text(
                              'Posts',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '${_userData!['posts'].length}',
                              style: TextStyle(fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                        SizedBox(width: 10),
                        Column(
                          children: [
                            Text(
                              'Followers',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '${_userData!['followers'].length}',
                              style: TextStyle(fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                        SizedBox(width: 10),
                        Column(
                          children: [
                            Text(
                              'Following',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '${_userData!['following'].length}',
                              style: TextStyle(fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              _userData!['bio'].toString().isNotEmpty ? _userData!['bio'] : "no bio",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(),
          Expanded(
            child: SingleChildScrollView(
              child: SizedBox(
                height: MediaQuery.of(context).size.height,
                child: ImageGrid(userId: widget.userId,),
              ),
            ),
          ),
        ],
      )
          : Center(
        child: Utils.circularProgressIndicator(),
      ),
    );
  }
}
