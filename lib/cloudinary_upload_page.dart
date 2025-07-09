import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CloudinaryUploadPage extends StatefulWidget {
  @override
  _CloudinaryUploadPageState createState() => _CloudinaryUploadPageState();
}

class _CloudinaryUploadPageState extends State<CloudinaryUploadPage> {
  File? _imageFile;
  String? _imageUrl;

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) return;

    final file = File(pickedFile.path);

   
    final cloudName = 'dtdn4tdom';
    final uploadPreset = 'travellapp_unsigned'; 

    final uri = Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload");

    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      final result = json.decode(responseData);
      setState(() {
        _imageUrl = result['secure_url'];
        _imageFile = file;
      });
    } else {
      print('❌ Upload failed: ${response.statusCode}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload image')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Upload to Cloudinary")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_imageFile != null)
              Image.file(_imageFile!, height: 150),
            if (_imageUrl != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text("Image URL:",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 5),
                    Text(_imageUrl!, textAlign: TextAlign.center),
                  ],
                ),
              ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickAndUploadImage,
              child: Text("Pick & Upload"),
            ),
          ],
        ),
      ),
    );
  }
}
