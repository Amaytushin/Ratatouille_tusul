import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'RecipeDetailScreen.dart';
import 'search_screen.dart';
import 'favorites_screen.dart';
import 'profile_screen.dart';
import 'add_recipe_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  List<String> categories = [];
  int selectedCategoryIndex = 0;
  int selectedBottomIndex = 0;

  List<Map<String, dynamic>> recipes = [];
  List<Map<String, dynamic>> favorites = [];

  bool isLoadingRecipes = false;

  late final AnimationController _controller;
  late final SearchScreen _searchScreen;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();

    _searchScreen = const SearchScreen();

    _loadCategories();
    _loadWishlist();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  // ================== CATEGORIES ==================
  Future<void> _loadCategories() async {
    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/categories/'),
      );

      if (response.statusCode == 200) {
        List data = json.decode(response.body);
        final loadedCategories = data.map<String>((cat) => cat['name'] as String).toList();

        final allIndex = loadedCategories.indexWhere((c) => c.toLowerCase() == 'бүгд');

        setState(() {
          categories = loadedCategories;
          selectedCategoryIndex = allIndex != -1 ? allIndex : 0;
        });

        await _loadRecipes(category: allIndex != -1 ? loadedCategories[allIndex] : null);
      }
    } catch (e) {
      debugPrint('Category error: $e');
    }
  }

  // ================== RECIPES ==================
  Future<void> _loadRecipes({String? category}) async {
    setState(() => isLoadingRecipes = true);

    try {
      String url = 'http://127.0.0.1:8000/api/recipes/';

      if (category != null && category.toLowerCase() != 'бүгд') {
        url += 'by_category/?category=$category';
      }

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        List data = json.decode(response.body);
        setState(() {
          recipes = data.map<Map<String, dynamic>>((r) {
            return {
              'id': r['id'],
              'name': r['name'],
              'time': r['time_required'].toString(),
              'servings': r['servings'].toString(),
              'cuisine': r['cuisine'],
              'image': r['image'],
              'nutrition': r['nutrition'],
              'average_rating': r['average_rating'] ?? 0.0,
            };
          }).toList();
        });
      }
    } catch (e) {
      debugPrint('Recipe error: $e');
    }

    setState(() => isLoadingRecipes = false);
  }

  // ================== WISHLIST ==================
  Future<void> _loadWishlist() async {
    final token = await _getToken();
    if (token == null) return;

    final response = await http.get(
      Uri.parse("http://127.0.0.1:8000/api/wishlist/my/"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      setState(() {
        favorites = data.map<Map<String, dynamic>>((item) {
          return {
            "wishlist_id": item["id"],
            "id": item["recipe"]["id"],
            "name": item["recipe"]["name"],
            "image": item["recipe"]["image"],
            "time": item["recipe"]["time_required"].toString(),
          };
        }).toList();
      });
    }
  }

  Future<void> _addToWishlist(int recipeId) async {
    final token = await _getToken();
    if (token == null) return;

    await http.post(
      Uri.parse("http://127.0.0.1:8000/api/wishlist/add/"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: json.encode({"recipe_id": recipeId}),
    );

    await _loadWishlist();
  }

  Future<void> _removeFromWishlist(int wishlistId) async {
    final token = await _getToken();
    if (token == null) return;

    await http.delete(
      Uri.parse("http://127.0.0.1:8000/api/wishlist/remove/$wishlistId/"),
      headers: {"Authorization": "Bearer $token"},
    );

    await _loadWishlist();
  }

  bool _isFavorite(int recipeId) => favorites.any((f) => f["id"] == recipeId);

  int? _getWishlistId(int recipeId) {
    final item = favorites.firstWhere((f) => f["id"] == recipeId, orElse: () => {});
    return item["wishlist_id"];
  }

  Future<void> _submitRating(int recipeId, double rating) async {
    final token = await _getToken();
    if (token == null) return;

    final response = await http.post(
      Uri.parse('http://127.0.0.1:8000/api/recipes/$recipeId/rate/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'rating': rating}),
    );

    if (response.statusCode == 200) {
      debugPrint('Rating submitted successfully');
      await _loadRecipes(category: categories[selectedCategoryIndex]);
    } else {
      debugPrint('Error submitting rating: ${response.statusCode}');
    }
  }

  // ================== UI ==================
  Widget _modernHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF7C3AED), Color(0xFFB37FEB)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(26),
          bottomRight: Radius.circular(26),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Ratatouille',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          CircleAvatar(
            backgroundColor: Colors.white,
            child: IconButton(
              icon: const Icon(Icons.person, color: Color(0xFF7C3AED)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ProfileScreen(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _recipeCard(Map<String, dynamic> recipe) {
    final isFav = _isFavorite(recipe['id']);
    final wishlistId = _getWishlistId(recipe['id']);
    double avgRating = (recipe['average_rating'] ?? 0).toDouble();

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RecipeDetailScreen(recipe: recipe),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: Image.network(
                recipe['image'],
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe['name'],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Average rating
                  Row(
                    children: [
                      RatingBarIndicator(
                        rating: avgRating,
                        itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
                        itemCount: 5,
                        itemSize: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(avgRating.toStringAsFixed(1)),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // User rating input
                  RatingBar.builder(
                    initialRating: 0,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemCount: 5,
                    itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.purple),
                    onRatingUpdate: (rating) async {
                      await _submitRating(recipe['id'], rating);
                    },
                    itemSize: 20,
                  ),

                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.timer, size: 16, color: Colors.deepPurple),
                          const SizedBox(width: 4),
                          Text(recipe['time']),
                        ],
                      ),
                      IconButton(
                        icon: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: Colors.red),
                        onPressed: () async {
                          if (isFav) {
                            await _removeFromWishlist(wishlistId!);
                          } else {
                            await _addToWishlist(recipe['id']);
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _homePage() {
    return Column(
      children: [
        _modernHeader(),
        const SizedBox(height: 16),

        // Categories
        SizedBox(
          height: 48,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: categories.length,
            itemBuilder: (_, index) {
              final selected = index == selectedCategoryIndex;
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: GestureDetector(
                  onTap: () {
                    setState(() => selectedCategoryIndex = index);
                    _loadRecipes(category: categories[index]);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    decoration: BoxDecoration(
                      color: selected ? const Color(0xFF7C3AED) : Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: const Color(0xFF7C3AED)),
                    ),
                    child: Text(
                      categories[index],
                      style: TextStyle(
                        color: selected ? Colors.white : const Color(0xFF7C3AED),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),

        // Recipes Grid
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: isLoadingRecipes
                ? const Center(child: CircularProgressIndicator())
                : GridView.builder(
                    itemCount: recipes.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.65,
                    ),
                    itemBuilder: (_, i) => _recipeCard(recipes[i]),
                  ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _homePage(),
      _searchScreen,
      const AddRecipeScreen(),
      WishlistScreen(
        favorites: favorites,
        onRemove: _removeFromWishlist,
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: IndexedStack(
          index: selectedBottomIndex,
          children: pages,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedBottomIndex,
        onTap: (i) => setState(() => selectedBottomIndex = i),
        selectedItemColor: const Color(0xFF7C3AED),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.restaurant), label: 'Recipes'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favorites'),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline),label: 'Add'),
        ],
      ),
    );
  }
}
