import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trabajo_final/providers/inventory_provider.dart';
import 'package:trabajo_final/services/auth_service.dart';
import 'package:trabajo_final/screens/login_screen.dart';
import 'package:trabajo_final/screens/manage_users_screen.dart'; // Importa la pantalla de gestión de usuarios

class AdminScreen extends StatefulWidget {
  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Cargar los productos y los pedidos
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final inventoryProvider = Provider.of<InventoryProvider>(context, listen: false);
      inventoryProvider.fetchProducts();
      inventoryProvider.fetchOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    // Verifica si el usuario tiene permiso de acceso
    if (authService.userRole != 'admin') {
      return LoginScreen(); // Redirige si el usuario no es admin
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Gestionar Inventario y Pedidos'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Inventario'),
            Tab(text: 'Pedidos'),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.people),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ManageUsersScreen()), // Navegar a la pantalla de gestión de usuarios
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
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildInventoryTab(context),
          _buildOrdersTab(context),
        ],
      ),
    );
  }

  Widget _buildInventoryTab(BuildContext context) {
    final inventoryProvider = Provider.of<InventoryProvider>(context);

    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            _showAddProductDialog(context);
          },
          child: Text('Agregar Producto'),
        ),
        Expanded(
          child: inventoryProvider.products.isEmpty
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
                        _showEditProductDialog(context, product);
                      },
                      onLongPress: () {
                        _showDeleteProductDialog(context, product['id']);
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildOrdersTab(BuildContext context) {
    final inventoryProvider = Provider.of<InventoryProvider>(context);

    return inventoryProvider.orders.isEmpty
        ? Center(child: Text('No hay pedidos.'))
        : ListView.builder(
            itemCount: inventoryProvider.orders.length,
            itemBuilder: (context, index) {
              final order = inventoryProvider.orders[index];
              return ListTile(
                title: Text('Pedido #${order['id']}'),
                subtitle: Text('Producto ID: ${order['producto_id']} | Cantidad: ${order['cantidad']} | Total: \$${order['total']}'),
                onTap: () {
                  _showOrderDetailsDialog(context, order);
                },
              );
            },
          );
  }

  void _showAddProductDialog(BuildContext context) {
    final _nameController = TextEditingController();
    final _quantityController = TextEditingController();
    final _priceController = TextEditingController();
    final inventoryProvider = Provider.of<InventoryProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Agregar Producto'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Nombre'),
              ),
              TextField(
                controller: _quantityController,
                decoration: InputDecoration(labelText: 'Cantidad'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _priceController,
                decoration: InputDecoration(labelText: 'Precio'),
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
                final name = _nameController.text;
                final quantity = int.tryParse(_quantityController.text) ?? 0;
                final price = double.tryParse(_priceController.text) ?? 0.0;

                if (name.isNotEmpty && quantity > 0 && price > 0) {
                  await inventoryProvider.addProduct(name, quantity, price);
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Datos no válidos')),
                  );
                }
              },
              child: Text('Agregar'),
            ),
          ],
        );
      },
    );
  }

  void _showEditProductDialog(BuildContext context, Map<String, dynamic> product) {
    final _quantityController = TextEditingController(text: product['cantidad'].toString());
    final inventoryProvider = Provider.of<InventoryProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Editar Producto'),
          content: TextField(
            controller: _quantityController,
            decoration: InputDecoration(labelText: 'Cantidad'),
            keyboardType: TextInputType.number,
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
                if (quantity >= 0) {
                  await inventoryProvider.updateProduct(product['id'], quantity);
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Cantidad no válida')),
                  );
                }
              },
              child: Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteProductDialog(BuildContext context, int productId) {
    final inventoryProvider = Provider.of<InventoryProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Eliminar Producto'),
          content: Text('¿Estás seguro de que deseas eliminar este producto?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                await inventoryProvider.deleteProduct(productId);
                Navigator.of(context).pop();
              },
              child: Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  void _showOrderDetailsDialog(BuildContext context, Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Detalles del Pedido'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ID del Pedido: ${order['id']}'),
              Text('ID del Producto: ${order['producto_id']}'),
              Text('Cantidad: ${order['cantidad']}'),
              Text('Total: \$${order['total']}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }
}
