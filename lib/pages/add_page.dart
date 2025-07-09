import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddPage extends StatefulWidget {
  const AddPage({super.key});

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  final ImagePicker _picker = ImagePicker();
  File? selectedImage;

  Future<void> getImage() async {
    final image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
      });
    }
  }

  Future<String?> uploadToCloudinary(File imageFile) async {
    final cloudName = 'dtdn4tdom';
    final uploadPreset = 'travellapp_unsigned';
    final uri = Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload");

    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    final response = await request.send();

    if (response.statusCode == 200) {
      final respStr = await response.stream.bytesToString();
      final jsonResp = json.decode(respStr);
      return jsonResp['secure_url'];
    } else {
      print('Upload failed: ${response.statusCode}');
      return null;
    }
  }

  TextEditingController placenamecontroller = TextEditingController();
  TextEditingController citynamecontroller = TextEditingController();
  TextEditingController captioncontroller = TextEditingController();

  final Color mainColor = const Color(0xFF26a69a);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFececf8),
      appBar: AppBar(
        backgroundColor: mainColor,
        title: const Text("Add Post"),
        centerTitle: false,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 30.0),
          Expanded(
            child: Material(
              elevation: 3.0,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30.0),
                topRight: Radius.circular(30.0),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    topRight: Radius.circular(30.0),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: GestureDetector(
                          onTap: getImage,
                          child: Container(
                            height: 180,
                            width: 180,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black45, width: 2.0),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: selectedImage != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Image.file(
                                      selectedImage!,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : const Icon(Icons.camera_alt_outlined, size: 50.0),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      Text(
                        "Place Name",
                        style: TextStyle(
                          fontSize: 22.0,
                          fontWeight: FontWeight.bold,
                          color: mainColor,
                        ),
                      ),
                      const SizedBox(height: 15.0),
                      Container(
                        padding: const EdgeInsets.only(left: 20.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFFececf8),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: TextField(
                          controller: placenamecontroller,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: "Enter Place Name",
                            hintStyle: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      Text(
                        "City Name",
                        style: TextStyle(
                          fontSize: 22.0,
                          fontWeight: FontWeight.bold,
                          color: mainColor,
                        ),
                      ),
                      const SizedBox(height: 15.0),
                      Container(
                        padding: const EdgeInsets.only(left: 20.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFFececf8),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: TextField(
                          controller: citynamecontroller,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: "Enter City Name",
                            hintStyle: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      Text(
                        "Caption",
                        style: TextStyle(
                          fontSize: 22.0,
                          fontWeight: FontWeight.bold,
                          color: mainColor,
                        ),
                      ),
                      const SizedBox(height: 15.0),
                      Container(
                        padding: const EdgeInsets.only(left: 20.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFFececf8),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: TextField(
                          controller: captioncontroller,
                          maxLines: 6,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: "Enter Caption...",
                            hintStyle: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30.0),
                      Center(
                        child: GestureDetector(
                          onTap: () async {
                            if (selectedImage != null &&
                                placenamecontroller.text.isNotEmpty &&
                                citynamecontroller.text.isNotEmpty &&
                                captioncontroller.text.isNotEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Uploading image...")),
                              );

                              String? downloadUrl = await uploadToCloudinary(selectedImage!);

                              if (downloadUrl == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("❌ Image upload failed.")),
                                );
                                return;
                              }

                              User? currentUser = FirebaseAuth.instance.currentUser;
                              if (currentUser != null) {
                                DocumentSnapshot userDoc = await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(currentUser.uid)
                                    .get();

                                String username = userDoc['name'] ?? 'Unknown';
                                String profileImageUrl = userDoc['profileImageUrl'] ?? '';

                                await FirebaseFirestore.instance.collection("posts").add({
                                  "imageUrl": downloadUrl,
                                  "place": placenamecontroller.text.trim(),
                                  "city": citynamecontroller.text.trim(),
                                  "caption": captioncontroller.text.trim(),
                                  "username": username,
                                  "uid": currentUser.uid,
                                  "profileImageUrl": profileImageUrl,
                                  "createdAt": FieldValue.serverTimestamp(),
                                });

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("✅ Post uploaded to Firestore!")),
                                );

                                Navigator.pop(context);
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Please complete all fields.")),
                              );
                            }
                          },
                          child: Container(
                            height: 50,
                            width: MediaQuery.of(context).size.width / 2,
                            decoration: BoxDecoration(
                              color: mainColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Center(
                              child: Text(
                                "Post",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30.0),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
