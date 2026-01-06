import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart'; // Ensure google_fonts is added or just use standard fonts if not
import 'package:toastification/toastification.dart'; // Add this import
import 'core/di/dependency_injection.dart';
import 'features/splash/presentation/pages/splash_page.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/register_page.dart';
import 'features/tenant/presentation/pages/tenant_page.dart';
import 'features/dashboard/presentation/pages/dashboard_page.dart';
import 'features/projects/presentation/pages/projects_page.dart';
import 'features/auth/presentation/controllers/auth_controller.dart';
import 'features/tenant/presentation/controllers/tenant_controller.dart';
import 'features/projects/presentation/controllers/project_controller.dart';
import 'firebase_options.dart';
import 'routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  DependencyInjection.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Professional SaaS Color Palette
    const primaryColor = Color(0xFF2563EB); // Royal Blue
    const secondaryColor = Color(0xFF1E293B); // Slate 800
    const backgroundColor = Color(0xFFF8FAFC); // Slate 50
    const surfaceColor = Colors.white;

    return ToastificationWrapper( // Wrap your App in ToastificationWrapper
      child: GetMaterialApp(
        title: 'Nexus SaaS Platform', // Rebranded for professional feel
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: backgroundColor,
          colorScheme: ColorScheme.fromSeed(
            seedColor: primaryColor,
            primary: primaryColor,
            secondary: secondaryColor,
            surface: surfaceColor,
            background: backgroundColor,
          ),
          
          // Typography
          textTheme: const TextTheme(
            displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: secondaryColor),
            displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: secondaryColor),
            titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: secondaryColor),
            bodyLarge: TextStyle(fontSize: 16, color: Colors.black87),
            bodyMedium: TextStyle(fontSize: 14, color: Colors.black54),
          ),
      
          // Input Styling
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: primaryColor, width: 2),
            ),
            labelStyle: TextStyle(color: Colors.grey.shade600),
          ),
      
          // Button Styling
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: primaryColor,
              textStyle: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          
          // Card Styling
          cardTheme: CardThemeData(
            elevation: 2,
            shadowColor: Colors.black.withOpacity(0.1),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            color: surfaceColor,
            margin: EdgeInsets.zero,
          ),
          
          appBarTheme: const AppBarTheme(
            backgroundColor: surfaceColor,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            centerTitle: false,
            titleTextStyle: TextStyle(
              color: secondaryColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            iconTheme: IconThemeData(color: secondaryColor),
          ),
        ),
        initialRoute: Routes.SPLASH,
        getPages: [
          GetPage(
            name: Routes.SPLASH, 
            page: () => const SplashPage(),
          ),
          GetPage(
            name: Routes.LOGIN, 
            page: () => LoginPage(),
          ),
          GetPage(
            name: Routes.REGISTER, 
            page: () => RegisterPage(),
          ),
          GetPage(
            name: Routes.TENANTS, 
            page: () => TenantPage(),
            binding: BindingsBuilder(() {
               Get.put(TenantController(Get.find(), Get.find(), Get.find()));
            })
          ),
          GetPage(
            name: Routes.DASHBOARD, 
            page: () => const DashboardPage(),
          ),
          GetPage(
            name: Routes.PROJECTS, 
            page: () => ProjectsPage(),
            binding: BindingsBuilder(() {
               Get.put(ProjectController(Get.find(), Get.find()));
            })
          ),
        ],
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
