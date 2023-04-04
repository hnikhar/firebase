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
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: _db.collection('users').doc(_user?.uid).snapshots(),
              builder: (BuildContext context, AsyncSnapshot<
                  DocumentSnapshot<Map<String, dynamic>>> snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                final userData = snapshot.data!.data() as Map<String, dynamic>;
                if (userData['avatar'] != null) {
                  _image = NetworkImage(userData['avatar']);
                }
                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'User Information',
                          style: TextStyle(
                              fontSize: 24.0, fontWeight: FontWeight.bold),
                        ),
                      ),
                      ListTile(
                        title: Text('Email'),
                        subtitle: Text(_auth.currentUser!.email!),
                      ),
                      ListTile(
                        title: Text('UID'),
                        subtitle: Text(_auth.currentUser!.uid),
                      ),
                      ListTile(
                        title: Text('Name'),
                        subtitle: Text(userData['name']),
                      ),
                      ListTile(
                        title: Text('Address'),
                        subtitle: Text(userData['address']),
                      ),
                      ListTile(
                        title: Text('Phone'),
                        subtitle: Text(userData['phone']),
                      ),
                      // show interest
                      ListTile(
                        title: Text('Interests'),
                        subtitle: Text(userData['interests'].join(', ')),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: _image,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: TextButton(
                          onPressed: _pickImage,
                          child: Text('Change Avatar'),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ElevatedButton(
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
          ),
          SizedBox(height: 16.0),
        ],
      ),
    );
  }
}

