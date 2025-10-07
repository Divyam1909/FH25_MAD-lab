

import 'package:flutter/material.dart';


class HomePage extends StatelessWidget {
  // Constructor is NOT const
  HomePage({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('E-commerce App'),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
        ],
      ),
      body: ListView(
        children: [
          _buildPromoCard(),
          _buildSectionHeader(context, 'Categories'),
          _buildCategoryList(),
          _buildSectionHeader(context, 'Featured Products'),
          _buildProductGrid(),
        ],
      ),
    );
  }


  Widget _buildPromoCard() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        height: 150,
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: Colors.indigo,
          borderRadius: BorderRadius.circular(16),
          image: const DecorationImage(
            image: NetworkImage('https://picsum.photos/id/1062/800/400'),
            fit: BoxFit.cover,
            opacity: 0.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'End of Season Sale',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            Text(
              'Up to 50% off on all items!',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }


  Widget _buildCategoryList() {
    final categories = {
      'Apparel': Icons.shopping_bag,
      'Electronics': Icons.phone_android,
      'Books': Icons.book,
      'Home': Icons.home_work,
      'More': Icons.category,
    };
    return SizedBox(
      height: 100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        children: categories.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.indigo.shade50,
                  child: Icon(entry.value, color: Colors.indigo),
                ),
                const SizedBox(height: 8),
                Text(entry.key),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }


  Widget _buildProductGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Image.network(
                  'https://picsum.photos/seed/${index + 1}/300/300',
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Product Name', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('\$${(index + 1) * 25}.00', style: TextStyle(color: Colors.grey.shade700)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
