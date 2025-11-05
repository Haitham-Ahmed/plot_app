// import 'package:flutter/material.dart';
// import 'package:flutter_gemini/flutter_gemini.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
// import 'package:firebase_core/firebase_core.dart'; // استيراد أساسي
// import 'package:plot_app/logs/auth_gate.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'firebase_options.dart'; // تأكد من استيراد الملف المعدل ببيانات plot-app-734f3

// final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   // --- بدء منطقة التحميل والاعدادات ---
//   try {
//     // تحميل إعدادات الوضع الليلي
//     final prefs = await SharedPreferences.getInstance();
//     final isDarkMode = prefs.getBool('isDarkMode') ?? false;
//     themeNotifier.value = isDarkMode ? ThemeMode.dark : ThemeMode.light;

//     // ✅✅ --- التحقق قبل تهيئة Firebase --- ✅✅
//     // هذا الشرط يمنع خطأ duplicate-app
//     if (Firebase.apps.isEmpty) {
//       print("ℹ️ Initializing Firebase for the first time...");
//       await Firebase.initializeApp(
//         options: DefaultFirebaseOptions.currentPlatform,
//       );
//       print("✅ Firebase initialized successfully!");
//       print(" Firebase App Name: ${Firebase.app().name}");
//       print(" Firebase Project ID: ${Firebase.app().options.projectId}"); // يجب أن يطبع plot-app-734f3
//     } else {
//       print("ℹ️ Firebase already initialized.");
//       print(" Firebase App Name: ${Firebase.app().name}");
//       print(" Firebase Project ID: ${Firebase.app().options.projectId}"); // تحقق من القيمة هنا أيضًا
//     }
//     // ✅✅ ------------------------------------ ✅✅


//     // تهيئة AdMob (يفضل بعد Firebase)
//     // ⚠️ ملاحظة: تأكد أن AdMob تم تهيئته مرة واحدة فقط أيضًا. وضعه هنا آمن.
//     print("ℹ️ Attempting to initialize Mobile Ads...");
//     // يمكنك إضافة تحقق مشابه إذا واجهت مشاكل مع AdMob لاحقًا
//     // if (MobileAds.instance == null) { ... }
//     await MobileAds.instance.initialize();
//     print("✅ Mobile Ads initialized successfully!");

//     // تهيئة Gemini (تأكد من صحة المفتاح)
//     // ⚠️ هل تحتاج لتهيئة Gemini في كل مرة؟ ربما يمكن التحقق هنا أيضًا
//     print("ℹ️ Attempting to initialize Gemini...");
//     Gemini.init(apiKey: "AIzaSyAaK4wtkAk4tXscoFaIDpsMeeBh0acjmpc");
//     print("✅ Gemini initialized successfully!");

//   } catch (e) {
//     print("❌❌❌ Firebase/Initialization Error: $e");
//     // Handle error appropriately, maybe show an error screen
//     // runApp(ErrorScreen(error: e.toString()));
//      return; // Stop execution on critical init error
//   }
//   // --- نهاية منطقة التحميل والاعدادات ---

//   print("🚀 Running the app...");
//   runApp(const PlotApp());
// }

// // ... باقي كود PlotApp كما هو ...
// class PlotApp extends StatelessWidget {
//   const PlotApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return ValueListenableBuilder<ThemeMode>(
//       valueListenable: themeNotifier,
//       builder: (_, currentMode, __) {
//         return MaterialApp(
//           title: 'مكتبة الحبكات',
//           debugShowCheckedModeBanner: false,
//           home: const AuthGate(), // يبدأ التطبيق من هنا بعد التهيئة

//           themeMode: currentMode,

//           // الثيم الفاتح
//           theme: ThemeData(
//             brightness: Brightness.light,
//             primarySwatch: Colors.blue,
//             fontFamily: 'Cairo',
//             scaffoldBackgroundColor: Colors.white,
//             appBarTheme: const AppBarTheme(
//               backgroundColor: Color(0xFF1E88E5),
//               foregroundColor: Colors.white,
//             ),
//             bottomNavigationBarTheme: const BottomNavigationBarThemeData(
//               selectedItemColor: Color(0xFF1E88E5),
//               unselectedItemColor: Colors.grey,
//             ),
//           ),

