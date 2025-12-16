import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ratatouille/screens/edit_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isLoading = true;
  String? username = "";
  String? email = "";
  String? avatar = "";

  String fixUrl(String? url) {
    if (url == null || url.isEmpty) return "";
    if (url.startsWith("http")) {
      return "$url?t=${DateTime.now().millisecondsSinceEpoch}";
    }
    return "http://127.0.0.1:8000$url?t=${DateTime.now().millisecondsSinceEpoch}";
  }

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("access");
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("access");
    await prefs.remove("refresh");

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, "/login");
  }

  Future<void> fetchProfile() async {
    setState(() => isLoading = true);

    String? token = await getToken();
    if (token == null) {
      setState(() => isLoading = false);
      return;
    }

    final url = Uri.parse("http://127.0.0.1:8000/api/users/me/");

    try {
      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          username = data["username"];
          email = data["email"];
          avatar = fixUrl(data["avatar"]);
          isLoading = false;
        });
      } else {
        print("PROFILE ERROR → ${response.statusCode}");
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("PROFILE FETCH FAILED → $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("My Profile"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: Column(
                children: [
                  // --- AVATAR ---
                  Center(
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.deepPurple[100],
                          backgroundImage: NetworkImage(avatar!),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () => print("Change avatar clicked"),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.deepPurple,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // --- USER INFO CARD ---
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 5,
                    shadowColor: Colors.deepPurple.withOpacity(0.2),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.person, color: Colors.deepPurple),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Text(
                                  username ?? "",
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 30, thickness: 1.2),
                          Row(
                            children: [
                              const Icon(Icons.email, color: Colors.deepPurple),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Text(
                                  email ?? "",
                                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // --- EDIT BUTTON ---
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        backgroundColor: Colors.deepPurple,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 3,
                      ),
                      child: const Text(
                        'Edit Profile',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // --- LOGOUT + REFRESH BUTTONS ---
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: fetchProfile,
                          icon: const Icon(Icons.refresh, color: Colors.white),
                          label: const Text('Refresh', style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: logout,
                          icon: const Icon(Icons.logout, color: Colors.white),
                          label: const Text('Logout', style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
