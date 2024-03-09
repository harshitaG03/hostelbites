import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditMenu extends StatefulWidget {
  const EditMenu({Key? key}) : super(key: key);

  @override
  _EditMenuState createState() => _EditMenuState();
}

class _EditMenuState extends State<EditMenu> {
  // Controllers for text fields
  TextEditingController breakfastController = TextEditingController();
  TextEditingController lunchController = TextEditingController();
  TextEditingController snacksController = TextEditingController();
  TextEditingController dinnerController = TextEditingController();

  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Load menu data on page load
    _loadMenuData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[100],
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.brown,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.edit),
            SizedBox(width: 2),
            Text('Edit Menu'),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildHeader(),
              SizedBox(height: 20),
              _buildTextField('BREAKFAST', breakfastController),
              _buildTextField('LUNCH', lunchController),
              _buildTextField('SNACKS', snacksController),
              _buildTextField('DINNER', dinnerController),
              SizedBox(height: 20),
              _buildCuteButton("Submit", _submitMenu),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: Colors.brown[300],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 20,
            child: Text(
              'Add Menu',
              style: TextStyle(
                fontSize: 40,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Positioned(
            bottom: 10,
            child: Text(
              'What is in the MENU?!',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              fillColor: Colors.white,
              filled: true,
              hintText: label,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCuteButton(String text, Function() onTap) {
    return ElevatedButton(
      onPressed: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          text,
          style: TextStyle(fontSize: 18),
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.brown[300], // Change the button color here
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  Future<void> _loadMenuData() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      // Fetch the latest document from the 'menu' collection
      DocumentSnapshot documentSnapshot = await firestore.collection('menu').doc('latest_menu').get();

      if (documentSnapshot.exists) {
        Map<String, dynamic> menuData = documentSnapshot.data() as Map<String, dynamic>;
        // Set the text in controllers with fetched data
        breakfastController.text = menuData['Breakfast'] ?? '';
        lunchController.text = menuData['Lunch'] ?? '';
        snacksController.text = menuData['Snacks'] ?? '';
        dinnerController.text = menuData['Dinner'] ?? '';
      }
    } catch (error) {
      print("Error loading menu data: $error");
    }
  }

  void _submitMenu() async {
    if (_isEmptyFields()) {
      _showErrorDialog("All fields must be filled!");
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      // Update menu data on submit
      await _updateMenuData();

      // Clear text field controllers
      breakfastController.clear();
      lunchController.clear();
      snacksController.clear();
      dinnerController.clear();

      // Show success dialog
      _showSuccessDialog();
    } catch (error) {
      print("Error submitting menu: $error");
      _showErrorDialog("Error submitting menu. Please try again!");
    } finally {
      setState(() {
        isSubmitting = false;
      });
    }
  }

  Future<void> _updateMenuData() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Update the 'menu' collection with the latest data
    await firestore.collection('menu').doc('latest_menu').set({
      'Breakfast': breakfastController.text,
      'Lunch': lunchController.text,
      'Snacks': snacksController.text,
      'Dinner': dinnerController.text,
    });
  }

  bool _isEmptyFields() {
    return breakfastController.text.isEmpty ||
        lunchController.text.isEmpty ||
        snacksController.text.isEmpty ||
        dinnerController.text.isEmpty;
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text('Menu updated successfully!'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}