import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'RecipeDetailScreen.dart';
import 'search_screen.dart';
import 'favorites_screen.dart';
import 'profile_screen.dart';

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

  late final AnimationController _controller;
  late final SearchScreen _searchScreen;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _controller.forward();

    _loadCategories();
    _loadRecipes();
    _loadWishlist();

    _searchScreen = const SearchScreen();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  Future<void> _loadCategories() async {
    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/categories/'),
      );

      if (response.statusCode == 200) {
        List data = json.decode(response.body);

        setState(() {
          categories = data.map<String>((cat) => cat['name'] as String).toList();
        });
      }
    } catch (e) {
      debugPrint("Category Error: $e");
    }
  }

  Future<void> _loadRecipes({String? category}) async {
    try {
      String url = 'http://127.0.0.1:8000/api/recipes/';

      if (category != null) {
        url += 'by_category/?category=$category';
      }

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        List data = json.decode(response.body);

        setState(() {
          recipes = data.map<Map<String, dynamic>>((r) => {
                'id': r['id'],
                'name': r['name'],
                'time': r['time_required'],
                'servings': r['servings'].toString(),
                'cuisine': r['cuisine'],
                'image': r['image'],
                'nutrition': r['nutrition'],
              }).toList();
        });
      }
    } catch (e) {
      debugPrint('Recipe Error: $e');
    }
  }

  Future<void> _loadWishlist() async {
    final token = await _getToken();
    if (token == null) return;

    final response = await http.get(
      Uri.parse("http://127.0.0.1:8000/api/wishlist/my/"),
      headers: {"Authorization": "Token $token"},
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
            "nutrition": item["recipe"]["nutrition"]
          };
        }).toList();
      });
    }
  }

  Future<void> _addToWishlist(int recipeId) async {
    final token = await _getToken();
    if (token == null) return;

    final response = await http.post(
      Uri.parse("http://127.0.0.1:8000/api/wishlist/add/"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Token $token"
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
      headers: {"Authorization": "Token $token"},
    );

    await _loadWishlist();
  }

  bool _isFavorite(int recipeId) {
    return favorites.any((item) => item["id"] == recipeId);
  }

  int? _getWishlistId(int recipeId) {
    final item =
        favorites.firstWhere((fav) => fav["id"] == recipeId, orElse: () => {});
    return item["wishlist_id"];
  }

  Widget _modernHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF7C3AED), Color(0xFFB37FEB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(26),
          bottomRight: Radius.circular(26),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Ratatouille',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              CircleAvatar(
                radius: 26,
                backgroundColor: Colors.white,
                child: IconButton(
                  icon: const Icon(Icons.person, color: Color(0xFF7C3AED), size: 28),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfileScreen(),
                      ),
                    );
                  },
                ),
              )

            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const TextField(
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Search recipes...',
                hintStyle: TextStyle(color: Colors.white70),
                icon: Icon(Icons.search, color: Colors.white),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _recipeCard(Map<String, dynamic> recipe) {
    final isFavorite = _isFavorite(recipe["id"]);
    final wishlistId = _getWishlistId(recipe["id"]);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => RecipeDetailScreen(recipe: recipe)),
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
            )
          ],
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
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
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.timer,
                              size: 16, color: Colors.deepPurple),
                          const SizedBox(width: 4),
                          Text('${recipe['time']} min'),
                        ],
                      ),
                      IconButton(
                        icon: Icon(
                            isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: Colors.red),
                        onPressed: () async {
                          if (isFavorite) {
                            await _removeFromWishlist(wishlistId!);
                          } else {
                            await _addToWishlist(recipe["id"]);
                          }
                        },
                      ),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _homePage() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _modernHeader(),
          const SizedBox(height: 20),

          // Categories
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final isSelected = index == selectedCategoryIndex;

                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedCategoryIndex = index;
                      });
                      _loadRecipes(category: categories[index]);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color:
                            isSelected ? const Color(0xFF7C3AED) : Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        border:
                            Border.all(color: const Color(0xFF7C3AED)),
                      ),
                      child: Text(
                        categories[index],
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF7C3AED),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          // Recipes Grid
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recipes.length,
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.72,
              ),
              itemBuilder: (context, index) {
                return _recipeCard(recipes[index]);
              },
            ),
          ),

          const SizedBox(height: 80),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    print("favoritesfavorites: $favorites");
    final pages = [
      _homePage(),
      _searchScreen,
      FavoritesScreen(
        
        favorites: favorites,
        onRemove: (wishlistId) async {
          await _removeFromWishlist(wishlistId); // HomeScreen-ийн API call
        },
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
        type: BottomNavigationBarType.fixed,
        currentIndex: selectedBottomIndex,
        onTap: (index) {
          setState(() {
            selectedBottomIndex = index;
          });
        },
        selectedItemColor: const Color(0xFF7C3AED),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.restaurant), label: 'Recipes'),
          BottomNavigationBarItem(
              icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite), label: 'Favorites'),
        ],
      ),
    );
  }
}
