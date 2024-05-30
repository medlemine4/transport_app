import 'package:flutter/material.dart';
import 'package:myapp/data/mongo_database.dart';

class VerifyPage extends StatefulWidget {
  final String email;
  final String Password;

  VerifyPage({required this.email, required this.Password});

  @override
  _VerifyPageState createState() => _VerifyPageState();
}

class _VerifyPageState extends State<VerifyPage> {
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _verifyCode() async {
    final code = _codeController.text;

    if (code.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Erreur'),
          content: Text('Veuillez remplir le champs.'),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await MongoDatabase.verifyCode(
          widget.email, code, widget.Password);

      setState(() {
        _isLoading = false;
      });

      if (success) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Succès'),
            content: Text('Compte créé avec succès.'),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.popUntil(context, ModalRoute.withName('/')),
                child: Text('OK'),
              ),
            ],
          ),
        );
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Erreur'),
            content: Text('Code de vérification incorrect ou une erreur s\'est produite.'),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Erreur'),
          content: Text('Une erreur est survenue. Veuillez réessayer.'),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vérifier le code'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _codeController,
              decoration: InputDecoration(labelText: 'Code de vérification'),
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _verifyCode,
                    child: Text('Vérifier le code'),
                  ),
          ],
        ),
      ),
    );
  }
}