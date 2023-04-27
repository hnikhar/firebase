import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'login.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  User? _user;
  ImageProvider? _image;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
    _image = AssetImage('assets/default_pic.png');
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _image = FileImage(File(image.path));
      });
      // Update the avatar field in Firebase
      await _db.collection('users').doc(_user?.uid).update({'avatar': image.path});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Information'),
        leading: SizedBox(),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 24.0),
            CircleAvatar(
              radius: 50,
              backgroundImage: _image,
            ),
            SizedBox(height: 16.0),
            TextButton(
              onPressed: _pickImage,
              child: Text('Change Avatar'),
            ),
            StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: _db.collection('users').doc(_user?.uid).snapshots(),
              builder: (BuildContext context, AsyncSnapshot<
                  DocumentSnapshot<Map<String, dynamic>>> snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                final userData = snapshot.data!.data() as Map<String, dynamic>;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 24.0),
                    ListTile(
                      title: Center(child: Text('UID')),
                      subtitle: Center(child: Text(_auth.currentUser!.uid!)),
                    ),
                    SizedBox(height: 24.0),
                    ListTile(
                      title: Center(child: Text('Email')),
                      subtitle: Center(child: Text(_auth.currentUser!.email!)),
                    ),
                    Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text('Name', textAlign: TextAlign.center),
                          SizedBox(height: 8.0),
                          Text(userData['name'], textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                    ListTile(
                      title: Center(child: Text('Address')),
                      subtitle: Center(child: Text(userData['address'])),
                    ),
                    ListTile(
                      title: Center(child:Text('Phone')),
                      subtitle: Center(child:Text(userData['phone'])),
                    ),
                    // show interests
                    ListTile(
                      title: Center(child:Text('Interests')),
                      subtitle: Center(child:Text(userData['interests'].join(', '))),
                    ),
                    SizedBox(height: 24.0),
                    ElevatedButton(
                      onPressed: () {
                        FirebaseAuth.instance.signOut();
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPage()),
                          (route) => false,
                        );
                      },
                      child: Text('Logout'),
                    ),
                    SizedBox(height: 24.0),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
