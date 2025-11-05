// import 'dart:convert';
// import 'dart:math';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_gemini/flutter_gemini.dart';
// import 'package:plot_app/gemini_utils.dart'; // تأكد من المسار
// import 'package:shared_preferences/shared_preferences.dart';

// class ChatScreen extends StatefulWidget {
//   final String plotType;

//   const ChatScreen({super.key, required this.plotType});

//   @override
//   State<ChatScreen> createState() => _ChatScreenState();
// }

// class _ChatScreenState extends State<ChatScreen> {
//   final TextEditingController _controller = TextEditingController();
//   late final List<Map<String, String?>> _messages;
//   final gemini = Gemini.instance;
//   bool _isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     _messages = [
//       {
//         "sender": "AI",
//         "title": null,
//         "text":
//             "أهلاً بك! لقد اخترت نوع: ${widget.plotType}.\nمن فضلك صف لي باختصار ما تريده في حبكتك (مثال: جريمة في قصر مهجور، حب في الفضاء...).",
//         "author": null,
//       }
//     ];
//   }

//   void _sendMessage() {
//     final text = _controller.text.trim();
//     if (text.isEmpty || _isLoading) return;

//     setState(() {
//       _messages.add({
//         "sender": "User",
//         "text": text,
//         "title": null,
//         "author": null,
//         });
//       _controller.clear();
//       _isLoading = true; // بدء التحميل (يبقى لإدارة حالة الزر والحقل)
//     });

//     _getAiResponse(text);
//   }

//   Future<void> _getAiResponse(String userPrompt) async {
//     final prompt =
//         """أنت كاتب محترف متخصص في توليد حبكات قصصية. مهمتك هي قراءة وصف المستخدم ونوع الحبكة المطلوب، ثم إنشاء رد بتنسيق JSON يحتوي على عنصرين:
//         1.  "title": عنوان إبداعي وجذاب للحبكة المقترحة (باللغة العربية).
//         2.  "plot": نص الحبكة نفسها، بحيث يكون موجزًا جدًا (سطرين إلى ثلاثة أسطر كحد أقصى)، مشوقًا، ومناسبًا لرواية أو قصة قصيرة (باللغة العربية).

//         نوع الحبكة المطلوب: ${widget.plotType}.
//         وصف المستخدم: "$userPrompt".

//         تأكد من أن الرد يكون بتنسيق JSON صالح تمامًا، مثال:
//         {
//           "title": "ظل في المرآة",
//           "plot": "أم تلاحظ أن انعكاس طفلها لا يطابق حركاته. في إحدى الليالي، يختفي الطفل الحقيقي، والانعكاس يكتب على الزجاج: 'أنا الأصل'."
//         }
//         """;

//     String aiResponseText;
//     Map<String, dynamic>? parsedResponse;

//     try {
//       final Candidates? candidates = await gemini.text(prompt);
//       aiResponseText = extractGeminiTextFromCandidates(candidates);

//       try {
//          final startIndex = aiResponseText.indexOf('{');
//          final endIndex = aiResponseText.lastIndexOf('}');
//          if (startIndex != -1 && endIndex != -1 && endIndex > startIndex) {
//             final jsonString = aiResponseText.substring(startIndex, endIndex + 1);
//             parsedResponse = jsonDecode(jsonString) as Map<String, dynamic>;
//          } else {
//            throw FormatException("JSON format not found in response");
//          }
//       } catch (e) {
//         debugPrint("⚠️ فشل تحليل JSON من رد Gemini: $e");
//         debugPrint("النص الخام المستلم: $aiResponseText");
//         parsedResponse = null;
//       }

//       setState(() {
//         if (parsedResponse != null && parsedResponse.containsKey('title') && parsedResponse.containsKey('plot')) {
//           _messages.add({
//             "sender": "AI",
//             "title": parsedResponse['title']?.toString() ?? "بلا عنوان",
//             "text": parsedResponse['plot']?.toString() ?? "لم يتم الحصول على حبكة.",
//             // ✅✅ 1. تغيير اسم المؤلف
//             "author": "عبدالله سعيد باقلاقل", 
//           });
//         } else {
//           _messages.add({
//             "sender": "AI",
//             "title": "حبكة غير معنونة",
//             "text": aiResponseText,
//             // ✅✅ 1. تغيير اسم المؤلف (حتى في حالة الفشل)
//             "author": "عبدالله سعيد باقلاقل", 
//           });
//         }
//       });
//     } catch (e) {
//       setState(() {
//         _messages.add({
//           "sender": "AI",
//           "title": "خطأ",
//           "text": "حصل خطأ أثناء الاتصال: $e",
//           "author": null,
//           });
//       });
//     } finally {
//       if (mounted) {
//         // إيقاف حالة التحميل (بدون عرض مؤشر مرئي)
//         setState(() => _isLoading = false); 
//       }
//     }
//   }

//   Future<void> _saveToFavorites(String text) async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("خطأ: لم يتم تسجيل دخول المستخدم.")),
//       );
//       return;
//     }
//     try {
//       await FirebaseFirestore.instance
//           .collection('users')
//           .doc(user.uid)
//           .collection('favorites')
//           .add({
//         'text': text,
//         'timestamp': FieldValue.serverTimestamp(),
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("تم حفظ الحبكة في المفضلة السحابية ✅")),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("فشل الحفظ: $e")),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF1E88E5)),
//           onPressed: () => Navigator.of(context).pop(),
//         ),
//         title: Text(
//           'إنشاء حبكة: ${widget.plotType}',
//           style: const TextStyle(
//             color: Colors.black87,
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//           ),
//           textDirection: TextDirection.rtl,
//         ),
//         centerTitle: true,
//       ),
//       body: Column(
//         children: <Widget>[
//           Expanded(
//             child: ListView.builder(
//               reverse: true, 
//               padding: const EdgeInsets.all(12.0),
//               itemCount: _messages.length,
//               itemBuilder: (_, index) {
//                 final message = _messages[_messages.length - 1 - index];
//                 return _buildMessageBubble(message);
//               },
//             ),
//           ),
//           // ❌❌ 3. تمت إزالة مؤشر التحميل من هنا
//           // if (_isLoading)
//           //    const Padding(
//           //      padding: EdgeInsets.symmetric(vertical: 8.0),
//           //      child: LinearProgressIndicator(),
//           //    ),
//           _buildTextComposer(),
//         ],
//       ),
//     );
//   }

//   Widget _buildMessageBubble(Map<String, String?> message) {
//     // ... (هذا الجزء لم يتغير في المنطق، فقط التأكد من الألوان)
//     final bool isUser = message["sender"] == "User";
//     final bool isAi = message["sender"] == "AI";
//     final bool isDark = Theme.of(context).brightness == Brightness.dark;
//     final Color userBubbleColor = isDark ? Colors.blueGrey[700]! : const Color(0xFFE3F2FD);
//     final Color aiBubbleColor = isDark ? Colors.grey[800]! : const Color(0xFFBBDEFB);

