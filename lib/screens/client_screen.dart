import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trabajo_final/providers/inventory_provider.dart';
import 'package:trabajo_final/services/auth_service.dart'; // Importa el servicio de autenticación
import 'package:trabajo_final/screens/login_screen.dart'; // Importa la pantalla de login
import 'package:trabajo_final/screens/order_history_screen.dart';

class ClientScreen extends StatefulWidget {
  @override
  _ClientScreenState createState() => _ClientScreenState();
}

class _ClientScreenState extends State<ClientScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar productos y pedidos en initState
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final inventoryProvider = Provider.of<InventoryProvider>(context, listen: false);
      inventoryProvider.fetchProducts();
      inventoryProvider.fetchOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final inventoryProvider = Provider.of<InventoryProvider>(context);
    final authService = Provider.of<AuthService>(context);

    // Verifica si el usuario tiene permiso de acceso
    if (authService.userRole != 'client') {
      return LoginScreen(); // Redirige si el usuario no es cliente
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Productos Disponibles'),
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => OrderHistoryScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              authService.logout(); // Cierra sesión
              Navigator.pushReplacementNamed(context, '/'); // Redirige al login
            },
          ),
        ],
      ),
      body: inventoryProvider.products.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: inventoryProvider.products.length,
              itemBuilder: (context, index) {
                final product = inventoryProvider.products[index];
                return ListTile(
                  title: Text(product['nombre']),
                  subtitle: Text('Cantidad: ${product['cantidad']}'),
                  trailing: Text('\$${product['precio']}'),
                  onTap: () {
                    _showOrderDialog(context, product);
                  },
                );
              },
            ),
    );
  }

  void _showOrderDialog(BuildContext context, Map<String, dynamic> product) {
    final inventoryProvider = Provider.of<InventoryProvider>(context, listen: false);
    final _quantityController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Realizar Pedido'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Producto: ${product['nombre']}'),
              TextField(
                controller: _quantityController,
                decoration: InputDecoration(labelText: 'Cantidad'),
                keyboardType: TextInputType.number,
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
              onPressed: () async {
                final quantity = int.tryParse(_quantityController.text) ?? 0;
                if (quantity > 0 && quantity <= product['cantidad']) {
                  final total = (quantity * product['precio']).toDouble();
                  final userId = 1; // Id de usuario fijo para simplicidad
                  await inventoryProvider.placeOrder(userId, product['id'], quantity, total);
                  await inventoryProvider.updateProduct(product['id'], product['cantidad'] - quantity);
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Cantidad no válida')));
                }
              },
              child: Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }
}
