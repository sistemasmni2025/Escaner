import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/search_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Ocultar la barra de estado y los botones del sistema (modo inmersivo de pantalla completa)
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Escaner Premium',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF1F5F9), // Neutral light slate background
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF4F46E5), // Indigo primary
          secondary: Color(0xFF3B82F6), // Blue secondary
          surface: Colors.white,
          background: Color(0xFFF1F5F9),
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: Color(0xFF1E293B), // Slate 800 dark text
          onBackground: Color(0xFF1E293B),
        ),
        textTheme: GoogleFonts.plusJakartaSansTextTheme(
          ThemeData.light().textTheme,
        ),
      ),
      home: const SearchScreen(),
    );
  }
}
