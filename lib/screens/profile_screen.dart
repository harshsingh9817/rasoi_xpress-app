import 'package:flutter/material.dart';
// import 'package:rasoi_app/screens/notifications_screen.dart';
import 'package:rasoi_app/screens/settings_screen.dart';
import 'package:rasoi_app/screens/auth_screen.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth
import 'package:rasoi_app/services/firestore_service.dart'; // Import FirestoreService
import 'package:rasoi_app/models/user.dart' as user_model; // Import User model with alias
import 'package:rasoi_app/models/address.dart'; // Import Address model
import 'package:rasoi_app/screens/add_edit_address_screen.dart'; // Import the new screen
// import 'package:rasoi_app/widgets/custom_app_bar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirestoreService _firestoreService = FirestoreService(); // Instance of FirestoreService
  User? _currentUser; // Firebase User
  final TextEditingController _nameController = TextEditingController(); // Controller for name editing

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _currentUser = FirebaseAuth.instance.currentUser; // Get current Firebase user
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose(); // Dispose the controller
    super.dispose();
  }

  // Method to handle name editing
  void _editUserName(user_model.User? userData) {
    _nameController.text = userData?.displayName ?? ''; // Pre-fill with current name

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Name'),
          content: TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Display Name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_nameController.text.isNotEmpty && _currentUser?.uid != null) {
                  await _firestoreService.updateUserData(
                    _currentUser!.uid,
                    {'displayName': _nameController.text.trim()},
                  );
                  if (!context.mounted) return;
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final String? uid = _currentUser?.uid; // Get UID of the current user

    return Scaffold(
      // appBar: const CustomAppBar(
      //   title: 'Profile',
      //   showNotification: false,
      // ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              color: Colors.white,
              child: StreamBuilder<user_model.User?>(
                stream: uid != null ? _firestoreService.getUser(uid) : Stream.value(null),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  final user_model.User? userData = snapshot.data;

                  return Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.deepOrange,
                        backgroundImage: userData?.photoURL != null
                            ? NetworkImage(userData!.photoURL!)
                            : null,
                        child: userData?.photoURL == null && userData?.displayName != null && userData!.displayName.isNotEmpty
                            ? Text(
                                userData.displayName[0],
                                style: const TextStyle(fontSize: 30, color: Colors.white),
                              )
                            : null,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        userData?.displayName ?? 'Guest',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        onPressed: () => _editUserName(userData),
                        icon: const Icon(Icons.edit, color: Colors.grey),
                      ),
                      Text(
                        userData?.email ?? 'No Email',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 10),
                      if (uid == null) // Show login/signup button if not logged in
                        OutlinedButton.icon(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const AuthScreen()));
                          },
                          icon: const Icon(Icons.login, color: Colors.deepOrange),
                          label: const Text('Login/Signup', style: TextStyle(color: Colors.deepOrange)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.deepOrange),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      if (uid != null) // Show logout button if logged in
                        OutlinedButton.icon(
                          onPressed: () async {
                            await FirebaseAuth.instance.signOut();
                            if (!context.mounted) return;
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (context) => const AuthScreen()),
                            );
                          },
                          icon: const Icon(Icons.logout, color: Colors.deepOrange),
                          label: const Text('Logout', style: TextStyle(color: Colors.deepOrange)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.deepOrange),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
            Container(
              color: Colors.white,
              child: TabBar(
                controller: _tabController,
                labelColor: Colors.deepOrange,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.deepOrange,
                tabs: const [
                  Tab(icon: Icon(Icons.location_on), text: 'My Addresses'),
                  Tab(icon: Icon(Icons.settings), text: 'Settings'),
                ],
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height - AppBar().preferredSize.height - kBottomNavigationBarHeight - 200, // Adjust height as needed
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildMyAddressesTab(),
                  const SettingsScreen(), // Using the new SettingsScreen here
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyAddressesTab() {
    final String? uid = _currentUser?.uid; // Get UID of the current user

    if (uid == null) {
      return const Center(child: Text('Please log in to view your addresses.'));
    }

    return StreamBuilder<List<Address>>(
      stream: _firestoreService.getAddresses(uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No addresses found. Add a new address.'));
        }

        final List<Address> addresses = snapshot.data!;

        return Column(
          children: [
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: addresses.length,
              itemBuilder: (context, index) {
                final address = addresses[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          address.fullName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(address.phone),
                        if (address.alternatePhone != null)
                          Text('Alt: ${address.alternatePhone}'),
                        Text('${address.street}, ${address.city} - ${address.pinCode}'),
                        if (address.village != null)
                          Text(address.village!),
                        Text('Type: ${address.type}'),
                        if (address.isDefault)
                          const Text(
                            'Default Address',
                            style: TextStyle(color: Colors.green),
                          ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddEditAddressScreen(
                                      address: address, // Pass existing address for editing
                                    ),
                                  ),
                                );
                              },
                              child: const Text('Edit'),
                            ),
                            TextButton(
                              onPressed: () async {
                                if (_currentUser?.uid != null) {
                                  await _firestoreService.deleteAddress(
                                    _currentUser!.uid,
                                    address.id,
                                  );
                                }
                              },
                              child: const Text('Delete', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddEditAddressScreen(), // No address means adding new
                  ),
                );
              },
              icon: const Icon(Icons.add_location),
              label: const Text('Add New Address'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
