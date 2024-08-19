import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trabajo_final/providers/inventory_provider.dart';

class OrderHistoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final inventoryProvider = Provider.of<InventoryProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Historial de Pedidos'),
      ),
      body: inventoryProvider.orders.isEmpty
          ? Center(child: Text('No hay pedidos en el historial.'))
          : ListView.builder(
              itemCount: inventoryProvider.orders.length,
              itemBuilder: (context, index) {
                final order = inventoryProvider.orders[index];
                return ListTile(
                  title: Text('Pedido #${order['id']}'),
                  subtitle: Text('Producto ID: ${order['producto_id']} | Cantidad: ${order['cantidad']} | Total: \$${order['total']}'),
                  trailing: IconButton(
                    icon: Icon(Icons.cancel),
                    onPressed: () {
                      _showCancelOrderDialog(context, order['id']);
                    },
                  ),
                  onTap: () {
                    _showOrderDetails(context, order);
                  },
                );
              },
            ),
    );
  }

  void _showOrderDetails(BuildContext context, Map<String, dynamic> order) {
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

  void _showCancelOrderDialog(BuildContext context, int orderId) {
    final inventoryProvider = Provider.of<InventoryProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Cancelar Pedido'),
          content: Text('¿Estás seguro de que deseas cancelar este pedido?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('No'),
            ),
            TextButton(
              onPressed: () async {
                await inventoryProvider.cancelOrder(orderId);
                Navigator.of(context).pop();
              },
              child: Text('Sí'),
            ),
          ],
        );
      },
    );
  }
}
