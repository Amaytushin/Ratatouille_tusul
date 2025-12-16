import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'SearchResultScreen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();

  Map<String, List<String>> pantryCategories = {}; // API-аас ачаалдаг
  final Set<String> selectedItems = {};
  bool isLoading = false;
  bool isFetching = true; // API-аас ачаалж байгааг заах

  @override
  void initState() {
    super.initState();
    fetchIngredients();
  }

  Future<void> fetchIngredients() async {
  try {
    final response = await http.get(Uri.parse('http://127.0.0.1:8000/api/ingredients/'));
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      Map<int, String> categoryNames = {
        1: 'Сүү сүүн бүтээгдэхүүн',
        2: 'Хүнсний ногоо ба навчит ургамал',
        3: 'Өндөг',
        4: 'Бяслаг',
      };

      Map<String, List<String>> categories = {};

      for (var item in data) {
        final catId = item['category'];
        final catName = categoryNames[catId] ?? 'Бусад';
        if (!categories.containsKey(catName)) {
          categories[catName] = [];
        }
        categories[catName]!.add(item['name']);
      }

      setState(() {
        pantryCategories = categories;
        isFetching = false;
      });
    } else {
      debugPrint('Error fetching ingredients: ${response.statusCode}');
      setState(() => isFetching = false);
    }
  } catch (e) {
    debugPrint('Exception fetching ingredients: $e');
    setState(() => isFetching = false);
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFF6D28D9),
        title: const Text('Орц сонгох', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: isFetching
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Header + Search Bar
                  Stack(
                    children: [
                      Image.asset('assets/images/rat2.jpg', width: double.infinity, height: 200, fit: BoxFit.cover),
                      Container(width: double.infinity, height: 200, color: Colors.black.withOpacity(0.2)),
                      Positioned.fill(
                        child: Align(
                          alignment: Alignment.center,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: TextField(
                              controller: _controller,
                              decoration: InputDecoration(
                                hintText: 'Орц хайх...',
                                filled: true,
                                fillColor: Colors.white,
                                prefixIcon: const Icon(Icons.search, color: Color(0xFF6D28D9)),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Pantry categories
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: pantryCategories.entries.map((entry) {
                        return _buildAlwaysExpandedCategory(entry.key, entry.value);
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 70),
                ],
              ),
            ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Миний орц (${selectedItems.length})",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6D28D9),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              ),
              onPressed: isLoading ? null : _searchRecipes,
              child: isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text("Жорууд харах", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlwaysExpandedCategory(String category, List<String> items) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(category, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items.map((item) {
              final isSelected = selectedItems.contains(item);
              return FilterChip(
                label: Text(item, style: TextStyle(color: isSelected ? Colors.white : Colors.black87)),
                selected: isSelected,
                selectedColor: const Color(0xFF6D28D9),
                backgroundColor: Colors.grey[200],
                checkmarkColor: Colors.transparent,
                onSelected: (_) {
                  setState(() {
                    if (isSelected) {
                      selectedItems.remove(item);
                    } else {
                      selectedItems.add(item);
                    }
                  });
                },
              );
            }).toList(),
          ),
        ]),
      ),
    );
  }

  void _searchRecipes() async {
    if (selectedItems.isEmpty) return;

    setState(() => isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/api/search_recipes/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'ingredients': selectedItems.toList()}),
      );
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SearchResultScreen(recipes: data),
          ),
        );
      } else {
        debugPrint('Error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Exception: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }
}
