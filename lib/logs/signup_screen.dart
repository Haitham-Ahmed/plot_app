// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart'; // ✅ 1. استيراد Firestore
// import 'package:intl/intl.dart'; // ✅ 2. استيراد حزمة التواريخ

// class SignUpScreen extends StatefulWidget {
//   const SignUpScreen({super.key});

//   @override
//   State<SignUpScreen> createState() => _SignUpScreenState();
// }

// class _SignUpScreenState extends State<SignUpScreen> {
//   // ✅ 3. مفتاح للـ Form
//   final _formKey = GlobalKey<FormState>();

//   // ✅ 4. إضافة Controllers للحقول الجديدة
//   final _nameController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _confirmPasswordController = TextEditingController();
//   final _dobController = TextEditingController(); // ده للعرض بس
  
//   DateTime? _selectedDate; // ده لحفظ التاريخ

//   final _auth = FirebaseAuth.instance;
//   String? _errorMessage;
//   bool _isLoading = false;

//   Future<void> _signUp() async {
//     // ✅ 5. التحقق من أن كل الحقول صالحة
//     if (!_formKey.currentState!.validate()) {
//       return; // لو في أخطاء، اعرضها ومتكملش
//     }

//     setState(() {
//       _errorMessage = null;
//       _isLoading = true;
//     });

//     try {
//       // 6. إنشاء الحساب بالإيميل والباسورد
//       UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
//         email: _emailController.text.trim(),
//         password: _passwordController.text.trim(),
//       );

//       // ✅ 7. حفظ البيانات الإضافية في Firestore
//       if (userCredential.user != null) {
//         await FirebaseFirestore.instance
//             .collection('users')
//             .doc(userCredential.user!.uid)
//             .set({
//           'name': _nameController.text.trim(),
//           'email': _emailController.text.trim(),
//           'dob': _selectedDate,
//           'isPremium': false, // القيمة الافتراضية عند إنشاء الحساب
//           // (هنا ممكن تضيف أي بيانات تانية عاوزها للمستخدم)
//         });
//       }
      
//       if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);

//     } on FirebaseAuthException catch (e) {
//       setState(() => _errorMessage = "فشل إنشاء الحساب: ${e.message}");
//     } catch (e) {
//       setState(() => _errorMessage = "حدث خطأ غير متوقع: ${e.toString()}");
//     } finally {
//       if (mounted) {
//         setState(() => _isLoading = false);
//       }
//     }
//   }

