import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travellapp/pages/home.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isLoading = false;
  bool _agreeToTerms = false;

  void _signUp() async {
    if (_formKey.currentState!.validate() && _agreeToTerms) {
      setState(() => _isLoading = true);
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        final userData = {
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'createdAt': Timestamp.now(),
          'profileImageUrl': '',
        };

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set(userData);

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Account Created Successfully!'),
          backgroundColor: Colors.green,
        ));

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => Home(userData: userData)),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Signup failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ));
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFa8edea), Color(0xFFfed6e3)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Text('Create Account',
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _nameController,
                    decoration: _inputDecoration('Full Name', Icons.person),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Enter name' : null,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    decoration: _inputDecoration('Email', Icons.email),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Enter email' : null,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: _inputDecoration('Password', Icons.lock),
                    validator: (value) => value != null && value.length < 6
                        ? 'Minimum 6 characters'
                        : null,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmController,
                    obscureText: true,
                    decoration:
                        _inputDecoration('Confirm Password', Icons.lock_outline),
                    validator: (value) => value != _passwordController.text
                        ? 'Passwords do not match'
                        : null,
                  ),
                  Row(
                    children: [
                      Checkbox(
                        value: _agreeToTerms,
                        onChanged: (val) =>
                            setState(() => _agreeToTerms = val ?? false),
                      ),
                      Text("Agree to terms", style: TextStyle(color: Colors.white)),
                    ],
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _signUp,
                    child: _isLoading
                        ? CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                        : Text('Sign Up'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 48),
                      backgroundColor: Color(0xFFa8edea),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
