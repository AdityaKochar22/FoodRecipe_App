import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String apiKey = "8252acf04c204532bfa679635cd9b8df";
  final String baseUrl = "https://api.spoonacular.com/recipes";

  Future<List<dynamic>> fetchRecipes() async {
    final url = Uri.parse("$baseUrl/random?number=10&apiKey=$apiKey");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['recipes'] ?? [];
    } else {
      throw Exception("Failed to load recipes");
    }
  }

  Future<Map<String, dynamic>> fetchMealPlan(
      String timeFrame, int targetCalories, String diet) async {
    final url = Uri.parse(
        "https://api.spoonacular.com/mealplanner/generate?timeFrame=$timeFrame&targetCalories=$targetCalories&diet=$diet&apiKey=$apiKey");

    print("Fetching Meal Plan from: $url"); // Debugging URL

    final response = await http.get(url);

    print("Response Status: ${response.statusCode}"); // Debugging response code
    print("Response Body: ${response.body}"); // Debugging response body

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load meal plan");
    }
  }

  Future<List<dynamic>> fetchIngredients(int recipeId) async {
    final url =
        Uri.parse("$baseUrl/$recipeId/ingredientWidget.json?apiKey=$apiKey");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['ingredients'] ?? [];
    } else {
      throw Exception("Failed to load ingredients");
    }
  }

  Future<List<dynamic>> fetchInstructions(int recipeId) async {
    final url =
        Uri.parse("$baseUrl/$recipeId/analyzedInstructions?apiKey=$apiKey");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data.isNotEmpty ? data[0]['steps'] ?? [] : [];
    } else {
      throw Exception("Failed to load instructions");
    }
  }
}
