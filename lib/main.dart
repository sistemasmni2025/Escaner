import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/search_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Hide status bar and system navigation buttons for full screen immersion
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
        scaffoldBackgroundColor: const Color(0xFFF2F2F7), // Apple System Gray 6 (Neutral background)
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF007AFF), // Apple Standard Blue
          secondary: Color(0xFF5856D6), // Apple Purple
          surface: Colors.white,
          background: Color(0xFFF2F2F7),
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: Colors.black, // Pure black titles
          onBackground: Colors.black,
        ),
        textTheme: GoogleFonts.interTextTheme(
          ThemeData.light().textTheme,
        ),
      ),
      home: const SearchScreen(),
    );
  }
}
