import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'recipe_details_screen.dart'; // Import RecipeDetailsScreen

class MealPlanScreen extends StatefulWidget {
  const MealPlanScreen({super.key});

  @override
  _MealPlanScreenState createState() => _MealPlanScreenState();
}

class _MealPlanScreenState extends State<MealPlanScreen> {
  final ApiService apiService = ApiService();
  final TextEditingController calorieController = TextEditingController();
  String selectedDiet = "vegetarian"; // Default diet
  List<dynamic> meals = [];
  Map<String, dynamic> nutrients = {};
  bool isLoading = false;

  void fetchMealPlan() async {
    setState(() => isLoading = true);
    try {
      final data = await apiService.fetchMealPlan(
        "day",
        int.tryParse(calorieController.text) ?? 2000,
        selectedDiet,
      );

      setState(() {
        meals = data['meals'];
        nutrients = data['nutrients'];
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching meal plan: $e");
      setState(() => isLoading = false);
    }
  }

  void openRecipeDetails(Map<String, dynamic> meal) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecipeDetailsScreen(
          recipe: {
            'id': meal['id'],
            'title': meal['title'],
            'image':
                "https://spoonacular.com/recipeImages/${meal['id']}-312x231.${meal['imageType']}",
            'readyInMinutes': meal['readyInMinutes'],
            'sourceUrl': meal['sourceUrl'],
            'servings': meal['servings'],
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Meal Planner")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: calorieController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Target Calories",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: selectedDiet,
                decoration: const InputDecoration(
                  labelText: "Diet Preference",
                  border: OutlineInputBorder(),
                ),
                items: [
                  "vegetarian",
                  "vegan",
                  "gluten_free",
                  "paleo",
                  "ketogenic"
                ].map((diet) {
                  return DropdownMenuItem(value: diet, child: Text(diet));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedDiet = value!;
                  });
                },
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: fetchMealPlan,
                  child: const Text("Generate Meal Plan"),
                ),
              ),
              const SizedBox(height: 20),
              if (isLoading) const Center(child: CircularProgressIndicator()),
              if (meals.length >= 3) ...[
                MealSection(
                    title: "🍳 Breakfast",
                    meal: meals[0],
                    onTap: openRecipeDetails),
                MealSection(
                    title: "🍽 Lunch",
                    meal: meals[1],
                    onTap: openRecipeDetails),
                MealSection(
                    title: "🌙 Dinner",
                    meal: meals[2],
                    onTap: openRecipeDetails),
              ] else if (!isLoading && meals.isNotEmpty) ...[
                Text("Meal plan incomplete",
                    style: TextStyle(fontSize: 16, color: Colors.grey)),
              ],
              if (nutrients.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Nutritional Summary:",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text("Calories: ${nutrients['calories']} kcal"),
                          Text("Carbs: ${nutrients['carbohydrates']} g"),
                          Text("Fat: ${nutrients['fat']} g"),
                          Text("Protein: ${nutrients['protein']} g"),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class MealSection extends StatelessWidget {
  final String title;
  final Map<String, dynamic> meal;
  final Function(Map<String, dynamic>) onTap;

  const MealSection(
      {super.key,
      required this.title,
      required this.meal,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        MealCard(meal: meal, onTap: onTap),
        const SizedBox(height: 10),
      ],
    );
  }
}

class MealCard extends StatelessWidget {
  final Map<String, dynamic> meal;
  final Function(Map<String, dynamic>) onTap;

  const MealCard({super.key, required this.meal, required this.onTap});

  @override
  Widget build(BuildContext context) {
    String imageUrl = meal['image'] != null && meal['image'].isNotEmpty
        ? "https://spoonacular.com/recipeImages/${meal['id']}-312x231.${meal['imageType']}"
        : "https://via.placeholder.com/150";

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 4,
      child: ListTile(
        contentPadding: EdgeInsets.all(8),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            imageUrl,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.broken_image, size: 50, color: Colors.grey),
          ),
        ),
        title:
            Text(meal['title'], style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("Ready in ${meal['readyInMinutes']} mins"),
        onTap: () => onTap(meal),
      ),
    );
  }
}
