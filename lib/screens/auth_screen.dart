import 'package:flutter/material.dart';
import 'package:trabajo_final/services/database_helper.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String _role = 'cliente';  // Valor por defecto para el Dropdown

  Future<void> _register() async {
    final db = await DatabaseHelper().database;
    await db.insert('usuarios', {
      'username': _usernameController.text,
      'password': _passwordController.text,
      'role': _role,
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Registro exitoso')),
    );
  }

  Future<void> _login() async {
    final db = await DatabaseHelper().database;
    final user = await db.query(
      'usuarios',
      where: 'username = ? AND password = ?',
      whereArgs: [_usernameController.text, _passwordController.text],
    );

    if (user.isNotEmpty) {
      if (user.first['role'] == 'cliente') {
        Navigator.pushReplacementNamed(context, '/client');
      } else if (user.first['role'] == 'administrador') {
        Navigator.pushReplacementNamed(context, '/admin');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Credenciales incorrectas')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Autenticación')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Usuario'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
            ),
            DropdownButton<String>(
              value: _role,
              onChanged: (String? newValue) {
                setState(() {
                  _role = newValue!;
                });
              },
              items: <String>['cliente', 'administrador']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: _register,
                  child: Text('Registrar'),
                ),
                ElevatedButton(
                  onPressed: _login,
                  child: Text('Iniciar Sesión'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
