import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class WishlistScreen extends StatefulWidget {
  final List<Map<String, dynamic>> favorites;
  final Future<void> Function(int) onRemove;

  const WishlistScreen({
    super.key,
    required this.favorites,
    required this.onRemove,
  });

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  late List<Map<String, dynamic>> favorites;

  @override
  void initState() {
    super.initState();
    favorites = widget.favorites;
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Future<void> _removeFavorite(int wishlistId) async {
    await widget.onRemove(wishlistId);
    setState(() {
      favorites.removeWhere((item) => item["wishlist_id"] == wishlistId);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (favorites.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            'Your wishlist is empty.',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        final item = favorites[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                item['image'],
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),
            ),
            title: Text(
              item['name'],
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text('${item['time']} min'),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                await _removeFavorite(item["wishlist_id"]);
              },
            ),
          ),
        );
      },
    );
  }
}