//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 6.0),
//       child: Row(
//         mainAxisAlignment:
//             isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
//         crossAxisAlignment: CrossAxisAlignment.end,
//         children: <Widget>[
//           Flexible(
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
//               decoration: BoxDecoration(
//                 color: isUser ? userBubbleColor : aiBubbleColor,
//                 borderRadius: BorderRadius.circular(18),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.end,
//                 children: [
//                   if (isAi && message["title"] != null)
//                     Padding(
//                       padding: const EdgeInsets.only(bottom: 6.0),
//                       child: Text(
//                         message["title"]!,
//                         style: const TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 16,
//                         ),
//                         textAlign: TextAlign.right,
//                         textDirection: TextDirection.rtl,
//                       ),
//                     ),
//                   Text(
//                     message["text"] ?? "",
//                     style: const TextStyle(fontSize: 15, height: 1.4),
//                     textAlign: TextAlign.right,
//                     textDirection: TextDirection.rtl,
//                   ),
//                   if (isAi && message["author"] != null)
//                      Padding(
//                        padding: const EdgeInsets.only(top: 8.0),
//                        child: Row(
//                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                          mainAxisSize: MainAxisSize.min,
//                          children: [
//                             if (message["text"] != null &&
//                                 !message["text"]!.startsWith("حصل خطأ") &&
//                                 message["text"] != "لم يتم الحصول على حبكة.")
//                              IconButton(
//                                padding: EdgeInsets.zero,
//                                constraints: const BoxConstraints(),
//                                icon: Icon(Icons.favorite_border,
//                                    color: isDark ? Colors.pinkAccent : Colors.red, size: 18),
//                                onPressed: () => _saveToFavorites(message["text"]!),
//                                tooltip: "حفظ في المفضلة",
//                              ),
//                            const Spacer(),
//                            Text(
//                              "مؤلف الحبكة: ${message["author"]!}", // سيظهر اسمك هنا
//                              style: TextStyle(
//                                fontSize: 11,
//                                color: isDark? Colors.grey[400] : Colors.grey[700],
//                                fontStyle: FontStyle.italic,
//                              ),
//                              textAlign: TextAlign.right,
//                              textDirection: TextDirection.rtl,
//                            ),
//                          ],
//                        ),
//                      ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTextComposer() {
//     final bool isDark = Theme.of(context).brightness == Brightness.dark;
//     final Color textFieldFillColor = isDark ? Colors.grey[850]! : Colors.grey[100]!;
//     // ✅✅ 2. ضمان أن لون الزر هو الأزرق المطلوب
//     const Color sendButtonColor = Color(0xFF1E88E5); 

//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
//       decoration: BoxDecoration(
//         color: Theme.of(context).cardColor,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             spreadRadius: 0,
//             blurRadius: 10,
//             offset: const Offset(0, -2),
//           ),
//         ],
//       ),
//       child: SafeArea(
//         child: Row(
//           children: <Widget>[
//             Expanded(
//               child: TextField(
//                 enabled: !_isLoading,
//                 controller: _controller,
//                 onSubmitted: (_) => _sendMessage(),
//                 decoration: InputDecoration(
//                   hintText: "صف الحبكة التي تريدها...",
//                   hintTextDirection: TextDirection.rtl,
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(25.0),
//                     borderSide: BorderSide.none,
//                   ),
//                   filled: true,
//                   fillColor: textFieldFillColor,
//                   contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//                 ),
//                 textAlign: TextAlign.right,
//                 textDirection: TextDirection.rtl,
//                 maxLines: null,
//                 keyboardType: TextInputType.multiline,
//               ),
//             ),
//             const SizedBox(width: 8),
//             Container(
//               decoration: BoxDecoration(
//                 // تغيير اللون إلى رمادي فقط عند التعطيل
//                 color: _isLoading ? Colors.grey : sendButtonColor, 
//                 shape: BoxShape.circle,
//               ),
//               margin: const EdgeInsets.symmetric(horizontal: 4.0),
//               child: IconButton(
//                 icon: const Icon(Icons.send, color: Colors.white),
//                 onPressed: _isLoading ? null : _sendMessage,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }



// // [ملف: chat_screen.dart]

// import 'dart:convert';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_gemini/flutter_gemini.dart';
// import 'package:plot_app/gemini_utils.dart';
// // ✅✅ --- بداية التعديل (استيرادات جديدة) --- ✅✅
// import 'package:plot_app/ad_manager.dart';
// import 'package:plot_app/paymob/payment_manager.dart';
// import 'package:plot_app/paymob/paymob_service.dart';
// import 'package:plot_app/paymob/payment_webview_screen.dart';
// // ✅✅ --- نهاية التعديل --- ✅✅

// class ChatScreen extends StatefulWidget {
//   final String plotType;

//   const ChatScreen({super.key, required this.plotType});

//   @override
//   State<ChatScreen> createState() => _ChatScreenState();
// }

// class _ChatScreenState extends State<ChatScreen> {
//   final TextEditingController _controller = TextEditingController();
//   late final List<Map<String, String?>> _messages;
//   final gemini = Gemini.instance;
//   bool _isLoading = false;

//   // ✅✅ --- بداية التعديل (إضافة خدمة الدفع) --- ✅✅
//   final PaymobService _paymobService = PaymobService();
//   // ✅✅ --- نهاية التعديل --- ✅✅

//   @override
//   void initState() {
//     super.initState();
//     _messages = [
//       {
//         "sender": "AI",
//         "title": null,
//         "text":
//             "أهلاً بك! لقد اخترت نوع: ${widget.plotType}.\nاكتب طلبك هنا (مثال: جريمة في قصر مهجور...). \n\nسيُطلب منك مشاهدة إعلان قصير مقابل كل طلب (بحد أقصى 3 يوميًا) إذا لم تكن مشتركًا.",
//         "author": null,
//       }
//     ];
//   }

//   // ✅✅ --- بداية التعديل (تعديل دالة الإرسال بالكامل) --- ✅✅
  
//   /// الدالة الرئيسية التي يتم استدعاؤها عند الضغط على زر الإرسال
//   void _sendMessage() async { // 1. تحويلها إلى async
//     final text = _controller.text.trim();
//     if (text.isEmpty || _isLoading) return; // منع الإرسال المتكرر

//     // 2. إضافة رسالة المستخدم للواجهة فوراً
//     setState(() {
//       _messages.add({
//         "sender": "User", "text": text, "title": null, "author": null,
//       });
//       _controller.clear();
//       _isLoading = true; // 3. إظهار مؤشر التحميل (LinearProgressIndicator)
//     });

//     // 4. التحقق من الاشتراك
//     bool isPremium = await PaymentManager.isPremiumUser();
//     if (isPremium) {
//       debugPrint("المستخدم مشترك. جارِ جلب الرد.");
//       await _getAiResponse(text); // انتظر الرد
//       return;
//     }

//     // 5. إذا لم يكن مشتركًا، تحقق من المحاولات المجانية (المخصصة)
//     bool canUse = await PaymentManager.canUseCustomPlot();
//     if (canUse) {
//       debugPrint("لدى المستخدم محاولات مجانية. جارِ عرض الإعلان.");
//       _showRewardedAdToGetPlot(text); // عرض الإعلان للحصول على الرد
//     } else {
//       // 6. إذا انتهت المحاولات، اعرض نافذة الدفع
//       debugPrint("انتهت المحاولات المجانية. جارِ عرض نافذة الدفع.");
//       _showPaymentDialog();
//       // إيقاف التحميل لأننا لن نرسل شيئًا الآن
//       if (mounted) {
//         setState(() => _isLoading = false);
//       }
//     }
//   }

//   /// دالة عرض الإعلان للحصول على الرد
//   void _showRewardedAdToGetPlot(String userPrompt) {
//     if (!mounted) return;
//     // لا نحتاج لإظهار مؤشر تحميل (Dialog) لأن _isLoading = true بالفعل
//     // ويتم عرض LinearProgressIndicator

//     AdManager.showRewardedAd(
//       () async { // دالة النجاح
//         debugPrint("🎉 نجح الإعلان. سيتم استهلاك محاولة وجلب الرد.");
//         await PaymentManager.incrementCustomPlotUses(); // استهلاك محاولة
//         await _getAiResponse(userPrompt); // جلب الرد بعد نجاح الإعلان
//       },
//       (String errorMessage) { // دالة الفشل
//         debugPrint("❌ فشل الإعلان. لن يتم إرسال الطلب.");
//         if (mounted) {
//           setState(() {
//             _isLoading = false; // إيقاف التحميل
//             // إضافة رسالة خطأ في الشات
//             _messages.add({
//               "sender": "AI",
//               "title": "خطأ في الإعلان",
//               "text": "فشل تحميل الإعلان. لا يمكن إرسال الطلب الآن. حاول مرة أخرى.\n $errorMessage",
//               "author": "النظام",
//             });
//           });
//         }
//       }
//     );
//   }

//   /// دالة عرض نافذة الدفع
//   void _showPaymentDialog() {
//      if (!mounted) return;
//      // السعر للعرض للمستخدم (تأكد منه)
//      const String displayPrice = "15 ريال سعودي";

