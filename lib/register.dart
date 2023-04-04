import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  Map<String, bool> _interests = {
    'Books': false,
    'Electronics': false,
    'Clothes': false,
    'Shoes': false,
    'Sports': false,
    'Furniture': false,
    'Pet Supplies': false,
    'Food': false,
    'Other': false,
  };

  Future<void> _createUser() async {
    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      print('User registered successfully: ${credential.user?.email}');

      await FirebaseFirestore.instance.collection('users').doc(credential.user!.uid).set({
        'email': _emailController.text,
        'name': _nameController.text,
        'address': _addressController.text,
        'phone': _phoneController.text,
        'interests': _interests.keys.where((key) => _interests[key]!).toList(),
        'avatar': 'https://static.thenounproject.com/png/5034901-200.png', // defalt image
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('User registered successfully: ${credential.user?.email}'),
          backgroundColor: Colors.green,
        ),
      );

      // Pop back to the login page after a short delay
      Future.delayed(Duration(seconds: 2), () {
        Navigator.pop(context);
      });
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      if (e.code == 'weak-password') {
        errorMessage = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'The account already exists for that email.';
      } else {
        errorMessage = 'An error occurred.';
      }

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      print(e);

      // Show a generic error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
              ),
              obscureText: true,
            ),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _addressController,
              decoration: InputDecoration(labelText: 'Address'),
            ),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: 'Phone'),
            ),
            SizedBox(height: 16),
            Text('Interests:'),
            SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _interests.keys
                  .map(
                    (key) => FilterChip(
                  label: Text(key),
                  selected: _interests[key]!,
                  onSelected: (bool value) {
                    setState(() {
                      _interests[key] = value;
                    });
                  },
                ),
              )
                  .toList(),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _createUser,
              child: Text('Register'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Back to Login'),
            ),
          ],
        ),
      ),
    );
  }
}
