import 'package:flutter/material.dart';
import 'package:rasoi_app/screens/menu_screen.dart';
import 'package:rasoi_app/screens/categories_screen.dart'; // Import CategoriesScreen
import 'package:rasoi_app/screens/my_orders_screen.dart';
import 'package:rasoi_app/screens/profile_screen.dart';
import 'package:rasoi_app/screens/help_screen.dart'; // Import HelpScreen
// import 'package:rasoi_app/screens/cart_screen.dart';
// import 'dart:ui'; // For BackdropFilter
import 'package:rasoi_app/widgets/custom_app_bar.dart'; // Import CustomAppBar

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  String? _searchQuery; // State variable to hold the search query

  final List<Widget> _screens = []; // Initialize as empty, will populate in initState

  @override
  void initState() {
    super.initState();
    _screens.addAll([
      MenuScreen(searchQuery: _searchQuery), // Pass searchQuery to MenuScreen
      const CategoriesScreen(),
      const MyOrdersScreen(),
      const ProfileScreen(),
      const HelpScreen(), // Add HelpScreen to screens
    ]);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      // Clear search query when navigating away from MenuScreen
      if (_selectedIndex != 0) {
        _searchQuery = null;
      }
    });
  }

  // Callback function to update searchQuery from CustomAppBar
  void _onSearchQueryChanged(String? query) {
    setState(() {
      _searchQuery = query;
      _screens[0] = MenuScreen(searchQuery: _searchQuery); // Update MenuScreen with new query
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(onSearch: _onSearchQueryChanged), // Pass onSearch callback
      body: _screens[_selectedIndex], // Directly show the selected screen
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.help),
            label: 'Help',
          ), // Add Help tab
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.deepOrange,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