//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: const Text("انتهت المحاولات المجانية 😔"),
//         content: Text( // استخدام Text مع متغير السعر
//           "لقد استهلكت محاولاتك المجانية (3) لهذا اليوم.\nللوصول الدائم وغير المحدود، يمكنك شراء الاشتراك الآن مقابل $displayPrice فقط.",
//           textDirection: TextDirection.rtl,
//         ),
//         actions: [
//           TextButton(child: const Text("لاحقًا"), onPressed: () => Navigator.pop(ctx)),
//           ElevatedButton(
//             child: Text("شراء ($displayPrice) 💳"), // استخدام متغير السعر
//             onPressed: () { 
//               Navigator.pop(ctx); // إغلاق نافذة الدفع
//               _handlePaymobPayment(); // بدء عملية الدفع
//             },
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
//           ),
//         ],
//       ),
//     );
//   }

//   /// دالة بدء عملية الدفع عبر Paymob
//   void _handlePaymobPayment() async {
//      if (!mounted) return;
//     // إظهار مؤشر تحميل (Dialog)
//     showDialog(context: context, builder: (context) => const Center(child: CircularProgressIndicator()), barrierDismissible: false);

//     // ⚠️⚠️ السعر: 15 ريال سعودي = 1500 هللة
//     const String amountCents = "1500"; // ⬅️ المبلغ بالهللات
//     const String currency = "SAR"; // ⬅️ تغيير العملة إلى ريال سعودي

//     try {
//       // تمرير المبلغ والعملة الجديدين
//       final paymentUrl = await _paymobService.getPaymentUrl(amountCents, currency);
//       if (!mounted) return;
//       Navigator.pop(context); // إخفاء مؤشر التحميل (Dialog)
//       if (!mounted) return;
//       // فتح شاشة الويب
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => PaymentWebViewScreen(paymentUrl: paymentUrl),
//         ),
//       );
//     } catch (e) {
//        if (!mounted) return;
//       Navigator.pop(context); // إخفاء مؤشر التحميل (Dialog)
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("❌ فشل بدء الدفع: ${e.toString()}"), backgroundColor: Colors.red),
//       );
//     }
//   }
//   // ✅✅ --- نهاية التعديل --- ✅✅


//   Future<void> _getAiResponse(String userPrompt) async {
//     final prompt =
//         """أنت كاتب محترف متخصص في توليد حبكات قصصية. مهمتك هي قراءة وصف المستخدم ونوع الحبكة المطلوب، ثم إنشاء رد بتنسيق JSON يحتوي على عنصرين:
//         1.  "title": عنوان إبداعي وجذاب للحبكة المقترحة (باللغة العربية).
//         2.  "plot": نص الحبكة نفسها، بحيث يكون موجزًا جدًا (سطرين إلى ثلاثة أسطر كحد أقصى)، مشوقًا، ومناسبًا لرواية أو قصة قصيرة (باللغة العربية).

//         نوع الحبكة المطلوب: ${widget.plotType}.
//         وصف المستخدم: "$userPrompt".

//         تأكد من أن الرد يكون بتنسيق JSON صالح تمامًا، مثال:
//         {
//           "title": "ظل في المرآة",
//           "plot": "أم تلاحظ أن انعكاس طفلها لا يطابق حركاته. في إحدى الليالي، يختفي الطفل الحقيقي، والانعكاس يكتب على الزجاج: 'أنا الأصل'."
//         }
//         """;

//     String aiResponseText;
//     Map<String, dynamic>? parsedResponse;

//     try {
//       final Candidates? candidates = await gemini.text(prompt);
//       aiResponseText = extractGeminiTextFromCandidates(candidates);

//       try {
//          final startIndex = aiResponseText.indexOf('{');
//          final endIndex = aiResponseText.lastIndexOf('}');
//          if (startIndex != -1 && endIndex != -1 && endIndex > startIndex) {
//             final jsonString = aiResponseText.substring(startIndex, endIndex + 1);
//             parsedResponse = jsonDecode(jsonString) as Map<String, dynamic>;
//          } else {
//            throw FormatException("JSON format not found in response");
//          }
//       } catch (e) {
//         debugPrint("⚠️ فشل تحليل JSON من رد Gemini: $e");
//         debugPrint("النص الخام المستلم: $aiResponseText");
//         parsedResponse = null;
//       }

//       setState(() {
//         if (parsedResponse != null && parsedResponse.containsKey('title') && parsedResponse.containsKey('plot')) {
//           _messages.add({
//             "sender": "AI",
//             "title": parsedResponse['title']?.toString() ?? "بلا عنوان",
//             "text": parsedResponse['plot']?.toString() ?? "لم يتم الحصول على حبكة.",
//             "author": "عبدالله سعيد باقلاقل", 
//           });
//         } else {
//           _messages.add({
//             "sender": "AI",
//             "title": "حبكة غير معنونة",
//             "text": aiResponseText,
//             "author": "عبدالله سعيد باقلاقل", 
//           });
//         }
//       });
//     } catch (e) {
//       setState(() {
//         _messages.add({
//           "sender": "AI",
//           "title": "خطأ",
//           "text": "حصل خطأ أثناء الاتصال: $e",
//           "author": null,
//           });
//       });
//     } finally {
//       if (mounted) {
//         // إيقاف حالة التحميل (بدون عرض مؤشر مرئي)
//         setState(() => _isLoading = false); 
//       }
//     }
//   }

//   Future<void> _saveToFavorites(String text) async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("خطأ: لم يتم تسجيل دخول المستخدم.")),
//       );
//       return;
//     }
//     try {
//       await FirebaseFirestore.instance
//           .collection('users')
//           .doc(user.uid)
//           .collection('favorites')
//           .add({
//         'text': text,
//         'timestamp': FieldValue.serverTimestamp(),
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("تم حفظ الحبكة في المفضلة السحابية ✅")),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("فشل الحفظ: $e")),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF1E88E5)),
//           onPressed: () => Navigator.of(context).pop(),
//         ),
//         title: Text(
//           'إنشاء حبكة: ${widget.plotType}',
//           style: const TextStyle(
//             color: Colors.black87,
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//           ),
//           textDirection: TextDirection.rtl,
//         ),
//         centerTitle: true,
//       ),
//       body: Column(
//         children: <Widget>[
//           Expanded(
//             child: ListView.builder(
//               reverse: true, 
//               padding: const EdgeInsets.all(12.0),
//               itemCount: _messages.length,
//               itemBuilder: (_, index) {
//                 final message = _messages[_messages.length - 1 - index];
//                 return _buildMessageBubble(message);
//               },
//             ),
//           ),
          
//           // ✅✅ --- بداية التعديل (إضافة مؤشر التحميل الخطي) --- ✅✅
//           // سيظهر هذا المؤشر عند الضغط على إرسال
//           if (_isLoading)
//              const Padding(
//                padding: EdgeInsets.symmetric(vertical: 0.0), // بدون مسافة
//                child: LinearProgressIndicator(), // مؤشر خطي
//              ),
//           // ✅✅ --- نهاية التعديل --- ✅✅
             
//           _buildTextComposer(),
//         ],
//       ),
//     );
//   }

//   Widget _buildMessageBubble(Map<String, String?> message) {
//     final bool isUser = message["sender"] == "User";
//     final bool isAi = message["sender"] == "AI";
//     final bool isDark = Theme.of(context).brightness == Brightness.dark;
//     final Color userBubbleColor = isDark ? Colors.blueGrey[700]! : const Color(0xFFE3F2FD);
//     final Color aiBubbleColor = isDark ? Colors.grey[800]! : const Color(0xFFBBDEFB);

