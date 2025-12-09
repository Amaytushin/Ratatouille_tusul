import 'package:flutter/material.dart';

class RecipeDetailScreen extends StatelessWidget {
  final Map<String, dynamic> recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
     print("🍏 NUTRITION DATA ===> ${recipe['nutrition']}");
    // Backend-аас ирсэн list/map-г default гаргах
    List<dynamic> ingredients = recipe['ingredients'] ?? [];
    List<dynamic> steps = recipe['steps'] ?? [];
    Map<String, dynamic> nutrition = recipe['nutrition'] ?? {};

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          // 🌈 Gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF7C3AED), Color(0xFFB37FEB), Color(0xFFF3E8FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero Image Section
                Hero(
                  tag: recipe['name'] ?? '',
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(32),
                      bottomRight: Radius.circular(32),
                    ),
                    child: Image.network(
                      recipe['image'] ?? '',
                      width: double.infinity,
                      height: 280,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Image.asset('assets/images/placeholder.png', fit: BoxFit.cover),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Recipe Info Card
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipe['name'] ?? '',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4A148C),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _infoChip(Icons.timer, recipe['time']?.toString() ?? ''),
                          _infoChip(Icons.people, recipe['servings']?.toString() ?? ''),
                          _infoChip(Icons.flag, recipe['cuisine'] ?? ''),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // 🍅 Ingredients Section
                _sectionTitle("🧂 Орц"),
                _ingredientsList(ingredients.map<String>((e) => e['name'].toString()).toList()),

                const SizedBox(height: 24),

                // 🟣 Илчлэгийн дэлгэрэнгүй хэсэг
               _sectionTitle("🍏 Илчлэг"),
              _nutritionInfoCard({
                "Илчлэг": nutrition['calories'] ?? 'N/A',
                "Уураг": nutrition['protein'] ?? 'N/A',
                "Өөх тос": nutrition['fat'] ?? 'N/A',
                "Нүүрс ус": nutrition['carbs'] ?? 'N/A',
              }),
              
                const SizedBox(height: 24),

                // 🍳 Cooking Steps Section
                _sectionTitle("👨‍🍳 Хоол хийх алхамууд"),
                _cookingSteps(
                  steps.map<String>((item) => item['description'].toString()).toList()),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 Info Chips (time, servings, cuisine)
  Widget _infoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF3E8FF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF7C3AED), size: 18),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(color: Color(0xFF4A148C), fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  // 🔹 Section Title
  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: [
            Shadow(color: Colors.black26, offset: Offset(1, 1), blurRadius: 2),
          ],
        ),
      ),
    );
  }

  // 🔹 Ingredients list
  Widget _ingredientsList(List<String> ingredients) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: ingredients
            .map(
              (item) => Container(
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Color(0xFF7C3AED), size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        item,
                        style: const TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  // 🔹 Nutrition Info Card
  Widget _nutritionInfoCard(Map<String, String> nutrients) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: nutrients.entries.map((entry) {
        return Column(
          children: [
            Text(
              entry.key,
              style: const TextStyle(
                color: Color(0xFF7C3AED),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              entry.value,
              style: const TextStyle(
                color: Color(0xFF4A148C),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        );
      }).toList(),
    ),
  );
}

  // 🔹 Cooking Steps
  Widget _cookingSteps(List<String> steps) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: steps
            .asMap()
            .entries
            .map(
              (entry) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: const Color(0xFF7C3AED),
                      child: Text(
                        "${entry.key + 1}",
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        entry.value,
                        style: const TextStyle(fontSize: 16, height: 1.5, color: Color(0xFF4A148C)),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
