import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../models/user.dart';

class ManageUsersScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestionar Usuarios'),
      ),
      body: ListView.builder(
        itemCount: authService.users.length,
        itemBuilder: (context, index) {
          final user = authService.users[index];
          return ListTile(
            title: Text(user.username),
            subtitle: Text('Rol: ${user.role}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    _showEditUserDialog(context, user);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    _showDeleteUserDialog(context, user.id);
                  },
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddUserDialog(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _showAddUserDialog(BuildContext context) {
    final _usernameController = TextEditingController();
    final _passwordController = TextEditingController();
    String _role = 'client';
    final authService = Provider.of<AuthService>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Agregar Usuario'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: 'Nombre de usuario'),
              ),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Contraseña'),
                obscureText: true,
              ),
              DropdownButton<String>(
                value: _role,
                items: [
                  DropdownMenuItem(value: 'admin', child: Text('Admin')),
                  DropdownMenuItem(value: 'client', child: Text('Client')),
                ],
                onChanged: (value) {
                  _role = value!;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                authService.addUser(
                  _usernameController.text,
                  _passwordController.text,
                  _role,
                );
                Navigator.of(context).pop();
              },
              child: Text('Agregar'),
            ),
          ],
        );
      },
    );
  }

  void _showEditUserDialog(BuildContext context, User user) {
    final _usernameController = TextEditingController(text: user.username);
    final _passwordController = TextEditingController(text: user.password);
    String _role = user.role;
    final authService = Provider.of<AuthService>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Editar Usuario'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: 'Nombre de usuario'),
              ),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Contraseña'),
                obscureText: true,
              ),
              DropdownButton<String>(
                value: _role,
                items: [
                  DropdownMenuItem(value: 'admin', child: Text('Admin')),
                  DropdownMenuItem(value: 'client', child: Text('Client')),
                ],
                onChanged: (value) {
                  _role = value!;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                authService.editUser(
                  user.id,
                  _usernameController.text,
                  _passwordController.text,
                  _role,
                );
                Navigator.of(context).pop();
              },
              child: Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteUserDialog(BuildContext context, int userId) {
    final authService = Provider.of<AuthService>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Eliminar Usuario'),
          content: Text('¿Estás seguro de que deseas eliminar este usuario?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                authService.deleteUser(userId);
                Navigator.of(context).pop();
              },
              child: Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }
}
