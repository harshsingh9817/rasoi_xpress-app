import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart'; // Add this import
import 'package:rasoi_app/widgets/reset_password_modal.dart';
import 'package:rasoi_app/screens/main_screen.dart'; // Added import for MainScreen
import 'package:rasoi_app/services/firestore_service.dart'; // Import FirestoreService
// import 'package:google_sign_in_web/google_sign_in_web.dart' as google_sign_in_web; // Removed
// import 'package:google_sign_in_web/web_sign_in_button.dart'; // Removed

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true; // To toggle between Login and Sign Up
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _signUpEmailController = TextEditingController();
  final TextEditingController _mobileNumberController = TextEditingController();
  final TextEditingController _signUpPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController(); // Added


  @override
  void initState() {
    super.initState();
    _initializeGoogleSignIn();
  }

  Future<void> _initializeGoogleSignIn() async {
    await GoogleSignIn.instance.initialize();
  }

  @override
  void dispose() {
    _signUpEmailController.dispose();
    _mobileNumberController.dispose();
    _signUpPasswordController.dispose();
    _confirmPasswordController.dispose();
    _fullNameController.dispose(); // Added
    super.dispose();
  }

  Future<void> _signInWithGoogle() async {
    try {
      debugPrint("Attempting Google Sign-In...");
      final GoogleSignInAccount googleUser = await GoogleSignIn.instance.authenticate();

      debugPrint("Google User: ${googleUser.displayName}, ${googleUser.email}");

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      debugPrint("Google Auth ID Token: ${googleAuth.idToken}");

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        if (!mounted) return;

        // Check if user exists in Firestore, if not create a new user document
        final firestoreService = FirestoreService();
        final existingUser = await firestoreService.getUser(user.uid).first;

        if (!mounted) return; // Moved check earlier

        if (existingUser == null) {
          await firestoreService.addUser(user.uid, {
            'displayName': user.displayName,
            'email': user.email,
            'photoURL': user.photoURL,
            'mobileNumber': null, // Mobile number not provided by Google Sign-In
            'hasCompletedFirstOrder': false,
          });
        } else {
          // Optionally update existing user data from Google profile
          await firestoreService.updateUserData(user.uid, {
            'displayName': user.displayName,
            'photoURL': user.photoURL,
          });
        }
      }

      debugPrint("User signed in with Google successfully!");
      // Navigate to the home screen or another authenticated screen
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    } on FirebaseAuthException catch (e) {
      debugPrint("Firebase Auth Exception during Google Sign-In: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to sign in with Google: ${e.message}')),
      );
    } catch (e) {
      debugPrint("Error during Google Sign-In: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An unexpected error occurred: $e')),
      );
    }
  }

  Future<void> _signInWithEmailAndPassword() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    } on FirebaseAuthException catch (e) {
      debugPrint("Firebase Auth Exception during Email/Password Sign-In: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to sign in: ${e.message}')),
      );
    } catch (e) {
      debugPrint("Error during Email/Password Sign-In: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An unexpected error occurred: $e')),
      );
    }
  }

  Future<void> _signUpWithEmailAndPassword() async {
    if (_signUpPasswordController.text != _confirmPasswordController.text) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match!')),
      );
      return;
    }
    try {
      final UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _signUpEmailController.text,
        password: _signUpPasswordController.text,
      );
      final User? user = userCredential.user;

      if (user != null) {
        // Add user data to Firestore
        final firestoreService = FirestoreService();
        await firestoreService.addUser(user.uid, {
          'displayName': _fullNameController.text,
          'email': user.email,
          'mobileNumber': _mobileNumberController.text,
          'photoURL': null,
          'hasCompletedFirstOrder': false,
        });

        debugPrint("User signed up with email and password successfully!");
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      debugPrint("Firebase Auth Exception during Email/Password Sign-Up: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to sign up: ${e.message}')),
      );
    } catch (e) {
      debugPrint("Error during Email/Password Sign-Up: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An unexpected error occurred: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, // Remove back button
        // Removed title/logo as requested
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset('assets/key_icon.png', height: 100), // Corrected asset path
              const SizedBox(height: 20),
              Text(
                _isLogin ? 'Welcome Back!' : 'Create Your Account',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _isLogin
                    ? 'Log in to access your Rasoi Xpress account.'
                    : 'Join Rasoi Xpress to start ordering.',
                style: TextStyle(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              if (_isLogin) _buildLoginForm(context) else _buildSignUpForm(context),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isLogin = !_isLogin;
                  });
                },
                child: Text(
                  _isLogin ? 'Don\'t have an account? Sign Up' : 'Already have an account? Log In',
                  style: const TextStyle(
                    color: Colors.deepOrange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm(BuildContext context) {
    return Column(
      children: [
        const Text('Email or Mobile Number', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        TextField(
          controller: _emailController,
          decoration: InputDecoration(
            hintText: 'harshsunil9817@gmail.com',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.grey[200],
          ),
        ),
        const SizedBox(height: 20),
        const Text('Password', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: InputDecoration(
            hintText: '********',
            suffixIcon: IconButton(
              icon: const Icon(Icons.visibility_off),
              onPressed: () {
                // Toggle password visibility
              },
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.grey[200],
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              showResetPasswordModal(context: context);
            },
            child: const Text('Forgot Password?', style: TextStyle(color: Colors.deepOrange)),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _signInWithEmailAndPassword,
            icon: const Icon(Icons.login),
            label: const Text('Log In'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepOrange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text('OR CONTINUE WITH', style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _signInWithGoogle,
            icon: Image.asset('assets/google_logo.png', height: 28), // Corrected asset path
            label: const Text('Sign in with Google', style: TextStyle(fontSize: 18)), // Increased font size
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.black,
              side: BorderSide(color: Colors.grey.shade300),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(vertical: 18), // Increased vertical padding
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpForm(BuildContext context) {
    return Column(
      children: [
        const Text('Full Name', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        TextField(
          controller: _fullNameController,
          decoration: InputDecoration(
            hintText: 'John Doe',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.grey[200],
          ),
        ),
        const SizedBox(height: 20),
        const Text('Email Address', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        TextField(
          controller: _signUpEmailController,
          decoration: InputDecoration(
            hintText: 'harshsunil9817@gmail.com',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.grey[200],
          ),
        ),
        const SizedBox(height: 20),
        const Text('Mobile Number', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        TextField(
          controller: _mobileNumberController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            hintText: '9876543210',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.grey[200],
          ),
        ),
        const SizedBox(height: 20),
        const Text('Password', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        TextField(
          controller: _signUpPasswordController,
          obscureText: true,
          decoration: InputDecoration(
            hintText: '********',
            suffixIcon: IconButton(
              icon: const Icon(Icons.visibility_off),
              onPressed: () {
                // Toggle password visibility
              },
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.grey[200],
          ),
        ),
        const SizedBox(height: 20),
        const Text('Confirm Password', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        TextField(
          controller: _confirmPasswordController,
          obscureText: true,
          decoration: InputDecoration(
            hintText: '********',
            suffixIcon: IconButton(
              icon: const Icon(Icons.visibility_off),
              onPressed: () {
                // Toggle password visibility
              },
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.grey[200],
          ),
        ),
        const SizedBox(height: 30),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _signUpWithEmailAndPassword,
            icon: const Icon(Icons.person_add),
            label: const Text('Sign Up', style: TextStyle(fontSize: 18)), // Increased font size
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepOrange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(vertical: 18), // Increased vertical padding
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text('OR CONTINUE WITH', style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _signInWithGoogle,
            icon: Image.asset('assets/google_logo.png', height: 28), // Corrected asset path
            label: const Text('Sign in with Google', style: TextStyle(fontSize: 18)), // Increased font size
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.black,
              side: BorderSide(color: Colors.grey.shade300),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(vertical: 18), // Increased vertical padding
            ),
          ),
        ),
      ],
    );
  }
}
