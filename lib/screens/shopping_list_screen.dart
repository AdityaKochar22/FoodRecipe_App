import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  _ShoppingListScreenState createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  final Box shoppingBox = Hive.box('shopping_list'); // Access Hive box

  void addItem(String fullItemText) {
    shoppingBox.put(fullItemText, fullItemText); // Store item as key-value
    setState(() {}); // Refresh UI
  }

  void removeItem(String fullItemText) {
    shoppingBox.delete(fullItemText);
    setState(() {}); // Refresh UI
  }

  void clearAllItems() {
    shoppingBox.clear();
    setState(() {});
  }

  void showAddItemDialog() {
    final TextEditingController itemController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Item"),
          content: TextField(
            controller: itemController,
            decoration: const InputDecoration(
              hintText: "Enter item (e.g., Sugar - 2 tbsp)",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (itemController.text.isNotEmpty) {
                  addItem(itemController.text);
                }
                Navigator.pop(context);
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Shopping List"),
        actions: [
          if (shoppingBox.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep, color: Colors.redAccent),
              onPressed: clearAllItems,
              tooltip: "Clear All",
            ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: shoppingBox.listenable(),
        builder: (context, Box box, _) {
          if (box.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined,
                      size: 80, color: Colors.grey),
                  SizedBox(height: 10),
                  Text("Your shopping list is empty",
                      style: TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, index) {
              final key = box.keys.toList()[index]; // Get item text

              return Dismissible(
                key: Key(key),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  color: Colors.redAccent,
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) => removeItem(key),
                child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  elevation: 2,
                  margin:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  child: ListTile(
                    leading: const Icon(Icons.shopping_bag,
                        color: Colors.orangeAccent),
                    title: Text(key, style: const TextStyle(fontSize: 16)),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => removeItem(key),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddItemDialog,
        tooltip: "Add Item",
        backgroundColor: Colors.orangeAccent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
