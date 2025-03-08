import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:recipe_finder/screens/recipe_details_screen.dart';
import 'package:recipe_finder/screens/shopping_list_screen.dart';
import '../services/api_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'favoritescreen.dart';
import 'meal_plan_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService apiService = ApiService();
  List<dynamic> recipes = [];
  List<dynamic> filteredRecipes = [];
  bool isLoading = true;
  bool isSearching = false;
  TextEditingController searchController = TextEditingController();
  final Box favoritesBox = Hive.box('favorites');

  @override
  void initState() {
    super.initState();
    fetchRecipes();
  }

  void fetchRecipes() async {
    try {
      final fetchedRecipes = await apiService.fetchRecipes();
      setState(() {
        recipes = fetchedRecipes;
        filteredRecipes = fetchedRecipes;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching recipes: $e");
      setState(() => isLoading = false);
    }
  }

  void filterRecipes(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredRecipes = recipes;
      } else {
        filteredRecipes = recipes
            .where((recipe) => recipe['title']
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void toggleFavorite(dynamic recipe) {
    String recipeId = recipe['id'].toString();
    if (favoritesBox.containsKey(recipeId)) {
      favoritesBox.delete(recipeId);
    } else {
      favoritesBox.put(recipeId, recipe);
    }
    setState(() {});
  }

  bool isFavorite(dynamic recipe) {
    return favoritesBox.containsKey(recipe['id'].toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: isSearching
            ? TextField(
                controller: searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: "Search Recipes...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: filterRecipes,
              )
            : const Text('Recipe Finder',
                style: TextStyle(fontWeight: FontWeight.bold)),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(isSearching ? Icons.cancel : Icons.search),
            onPressed: () {
              setState(() {
                isSearching = !isSearching;
                if (!isSearching) {
                  searchController.clear();
                  filteredRecipes = recipes;
                }
              });
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.deepOrangeAccent),
              child: Row(
                children: [
                  Icon(Icons.restaurant, size: 40, color: Colors.white),
                  SizedBox(width: 10),
                  Text("Recipe Finder",
                      style: TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.restaurant_menu, color: Colors.deepOrange),
              title: Text("Meal Planner"),
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const MealPlanScreen())),
            ),
            ListTile(
              leading: Icon(Icons.shopping_cart, color: Colors.deepOrange),
              title: Text("Shopping List"),
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ShoppingListScreen())),
            ),
            ListTile(
              leading: Icon(Icons.favorite, color: Colors.deepOrange),
              title: Text("Favorites"),
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const FavoritesScreen())),
            ),
            ListTile(
              leading: Icon(Icons.settings, color: Colors.deepOrange),
              title: Text("Mode Toggle"),
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SettingsScreen())),
            ),
          ],
        ),
      ),
      body: ValueListenableBuilder(
        valueListenable: favoritesBox.listenable(),
        builder: (context, Box box, _) {
          return isLoading
              ? Center(child: CircularProgressIndicator())
              : filteredRecipes.isEmpty
                  ? Center(
                      child: Text("No recipes found",
                          style: TextStyle(fontSize: 18)))
                  : ListView.builder(
                      padding: EdgeInsets.all(10),
                      itemCount: filteredRecipes.length,
                      itemBuilder: (context, index) {
                        final recipe = filteredRecipes[index];
                        final imageUrl =
                            recipe['image'].replaceAll("http://", "https://");

                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 8),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            contentPadding: EdgeInsets.all(10),
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: CachedNetworkImage(
                                imageUrl: imageUrl,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                placeholder: (context, url) =>
                                    CircularProgressIndicator(),
                                errorWidget: (context, url, error) => Icon(
                                    Icons.broken_image,
                                    size: 50,
                                    color: Colors.grey),
                              ),
                            ),
                            title: Text(recipe['title'],
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(
                                'Ready in ${recipe['readyInMinutes']} mins'),
                            trailing: IconButton(
                              icon: Icon(
                                isFavorite(recipe)
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: isFavorite(recipe) ? Colors.red : null,
                              ),
                              onPressed: () => toggleFavorite(recipe),
                            ),
                            onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            RecipeDetailsScreen(
                                                recipe: recipe)))
                                .then((_) => setState(() {})),
                          ),
                        );
                      },
                    );
        },
      ),
    );
  }
}