//   // ✅ 8. دالة اختيار تاريخ الميلاد
//   Future<void> _selectDate(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: _selectedDate ?? DateTime.now(),
//       firstDate: DateTime(1900),
//       lastDate: DateTime.now(),
//     );
//     if (picked != null && picked != _selectedDate) {
//       setState(() {
//         _selectedDate = picked;
//         _dobController.text = DateFormat('yyyy-MM-dd').format(picked); // تنسيق التاريخ
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("إنشاء حساب جديد")),
//       body: Center(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(24.0),
//           // ✅ 9. استخدام Form
//           child: Form(
//             key: _formKey,
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const Text("مرحبًا بك!", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
//                 const SizedBox(height: 30),

//                 // --- حقل الاسم ---
//                 TextFormField(
//                   controller: _nameController,
//                   decoration: const InputDecoration(labelText: "الاسم", border: OutlineInputBorder()),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'الرجاء إدخال الاسم';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 16),

//                 // --- حقل الإيميل ---
//                 TextFormField(
//                   controller: _emailController,
//                   decoration: const InputDecoration(labelText: "البريد الإلكتروني", border: OutlineInputBorder()),
//                   keyboardType: TextInputType.emailAddress,
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'الرجاء إدخال البريد الإلكتروني';
//                     }
//                     if (!value.contains('@')) {
//                       return 'البريد الإلكتروني غير صالح';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 16),

//                 // --- حقل تاريخ الميلاد ---
//                 TextFormField(
//                   controller: _dobController,
//                   decoration: const InputDecoration(
//                     labelText: "تاريخ الميلاد",
//                     border: OutlineInputBorder(),
//                     suffixIcon: Icon(Icons.calendar_today),
//                   ),
//                   readOnly: true, // تمنع الكتابة المباشرة
//                   onTap: () => _selectDate(context), // تفتح التقويم عند الضغط
//                   validator: (value) {
//                     if (_selectedDate == null) {
//                       return 'الرجاء إدخال تاريخ الميلاد';
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
//                     if (value.length < 6) { // ✅ التحقق من الطول
//                       return 'كلمة المرور يجب أن تكون 6 حروف على الأقل';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 16),

//                 // --- حقل تأكيد كلمة السر ---
//                 TextFormField(
//                   controller: _confirmPasswordController,
//                   decoration: const InputDecoration(labelText: "تأكيد كلمة المرور", border: OutlineInputBorder()),
//                   obscureText: true,
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'الرجاء تأكيد كلمة المرور';
//                     }
//                     if (value != _passwordController.text) { // ✅ التحقق من التطابق
//                       return 'كلمتا المرور غير متطابقتين';
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
//                     onPressed: _isLoading ? null : _signUp,
//                     child: _isLoading 
//                            ? const CircularProgressIndicator(color: Colors.white) 
//                            : const Text("إنشاء حساب"),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }



// [ملف: signup_screen.dart]

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:intl/intl.dart'; 
import 'package:plot_app/home_screen.dart'; // ✅ استيراد HomeScreen

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _dobController = TextEditingController(); 
  
  DateTime? _selectedDate; 

  final _auth = FirebaseAuth.instance;
  String? _errorMessage;
  bool _isLoading = false;

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    try {
      // 6. إنشاء الحساب
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // 7. حفظ البيانات الإضافية
      if (userCredential.user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'dob': _selectedDate,
          'isPremium': false, 
        });
      }
      
      // ✅✅ --- بداية التعديل --- ✅✅
      // عند نجاح التسجيل، انتقل للشاشة الرئيسية واستبدل هذه الشاشة
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
      // ✅✅ --- نهاية التعديل --- ✅✅

    } on FirebaseAuthException catch (e) {
      setState(() => _errorMessage = "فشل إنشاء الحساب: ${e.message}");
    } catch (e) {
      setState(() => _errorMessage = "حدث خطأ غير متوقع: ${e.toString()}");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // 8. دالة اختيار تاريخ الميلاد
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dobController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("إنشاء حساب جديد")),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("مرحبًا بك!", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 30),

                // --- حقل الاسم ---
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: "الاسم", border: OutlineInputBorder()),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال الاسم';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // --- حقل الإيميل ---
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: "البريد الإلكتروني", border: OutlineInputBorder()),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال البريد الإلكتروني';
                    }
                    if (!value.contains('@')) {
                      return 'البريد الإلكتروني غير صالح';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // --- حقل تاريخ الميلاد ---
                TextFormField(
                  controller: _dobController,
                  decoration: const InputDecoration(
                    labelText: "تاريخ الميلاد",
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  readOnly: true, 
                  onTap: () => _selectDate(context), 
                  validator: (value) {
                    if (_selectedDate == null) {
                      return 'الرجاء إدخال تاريخ الميلاد';
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
                    if (value.length < 6) { 
                      return 'كلمة المرور يجب أن تكون 6 حروف على الأقل';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // --- حقل تأكيد كلمة السر ---
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: const InputDecoration(labelText: "تأكيد كلمة المرور", border: OutlineInputBorder()),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء تأكيد كلمة المرور';
                    }
                    if (value != _passwordController.text) { 
                      return 'كلمتا المرور غير متطابقتين';
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
                    onPressed: _isLoading ? null : _signUp,
                    child: _isLoading 
                           ? const CircularProgressIndicator(color: Colors.white) 
                           : const Text("إنشاء حساب"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}