//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 6.0),
//       child: Row(
//         mainAxisAlignment:
//             isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
//         crossAxisAlignment: CrossAxisAlignment.end,
//         children: <Widget>[
//           Flexible(
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
//               decoration: BoxDecoration(
//                 color: isUser ? userBubbleColor : aiBubbleColor,
//                 borderRadius: BorderRadius.circular(18),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.end,
//                 children: [
//                   if (isAi && message["title"] != null)
//                     Padding(
//                       padding: const EdgeInsets.only(bottom: 6.0),
//                       child: Text(
//                         message["title"]!,
//                         style: const TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 16,
//                         ),
//                         textAlign: TextAlign.right,
//                         textDirection: TextDirection.rtl,
//                       ),
//                     ),
//                   Text(
//                     message["text"] ?? "",
//                     style: const TextStyle(fontSize: 15, height: 1.4),
//                     textAlign: TextAlign.right,
//                     textDirection: TextDirection.rtl,
//                   ),
//                   if (isAi && message["author"] != null)
//                      Padding(
//                        padding: const EdgeInsets.only(top: 8.0),
//                        child: Row(
//                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                          mainAxisSize: MainAxisSize.min,
//                          children: [
//                             if (message["text"] != null &&
//                                 !message["text"]!.startsWith("حصل خطأ") &&
//                                 !message["text"]!.startsWith("فشل تحميل") && // ⬅️ عدم إظهار الحفظ لرسائل الخطأ
//                                 message["text"] != "لم يتم الحصول على حبكة.")
//                              IconButton(
//                                padding: EdgeInsets.zero,
//                                constraints: const BoxConstraints(),
//                                icon: Icon(Icons.favorite_border,
//                                    color: isDark ? Colors.pinkAccent : Colors.red, size: 18),
//                                onPressed: () => _saveToFavorites(message["text"]!),
//                                tooltip: "حفظ في المفضلة",
//                              ),
//                            const Spacer(),
//                            Text(
//                              "مؤلف الحبكة: ${message["author"]!}", // سيظهر اسمك هنا
//                              style: TextStyle(
//                                fontSize: 11,
//                                color: isDark? Colors.grey[400] : Colors.grey[700],
//                                fontStyle: FontStyle.italic,
//                              ),
//                              textAlign: TextAlign.right,
//                              textDirection: TextDirection.rtl,
//                            ),
//                          ],
//                        ),
//                      ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTextComposer() {
//     final bool isDark = Theme.of(context).brightness == Brightness.dark;
//     final Color textFieldFillColor = isDark ? Colors.grey[850]! : Colors.grey[100]!;
//     const Color sendButtonColor = Color(0xFF1E88E5); 

//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
//       decoration: BoxDecoration(
//         color: Theme.of(context).cardColor,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             spreadRadius: 0,
//             blurRadius: 10,
//             offset: const Offset(0, -2),
//           ),
//         ],
//       ),
//       child: SafeArea(
//         child: Row(
//           children: <Widget>[
//             Expanded(
//               child: TextField(
//                 enabled: !_isLoading, // ⬅️ تعطيل الحقل أثناء التحميل
//                 controller: _controller,
//                 onSubmitted: (_) => _sendMessage(),
//                 decoration: InputDecoration(
//                   hintText: "صف الحبكة التي تريدها...",
//                   hintTextDirection: TextDirection.rtl,
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(25.0),
//                     borderSide: BorderSide.none,
//                   ),
//                   filled: true,
//                   fillColor: textFieldFillColor,
//                   contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//                 ),
//                 textAlign: TextAlign.right,
//                 textDirection: TextDirection.rtl,
//                 maxLines: null,
//                 keyboardType: TextInputType.multiline,
//               ),
//             ),
//             const SizedBox(width: 8),
//             Container(
//               decoration: BoxDecoration(
//                 // تغيير اللون إلى رمادي فقط عند التعطيل
//                 color: _isLoading ? Colors.grey : sendButtonColor, 
//                 shape: BoxShape.circle,
//               ),
//               margin: const EdgeInsets.symmetric(horizontal: 4.0),
//               child: IconButton(
//                 icon: const Icon(Icons.send, color: Colors.white),
//                 onPressed: _isLoading ? null : _sendMessage, // ⬅️ تعطيل الزر أثناء التحميل
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }






// // [ملف: chat_screen.dart] - النسخة الكاملة والمعدلة

// import 'dart:async'; // ✅ استيراد للـ Timer (للانتظار قبل إعادة المحاولة)
// import 'dart:convert';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_gemini/flutter_gemini.dart';
// import 'package:plot_app/gemini_utils.dart'; // تأكد من استيراد ملف gemini_utils.dart الصحيح
// import 'package:plot_app/ad_manager.dart';
// import 'package:plot_app/paymob/payment_manager.dart';
// import 'package:plot_app/paymob/paymob_service.dart';
// import 'package:plot_app/paymob/payment_webview_screen.dart';

// class ChatScreen extends StatefulWidget {
//   final String plotType;

//   const ChatScreen({super.key, required this.plotType});

//   @override
//   State<ChatScreen> createState() => _ChatScreenState();
// }

// class _ChatScreenState extends State<ChatScreen> {
//   final TextEditingController _controller = TextEditingController();
//   late final List<Map<String, String?>> _messages;
//   final gemini = Gemini.instance;
//   bool _isLoading = false;
//   final PaymobService _paymobService = PaymobService();

//   @override
//   void initState() {
//     super.initState();
//     // ✅✅ تم تعديل رسالة الترحيب --- ✅✅
//     _messages = [
//       {
//         "sender": "AI",
//         "title": null,
//         "text":
//             "أهلاً بك في قسم حبكات الـ ${widget.plotType}! لديك 3 محاولات مجانية اليوم لإنشاء حبكات مخصصة. للحصول على استخدام غير محدود، يمكنك الاشتراك.", // <-- الرسالة الجديدة
//         "author": null,
//       }
//     ];
//   }

//   /// الدالة الرئيسية التي يتم استدعاؤها عند الضغط على زر الإرسال
//   void _sendMessage() async {
//     final text = _controller.text.trim();
//     if (text.isEmpty || _isLoading) return;

//     setState(() {
//       _messages.add({ "sender": "User", "text": text, "title": null, "author": null, });
//       _controller.clear();
//       _isLoading = true;
//     });

//     bool isPremium = await PaymentManager.isPremiumUser();
//     if (isPremium) {
//       debugPrint("المستخدم مشترك. جارِ جلب الرد.");
//       // استدعاء جلب الرد مع تفعيل إعادة المحاولة مرة واحدة (retries = 1)
//       await _getAiResponse(text, retries: 1);
//       return;
//     }

//     bool canUse = await PaymentManager.canUseCustomPlot();
//     if (canUse) {
//       debugPrint("لدى المستخدم محاولات مجانية. جارِ عرض الإعلان.");
//       _showRewardedAdToGetPlot(text);
//     } else {
//       debugPrint("انتهت المحاولات المجانية. جارِ عرض نافذة الدفع.");
//       _showPaymentDialog();
//       if (mounted) { setState(() => _isLoading = false); }
//     }
//   }

//   /// دالة عرض الإعلان للحصول على الرد
//   void _showRewardedAdToGetPlot(String userPrompt) {
//     if (!mounted) return;
//     AdManager.showRewardedAd(
//       () async {
//         debugPrint("🎉 نجح الإعلان. سيتم استهلاك محاولة وجلب الرد.");
//         await PaymentManager.incrementCustomPlotUses();
//         // استدعاء جلب الرد مع تفعيل إعادة المحاولة مرة واحدة (retries = 1)
//         await _getAiResponse(userPrompt, retries: 1);
//       },
//       (String errorMessage) {
//         debugPrint("❌ فشل الإعلان. لن يتم إرسال الطلب.");
//         if (mounted) {
//           setState(() {
//             _isLoading = false;
//             _messages.add({ "sender": "AI", "title": "خطأ في الإعلان", "text": "فشل تحميل الإعلان. لا يمكن إرسال الطلب الآن. حاول مرة أخرى.\n $errorMessage", "author": "النظام", });
//           });
//         }
//       }
//     );
//   }

