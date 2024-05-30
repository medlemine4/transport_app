// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, use_key_in_widget_constructors, library_private_types_in_public_api, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:myapp/data/mongo_database.dart';
import 'package:myapp/auth/login.dart';
import 'package:myapp/auth/verify_page.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> with TickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isLoading = false;

  Future<void> _signUp() async {
    final email = _emailController.text;
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _showDialog('Erreur', 'Veuillez remplir tous les champs.');
      return;
    }

    if (password != confirmPassword) {
      _showDialog('Erreur', 'Les mots de passe ne correspondent pas.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await MongoDatabase.sendVerificationCode(email);

      setState(() {
        _isLoading = false;
      });

      if (success) {
        _showDialog(
          'Succès',
          'Vérifiez votre email pour le code de vérification.',
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        VerifyPage(email: email, Password: password),
                  ),
                );
              },
              child: Text('OK'),
            ),
          ],
        );
      } else {
        _showDialog('Erreur', 'Cet email est déjà utilisé.');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showDialog('Erreur', 'Une erreur est survenue. Veuillez réessayer.');
    }
  }

  void _showDialog(String title, String content, {List<Widget>? actions}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: actions ??
            [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade800,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [
          // Animated Gradient Background
          AnimatedContainer(
            duration: Duration(seconds: 5),
            onEnd: () {
              setState(() {});
            },
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade800, Colors.purple.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Main Content
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: AnimatedSwitcher(
                duration: Duration(milliseconds: 500),
                child: Card(
                  key: ValueKey<int>(1),
                  elevation: 15,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  shadowColor: Colors.black.withOpacity(0.2),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Inscription',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 20),
                        _buildTextField(
                          controller: _emailController,
                          labelText: 'Email',
                          icon: Icons.email,
                        ),
                        SizedBox(height: 16),
                        _buildTextField(
                          controller: _passwordController,
                          labelText: 'Mot de passe',
                          icon: Icons.lock,
                          obscureText: true,
                        ),
                        SizedBox(height: 16),
                        _buildTextField(
                          controller: _confirmPasswordController,
                          labelText: 'Confirmer le mot de passe',
                          icon: Icons.lock,
                          obscureText: true,
                        ),
                        SizedBox(height: 20),
                        AnimatedSwitcher(
                          duration: Duration(milliseconds: 300),
                          child: _isLoading
                              ? CircularProgressIndicator(
                                  key: ValueKey<int>(1),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.blue),
                                )
                              : _buildSignUpButton(),
                        ),
                        SizedBox(height: 10),
                        _buildTextButton(
                          label: 'Se connecter',
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LoginPage()),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (_isLoading)
            Opacity(
              opacity: 0.8,
              child: ModalBarrier(dismissible: false, color: Colors.black),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    bool obscureText = false,
  }) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.blue),
          labelText: labelText,
          labelStyle: TextStyle(color: Colors.blue),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue, width: 2.0),
            borderRadius: BorderRadius.circular(15.0),
          ),
        ),
        obscureText: obscureText,
      ),
    );
  }

  Widget _buildSignUpButton() {
    return ElevatedButton(
      key: ValueKey<int>(2),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.blue,
        padding: EdgeInsets.symmetric(
          vertical: 16.0,
          horizontal: 32.0,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.0),
        ),
        textStyle: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
        elevation: 10,
        shadowColor: Colors.blueAccent,
      ).copyWith(
        elevation: MaterialStateProperty.resolveWith<double>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.pressed)) {
              return 15;
            }
            return 10; // Default elevation
          },
        ),
      ),
      onPressed: _signUp,
      child: Text("S'inscrire"),
    );
  }

  Widget _buildTextButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return TextButton(
      style: TextButton.styleFrom(
        foregroundColor: Colors.blue,
        textStyle: TextStyle(
          decoration: TextDecoration.underline,
          fontSize: 16,
        ),
      ),
      onPressed: onPressed,
      child: Text(label),
    );
  }
}
