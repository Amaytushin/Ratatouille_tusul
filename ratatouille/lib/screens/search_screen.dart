import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();

  final Map<String, List<String>> pantryCategories = {
    'Мах': [
      'үхрийн мах', 'гахайн мах', 'тахианы мах', 'загас', 'хонины мах', 'тахианы цээж мах'
    ],
    'Хүнсний ногоо ба навчит ургамал': [
      'сармис', 'сонгино', 'бөөрөнхий чинжүү', 'ногоон сонгино',
      'лууван', 'улаан лооль', 'төмс', 'улаан сонгино', 'сельдерей', 'авокадо'
    ],
    'Мөөг': [
      'цагаан мөөг', 'портобелло мөөг', 'шитаке мөөг',
      'порчини мөөг', 'хясаан мөөг', 'энооки мөөг'
    ],
    'Жимс': [
      'алим', 'банана', 'жүрж', 'нимбэг', 'манго', 'хан боргоцой', 'гадил', 'үзэм'
    ],
    'Жимсгэнэ': [
      'гүзээлзгэнэ', 'хөх нэрс', 'үхрийн нүд', 'тошлой', 'жимсний холимог'
    ],
    'Бяслаг': [
      'чеддар', 'моцарелла', 'пармезан', 'бри', 'фета', 'крем бяслаг'
    ],
    'Гал тогооны үндсэн зүйлс': [
      'цөцгийн тос', 'өндөг', 'сүү', 'элсэн чихэр',
      'гурил', 'оливийн тос', 'сармисны нунтаг', 'цагаан будаа',
      'кетчуп', 'шар буурцгийн сүмс', 'майонез', 'талх',
      'бөөлжгөөний нунтаг', 'орегано', 'төмс', 'паприка',
      'спагетти', 'газрын самрын тос', 'чинжүү нунтаг', 'чеддар бяслаг',
      'улаан лооль', 'базил', 'яншуй'
    ],
    'Нарийн боовны зүйлс': [
      'гурил', 'нарийн боовны нунтаг', 'ваниль', 'жигд нунтаг', 'какао', 'зөгийн бал'
    ],
  };

  final Set<String> selectedItems = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFF6D28D9), // LoginScreen шиг нил ягаан
        title: const Text(
            'Орц сонгох',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: const [
            Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Icon(Icons.sort_by_alpha, color: Colors.white),
            )
        ],
        ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ✅ HEADER хэсэг — зураг + хайлтын хэсэг
            Stack(
              children: [
                Image.asset(
                  'assets/images/rat2.jpg',
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.1),
                  ),
                ),
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: 'орц хайх...',
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

            // ✅ Категориуд (бүгд нээлттэй)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: pantryCategories.entries.map((entry) {
                  final category = entry.key;
                  final items = entry.value;
                  return _buildAlwaysExpandedCategory(category, items);
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
                backgroundColor: Color(0xFF6D28D9),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              ),
              onPressed: () {},
              child: const Text("Жорууд харах", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  /// ✅ Категори бүгд анхнаасаа нээлттэй байх
  Widget _buildAlwaysExpandedCategory(String category, List<String> items) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              category,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items.map((item) {
                final isSelected = selectedItems.contains(item);
                return FilterChip(
                label: Text(
                    item,
                    style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w500,
                    ),
                ),
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
          ],
        ),
      ),
    );
  }
}