//   // --- دوال الدفع (لم تتغير) ---
//   void _showPaymentDialog() {
//      if (!mounted) return;
//      const String displayPrice = "15 ريال سعودي";
//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: const Text("انتهت المحاولات المجانية 😔"),
//         content: Text(
//           "لقد استهلكت محاولاتك المجانية (3) لهذا اليوم.\nللوصول الدائم وغير المحدود، يمكنك شراء الاشتراك الآن مقابل $displayPrice فقط.",
//           textDirection: TextDirection.rtl,
//         ),
//         actions: [
//           TextButton(child: const Text("لاحقًا"), onPressed: () => Navigator.pop(ctx)),
//           ElevatedButton(
//             child: Text("شراء ($displayPrice) 💳"),
//             onPressed: () { Navigator.pop(ctx); _handlePaymobPayment(); },
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
//           ),
//         ],
//       ),
//     );
//   }
//   void _handlePaymobPayment() async {
//       if (!mounted) return;
//     showDialog(context: context, builder: (context) => const Center(child: CircularProgressIndicator()), barrierDismissible: false);
//     const String amountCents = "1500";
//     const String currency = "SAR";
//     try {
//       final paymentUrl = await _paymobService.getPaymentUrl(amountCents, currency);
//       if (!mounted) return;
//       Navigator.pop(context); // إغلاق التحميل
//       if (!mounted) return;
//       Navigator.push( context, MaterialPageRoute( builder: (context) => PaymentWebViewScreen(paymentUrl: paymentUrl), ), );
//     } catch (e) {
//        if (!mounted) return;
//       Navigator.pop(context); // إغلاق التحميل
//       ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text("❌ فشل بدء الدفع: ${e.toString()}"), backgroundColor: Colors.red), );
//     }
//   }
//   // --- نهاية دوال الدفع ---

//   /// جلب الرد من Gemini مع Prompt معدل وآلية إعادة المحاولة لخطأ 503
//   Future<void> _getAiResponse(String userPrompt, {int retries = 1}) async {
//     // ✅✅ --- Prompt معدل لطلب حبكة قصيرة --- ✅✅
//     final prompt = """أنت خبير في توليد **شرارة القصة الأولية (الحبكة)** فقط. مهمتك قراءة وصف المستخدم ونوع الحبكة، ثم إنشاء رد JSON يحتوي على عنصرين:
// 1. "title": عنوان جذاب (بالعربية).
// 2. "plot": **فكرة الحبكة الأساسية فقط** في جملتين أو ثلاث جمل كحد أقصى (بالعربية). يجب أن تكون الحبكة **موجزة للغاية**، مجرد فكرة أولية مشوقة، **وليست ملخصًا للقصة**. تجنب تمامًا إضافة أي تفاصيل سردية أو تطور للشخصيات أو الأحداث.

// مثال للحبكة المطلوبة:
// { "title": "ظل في المرآة", "plot": "أم تلاحظ أن انعكاس طفلها لا يطابق حركاته. في إحدى الليالي، يختفي الطفل الحقيقي، والانعكاس يكتب على الزجاج: 'أنا الأصل'." }

// نوع الحبكة المطلوب: ${widget.plotType}.
// وصف المستخدم: "$userPrompt".
// الرد يجب أن يكون JSON فقط بهذا الشكل: { "title": "...", "plot": "..." }""";
//     // ✅✅ ------------------------------------ ✅✅

//     String aiResponseText = "لم يتم الحصول على رد.";
//     Map<String, dynamic>? parsedResponse;

//     try {
//       final Candidates? candidates = await gemini.text(prompt);
//       aiResponseText = extractGeminiTextFromCandidates(candidates);

//       // --- محاولة تحليل JSON ---
//       final startIndex = aiResponseText.indexOf('{');
//       final endIndex = aiResponseText.lastIndexOf('}');
//       if (startIndex != -1 && endIndex != -1 && endIndex > startIndex) {
//         final potentialJsonString = aiResponseText.substring(startIndex, endIndex + 1).trim();
//         try {
//           parsedResponse = jsonDecode(potentialJsonString) as Map<String, dynamic>;
//           debugPrint("✅ نجح تحليل JSON.");
//         } catch (jsonError) { debugPrint("⚠️ فشل تحليل JSON: $jsonError"); parsedResponse = null; }
//       } else { debugPrint("⚠️ لم يتم العثور على هيكل JSON في الرد."); parsedResponse = null; }
//       // --- نهاية محاولة تحليل JSON ---

//       // إضافة الرسالة الناجحة أو النص الخام
//       if (mounted) { // تحقق قبل استدعاء setState
//         setState(() {
//           if (parsedResponse != null && parsedResponse.containsKey('title') && parsedResponse.containsKey('plot')) {
//              _messages.add({ "sender": "AI", "title": parsedResponse['title']?.toString() ?? "بلا عنوان", "text": parsedResponse['plot']?.toString() ?? "لم يتم الحصول على حبكة.", "author": "عبدالله سعيد باقلاقل", });
//           } else {
//              _messages.add({ "sender": "AI", "title": "حبكة غير معنونة", "text": aiResponseText.isNotEmpty ? aiResponseText : "تم استلام رد فارغ.", "author": "عبدالله سعيد باقلاقل", });
//           }
//            _isLoading = false; // إيقاف التحميل عند النجاح
//         });
//       }

//     } catch (e) {
//       debugPrint("❌❌ خطأ في الاتصال بـ Gemini (المحاولة $retries): $e");

//       // ✅✅ --- آلية إعادة المحاولة لـ 503 --- ✅✅
//       if (e is GeminiException && e.toString().contains("status code of 503") && retries > 0) {
//         debugPrint("⏳ خطأ 503، سيتم إعادة المحاولة بعد ثانيتين...");
//         await Future.delayed(const Duration(seconds: 2));
//         if (mounted) {
//            // لا تقم بتغيير _isLoading هنا، اتركه true
//            await _getAiResponse(userPrompt, retries: retries - 1);
//         } else {
//             // إذا تم إغلاق الشاشة، لا حاجة لعمل شيء
//             debugPrint("Screen closed during retry delay.");
//         }
//         return; // الخروج من الـ catch الحالي
//       }
//       // ✅✅ -------------------------------- ✅✅

//       // --- عرض رسالة الخطأ الودية (إذا فشلت إعادة المحاولة أو كان خطأ آخر) ---
//       String userFriendlyErrorMessage;
//       if (e is GeminiException && e.toString().contains("status code of 503")) {
//           userFriendlyErrorMessage = "الخادم لا يزال مشغولًا ⏳. نرجو المحاولة مرة أخرى بعد قليل.";
//       } else if (e is GeminiException) {
//          userFriendlyErrorMessage = "حدث خطأ أثناء الاتصال بخدمة الذكاء الاصطناعي.";
//       } else {
//         userFriendlyErrorMessage = "حدث خطأ غير متوقع 😵. يرجى التحقق من اتصالك بالإنترنت والمحاولة مرة أخرى.";
//       }

//       if (mounted) { // تحقق قبل استدعاء setState
//           setState(() {
//             _messages.add({ "sender": "AI", "title": "عذرًا, حدث خطأ", "text": userFriendlyErrorMessage, "author": "النظام", });
//              _isLoading = false; // إيقاف التحميل عند عرض الخطأ النهائي
//           });
//       }
//        // --- نهاية عرض رسالة الخطأ الودية ---
//     }
//     // لا حاجة لـ finally، تم نقل _isLoading = false لداخل try و catch
//   }


//   Future<void> _saveToFavorites(String text) async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user == null) {
//         if (!mounted) return; // Check mounted before showing SnackBar
//         ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text("خطأ: لم يتم تسجيل دخول المستخدم.")),
//         );
//         return;
//     }
//     try {
//         await FirebaseFirestore.instance
//             .collection('users')
//             .doc(user.uid)
//             .collection('favorites')
//             .add({
//             'text': text,
//             'timestamp': FieldValue.serverTimestamp(),
//         });
//         if (!mounted) return; // Check mounted before showing SnackBar
//         ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text("تم حفظ الحبكة في المفضلة السحابية ✅")),
//         );
//     } catch (e) {
//         if (!mounted) return; // Check mounted before showing SnackBar
//         ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text("فشل الحفظ: $e")),
//         );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         // استخدام ألوان و elevation متناسقة مع الثيم
//         elevation: 1, // ظل خفيف
//          backgroundColor: Theme.of(context).appBarTheme.backgroundColor ?? Theme.of(context).colorScheme.surface,
//          foregroundColor: Theme.of(context).appBarTheme.foregroundColor ?? Theme.of(context).colorScheme.onSurface,
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back_ios, color: Theme.of(context).appBarTheme.foregroundColor ?? Colors.blue),
//           onPressed: () => Navigator.of(context).pop(),
//         ),
//         title: Text(
//           'إنشاء حبكة: ${widget.plotType}',
//           style: TextStyle(
//             color: Theme.of(context).appBarTheme.foregroundColor ?? Colors.black87,
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//           ),
//           textDirection: TextDirection.rtl,
//         ),
//         centerTitle: true,
//       ),
//       body: Column(
//         children: <Widget>[
//           Expanded(
//             child: ListView.builder(
//               reverse: true,
//               padding: const EdgeInsets.all(12.0),
//               itemCount: _messages.length,
//               itemBuilder: (_, index) {
//                 // Ensure index is valid before accessing _messages
//                 if (index < 0 || index >= _messages.length) {
//                     return const SizedBox.shrink(); // Return empty widget if index is out of bounds
//                  }
//                 final message = _messages[_messages.length - 1 - index];
//                 return _buildMessageBubble(message);
//               },
//             ),
//           ),
//           if (_isLoading)
//              const Padding(
//                padding: EdgeInsets.symmetric(vertical: 0.0),
//                child: LinearProgressIndicator(),
//              ),
//           _buildTextComposer(),
//         ],
//       ),
//     );
//   }

