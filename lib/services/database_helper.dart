import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._();
  static Database? _database;

  DatabaseHelper._();

  factory DatabaseHelper() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'trabajo_final.db');
    print('DB Path: $path');  // Depuración: ruta de la base de datos
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    print('Creating tables...');
    await db.execute('''
      CREATE TABLE usuarios(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE,
        password TEXT,
        role TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE productos(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT,
        cantidad INTEGER,
        precio REAL
      )
    ''');

    await db.execute('''
      CREATE TABLE facturas(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        usuario_id INTEGER,
        producto_id INTEGER,
        cantidad INTEGER,
        total REAL,
        FOREIGN KEY(usuario_id) REFERENCES usuarios(id),
        FOREIGN KEY(producto_id) REFERENCES productos(id)
      )
    ''');

    // Inserción de productos de prueba
    await db.insert('productos', {
      'nombre': 'Producto 1',
      'cantidad': 10,
      'precio': 50.0,
    });

    await db.insert('productos', {
      'nombre': 'Producto 2',
      'cantidad': 20,
      'precio': 150.0,
    });

    print('Products inserted');
  }

  Future<int> insertFactura(Map<String, dynamic> factura) async {
    final db = await database;
    return await db.insert('facturas', factura);
  }

  Future<List<Map<String, dynamic>>> getFacturas() async {
    final db = await database;
    return await db.query('facturas');
  }
}
