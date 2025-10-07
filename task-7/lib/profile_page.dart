


import 'package:flutter/material.dart';


class ProfilePage extends StatelessWidget {
  // Constructor is NOT const
  ProfilePage({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
      ),
      body: ListView(
        children: [
          _buildProfileHeader(),
          const SizedBox(height: 20),
          _buildOptionList(),
          const SizedBox(height: 20),
          _buildLogoutButton(context),
        ],
      ),
    );
  }


  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      color: Colors.white,
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: AssetImage('assets/images/profile.png'), // Ensure this asset exists
          ),
          SizedBox(height: 16),
          Text(
            'Divyam Navin',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          Text(
            'divyam.navin@gmail.com',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }


  Widget _buildOptionList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            _buildOptionTile(Icons.shopping_bag_outlined, 'My Orders'),
            const Divider(height: 0),
            _buildOptionTile(Icons.location_on_outlined, 'Shipping Addresses'),
            const Divider(height: 0),
            _buildOptionTile(Icons.payment_outlined, 'Payment Methods'),
            const Divider(height: 0),
            _buildOptionTile(Icons.settings_outlined, 'Settings'),
          ],
        ),
      ),
    );
  }


  Widget _buildOptionTile(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey.shade700),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {},
    );
  }


  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: OutlinedButton.icon(
        icon: const Icon(Icons.logout),
        label: const Text('Log Out'),
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red,
          side: const BorderSide(color: Colors.red),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}
