import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trabajo_final/providers/inventory_provider.dart';
import 'package:trabajo_final/screens/client_screen.dart';
import 'package:trabajo_final/screens/admin_screen.dart';
import 'package:trabajo_final/screens/login_screen.dart';
import 'package:trabajo_final/screens/order_history_screen.dart';
import 'package:trabajo_final/services/auth_service.dart'; // Importar el servicio de autenticación

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => InventoryProvider()),
        ChangeNotifierProvider(create: (_) => AuthService()), // Proveedor de AuthService
      ],
      child: MaterialApp(
        title: 'Trabajo Final',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.orange),
          fontFamily: 'Roboto',
          textTheme: TextTheme(
            headlineLarge: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            bodyLarge: TextStyle(fontSize: 18.0),
          ),
          buttonTheme: ButtonThemeData(
            buttonColor: Colors.blue,
            textTheme: ButtonTextTheme.primary,
          ),
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: Consumer<AuthService>(
          builder: (context, authService, _) {
            if (authService.userRole == 'admin') {
              return AdminScreen();
            } else if (authService.userRole == 'client') {
              return ClientScreen();
            }
            return LoginScreen(); // Por defecto, mostrar la pantalla de login
          },
        ),
        routes: {
          '/client': (context) => ClientScreen(),
          '/admin': (context) => AdminScreen(),
          '/orderHistory': (context) => OrderHistoryScreen(),
        },
      ),
    );
  }
}
