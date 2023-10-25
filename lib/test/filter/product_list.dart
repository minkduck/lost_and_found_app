import 'package:anim_search_bar/anim_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lost_and_find_app/test/filter/product.dart';

import '../../utils/colors.dart';
import '../../widgets/custom_search_bar.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final List<String> categories = ['Food', 'Fruits', 'Sports', 'Vehicles', 'H','A','B'];

  List<String> selectedCategories = [];
  String filterText = '';

  void onFilterTextChanged(String text) {
    setState(() {
      filterText = text;
    });
  }

  void onSubmitted() {
    // Handle search submission here
    print('Search submitted with text: $filterText');
  }

  @override
  Widget build(BuildContext context) {
    final filteredProducts = Product.productList
        .where((product) =>
    selectedCategories.isEmpty ||
        selectedCategories.contains(product.category))
        .where((product) =>
    filterText.isEmpty ||
        product.name.toLowerCase().contains(filterText.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Filter Record using Text'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Filter by name',
                hintText: 'Enter a name to filter...',
              ),
              onChanged: (text) {
                setState(() {
                  filterText = text;
                });
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("All", style: TextStyle(fontSize: 20),),
              Gap(20),
              CustomSearchBar(
                filterText: filterText, // Pass the filter text
                onFilterTextChanged: onFilterTextChanged, // Set the filter text handler
                onSubmitted: onSubmitted,


              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: categories
                    .map((category) => GestureDetector(
                  onTap: () {
                    setState(() {
                      if (selectedCategories.contains(category)) {
                        selectedCategories.remove(category);
                      } else {
                        selectedCategories.add(category);
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8, horizontal: 16),
                    child: Text(
                      category,
                      style: TextStyle(
                        color: selectedCategories.contains(category)
                            ? Color(0xFF4CCEAC) // Selected text color
                            : Color(0xFF535AC8), // Unselected text color
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ))
                    .toList(),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredProducts.length,
              itemBuilder: (context, index) {
                final product = filteredProducts[index];
                return Card(
                  elevation: 8.0,
                  margin: EdgeInsets.all(8),
                  child: Container(
                    decoration: BoxDecoration(color: Colors.indigoAccent),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      title: Text(
                        product.name,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        product.category,
                        style: TextStyle(
                          color: Colors.white,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
