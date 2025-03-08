import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'recipe_details_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final Box favoritesBox = Hive.box('favorites');

  void openRecipeDetails(Map<String, dynamic> recipe) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecipeDetailsScreen(recipe: recipe),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favorite Recipes')),
      body: ValueListenableBuilder(
        valueListenable: favoritesBox.listenable(),
        builder: (context, Box box, _) {
          if (box.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 80, color: Colors.grey),
                  const SizedBox(height: 10),
                  Text("No favorite recipes yet!",
                      style: TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ),
            );
          }

          final favoriteRecipes = box.values.toList();

          return ListView.builder(
            itemCount: favoriteRecipes.length,
            itemBuilder: (context, index) {
              final recipe = favoriteRecipes[index];
              final imageUrl =
                  recipe['image'].replaceAll("http://", "https://");

              return Dismissible(
                key: Key(recipe['id'].toString()),
                direction: DismissDirection.endToStart,
                background: Container(
                  padding: const EdgeInsets.only(right: 20),
                  alignment: Alignment.centerRight,
                  color: Colors.red,
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (direction) {
                  favoritesBox.delete(recipe['id'].toString());
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Recipe removed from favorites")),
                  );
                },
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CachedNetworkImage(
                        imageUrl: imageUrl,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            const CircularProgressIndicator(),
                        errorWidget: (context, url, error) => const Icon(
                          Icons.broken_image,
                          size: 50,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    title: Text(recipe['title']),
                    subtitle: Text('Ready in ${recipe['readyInMinutes']} mins'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        favoritesBox.delete(recipe['id'].toString());
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Recipe removed from favorites")),
                        );
                      },
                    ),
                    onTap: () => openRecipeDetails(recipe),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
