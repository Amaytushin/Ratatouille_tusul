import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Ingredient {
  final int id;
  final String name;
  Ingredient({required this.id, required this.name});
}

class AddRecipeScreen extends StatefulWidget {
  const AddRecipeScreen({Key? key}) : super(key: key);

  @override
  State<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String description = '';
  String timeRequired = '';
  int servings = 1;
  String cuisine = '';
  int? categoryId;
  Uint8List? imageBytes;
  String? imageName;

  List<Ingredient> allIngredients = [];
  List<Ingredient> selectedIngredients = [];

  String calories = '';
  String protein = '';
  String fat = '';
  String carbs = '';

  List<Map<String, dynamic>> categories = [];

  @override
  void initState() {
    super.initState();
    _loadIngredients();
    _loadCategories();
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Future<void> _loadIngredients() async {
    final response = await http.get(Uri.parse('http://127.0.0.1:8000/api/ingredients/'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        allIngredients = List<Ingredient>.from(
          data.map((i) => Ingredient(id: i['id'], name: i['name']))
        );
      });
    }
  }

  Future<void> _loadCategories() async {
    final response = await http.get(Uri.parse('http://127.0.0.1:8000/api/categories/'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        categories = List<Map<String, dynamic>>.from(data);
      });
    }
  }

  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result != null && result.files.single.bytes != null) {
      setState(() {
        imageBytes = result.files.single.bytes!;
        imageName = result.files.single.name;
      });
    }
  }

  Future<void> _submitRecipe() async {
    if (!_formKey.currentState!.validate()) return;

    if (categoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Category сонгоно уу')));
      return;
    }

    if (selectedIngredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ingredients сонгоно уу')));
      return;
    }

    final token = await _getToken();
    if (token == null) return;

    var uri = Uri.parse('http://127.0.0.1:8000/api/recipes/');
    var request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer $token';

    request.fields['name'] = name;
    request.fields['description'] = description;
    request.fields['time_required'] = timeRequired;
    request.fields['servings'] = servings.toString();
    request.fields['cuisine'] = cuisine;
    request.fields['category'] = categoryId.toString();

    // Nutrition
    request.fields['nutrition.calories'] = calories;
    request.fields['nutrition.protein'] = protein;
    request.fields['nutrition.fat'] = fat;
    request.fields['nutrition.carbs'] = carbs;

    // Ingredients
    for (var ing in selectedIngredients) {
      request.fields['ingredients'] = ing.id.toString();
    }

    // Image
    if (imageBytes != null && imageName != null) {
      request.files.add(http.MultipartFile.fromBytes(
        'image',
        imageBytes!,
        filename: imageName,
      ));
    }

    var response = await request.send();
    if (response.statusCode == 201 || response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Recipe амжилттай нэмэгдлээ')));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Алдаа гарлаа: ${response.statusCode}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Recipe')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Name'),
                onChanged: (val) => name = val,
                validator: (val) => val == null || val.isEmpty ? 'Name required' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Description'),
                onChanged: (val) => description = val,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Time Required'),
                onChanged: (val) => timeRequired = val,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Servings'),
                keyboardType: TextInputType.number,
                onChanged: (val) => servings = int.tryParse(val) ?? 1,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Cuisine'),
                onChanged: (val) => cuisine = val,
              ),
              const SizedBox(height: 16),
              // Category
              DropdownButtonFormField<int>(
                value: categoryId,
                decoration: const InputDecoration(labelText: 'Category'),
                items: categories
                    .map((c) => DropdownMenuItem<int>(
                          value: c['id'] as int,
                          child: Text(c['name']),
                        ))
                    .toList(),
                onChanged: (val) => setState(() => categoryId = val),
                validator: (val) => val == null ? 'Select category' : null,
              ),
              const SizedBox(height: 16),
              // Ingredients MultiSelect
              MultiSelectDialogField<Ingredient>(
                items: allIngredients
                    .map((e) => MultiSelectItem<Ingredient>(e, e.name))
                    .toList(),
                title: const Text('Ingredients'),
                buttonText: const Text('Select Ingredients'),
                listType: MultiSelectListType.LIST,
                onConfirm: (values) {
                  selectedIngredients = values;
                },
                chipDisplay: MultiSelectChipDisplay(
                  onTap: (value) {
                    selectedIngredients.remove(value);
                    setState(() {});
                  },
                ),
              ),
              const SizedBox(height: 16),
              // Nutrition
              TextFormField(
                decoration: const InputDecoration(labelText: 'Калор'),
                onChanged: (val) => calories = val,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Уураг'),
                onChanged: (val) => protein = val,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Өөх тос'),
                onChanged: (val) => fat = val,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Нүүрс ус'),
                onChanged: (val) => carbs = val,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _pickImage,
                child: const Text('Select Image'),
              ),
              if (imageBytes != null)
                Image.memory(imageBytes!, height: 120, width: 120, fit: BoxFit.cover),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submitRecipe,
                child: const Text('Add Recipe'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