//   Widget _buildMessageBubble(Map<String, String?> message) {
//     final bool isUser = message["sender"] == "User";
//     final bool isAi = message["sender"] == "AI";
//     final bool isDark = Theme.of(context).brightness == Brightness.dark;
//     // استخدام ألوان متناسقة مع الثيم
//     final Color userBubbleColor = isDark ? Colors.blueGrey[700]! : Theme.of(context).colorScheme.primaryContainer;
//     final Color aiBubbleColor = isDark ? Colors.grey[800]! : Theme.of(context).colorScheme.secondaryContainer;
//      final Color userTextColor = isDark ? Colors.white : Theme.of(context).colorScheme.onPrimaryContainer;
//      final Color aiTextColor = isDark ? Colors.white : Theme.of(context).colorScheme.onSecondaryContainer;

//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 6.0),
//       child: Row(
//         mainAxisAlignment:
//             isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
//         crossAxisAlignment: CrossAxisAlignment.end,
//         children: <Widget>[
//           Flexible(
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
//               decoration: BoxDecoration(
//                 color: isUser ? userBubbleColor : aiBubbleColor,
//                 borderRadius: BorderRadius.circular(18),
//                  boxShadow: [ // ظل خفيف للفقاعات
//                      BoxShadow(
//                        color: Colors.black.withOpacity(0.05),
//                        blurRadius: 3,
//                        offset: const Offset(1, 1),
//                      ),
//                    ],
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.end,
//                 children: [
//                   if (isAi && message["title"] != null && message["title"]!.isNotEmpty)
//                     Padding(
//                       padding: const EdgeInsets.only(bottom: 6.0),
//                       child: Text(
//                         message["title"]!,
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 16,
//                           color: aiTextColor, // لون النص
//                         ),
//                         textAlign: TextAlign.right,
//                         textDirection: TextDirection.rtl,
//                       ),
//                     ),
//                   Text(
//                     message["text"] ?? "",
//                     style: TextStyle(fontSize: 15, height: 1.4, color: isUser ? userTextColor : aiTextColor), // لون النص
//                     textAlign: TextAlign.right,
//                     textDirection: TextDirection.rtl,
//                   ),
//                   if (isAi && message["author"] != null && message["author"] != "النظام") // لا تعرض الجزء السفلي لرسائل النظام
//                      Padding(
//                        padding: const EdgeInsets.only(top: 8.0),
//                        child: Row(
//                          mainAxisAlignment: MainAxisAlignment.end, // تأكد من المحاذاة لليمين
//                          mainAxisSize: MainAxisSize.min, // اجعل الصف يأخذ أقل مساحة ممكنة
//                          children: [
//                             // زر الحفظ
//                             if (message["text"] != null &&
//                                 message["text"]!.isNotEmpty &&
//                                 !message["text"]!.startsWith("فشل تحميل") &&
//                                 message["text"] != "لم يتم الحصول على حبكة." &&
//                                 message["title"] != "عذرًا, حدث خطأ") // لا تظهر الحفظ لرسائل الخطأ
//                              IconButton(
//                                visualDensity: VisualDensity.compact, // تقليل المساحة حول الأيقونة
//                                padding: const EdgeInsets.only(left: 8), // مسافة يسار الأيقونة
//                                constraints: const BoxConstraints(),
//                                icon: Icon(Icons.favorite_border,
//                                    color: isDark ? Colors.pinkAccent : Colors.red, size: 18),
//                                onPressed: () => _saveToFavorites(message["text"]!),
//                                tooltip: "حفظ في المفضلة",
//                              ),
//                             // نص المؤلف (إذا لم يكن زر الحفظ موجودًا، هذا سيأخذ المساحة)
//                             Flexible( // استخدم Flexible ليأخذ المساحة المتبقية
//                                child: Text(
//                                  "مؤلف الحبكة: ${message["author"]!}",
//                                  style: TextStyle(
//                                    fontSize: 11,
//                                    color: isDark? Colors.grey[400] : Colors.grey[700],
//                                    fontStyle: FontStyle.italic,
//                                  ),
//                                  textAlign: TextAlign.right,
//                                  textDirection: TextDirection.rtl,
//                                  overflow: TextOverflow.ellipsis, // منع النص الطويل من التجاوز
//                                ),
//                             ),
//                          ],
//                        ),
//                      ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTextComposer() {
//     final bool isDark = Theme.of(context).brightness == Brightness.dark;
//     final Color textFieldFillColor = isDark ? Colors.grey[850]! : Colors.grey[100]!;
//     final Color sendButtonColor = Theme.of(context).colorScheme.primary; // استخدام لون الثيم الأساسي

//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
//       decoration: BoxDecoration(
//         color: Theme.of(context).cardColor,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             spreadRadius: 0,
//             blurRadius: 10,
//             offset: const Offset(0, -2),
//           ),
//         ],
//       ),
//       child: SafeArea(
//         child: Row(
//           children: <Widget>[
//             Expanded(
//               child: TextField(
//                 enabled: !_isLoading,
//                 controller: _controller,
//                 onSubmitted: (_) => _sendMessage(),
//                 decoration: InputDecoration(
//                   hintText: "صف الحبكة التي تريدها...",
//                   hintTextDirection: TextDirection.rtl,
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(25.0),
//                     borderSide: BorderSide.none,
//                   ),
//                   filled: true,
//                   fillColor: textFieldFillColor,
//                   contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//                 ),
//                 textAlign: TextAlign.right,
//                 textDirection: TextDirection.rtl,
//                 maxLines: null, // يسمح بأكثر من سطر
//                 minLines: 1,    // يبدأ بسطر واحد
//                 keyboardType: TextInputType.multiline,
//               ),
//             ),
//             const SizedBox(width: 8),
//             Container(
//               decoration: BoxDecoration(
//                 color: _isLoading ? Colors.grey : sendButtonColor,
//                 shape: BoxShape.circle,
//               ),
//               margin: const EdgeInsets.symmetric(horizontal: 4.0),
//               child: IconButton(
//                 icon: const Icon(Icons.send, color: Colors.white),
//                 onPressed: _isLoading ? null : _sendMessage,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }




// [ملف: chat_screen.dart] - معدل لإخفاء التحميل وتغيير الألوان

import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:plot_app/gemini_utils.dart';
import 'package:plot_app/ad_manager.dart';
import 'package:plot_app/paymob/payment_manager.dart';
import 'package:plot_app/paymob/paymob_service.dart';
import 'package:plot_app/paymob/payment_webview_screen.dart';

class ChatScreen extends StatefulWidget {
  final String plotType;

  const ChatScreen({super.key, required this.plotType});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  late final List<Map<String, String?>> _messages;
  final gemini = Gemini.instance;
  bool _isLoading = false;
  final PaymobService _paymobService = PaymobService();

