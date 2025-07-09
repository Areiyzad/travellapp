import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:travellapp/pages/login.dart';

class EditableProfilePage extends StatefulWidget {
  const EditableProfilePage({Key? key}) : super(key: key);

  @override
  State<EditableProfilePage> createState() => _EditableProfilePageState();
}

class _EditableProfilePageState extends State<EditableProfilePage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final Color mainColor = const Color(0xFF26A69A);

  bool isSaving = false;
  String profileImageUrl = '';
  File? selectedImage;
  late User currentUser;

  final String cloudinaryUploadPreset = "travellapp_unsigned";
  final String cloudinaryCloudName = "dtdn4tdom";

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser!;
  }

  Future<Map<String, dynamic>> fetchUserData() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get();
    final data = snapshot.data() ?? {};
    profileImageUrl = data['profileImageUrl'] ?? '';
    nameController.text = data['name'] ?? '';
    emailController.text = data['email'] ?? '';
    bioController.text = data['bio'] ?? '';
    return data;
  }

  Future<String> uploadToCloudinary(File imageFile) async {
    final mimeType = lookupMimeType(imageFile.path)?.split('/');
    if (mimeType == null || mimeType.length != 2) {
      throw Exception("Invalid image MIME type.");
    }

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('https://api.cloudinary.com/v1_1/$cloudinaryCloudName/image/upload'),
    );

    request.fields['upload_preset'] = cloudinaryUploadPreset;
    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        imageFile.path,
        contentType: MediaType(mimeType[0], mimeType[1]),
      ),
    );

    final response = await request.send();
    if (response.statusCode == 200) {
      final responseData = await http.Response.fromStream(response);
      final jsonData = json.decode(responseData.body);
      return jsonData['secure_url'];
    } else {
      throw Exception('Image upload failed');
    }
  }

  Future<void> saveChanges() async {
    setState(() => isSaving = true);
    String imageUrl = profileImageUrl;

    try {
      if (selectedImage != null) {
        imageUrl = await uploadToCloudinary(selectedImage!);
      }

      await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).update({
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'bio': bioController.text.trim(),
        'profileImageUrl': imageUrl,
      });

      // Update all posts created by this user with the new image
      final posts = await FirebaseFirestore.instance
          .collection('posts')
          .where('uid', isEqualTo: currentUser.uid)
          .get();

      for (final doc in posts.docs) {
        await doc.reference.update({'profileImageUrl': imageUrl});
      }

      setState(() {
        isSaving = false;
        profileImageUrl = imageUrl;
        selectedImage = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully!")),
      );
    } catch (e) {
      setState(() => isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update: $e")),
      );
    }
  }

  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => selectedImage = File(picked.path));
    }
  }

  Future<void> changePassword() async {
    if (passwordController.text.trim().length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password must be at least 6 characters.")),
      );
      return;
    }

    try {
      await currentUser.updatePassword(passwordController.text.trim());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password changed successfully.")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to change password: $e")),
      );
    }
  }

  void logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        backgroundColor: mainColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: logout,
          )
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchUserData(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                GestureDetector(
                  onTap: pickImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: selectedImage != null
                        ? FileImage(selectedImage!)
                        : (profileImageUrl.isNotEmpty
                            ? NetworkImage(profileImageUrl)
                            : const AssetImage("images/boy.jpg")) as ImageProvider,
                  ),
                ),
                const SizedBox(height: 10),
                const Text("Tap to change profile picture"),
                const SizedBox(height: 20),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: "Name",
                    prefixIcon: const Icon(Icons.person),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: "Email",
                    prefixIcon: const Icon(Icons.email),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: bioController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: "Bio",
                    prefixIcon: const Icon(Icons.edit_note),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mainColor,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: isSaving ? null : saveChanges,
                  icon: const Icon(Icons.save),
                  label: Text(isSaving ? "Saving..." : "Save Changes"),
                ),
                const SizedBox(height: 30),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "New Password",
                    prefixIcon: const Icon(Icons.lock),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: changePassword,
                  icon: const Icon(Icons.key),
                  label: const Text("Change Password"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
