


import 'package:flutter/material.dart';


class CartPage extends StatelessWidget {
  // Constructor is NOT const
  CartPage({super.key});


  final bool _isCartEmpty = false;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
      ),
      body: _isCartEmpty ? _buildEmptyCart() : _buildCartList(),
      bottomNavigationBar: _isCartEmpty ? null : _buildCheckoutBar(context),
    );
  }


  Widget _buildEmptyCart() {
    // KEY FIX: Removed 'const' from the Center widget.
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.remove_shopping_cart, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text('Your cart is empty!', style: TextStyle(fontSize: 20)),
        ],
      ),
    );
  }


  Widget _buildCartList() {
    return ListView.builder(
      itemCount: 3,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network('https://picsum.photos/seed/${index + 10}/100/100'),
            ),
            title: Text('Product Item ${index + 1}'),
            subtitle: const Text('\$49.99'),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () {},
            ),
          ),
        );
      },
    );
  }


  Widget _buildCheckoutBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Total', style: TextStyle(color: Colors.grey)),
              Text('\$149.97', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Checkout'),
          ),
        ],
      ),
    );
  }
}
