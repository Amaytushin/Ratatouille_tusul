import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'RecipeDetailScreen.dart';
import 'search_screen.dart';
import 'favorites_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  List<String> categories = [];
  int selectedCategoryIndex = 0;
  int selectedBottomIndex = 0;

  List<Map<String, dynamic>> recipes = [];
  List<Map<String, dynamic>> favorites = [];

  late final AnimationController _controller;
  late final Animation<double> _featuredScale;
  late final Animation<double> _featuredFade;
  late final Animation<double> _bottomFade;

  late final SearchScreen _searchScreen;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _featuredScale = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.3, 0.6, curve: Curves.easeOutBack)),
    );

    _featuredFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.3, 0.6, curve: Curves.easeIn)),
    );

    _bottomFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.7, 1.0, curve: Curves.easeIn)),
    );

    _controller.forward();

    _loadCategories();
    _loadRecipes();

    _searchScreen = const SearchScreen();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final response = await http.get(Uri.parse('http://127.0.0.1:8000/api/categories/'));
      if (response.statusCode == 200) {
        List data = json.decode(response.body);
        setState(() {
          categories = data.map<String>((cat) => cat['name'] as String).toList();
        });
      } else {
        debugPrint('Failed to load categories: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching categories: $e');
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
          recipes = data.map<Map<String, dynamic>>((recipe) => {
                'name': recipe['name'],
                'time': recipe['time_required'],
                'servings': recipe['servings'].toString(),
                'cuisine': recipe['cuisine'],
                'image': recipe['image'],
              }).toList();
        });
      } else {
        debugPrint('Failed to load recipes: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching recipes: $e');
    }
  }

  Widget _recipeCard(Map<String, dynamic> recipe) {
    final isFavorite = favorites.contains(recipe);
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => RecipeDetailScreen(recipe: recipe)),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Image.network(
              recipe['image'] ?? '',
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  Image.asset('assets/images/placeholder.png', fit: BoxFit.cover),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Text(
                  recipe['name'] ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: Colors.red,
                ),
                onPressed: () {
                  setState(() {
                    if (isFavorite) {
                      favorites.remove(recipe);
                    } else {
                      favorites.add(recipe);
                    }
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _featuredRecipe(Map<String, dynamic> recipe) {
    if (recipe.isEmpty) return const SizedBox.shrink();
    final isFavorite = favorites.contains(recipe);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => RecipeDetailScreen(recipe: recipe)),
        );
      },
      child: FadeTransition(
        opacity: _featuredFade,
        child: ScaleTransition(
          scale: _featuredScale,
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.purple.withOpacity(0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                )
              ],
            ),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.network(
                    recipe['image'] ?? '',
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Image.asset('assets/images/placeholder.png', fit: BoxFit.cover),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Text(
                    recipe['name'] ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(color: Colors.black38, offset: Offset(1, 1), blurRadius: 2)
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: IconButton(
                    icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        if (isFavorite) {
                          favorites.remove(recipe);
                        } else {
                          favorites.add(recipe);
                        }
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _homePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 Header image + title
          Container(
            width: double.infinity,
            height: 120,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              image: const DecorationImage(
                image: AssetImage('assets/images/ratatouille.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Ratatouille',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4C1D95),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 🔹 Featured recipe
          _featuredRecipe(recipes.isNotEmpty ? recipes[0] : {}),
          const SizedBox(height: 20),

          // 🔹 Categories
          SizedBox(
            height: 50,
            child: categories.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
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
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              gradient: isSelected
                                  ? const LinearGradient(
                                      colors: [Color(0xFF7C3AED), Color(0xFFB37FEB)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    )
                                  : null,
                              color: isSelected ? null : Colors.white,
                              borderRadius: BorderRadius.circular(30),
                              border: isSelected ? null : Border.all(color: const Color(0xFF7C3AED)),
                            ),
                            child: Text(
                              categories[index],
                              style: TextStyle(
                                color: isSelected ? Colors.white : const Color(0xFF7C3AED),
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 20),

          // 🔹 Grid recipes
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recipes.length > 1 ? recipes.length - 1 : 0,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 0.72,
              ),
              itemBuilder: (context, index) {
                return _recipeCard(recipes[index + 1]);
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
    final pages = [
      _homePage(),
      _searchScreen,
      FavoritesScreen(favorites: favorites),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: IndexedStack(index: selectedBottomIndex, children: pages),
      ),
      bottomNavigationBar: FadeTransition(
        opacity: _bottomFade,
        child: BottomNavigationBar(
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
            BottomNavigationBarItem(icon: Icon(Icons.restaurant), label: 'Recipes'),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
            BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favorites'),
          ],
        ),
      ),
    );
  }
}
