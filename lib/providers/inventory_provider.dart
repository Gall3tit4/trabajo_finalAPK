import 'package:flutter/material.dart';
import 'package:trabajo_final/services/database_helper.dart';

class InventoryProvider with ChangeNotifier {
  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _orders = [];

  List<Map<String, dynamic>> get products => _products;
  List<Map<String, dynamic>> get orders => _orders;

  Future<void> fetchProducts() async {
    final db = await DatabaseHelper().database;
    _products = await db.query('productos');
    notifyListeners();
  }

  Future<void> fetchOrders() async {
    final db = await DatabaseHelper().database;
    _orders = await db.query('facturas');
    notifyListeners();
  }

  Future<void> placeOrder(int userId, int productId, int quantity, double total) async {
    final db = await DatabaseHelper().database;
    await db.insert('facturas', {
      'usuario_id': userId,
      'producto_id': productId,
      'cantidad': quantity,
      'total': total,
    });
    await fetchOrders();  // Recargar la lista de pedidos después de hacer un pedido
  }

  Future<void> addProduct(String name, int quantity, double price) async {
    final db = await DatabaseHelper().database;
    await db.insert('productos', {
      'nombre': name,
      'cantidad': quantity,
      'precio': price,
    });
    await fetchProducts();  // Recargar la lista después de agregar un producto
  }

  Future<void> updateProduct(int id, int quantity) async {
    final db = await DatabaseHelper().database;
    await db.update(
      'productos',
      {'cantidad': quantity},
      where: 'id = ?',
      whereArgs: [id],
    );
    await fetchProducts();  // Recargar la lista después de modificar un producto
  }

  Future<void> deleteProduct(int id) async {
    final db = await DatabaseHelper().database;
    await db.delete(
      'productos',
      where: 'id = ?',
      whereArgs: [id],
    );
    await fetchProducts();  // Recargar la lista después de eliminar un producto
  }

  Future<void> cancelOrder(int orderId) async {
    final db = await DatabaseHelper().database;
    final order = await db.query('facturas', where: 'id = ?', whereArgs: [orderId]);

    if (order.isNotEmpty) {
      final productId = order.first['producto_id'] as int;
      final quantity = order.first['cantidad'] as int;

      // Actualizar la cantidad del producto en el inventario
      final product = await db.query('productos', where: 'id = ?', whereArgs: [productId]);
      if (product.isNotEmpty) {
        final currentQuantity = product.first['cantidad'] as int;  // Asegurar que sea un int
        final newQuantity = currentQuantity + quantity;  // Suma correcta
        await db.update(
          'productos',
          {'cantidad': newQuantity},
          where: 'id = ?',
          whereArgs: [productId],
        );
      }

      // Eliminar el pedido
      await db.delete('facturas', where: 'id = ?', whereArgs: [orderId]);
      await fetchOrders();  // Recargar la lista de pedidos después de cancelar un pedido
    }
  }
}