  @override
  void initState() {
    super.initState();
    _messages = [
      {
        "sender": "AI",
        "title": null,
        "text":
            "أهلاً بك في قسم حبكات الـ ${widget.plotType}! لديك 3 محاولات مجانية اليوم لإنشاء حبكات مخصصة. للحصول على استخدام غير محدود، يمكنك الاشتراك.",
        "author": null,
      }
    ];
  }

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isLoading) return;

    setState(() {
      _messages.add({ "sender": "User", "text": text, "title": null, "author": null, });
      _controller.clear();
      _isLoading = true; // لا يزال مهمًا لتعطيل الزر والحقل
    });

    bool isPremium = await PaymentManager.isPremiumUser();
    if (isPremium) {
      debugPrint("المستخدم مشترك. جارِ جلب الرد.");
      await _getAiResponse(text, retries: 1);
      return;
    }

    bool canUse = await PaymentManager.canUseCustomPlot();
    if (canUse) {
      debugPrint("لدى المستخدم محاولات مجانية. جارِ عرض الإعلان.");
      _showRewardedAdToGetPlot(text);
    } else {
      debugPrint("انتهت المحاولات المجانية. جارِ عرض نافذة الدفع.");
      _showPaymentDialog();
      if (mounted) { setState(() => _isLoading = false); }
    }
  }

  void _showRewardedAdToGetPlot(String userPrompt) {
    if (!mounted) return;
    AdManager.showRewardedAd(
      () async {
        debugPrint("🎉 نجح الإعلان. سيتم استهلاك محاولة وجلب الرد.");
        await PaymentManager.incrementCustomPlotUses();
        await _getAiResponse(userPrompt, retries: 1);
      },
      (String errorMessage) {
        debugPrint("❌ فشل الإعلان. لن يتم إرسال الطلب.");
        if (mounted) {
          setState(() {
            _isLoading = false;
            _messages.add({ "sender": "AI", "title": "خطأ في الإعلان", "text": "فشل تحميل الإعلان. لا يمكن إرسال الطلب الآن. حاول مرة أخرى.\n $errorMessage", "author": "النظام", });
          });
        }
      }
    );
  }

  // --- دوال الدفع (لم تتغير) ---
  void _showPaymentDialog() { /* ... كما هي ... */
     if (!mounted) return;
     const String displayPrice = "15 ريال سعودي";
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("انتهت المحاولات المجانية 😔"),
        content: Text(
          "لقد استهلكت محاولاتك المجانية (3) لهذا اليوم.\nللوصول الدائم وغير المحدود، يمكنك شراء الاشتراك الآن مقابل $displayPrice فقط.",
          textDirection: TextDirection.rtl,
        ),
        actions: [
          TextButton(child: const Text("لاحقًا"), onPressed: () => Navigator.pop(ctx)),
          ElevatedButton(
            child: Text("شراء ($displayPrice) 💳"),
            onPressed: () { Navigator.pop(ctx); _handlePaymobPayment(); },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
          ),
        ],
      ),
    );
  }
  void _handlePaymobPayment() async { /* ... كما هي ... */
      if (!mounted) return;
    showDialog(context: context, builder: (context) => const Center(child: CircularProgressIndicator()), barrierDismissible: false);
    const String amountCents = "1500";
    const String currency = "SAR";
    try {
      final paymentUrl = await _paymobService.getPaymentUrl(amountCents, currency);
      if (!mounted) return;
      Navigator.pop(context); // إغلاق التحميل
      if (!mounted) return;
      Navigator.push( context, MaterialPageRoute( builder: (context) => PaymentWebViewScreen(paymentUrl: paymentUrl), ), );
    } catch (e) {
       if (!mounted) return;
      Navigator.pop(context); // إغلاق التحميل
      ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text("❌ فشل بدء الدفع: ${e.toString()}"), backgroundColor: Colors.red), );
    }
  }
  // --- نهاية دوال الدفع ---


  /// جلب الرد من Gemini مع Prompt معدل وآلية إعادة المحاولة لخطأ 503
  Future<void> _getAiResponse(String userPrompt, {int retries = 1}) async {
    final prompt = """أنت خبير في توليد **شرارة القصة الأولية (الحبكة)** فقط. مهمتك قراءة وصف المستخدم ونوع الحبكة، ثم إنشاء رد JSON يحتوي على عنصرين:
1. "title": عنوان جذاب (بالعربية).
2. "plot": **فكرة الحبكة الأساسية فقط** في جملتين أو ثلاث جمل كحد أقصى (بالعربية). يجب أن تكون الحبكة **موجزة للغاية**، مجرد فكرة أولية مشوقة، **وليست ملخصًا للقصة**. تجنب تمامًا إضافة أي تفاصيل سردية أو تطور للشخصيات أو الأحداث.

مثال للحبكة المطلوبة:
{ "title": "ظل في المرآة", "plot": "أم تلاحظ أن انعكاس طفلها لا يطابق حركاته. في إحدى الليالي، يختفي الطفل الحقيقي، والانعكاس يكتب على الزجاج: 'أنا الأصل'." }

نوع الحبكة المطلوب: ${widget.plotType}.
وصف المستخدم: "$userPrompt".
الرد يجب أن يكون JSON فقط بهذا الشكل: { "title": "...", "plot": "..." }""";

    String aiResponseText = "لم يتم الحصول على رد.";
    Map<String, dynamic>? parsedResponse;

    try {
      final Candidates? candidates = await gemini.text(prompt);
      aiResponseText = extractGeminiTextFromCandidates(candidates);

      // --- محاولة تحليل JSON ---
      final startIndex = aiResponseText.indexOf('{');
      final endIndex = aiResponseText.lastIndexOf('}');
      if (startIndex != -1 && endIndex != -1 && endIndex > startIndex) {
        final potentialJsonString = aiResponseText.substring(startIndex, endIndex + 1).trim();
        try {
          parsedResponse = jsonDecode(potentialJsonString) as Map<String, dynamic>;
          debugPrint("✅ نجح تحليل JSON.");
        } catch (jsonError) { debugPrint("⚠️ فشل تحليل JSON: $jsonError"); parsedResponse = null; }
      } else { debugPrint("⚠️ لم يتم العثور على هيكل JSON في الرد."); parsedResponse = null; }
      // --- نهاية محاولة تحليل JSON ---

      if (mounted) {
        setState(() {
          if (parsedResponse != null && parsedResponse.containsKey('title') && parsedResponse.containsKey('plot')) {
             _messages.add({ "sender": "AI", "title": parsedResponse['title']?.toString() ?? "بلا عنوان", "text": parsedResponse['plot']?.toString() ?? "لم يتم الحصول على حبكة.", "author": "عبدالله سعيد باقلاقل", });
          } else {
             _messages.add({ "sender": "AI", "title": "حبكة غير معنونة", "text": aiResponseText.isNotEmpty ? aiResponseText : "تم استلام رد فارغ.", "author": "عبدالله سعيد باقلاقل", });
          }
           _isLoading = false;
        });
      }

    } catch (e) {
      debugPrint("❌❌ خطأ في الاتصال بـ Gemini (المحاولة $retries): $e");

      // --- آلية إعادة المحاولة لـ 503 ---
      if (e is GeminiException && e.toString().contains("status code of 503") && retries > 0) {
        debugPrint("⏳ خطأ 503، سيتم إعادة المحاولة بعد ثانيتين...");
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
           await _getAiResponse(userPrompt, retries: retries - 1);
        } else { debugPrint("Screen closed during retry delay."); }
        return;
      }
      // --- نهاية آلية إعادة المحاولة ---

      // --- عرض رسالة الخطأ الودية ---
      String userFriendlyErrorMessage;
      if (e is GeminiException && e.toString().contains("status code of 503")) {
          userFriendlyErrorMessage = "الخادم لا يزال مشغولًا ⏳. نرجو المحاولة مرة أخرى بعد قليل.";
      } else if (e is GeminiException) {
         userFriendlyErrorMessage = "حدث خطأ أثناء الاتصال بخدمة الذكاء الاصطناعي.";
      } else {
        userFriendlyErrorMessage = "حدث خطأ غير متوقع 😵. يرجى التحقق من اتصالك بالإنترنت والمحاولة مرة أخرى.";
      }
      if (mounted) {
          setState(() {
            _messages.add({ "sender": "AI", "title": "عذرًا, حدث خطأ", "text": userFriendlyErrorMessage, "author": "النظام", });
             _isLoading = false;
          });
      }
       // --- نهاية عرض رسالة الخطأ الودية ---
    }
  }

  Future<void> _saveToFavorites(String text) async { /* ... كما هي ... */
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("خطأ: لم يتم تسجيل دخول المستخدم.")),
        );
        return;
    }
    try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('favorites')
            .add({
            'text': text,
            'timestamp': FieldValue.serverTimestamp(),
        });
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("تم حفظ الحبكة في المفضلة السحابية ✅")),
        );
    } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("فشل الحفظ: $e")),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    // تحديد لون AppBar بناءً على الثيم
    final appBarColor = Theme.of(context).appBarTheme.backgroundColor ?? Theme.of(context).colorScheme.primary;
    final appBarForegroundColor = Theme.of(context).appBarTheme.foregroundColor ?? Theme.of(context).colorScheme.onPrimary;

    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        backgroundColor: appBarColor,
        foregroundColor: appBarForegroundColor,
        leading: IconButton(
          // استخدم لون foregroundColor للأيقونة
          icon: Icon(Icons.arrow_back_ios, color: appBarForegroundColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'إنشاء حبكة: ${widget.plotType}',
          // استخدم لون foregroundColor للنص
          style: TextStyle( color: appBarForegroundColor, fontSize: 20, fontWeight: FontWeight.bold),
          textDirection: TextDirection.rtl,
        ),
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              reverse: true,
              padding: const EdgeInsets.all(12.0),
              itemCount: _messages.length,
              itemBuilder: (_, index) {
                 if (index < 0 || index >= _messages.length) return const SizedBox.shrink();
                final message = _messages[_messages.length - 1 - index];
                return _buildMessageBubble(message);
              },
            ),
          ),
          // ✅✅ --- تمت إزالة مؤشر التحميل من هنا --- ✅✅
          // if (_isLoading)
          //    const Padding(
          //      padding: EdgeInsets.symmetric(vertical: 0.0),
          //      child: LinearProgressIndicator(),
          //    ),
          _buildTextComposer(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, String?> message) {
    final bool isUser = message["sender"] == "User";
    final bool isAi = message["sender"] == "AI";
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    // ✅✅ --- بداية تعديل الألوان --- ✅✅
    // استخدم درجات من اللون الأزرق
    final Color userBubbleColor = isDark ? Colors.blue[900]! : Colors.blue[300]!; // أزرق أغمق للمستخدم
    final Color aiBubbleColor = isDark ? Colors.blueGrey[800]! : Colors.blue[100]!; // أزرق فاتح للـ AI
    // تحديد لون النص لضمان الوضوح
    final Color userTextColor = isDark ? Colors.white : Colors.black87; // نص فاتح على خلفية غامقة والعكس
    final Color aiTextColor = isDark ? Colors.white70 : Colors.black87; // نص فاتح على خلفية غامقة والعكس
    // ✅✅ --- نهاية تعديل الألوان --- ✅✅

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end, // لمحاذاة الفقاعات بشكل أفضل
        children: <Widget>[
          Flexible( // لمنع الفقاعات من تجاوز عرض الشاشة
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
              decoration: BoxDecoration(
                color: isUser ? userBubbleColor : aiBubbleColor, // تطبيق الألوان الجديدة
                borderRadius: BorderRadius.only( // زوايا دائرية مختلفة قليلًا
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                  bottomLeft: isUser ? Radius.circular(18) : Radius.circular(4), // زاوية حادة قليلاً للـ AI
                  bottomRight: isUser ? Radius.circular(4) : Radius.circular(18), // زاوية حادة قليلاً للمستخدم
                ),
                 boxShadow: [
                     BoxShadow(
                       color: Colors.black.withOpacity(0.08),
                       blurRadius: 4,
                       offset: const Offset(1, 1),
                     ),
                   ],
              ),
              child: Column(
                crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start, // محاذاة النص داخل الفقاعة
                children: [
                  if (isAi && message["title"] != null && message["title"]!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6.0),
                      child: Text(
                        message["title"]!,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: aiTextColor, // تطبيق لون النص
                        ),
                        textAlign: TextAlign.right, // دائمًا لليمين للعناوين
                        textDirection: TextDirection.rtl,
                      ),
                    ),
                  Text(
                    message["text"] ?? "",
                    style: TextStyle(fontSize: 15, height: 1.4, color: isUser ? userTextColor : aiTextColor), // تطبيق لون النص
                    textAlign: TextAlign.right, // دائمًا لليمين للنص الأساسي
                    textDirection: TextDirection.rtl,
                  ),
                   // --- تعديل لعرض زر الحفظ والمؤلف بشكل أفضل ---
                  if (isAi && message["author"] != null && message["author"] != "النظام")
                     Padding(
                       padding: const EdgeInsets.only(top: 8.0),
                       child: Row(
                         mainAxisAlignment: MainAxisAlignment.end, // تأكد من المحاذاة لليمين
                         mainAxisSize: MainAxisSize.min,
                         children: [
                            // زر الحفظ
                            if (message["text"] != null && message["text"]!.isNotEmpty && message["title"] != "عذرًا, حدث خطأ")
                             SizedBox( // أضف حجمًا للزر لسهولة الضغط
                               height: 24, width: 24,
                               child: IconButton(
                                 visualDensity: VisualDensity.compact,
                                 padding: EdgeInsets.zero, // بدون padding داخلي
                                 icon: Icon(Icons.favorite_border,
                                     color: isDark ? Colors.pinkAccent.shade100 : Colors.red.shade400, size: 18),
                                 onPressed: () => _saveToFavorites(message["text"]!),
                                 tooltip: "حفظ في المفضلة",
                               ),
                             ),
                           if (message["text"] != null && message["text"]!.isNotEmpty && message["title"] != "عذرًا, حدث خطأ")
                             const SizedBox(width: 8), // مسافة بين الزر والمؤلف

                           // نص المؤلف (أعطه مساحة مرنة)
                            Flexible(
                              child: Text(
                                "مؤلف الحبكة: ${message["author"]!}",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark? Colors.grey[400] : Colors.grey[700],
                                  fontStyle: FontStyle.italic,
                                ),
                                textAlign: TextAlign.right,
                                textDirection: TextDirection.rtl,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                         ],
                       ),
                     ),
                  // --- نهاية التعديل ---
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextComposer() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textFieldFillColor = isDark ? Colors.grey[850]! : Colors.grey[100]!;
    // ✅✅ --- تحديد لون الزر الأزرق المطلوب --- ✅✅
    const Color sendButtonColor = Color(0xFF1E88E5); // <-- اللون الأزرق المحدد

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor, // لون خلفية شريط الإدخال
        boxShadow: [ BoxShadow( color: Colors.black.withOpacity(0.05), spreadRadius: 0, blurRadius: 10, offset: const Offset(0, -2), ), ],
      ),
      child: SafeArea( // لضمان عدم التداخل مع عناصر النظام في الأسفل
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end, // لمحاذاة الحقل والزر رأسيًا
          children: <Widget>[
            Expanded(
              child: TextField(
                enabled: !_isLoading,
                controller: _controller,
                onSubmitted: (_) => _sendMessage(),
                decoration: InputDecoration(
                  hintText: "صف الحبكة التي تريدها...",
                  hintTextDirection: TextDirection.rtl,
                  border: OutlineInputBorder( borderRadius: BorderRadius.circular(25.0), borderSide: BorderSide.none,),
                  filled: true,
                  fillColor: textFieldFillColor,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), // تعديل الـ padding قليلاً
                ),
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
                minLines: 1, // السماح بسطر واحد في البداية
                maxLines: 5, // السماح بالتمدد حتى 5 أسطر
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.send, // تغيير زر الإدخال إلى "إرسال"
                onEditingComplete: _sendMessage, // الإرسال عند الضغط على زر الإدخال
              ),
            ),
            const SizedBox(width: 8),
            Container(
              margin: const EdgeInsets.only(bottom: 2),
              decoration: BoxDecoration(
                // ✅✅ --- تطبيق اللون الأزرق المحدد --- ✅✅
                color: _isLoading ? Colors.grey : sendButtonColor,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white),
                onPressed: _isLoading ? null : _sendMessage,
                tooltip: 'إرسال',
              ),
            ),
          ],
        ),
      ),
    );
  }
}