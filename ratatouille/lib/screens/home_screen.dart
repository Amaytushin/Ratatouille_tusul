import 'package:flutter/material.dart';
import 'RecipeDetailScreen.dart';
import 'search_screen.dart'; // SearchScreen холбож байна

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final List<String> categories = ['Өглөөний цай', 'Оройн хоол', 'Фитнэс хоол', 'Кето дэглэм'];
  int selectedCategoryIndex = 0;
  int selectedBottomIndex = 0;

  final List<Map<String, String>> recipes = [
    {
      'name': 'Банштай цай',
      'time': '35 mins',
      'servings': '4',
      'cuisine': 'Mongolia',
      'image': 'assets/images/bansh.jpg',
    },
    {
      'name': 'Үхрийн махан Стек',
      'time': '45 минут',
      'servings': '2',
      'cuisine': 'Америк',
      'image': 'assets/images/beef1.jpg',
    },
    {
      'name': 'Гриллдэж шарсан үхрийн мах',
      'time': '50 минут',
      'servings': '4',
      'cuisine': 'Франц',
      'image': 'assets/images/beef2.jpg',
    },
  ];

  late final AnimationController _controller;
  late final Animation<double> _featuredScale;
  late final Animation<double> _featuredFade;
  late final Animation<double> _bottomFade;

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
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _recipeCard(Map<String, String> recipe, int index) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecipeDetailScreen(recipe: recipe),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Image.asset(
              recipe['image']!,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Text(
                  recipe['name']!,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _featuredRecipe(Map<String, String> recipe) {
    return FadeTransition(
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
                child: Image.asset(
                  recipe['image']!,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe['name']!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: Colors.black38,
                            offset: Offset(1, 1),
                            blurRadius: 2,
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bottomNavigation() {
    return FadeTransition(
      opacity: _bottomFade,
      child: BottomNavigationBar(
        currentIndex: selectedBottomIndex,
        onTap: (index) {
          setState(() {
            selectedBottomIndex = index;
          });

          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SearchScreen()),
            );
          }
        },
        selectedItemColor: const Color(0xFF7C3AED),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.restaurant), label: 'Recipes'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favorites'),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    image: const DecorationImage(
                      image: AssetImage('assets/images/ratatouille.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Center(
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
                _featuredRecipe(recipes[0]),
                const SizedBox(height: 20),
                SizedBox(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final isSelected = index == selectedCategoryIndex;
                      return Padding(
                        padding: const EdgeInsets.only(right: 14),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedCategoryIndex = index;
                            });
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
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 0.72,
                  ),
                  itemCount: recipes.length - 1,
                  itemBuilder: (context, index) {
                    return _recipeCard(recipes[index + 1], index);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _bottomNavigation(),
    );
  }
}
