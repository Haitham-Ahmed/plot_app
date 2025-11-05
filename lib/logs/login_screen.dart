// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'signup_screen.dart'; 

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   // ✅ 1. إضافة مفتاح للـ Form
//   final _formKey = GlobalKey<FormState>();

//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _auth = FirebaseAuth.instance;
//   String? _errorMessage;
//   bool _isLoading = false;

//   Future<void> _login() async {
//     // ✅ 2. التحقق من الحقول
//     if (!_formKey.currentState!.validate()) {
//       return; // لو الحقول فاضية، اعرض الخطأ ومتكملش
//     }
    
//     setState(() {
//       _errorMessage = null;
//       _isLoading = true;
//     });

//     try {
//       await _auth.signInWithEmailAndPassword(
//         email: _emailController.text.trim(),
//         password: _passwordController.text.trim(),
//       );
//     } on FirebaseAuthException catch (e) {
//       // ✅ 3. Firebase هيرد بالأخطاء (زي "user-not-found" أو "wrong-password")
//       setState(() => _errorMessage = "فشل الدخول: البريد الإلكتروني أو كلمة المرور غير صحيحة.");
//     } catch (e) {
//       setState(() => _errorMessage = "حدث خطأ غير متوقع: ${e.toString()}");
//     } finally {
//       if (mounted) {
//         setState(() => _isLoading = false);
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(24.0),
//           // ✅ 4. استخدام Form
//           child: Form(
//             key: _formKey,
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Image.asset('assets/images/open-book.png', height: 100),
//                 const SizedBox(height: 20),
//                 const Text("تسجيل الدخول", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
//                 const SizedBox(height: 30),
                
//                 // --- حقل الإيميل ---
//                 TextFormField(
//                   controller: _emailController,
//                   decoration: const InputDecoration(labelText: "البريد الإلكتروني", border: OutlineInputBorder()),
//                   keyboardType: TextInputType.emailAddress,
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'الرجاء إدخال البريد الإلكتروني';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 16),
                
//                 // --- حقل كلمة السر ---
//                 TextFormField(
//                   controller: _passwordController,
//                   decoration: const InputDecoration(labelText: "كلمة المرور", border: OutlineInputBorder()),
//                   obscureText: true,
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'الرجاء إدخال كلمة المرور';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 20),
                
//                 if (_errorMessage != null)
//                   Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
//                 const SizedBox(height: 10),
                
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: _isLoading ? null : _login,
//                     child: _isLoading
//                            ? const CircularProgressIndicator(color: Colors.white)
//                            : const Text("دخول"),
//                   ),
//                 ),
//                 TextButton(
//                   onPressed: _isLoading ? null : () {
//                     Navigator.push(context, MaterialPageRoute(builder: (_) => const SignUpScreen()));
//                   },
//                   child: const Text("ليس لديك حساب؟ إنشاء حساب جديد"),
//                 )
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }



// [ملف: login_screen.dart]

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:plot_app/home_screen.dart'; // ✅ استيراد HomeScreen
import 'signup_screen.dart'; 

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // ✅ 1. إضافة مفتاح للـ Form
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  String? _errorMessage;
  bool _isLoading = false;

  Future<void> _login() async {
    // ✅ 2. التحقق من الحقول
    if (!_formKey.currentState!.validate()) {
      return; // لو الحقول فاضية، اعرض الخطأ ومتكملش
    }
    
    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // ✅✅ --- بداية التعديل --- ✅✅
      // عند نجاح الدخول، انتقل للشاشة الرئيسية واستبدل شاشة الدخول
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
      // ✅✅ --- نهاية التعديل --- ✅✅

    } on FirebaseAuthException catch (e) {
      // ✅ 3. Firebase هيرد بالأخطاء
      setState(() => _errorMessage = "فشل الدخول: البريد الإلكتروني أو كلمة المرور غير صحيحة.");
    } catch (e) {
      setState(() => _errorMessage = "حدث خطأ غير متوقع: ${e.toString()}");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          // ✅ 4. استخدام Form
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/open-book.png', height: 100),
                const SizedBox(height: 20),
                const Text("تسجيل الدخول", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 30),
                
                // --- حقل الإيميل ---
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: "البريد الإلكتروني", border: OutlineInputBorder()),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال البريد الإلكتروني';
                    }
                    if (!value.contains('@')) { // تحقق بسيط
                      return 'البريد الإلكتروني غير صالح';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // --- حقل كلمة السر ---
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: "كلمة المرور", border: OutlineInputBorder()),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال كلمة المرور';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                
                if (_errorMessage != null)
                  Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 10),
                
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    child: _isLoading
                           ? const CircularProgressIndicator(color: Colors.white)
                           : const Text("دخول"),
                  ),
                ),
                TextButton(
                  onPressed: _isLoading ? null : () {
                    // ✅ استخدام push للانتقال لإنشاء الحساب
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const SignUpScreen()));
                  },
                  child: const Text("ليس لديك حساب؟ إنشاء حساب جديد"),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}