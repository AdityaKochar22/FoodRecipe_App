import 'package:flutter/material.dart';
import '../services/api_service.dart';

class RecipeDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> recipe;

  const RecipeDetailsScreen({super.key, required this.recipe});

  @override
  _RecipeDetailsScreenState createState() => _RecipeDetailsScreenState();
}

class _RecipeDetailsScreenState extends State<RecipeDetailsScreen> {
  final ApiService apiService = ApiService();
  List<dynamic> ingredients = [];
  List<dynamic> instructions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchRecipeDetails();
  }

  void fetchRecipeDetails() async {
    try {
      final fetchedIngredients =
          await apiService.fetchIngredients(widget.recipe['id']);
      final fetchedInstructions =
          await apiService.fetchInstructions(widget.recipe['id']);

      setState(() {
        ingredients = fetchedIngredients;
        instructions = fetchedInstructions;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching recipe details: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.recipe['title'])),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Hero animation for smooth transition
            Hero(
              tag: widget.recipe['id'],
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: widget.recipe['image'] != null &&
                        widget.recipe['image'].isNotEmpty
                    ? Image.network(
                        widget.recipe['image'],
                        width: 350,
                        height: 350,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.broken_image,
                                size: 100, color: Colors.grey),
                      )
                    : const Icon(Icons.broken_image,
                        size: 100, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 20),

            // Ingredients Section
            Text("Ingredients:",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            isLoading
                ? Center(child: CircularProgressIndicator())
                : ingredients.isNotEmpty
                    ? Column(
                        children: ingredients.map((ingredient) {
                          return Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            elevation: 3,
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            child: ListTile(
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  "https://spoonacular.com/cdn/ingredients_100x100/${ingredient['image']}",
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Icon(Icons.broken_image,
                                          size: 50, color: Colors.grey),
                                ),
                              ),
                              title: Text(ingredient['name'],
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                              subtitle: Text(
                                  "${ingredient['amount']['metric']['value']} ${ingredient['amount']['metric']['unit']}",
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold)),
                            ),
                          );
                        }).toList(),
                      )
                    : Text("No ingredients found",
                        style: TextStyle(fontSize: 16, color: Colors.grey)),

            const SizedBox(height: 20),

            // Instructions Section
            Text("Instructions:",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            isLoading
                ? Center(child: CircularProgressIndicator())
                : instructions.isNotEmpty
                    ? Column(
                        children: instructions.map((step) {
                          return Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            elevation: 3,
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.orangeAccent,
                                child: Text(
                                  step['number'].toString(),
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                              ),
                              title: Text(step['step'],
                                  style: TextStyle(fontSize: 16)),
                            ),
                          );
                        }).toList(),
                      )
                    : Text("No instructions available",
                        style: TextStyle(fontSize: 16, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
