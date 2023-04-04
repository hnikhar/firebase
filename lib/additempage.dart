import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddItemPage extends StatefulWidget {
  @override
  _AddItemPageState createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  final _formKey = GlobalKey<FormState>();
  final _firestore = FirebaseFirestore.instance;
  User? loggedInUser;

  String itemName = '';
  String description = '';
  String price = '';
  String itemAddress = '';
  String itemType = '';
  String community = '';
  List<String> itemTypes = [
    'Electronics',
    'Furniture',
    'Clothing',
    'Books',
    'Shoes',
    'Sports',
    'Pet Supplies',
    'Food',
    'Other'
  ];

  List<String> communities = ['Community A', 'Community B', 'Community C'];

  @override
  void initState() {
    super.initState();
    loggedInUser = FirebaseAuth.instance.currentUser;
  }

  Future<void> _addItem() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        await _firestore.collection('items').add({
          'uid': loggedInUser!.uid,
          'community': community,
          'item_name': itemName,
          'price': double.parse(price),
          'item_address': itemAddress,
          'description': description,
          'item_type': itemType,
          'item_pic': 'https://via.placeholder.com/150',
          'timestamp': Timestamp.now(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Item added successfully'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context);
      } catch (e) {
        print(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        title: Text('Add Item'),
    ),
    body: Padding(
    padding: EdgeInsets.all(16.0),
    child: Form(
    key: _formKey,
    child: ListView(
    children: [
    TextFormField(
    decoration: InputDecoration(labelText: 'Item Name'),
    validator: (value) {
    if (value == null || value.isEmpty) {
    return 'Please enter an item name';
    }
    return null;
    },
    onSaved: (value) {
    itemName = value!;
    },
    ),
    TextFormField(
    decoration: InputDecoration(labelText: 'Description'),
    validator: (value) {
    if (value == null || value.isEmpty) {
    return 'Please enter a description';
    }
    return null;
    },
    onSaved: (value) {
    description = value!;
    },
    ),
    TextFormField(
    decoration: InputDecoration(labelText: 'Price'),
    keyboardType: TextInputType.number,
    validator: (value) {
    if (value == null || value.isEmpty) {
    return 'Please enter a price';
    }
    return null;
    },
    onSaved: (value) {
    price = value!;
    },
    ),
    TextFormField(
    decoration: InputDecoration(labelText: 'Item Address'),
    validator: (value) {
    if (value == null || value.isEmpty) {
    return 'Please enter an item address';
    }
    return null;
    },
    onSaved: (value) {
    itemAddress = value!;
    },
    ),
      DropdownButtonFormField(
        decoration: InputDecoration(labelText: 'Item Type'),
        value: itemType.isEmpty ? null : itemType,
        items: itemTypes.map((type) {
          return DropdownMenuItem(
            value: type,
            child: Text(type),
          );
        }).toList(),
        onChanged: (newValue) {
          setState(() {
            itemType = newValue as String;
          });
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select an item type';
          }
          return null;
        },
      ),
      DropdownButtonFormField(
        decoration: InputDecoration(labelText: 'Community'),
        value: community.isEmpty ? null : community,
        items: communities.map((comm) {
          return DropdownMenuItem(
            value: comm,
            child: Text(comm),
          );
        }).toList(),
        onChanged: (newValue) {
          setState(() {
            community = newValue as String;
          });
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select a community';
          }
          return null;
        },
      ),
      SizedBox(height: 16),
      ElevatedButton(
        onPressed: _addItem,
        child: Text('Add Item'),
      ),
    ],
    ),
    ),
    ),
    );
  }
}
