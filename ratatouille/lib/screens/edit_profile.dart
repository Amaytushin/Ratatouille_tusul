import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  Uint8List? webImage; // Web
  File? mobileImage; // Mobile

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadCurrentUser();
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("access");
  }

  Future<void> loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString("username") ?? "";
    final email = prefs.getString("email") ?? "";

    usernameController.text = username;
    emailController.text = email;
  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();

    if (kIsWeb) {
      final XFile? file = await picker.pickImage(source: ImageSource.gallery);
      if (file != null) {
        final bytes = await file.readAsBytes();
        setState(() => webImage = bytes);
      }
    } else {
      final XFile? file = await picker.pickImage(source: ImageSource.gallery);
      if (file != null) {
        setState(() => mobileImage = File(file.path));
      }
    }
  }

  Future<void> saveProfile() async {
    setState(() => isLoading = true);

    String? token = await getToken();
    if (token == null) return;

    var request = http.MultipartRequest(
      "PATCH",
      Uri.parse("http://127.0.0.1:8000/api/users/me_update/"),
    );

    request.headers["Authorization"] = "Bearer $token";

    request.fields["username"] = usernameController.text;
    request.fields["email"] = emailController.text;

    // ---- Image Upload ----
    if (kIsWeb && webImage != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          "avatar",
          webImage!,
          filename: "avatar.png",
        ),
      );
    } else if (!kIsWeb && mobileImage != null) {
      request.files.add(
        await http.MultipartFile.fromPath("avatar", mobileImage!.path),
      );
    }

    final response = await request.send();
    final resBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      print("UPDATED: $resBody");

      // Update local storage
      final prefs = await SharedPreferences.getInstance();
      prefs.setString("username", usernameController.text);
      prefs.setString("email", emailController.text);

      if (!mounted) return;
      Navigator.pop(context);
    } else {
      print("UPDATE FAILED: ${response.statusCode}");
      print(resBody);
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // -------- Avatar Preview --------
            GestureDetector(
              onTap: pickImage,
              child: CircleAvatar(
                radius: 55,
                backgroundImage: webImage != null
                    ? MemoryImage(webImage!)
                    : (mobileImage != null
                          ? FileImage(mobileImage!) as ImageProvider
                          : const AssetImage("assets/images/default.png")),
              ),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: usernameController,
              decoration: const InputDecoration(
                labelText: "Username",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),

            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Save", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