//           // الثيم الداكن
//           darkTheme: ThemeData(
//             brightness: Brightness.dark,
//             primarySwatch: Colors.blue,
//             fontFamily: 'Cairo',
//             scaffoldBackgroundColor: const Color(0xFF121212),
//             appBarTheme: const AppBarTheme(
//               backgroundColor: Color(0xFF1E1E1E),
//               foregroundColor: Colors.white,
//             ),
//             bottomNavigationBarTheme: const BottomNavigationBarThemeData(
//               selectedItemColor: Colors.blueAccent,
//               unselectedItemColor: Colors.grey,
//             ),
//             cardColor: const Color(0xFF1E1E1E),
//             elevatedButtonTheme: ElevatedButtonThemeData(
//               style: ButtonStyle(
//                 backgroundColor: WidgetStateProperty.all(Colors.blue),
//               ),
//             ),
//           ),

//           builder: (context, child) {
//             return Directionality(
//               textDirection: TextDirection.rtl,
//               child: child ?? const SizedBox.shrink(),
//             );
//           },
//         );
//       },
//     );
//   }
// }





// [ملف: main.dart]

import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:firebase_core/firebase_core.dart';
// ❌ تم حذف AuthGate من هنا
import 'package:plot_app/logs/login_screen.dart'; // ✅ تحديد شاشة البداية
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart'; 

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // تحميل إعدادات الوضع الليلي
    final prefs = await SharedPreferences.getInstance();
    final isDarkMode = prefs.getBool('isDarkMode') ?? false;
    themeNotifier.value = isDarkMode ? ThemeMode.dark : ThemeMode.light;

    // ✅✅ --- التحقق قبل تهيئة Firebase --- ✅✅
    if (Firebase.apps.isEmpty) {
      print("ℹ️ Initializing Firebase for the first time...");
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } 
    // تهيئة AdMob
    await MobileAds.instance.initialize();
    
    // تهيئة Gemini
    Gemini.init(apiKey: "AIzaSyDKsSvYmtTMuWVvLkxTQJODs3JJc1_Uj1A");

  } catch (e) {
    print("❌❌❌ Firebase/Initialization Error: $e");
     return; // Stop execution on critical init error
  }

  print("🚀 Running the app...");
  runApp(const PlotApp());
}

class PlotApp extends StatelessWidget {
  const PlotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, currentMode, __) {
        return MaterialApp(
          title: 'مكتبة الحبكات',
          debugShowCheckedModeBanner: false,
          
          // ✅✅ --- بداية التعديل --- ✅✅
          home: const LoginScreen(), // ✅ يبدأ التطبيق من شاشة الدخول
          // ❌ home: const AuthGate(), // ❌ لم نعد نستخدم AuthGate هنا
          // ✅✅ --- نهاية التعديل --- ✅✅

          themeMode: currentMode, // ✅ تحديد وضع الثيم الحالي

          // 🎨 الثيم الفاتح (الأساسي)
          theme: ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.blue,
            fontFamily: 'Cairo',
            scaffoldBackgroundColor: Colors.white,
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF1E88E5),
              foregroundColor: Colors.white,
            ),
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              selectedItemColor: Color(0xFF1E88E5),
              unselectedItemColor: Colors.grey,
            ),
          ),

          // 🎨 الثيم الداكن (الجديد)
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primarySwatch: Colors.blue,
            fontFamily: 'Cairo',
            scaffoldBackgroundColor: const Color(0xFF121212),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF1E1E1E),
              foregroundColor: Colors.white,
            ),
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              selectedItemColor: Colors.blueAccent,
              unselectedItemColor: Colors.grey,
            ),
            cardColor: const Color(0xFF1E1E1E),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.blue),
              ),
            ),
          ),

          builder: (context, child) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: child ?? const SizedBox.shrink(),
            );
          },
        );
      },
    );
  }
}