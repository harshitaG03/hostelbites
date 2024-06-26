import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';



class SpecialNoteScreen extends StatefulWidget {
  const SpecialNoteScreen({Key? key}) : super(key: key);

  @override
  State<SpecialNoteScreen> createState() => _SpecialNoteScreenState();
}

class _SpecialNoteScreenState extends State<SpecialNoteScreen> {
  final _textController = TextEditingController();
  String userPost = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[800],
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.brown[900]),
        centerTitle: true,
        backgroundColor: Colors.brown[300],
        foregroundColor: Colors.white,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.account_balance_wallet),
            SizedBox(width: 2),
            Text('Important Notice',
              style: TextStyle(
                color: Colors.brown[900],
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              height: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: DecorationImage(
                  image: AssetImage('assets/images/impp.jpg'), // Replace 'assets/background_image.jpg' with your image asset path
                  fit: BoxFit.cover,
                ),
                color: Colors.brown[300],
              ),
              // child: Center(
              //   child: Text(
              //     'IMPORTANT NOTICE FOR STUDENT!!',
              //     style: GoogleFonts.actor(fontSize: 23, color: Colors.white, fontWeight: FontWeight.bold),
              //     textAlign: TextAlign.center,
              //
              //   ),
              //
              // ),
            ),

          ),
          SizedBox(height: 20),
          Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: 'Important notice for students!',
                      fillColor: Colors.brown[200], // Set your desired background color here
                      filled: true,
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        onPressed: () {
                          _textController.clear();
                        },
                        icon: const Icon(Icons.clear),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  MaterialButton(
                    onPressed: () {
                      userPost = _textController.text;
                      // Call function to add notice to Firestore
                      addNoticeToFirestore(userPost);
                    },
                    color: Colors.brown[200],
                    child: const Text('Post'),
                  ),
                  const SizedBox(height: 20),
                  // Section to show posted notice
                  _buildPostedNoticeSection(),
                ],
              ))
        ],
      ),
    );
  }

  // Function to add notice to Firestore
  Future<void> addNoticeToFirestore(String notice) async {
    try {
      await FirebaseFirestore.instance.collection('notice').add({
        'content': notice,
        'timestamp': FieldValue.serverTimestamp(), // Optional: You can add a timestamp for ordering
      });

      // Show a success dialog and clear text field
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Success'),
          content: Text('Notice posted successfully!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _textController.clear();
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      // Handle the error
      print('Error adding notice to Firestore: $e');
    }
  }

  // Widget to build the section displaying posted notice
  Widget _buildPostedNoticeSection() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('notice').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<Widget> notices = [];
          for (var doc in snapshot.data!.docs) {
            String content = doc['content'];
            notices.add(
              Card(
                margin: EdgeInsets.symmetric(vertical: 5),
                child: ListTile(
                  title: Text(content),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      // Call function to delete notice from Firestore
                      deleteNotice(doc.id);
                    },
                  ),
                ),
              ),
            );
          }
          return Column(
            children: notices,
          );
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return SizedBox.shrink();
        }
      },
    );
  }

  // Function to delete notice from Firestore
  Future<void> deleteNotice(String docId) async {
    try {
      await FirebaseFirestore.instance.collection('notice').doc(docId).delete();
    } catch (e) {
      print('Error deleting notice: $e');
    }
  }
}
