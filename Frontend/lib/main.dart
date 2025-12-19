import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants.dart';
import 'routes/app_router.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(const ProviderScope(child: BeztaMyApp()));
}

class BeztaMyApp extends ConsumerWidget {
  const BeztaMyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'BeztaMy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF4CAF50),
        scaffoldBackgroundColor: AppConstants.appBackgroundColor,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppConstants.appBackgroundColor,
          elevation: 0,
          iconTheme: IconThemeData(color: Color(0xFF171A1F)),
          titleTextStyle: TextStyle(
            color: Color(0xFF171A1F),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        textTheme: GoogleFonts.interTextTheme(),
      ),
      routerConfig: router,
    );
  }
}
