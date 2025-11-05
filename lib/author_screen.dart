// // import 'dart:math'; // لاستخدام Random
// // import 'package:flutter/material.dart';
// // import 'package:url_launcher/url_launcher.dart';
// // import 'quotes.dart'; // ✅ استيراد ملف الاقتباسات الجديد

// // class AuthorScreen extends StatefulWidget {
// //   const AuthorScreen({super.key});

// //   @override
// //   State<AuthorScreen> createState() => _AuthorScreenState();
// // }

// // class _AuthorScreenState extends State<AuthorScreen> {
// //   String _randomQuote = ""; // متغير لحفظ الاقتباس العشوائي

// //   @override
// //   void initState() {
// //     super.initState();
// //     _loadRandomQuote(); // تحميل اقتباس عشوائي عند فتح الصفحة
// //   }

// //   // دالة لتحميل وعرض اقتباس عشوائي
// //   void _loadRandomQuote() {
// //     setState(() {
// //       _randomQuote = getRandomQuote(); // استدعاء الدالة من quotes.dart
// //     });
// //   }

// //   // دالة مساعدة لفتح الروابط
// //   Future<void> _launchURL(String url) async {
// //     final Uri uri = Uri.parse(url);
// //     if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
// //       debugPrint('Could not launch $url');
// //       // يمكنك إظهار SnackBar هنا
// //       if (mounted) {
// //          ScaffoldMessenger.of(context).showSnackBar(
// //            SnackBar(content: Text('لم يتمكن من فتح الرابط: $url')),
// //          );
// //       }
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     // تحديد الألوان بناءً على الثيم
// //     final bool isDark = Theme.of(context).brightness == Brightness.dark;
// //     final Color cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
// //     final Color headerBackgroundColor = isDark ? Colors.grey[850]! : const Color(0xFFFFF3E0); // لون ذهبي فاتح للخلفية
// //     final Color headerTextColor = isDark ? Colors.white70 : Colors.black87;
// //     const Color goldColor = Color(0xFFD4AF37); // لون ذهبي
// //     const Color turquoiseColor = Color(0xFF40E0D0); // لون تركواز

// //     return Scaffold(
// //       // استخدام لون خلفية أبيض أو أسود ناعم
// //       backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
// //       body: SingleChildScrollView( // السماح بالتمرير إذا كان المحتوى أطول من الشاشة
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.stretch,
// //           children: [
// //             // --- 1️⃣ العنوان العلوي ---
// //             Container(
// //               padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 16.0),
// //               color: headerBackgroundColor,
// //               child: SafeArea( // لإضافة مسافة من الأعلى
// //                 bottom: false, // لا نريد مسافة من الأسفل هنا
// //                 child: Column(
// //                   crossAxisAlignment: CrossAxisAlignment.end, // لليمين
// //                   children: [
// //                     Text(
// //                       '✍ قلم الكاتب',
// //                       style: TextStyle(
// //                         fontSize: 28,
// //                         fontWeight: FontWeight.bold,
// //                         color: headerTextColor,
// //                       ),
// //                       textAlign: TextAlign.right,
// //                       textDirection: TextDirection.rtl,
// //                     ),
// //                     const SizedBox(height: 8),
// //                     Text(
// //                       'مساحة من الحبر والروح، أشاركك فيها رحلتي مع الكتابة… لتبدأ رحلتك أنت.',
// //                       style: TextStyle(
// //                         fontSize: 16,
// //                         color: headerTextColor.withOpacity(0.8),
// //                         height: 1.4,
// //                       ),
// //                       textAlign: TextAlign.right,
// //                       textDirection: TextDirection.rtl,
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //             ),

// //             // إضافة مسافة قبل البطاقات
// //             const SizedBox(height: 20),

// //             // --- 2️⃣ البطاقة الأولى – عن الكاتب ---
// //             _buildInfoCard(
// //               context: context,
// //               cardColor: cardColor,
// //               title: '🧭 من هو عبدالله سعيد باقلاقل؟',
// //               titleColor: goldColor, // لون العنوان ذهبي
// //               icon: Icons.person_outline, // أيقونة مناسبة
// //               children: [
// //                 const Text(
// //                   'كاتب روائي وسيناريست ومدرب كتابة.\nأؤمن أن الكلمة قادرة على تغيير الوعي، وأن كل سطرٍ يُكتب بصدق يمكن أن يغيّر حياة إنسان.',
// //                   style: TextStyle(fontSize: 16, height: 1.5),
// //                   textDirection: TextDirection.rtl,
// //                 ),
// //                 const SizedBox(height: 10),
// //                 const Text(
// //                   'بدأت رحلتي منذ الطفولة، حين كانت الحكايات عالمي الأول. واليوم، أشارك شغفي مع الكتّاب عبر كتبي ومشاريعي ومجتمع رتوش.',
// //                   style: TextStyle(fontSize: 16, height: 1.5),
// //                   textDirection: TextDirection.rtl,
// //                 ),
// //                  const SizedBox(height: 10),
// //                 const Text(
// //                   'هنا… نكتب لأن الكتابة ليست خيارًا، بل نداء لا يمكن تجاهله.',
// //                    style: TextStyle(fontSize: 16, height: 1.5, fontStyle: FontStyle.italic),
// //                   textDirection: TextDirection.rtl,
// //                 ),
// //                 const SizedBox(height: 15),
// //                  // زر الفيديو الوثائقي
// //                  Align(
// //                    alignment: Alignment.centerRight,
// //                    child: TextButton.icon(
// //                       icon: const Icon(Icons.play_circle_outline, color: Colors.redAccent),
// //                       label: const Text('شاهد فيديو وثائقي عن سيرتي', style: TextStyle(color: Colors.redAccent)),
// //                       onPressed: () => _launchURL('https://youtu.be/DLiw-hpMT5k?si=bCAhBL71-uPBSUAK'),
// //                     ),
// //                  ),
// //               ],
// //             ),

// //             // --- 3️⃣ البطاقة الثانية – أعمال الكاتب ---
// //             _buildInfoCard(
// //               context: context,
// //               cardColor: cardColor,
// //               title: '📘 أعمالي وكتبي',
// //               titleColor: turquoiseColor, // لون العنوان تركواز
// //               icon: Icons.menu_book,
// //               children: [
// //                 const Text(
// //                   '✍ من الكتب التي شكّلت رحلتي في عالم الكتابة:',
// //                   style: TextStyle(fontSize: 16, height: 1.5, fontWeight: FontWeight.w500),
// //                   textDirection: TextDirection.rtl,
// //                 ),
// //                 const SizedBox(height: 8),
// //                 const Text(' • كيف تكسب من كتاباتك 💰', style: TextStyle(fontSize: 16), textDirection: TextDirection.rtl),
// //                 const Text(' • قصتي مع التأليف 🎬', style: TextStyle(fontSize: 16), textDirection: TextDirection.rtl),
// //                 const Text(' • دليل وصف الشخصيات الروائية 🎭', style: TextStyle(fontSize: 16), textDirection: TextDirection.rtl),
// //                 const SizedBox(height: 10),
// //                 const Text(
// //                   'كل كتاب منها كتبته لأساعد الكتّاب المستقلين على تحويل موهبتهم إلى مهنة، وشغفهم إلى مصدر دخل.',
// //                   style: TextStyle(fontSize: 16, height: 1.5),
// //                   textDirection: TextDirection.rtl,
// //                 ),
// //                 const SizedBox(height: 15),
// //                 // زر اكتشاف الكتب
// //                  Align(
// //                    alignment: Alignment.centerRight,
// //                    child: ElevatedButton.icon(
// //                       icon: const Icon(Icons.storefront, color: Colors.black87),
// //                       label: const Text('اكتشف كتبي كاملة', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
// //                       onPressed: () => _launchURL('https://galagel.com/'), // ⬅️ رابط موقعك
// //                       style: ElevatedButton.styleFrom(
// //                         backgroundColor: goldColor, // لون الزر ذهبي
// //                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
// //                       ),
// //                     ),
// //                  ),
// //               ],
// //             ),

// //             // --- 4️⃣ البطاقة الثالثة – مشاريعي ومجتمعي ---
// //             _buildInfoCard(
// //               context: context,
// //               cardColor: cardColor,
// //               title: '🌍 مجمع رتوش للكتّاب المستقلين',
// //               titleColor: Colors.green, // لون العنوان أخضر
// //               icon: Icons.groups_outlined,
// //               children: [
// //                  const Text(
// //                   'رتوش ليست مجرد عضوية… إنها مجتمع رقمي للكتّاب المستقلين.\nنتعلم، نكتب، ونتعاون لبناء مستقبل مهني من الحروف.',
// //                   style: TextStyle(fontSize: 16, height: 1.5),
// //                   textDirection: TextDirection.rtl,
// //                 ),
// //                 const SizedBox(height: 10),
// //                  const Text(
// //                   'ستجد في رتوش ورش عمل، كتب رقمية، وأدوات تساعدك على تطوير مهارتك خطوة بخطوة.',
// //                   style: TextStyle(fontSize: 16, height: 1.5),
// //                   textDirection: TextDirection.rtl,
// //                 ),
// //                 const SizedBox(height: 15),
// //                  // زر الانضمام لرتوش
// //                  Align(
// //                    alignment: Alignment.centerRight,
// //                    child: ElevatedButton.icon(
// //                      icon: const Icon(Icons.language, color: Colors.white),
// //                      label: const Text('انضم الآن إلى مجتمع رتوش', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
// //                      onPressed: () => _launchURL('https://galagel.com/admission/'), // ⬅️ رابط رتوش
// //                      style: ElevatedButton.styleFrom(
// //                        backgroundColor: turquoiseColor, // لون الزر تركواز
// //                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
// //                      ),
// //                    ),
// //                  ),
// //               ],
// //             ),

// //             // --- 5️⃣ البطاقة الرابعة – اقتباس اليوم ---
// //              _buildInfoCard(
// //               context: context,
// //               cardColor: cardColor,
// //               title: '💫 اقتباس اليوم',
// //               titleColor: Colors.purpleAccent, // لون مختلف للاقتباس
// //               icon: Icons.format_quote,
// //               children: [
// //                 Text(
// //                   '💬 $_randomQuote', // عرض الاقتباس العشوائي
// //                   style: const TextStyle(fontSize: 17, height: 1.6, fontStyle: FontStyle.italic),
// //                   textAlign: TextAlign.center, // توسيط الاقتباس
// //                   // textDirection: TextDirection.rtl, // النص عربي بالفعل
// //                 ),
// //                  const SizedBox(height: 10),
// //                  const Text(
// //                    '(من تأملات الكاتب عبدالله سعيد باقلاقل)',
// //                    style: TextStyle(fontSize: 12, color: Colors.grey),
// //                    textAlign: TextAlign.center,
// //                  ),
// //                  // زر لتحديث الاقتباس (اختياري)
// //                  Align(
// //                    alignment: Alignment.centerLeft,
// //                    child: IconButton(
// //                      icon: const Icon(Icons.refresh, color: Colors.grey),
// //                      tooltip: 'اقتباس جديد',
// //                      onPressed: _loadRandomQuote, // استدعاء الدالة لتغيير الاقتباس
// //                    ),
// //                  ),
// //               ],
// //             ),

// //             // --- 6️⃣ الخاتمة الأدبية ---
// //             Padding(
// //               padding: const EdgeInsets.symmetric(vertical: 30.0),
// //               child: Text(
// //                 '🖋 في كل مرة تكتب، هناك عالم ينتظرك لتخلقه 🖋\n— عبدالله سعيد باقلاقل',
// //                 textAlign: TextAlign.center,
// //                 style: TextStyle(
// //                   fontSize: 14,
// //                   fontStyle: FontStyle.italic,
// //                   color: Colors.grey[600],
// //                 ),
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   // دالة مساعدة لبناء البطاقات بشكل موحد
// //   Widget _buildInfoCard({
// //     required BuildContext context,
// //     required Color cardColor,
// //     required String title,
// //     required Color titleColor,
// //     required IconData icon,
// //     required List<Widget> children,
// //   }) {
// //     return Padding(
// //       padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
// //       child: Card(
// //         color: cardColor,
// //         elevation: 3, // ظل أخف قليلاً
// //         shadowColor: Colors.black.withOpacity(0.3),
// //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
// //         child: Padding(
// //           padding: const EdgeInsets.all(16.0),
// //           child: Column(
// //             crossAxisAlignment: CrossAxisAlignment.end, // محاذاة كل المحتوى لليمين
// //             children: [
// //               Row(
// //                 mainAxisAlignment: MainAxisAlignment.end, // أيقونة وعنوان لليمين
// //                 children: [
// //                   Text(
// //                     title,
// //                     style: TextStyle(
// //                       fontSize: 18,
// //                       fontWeight: FontWeight.bold,
// //                       color: titleColor,
// //                     ),
// //                     textDirection: TextDirection.rtl,
// //                   ),
// //                   const SizedBox(width: 8),
// //                   Icon(icon, color: titleColor), // أيقونة بنفس لون العنوان
// //                 ],
// //               ),
// //               const Divider(height: 20, thickness: 0.5), // خط فاصل أنعم
// //               ...children, // إضافة المحتوى الخاص بالبطاقة
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }





// import 'dart:math';
// import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'quotes.dart'; // ✅ ملف الاقتباسات

// class AuthorScreen extends StatefulWidget {
//   const AuthorScreen({super.key});

//   @override
//   State<AuthorScreen> createState() => _AuthorScreenState();
// }

// class _AuthorScreenState extends State<AuthorScreen> {
//   String _randomQuote = "";

//   @override
//   void initState() {
//     super.initState();
//     _loadRandomQuote();
//   }

//   void _loadRandomQuote() {
//     setState(() {
//       _randomQuote = getRandomQuote();
//     });
//   }

//   Future<void> _launchURL(String url) async {
//     final Uri uri = Uri.parse(url);
//     if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('لم يتمكن من فتح الرابط: $url')),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final bool isDark = Theme.of(context).brightness == Brightness.dark;
//     final Color cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
//     final Color headerBackgroundColor =
//         isDark ? Colors.grey[900]! : const Color(0xFFFFF3E0);
//     final Color headerTextColor = isDark ? Colors.white70 : Colors.black87;
//     const Color goldColor = Color(0xFFD4AF37);
//     const Color turquoiseColor = Color(0xFF40E0D0);

//     return Scaffold(
//       backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
//       body: SafeArea(
//         child: LayoutBuilder(
//           builder: (context, constraints) {
//             return SingleChildScrollView(
//               padding: const EdgeInsets.only(bottom: 30),
//               child: ConstrainedBox(
//                 constraints: BoxConstraints(minHeight: constraints.maxHeight),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   children: [
//                     // 1️⃣ العنوان العلوي
//                     Container(
//                       width: double.infinity,
//                       padding: const EdgeInsets.symmetric(
//                           vertical: 30.0, horizontal: 16.0),
//                       color: headerBackgroundColor,
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.end,
//                         children: [
//                           Text(
//                             '✍ قلم الكاتب',
//                             style: TextStyle(
//                               fontSize: 28,
//                               fontWeight: FontWeight.bold,
//                               color: headerTextColor,
//                             ),
//                             textAlign: TextAlign.right,
//                             textDirection: TextDirection.rtl,
//                           ),
//                           const SizedBox(height: 8),
//                           Text(
//                             'مساحة من الحبر والروح، أشاركك فيها رحلتي مع الكتابة… لتبدأ رحلتك أنت.',
//                             style: TextStyle(
//                               fontSize: 16,
//                               color: headerTextColor.withOpacity(0.8),
//                               height: 1.4,
//                             ),
//                             textAlign: TextAlign.right,
//                             textDirection: TextDirection.rtl,
//                           ),
//                         ],
//                       ),
//                     ),

//                     const SizedBox(height: 20),

//                     // 2️⃣ من هو الكاتب
//                     _buildInfoCard(
//                       context: context,
//                       cardColor: cardColor,
//                       title: '🧭 من هو عبدالله سعيد باقلاقل؟',
//                       titleColor: goldColor,
//                       icon: Icons.person_outline,
//                       children: [
//                         const Text(
//                           'كاتب روائي وسيناريست ومدرب كتابة.\nأؤمن أن الكلمة قادرة على تغيير الوعي، وأن كل سطرٍ يُكتب بصدق يمكن أن يغيّر حياة إنسان.',
//                           style: TextStyle(fontSize: 16, height: 1.5),
//                           textDirection: TextDirection.rtl,
//                         ),
//                         const SizedBox(height: 10),
//                         const Text(
//                           'بدأت رحلتي منذ الطفولة، حين كانت الحكايات عالمي الأول. واليوم، أشارك شغفي مع الكتّاب عبر كتبي ومشاريعي ومجتمع رتوش.',
//                           style: TextStyle(fontSize: 16, height: 1.5),
//                           textDirection: TextDirection.rtl,
//                         ),
//                         const SizedBox(height: 10),
//                         const Text(
//                           'هنا… نكتب لأن الكتابة ليست خيارًا، بل نداء لا يمكن تجاهله.',
//                           style: TextStyle(
//                               fontSize: 16,
//                               height: 1.5,
//                               fontStyle: FontStyle.italic),
//                           textDirection: TextDirection.rtl,
//                         ),
//                         const SizedBox(height: 15),
//                         Align(
//                           alignment: Alignment.centerRight,
//                           child: TextButton.icon(
//                             icon: const Icon(Icons.play_circle_outline,
//                                 color: Colors.redAccent),
//                             label: const Text(
//                               'شاهد فيديو وثائقي عن سيرتي',
//                               style: TextStyle(color: Colors.redAccent),
//                             ),
//                             onPressed: () => _launchURL(
//                                 'https://youtu.be/DLiw-hpMT5k?si=bCAhBL71-uPBSUAK'),
//                           ),
//                         ),
//                       ],
//                     ),

//                     // 3️⃣ أعمال الكاتب
//                     _buildInfoCard(
//                       context: context,
//                       cardColor: cardColor,
//                       title: '📘 أعمالي وكتبي',
//                       titleColor: turquoiseColor,
//                       icon: Icons.menu_book,
//                       children: [
//                         const Text(
//                           '✍ من الكتب التي شكّلت رحلتي في عالم الكتابة:',
//                           style: TextStyle(
//                               fontSize: 16,
//                               height: 1.5,
//                               fontWeight: FontWeight.w500),
//                           textDirection: TextDirection.rtl,
//                         ),
//                         const SizedBox(height: 8),
//                         const Text(' • كيف تكسب من كتاباتك 💰',
//                             style: TextStyle(fontSize: 16),
//                             textDirection: TextDirection.rtl),
//                         const Text(' • قصتي مع التأليف 🎬',
//                             style: TextStyle(fontSize: 16),
//                             textDirection: TextDirection.rtl),
//                         const Text(' • دليل وصف الشخصيات الروائية 🎭',
//                             style: TextStyle(fontSize: 16),
//                             textDirection: TextDirection.rtl),
//                         const SizedBox(height: 10),
//                         const Text(
//                           'كل كتاب منها كتبته لأساعد الكتّاب المستقلين على تحويل موهبتهم إلى مهنة، وشغفهم إلى مصدر دخل.',
//                           style: TextStyle(fontSize: 16, height: 1.5),
//                           textDirection: TextDirection.rtl,
//                         ),
//                         const SizedBox(height: 15),
//                         Align(
//                           alignment: Alignment.centerRight,
//                           child: ElevatedButton.icon(
//                             icon: const Icon(Icons.storefront,
//                                 color: Colors.black87),
//                             label: const Text(
//                               'اكتشف كتبي كاملة',
//                               style: TextStyle(
//                                   color: Colors.black87,
//                                   fontWeight: FontWeight.bold),
//                             ),
//                             onPressed: () =>
//                                 _launchURL('https://galagel.com/'),
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: goldColor,
//                               shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(8)),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),

//                     // 4️⃣ مجتمع رتوش
//                     _buildInfoCard(
//                       context: context,
//                       cardColor: cardColor,
//                       title: '🌍 مجمع رتوش للكتّاب المستقلين',
//                       titleColor: Colors.green,
//                       icon: Icons.groups_outlined,
//                       children: [
//                         const Text(
//                           'رتوش ليست مجرد عضوية… إنها مجتمع رقمي للكتّاب المستقلين.\nنتعلم، نكتب، ونتعاون لبناء مستقبل مهني من الحروف.',
//                           style: TextStyle(fontSize: 16, height: 1.5),
//                           textDirection: TextDirection.rtl,
//                         ),
//                         const SizedBox(height: 10),
//                         const Text(
//                           'ستجد في رتوش ورش عمل، كتب رقمية، وأدوات تساعدك على تطوير مهارتك خطوة بخطوة.',
//                           style: TextStyle(fontSize: 16, height: 1.5),
//                           textDirection: TextDirection.rtl,
//                         ),
//                         const SizedBox(height: 15),
//                         Align(
//                           alignment: Alignment.centerRight,
//                           child: ElevatedButton.icon(
//                             icon: const Icon(Icons.language, color: Colors.white),
//                             label: const Text(
//                               'انضم الآن إلى مجتمع رتوش',
//                               style: TextStyle(
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.bold),
//                             ),
//                             onPressed: () => _launchURL(
//                                 'https://galagel.com/admission/'),
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: turquoiseColor,
//                               shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(8)),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),

//                     // 5️⃣ اقتباس اليوم
//                     _buildInfoCard(
//                       context: context,
//                       cardColor: cardColor,
//                       title: '💫 اقتباس اليوم',
//                       titleColor: Colors.purpleAccent,
//                       icon: Icons.format_quote,
//                       children: [
//                         Text(
//                           '💬 $_randomQuote',
//                           style: const TextStyle(
//                               fontSize: 17,
//                               height: 1.6,
//                               fontStyle: FontStyle.italic),
//                           textAlign: TextAlign.center,
//                         ),
//                         const SizedBox(height: 10),
//                         const Text(
//                           '(من تأملات الكاتب عبدالله سعيد باقلاقل)',
//                           style: TextStyle(fontSize: 12, color: Colors.grey),
//                           textAlign: TextAlign.center,
//                         ),
//                         Align(
//                           alignment: Alignment.centerLeft,
//                           child: IconButton(
//                             icon: const Icon(Icons.refresh, color: Colors.grey),
//                             tooltip: 'اقتباس جديد',
//                             onPressed: _loadRandomQuote,
//                           ),
//                         ),
//                       ],
//                     ),

//                     // 6️⃣ الخاتمة
//                     Padding(
//                       padding: const EdgeInsets.symmetric(vertical: 30.0),
//                       child: Text(
//                         '🖋 في كل مرة تكتب، هناك عالم ينتظرك لتخلقه 🖋\n— عبدالله سعيد باقلاقل',
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                           fontSize: 14,
//                           fontStyle: FontStyle.italic,
//                           color: Colors.grey[600],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildInfoCard({
//     required BuildContext context,
//     required Color cardColor,
//     required String title,
//     required Color titleColor,
//     required IconData icon,
//     required List<Widget> children,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
//       child: Card(
//         color: cardColor,
//         elevation: 3,
//         shadowColor: Colors.black.withOpacity(0.3),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.end,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   Flexible(
//                     child: Text(
//                       title,
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: titleColor,
//                       ),
//                       textDirection: TextDirection.rtl,
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   Icon(icon, color: titleColor),
//                 ],
//               ),
//               const Divider(height: 20, thickness: 0.5),
//               ...children,
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }





// [ملف: author_screen.dart]

import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart'; // ✅ استيراد
import 'package:flutter/material.dart';
import 'package:plot_app/logs/login_screen.dart'; // ✅ استيراد
import 'package:plot_app/main.dart'; // ✅ استيراد
import 'package:shared_preferences/shared_preferences.dart'; // ✅ استيراد
import 'package:url_launcher/url_launcher.dart';
import 'quotes.dart'; // ✅ ملف الاقتباسات

class AuthorScreen extends StatefulWidget {
  const AuthorScreen({super.key});

  @override
  State<AuthorScreen> createState() => _AuthorScreenState();
}

class _AuthorScreenState extends State<AuthorScreen> {
  String _randomQuote = "";

  @override
  void initState() {
    super.initState();
    _loadRandomQuote();
  }

  void _loadRandomQuote() {
    setState(() {
      _randomQuote = getRandomQuote();
    });
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('لم يتمكن من فتح الرابط: $url')),
        );
      }
    }
  }

  // ✅✅ --- بداية التعديل (إضافة دالة تسجيل الخروج) --- ✅✅
  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    // العودة لشاشة الدخول ومنع الرجوع
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false, // حذف كل الشاشات السابقة
      );
    }
  }
  // ✅✅ --- نهاية التعديل --- ✅✅

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color headerBackgroundColor =
        isDark ? Colors.grey[900]! : const Color(0xFFFFF3E0);
    final Color headerTextColor = isDark ? Colors.white70 : Colors.black87;
    const Color goldColor = Color(0xFFD4AF37);
    const Color turquoiseColor = Color(0xFF40E0D0);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 30),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1️⃣ العنوان العلوي
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          vertical: 30.0, horizontal: 16.0),
                      color: headerBackgroundColor,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '✍ قلم الكاتب',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: headerTextColor,
                            ),
                            textAlign: TextAlign.right,
                            textDirection: TextDirection.rtl,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'مساحة من الحبر والروح، أشاركك فيها رحلتي مع الكتابة… لتبدأ رحلتك أنت.',
                            style: TextStyle(
                              fontSize: 16,
                              color: headerTextColor.withOpacity(0.8),
                              height: 1.4,
                            ),
                            textAlign: TextAlign.right,
                            textDirection: TextDirection.rtl,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 2️⃣ من هو الكاتب
                    _buildInfoCard(
                      context: context,
                      cardColor: cardColor,
                      title: '🧭 من هو عبدالله سعيد باقلاقل؟',
                      titleColor: goldColor,
                      icon: Icons.person_outline,
                      children: [
                        const Text(
                          'كاتب روائي وسيناريست ومدرب كتابة.\nأؤمن أن الكلمة قادرة على تغيير الوعي، وأن كل سطرٍ يُكتب بصدق يمكن أن يغيّر حياة إنسان.',
                          style: TextStyle(fontSize: 16, height: 1.5),
                          textDirection: TextDirection.rtl,
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'بدأت رحلتي منذ الطفولة، حين كانت الحكايات عالمي الأول. واليوم، أشارك شغفي مع الكتّاب عبر كتبي ومشاريعي ومجتمع رتوش.',
                          style: TextStyle(fontSize: 16, height: 1.5),
                          textDirection: TextDirection.rtl,
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'هنا… نكتب لأن الكتابة ليست خيارًا، بل نداء لا يمكن تجاهله.',
                          style: TextStyle(
                              fontSize: 16,
                              height: 1.5,
                              fontStyle: FontStyle.italic),
                          textDirection: TextDirection.rtl,
                        ),
                        const SizedBox(height: 15),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            icon: const Icon(Icons.play_circle_outline,
                                color: Colors.redAccent),
                            label: const Text(
                              'شاهد فيديو وثائقي عن سيرتي',
                              style: TextStyle(color: Colors.redAccent),
                            ),
                            onPressed: () => _launchURL(
                                'https://youtu.be/DLiw-hpMT5k?si=bCAhBL71-uPBSUAK'),
                          ),
                        ),
                      ],
                    ),

                    // 3️⃣ أعمال الكاتب
                    _buildInfoCard(
                      context: context,
                      cardColor: cardColor,
                      title: '📘 أعمالي وكتبي',
                      titleColor: turquoiseColor,
                      icon: Icons.menu_book,
                      children: [
                        const Text(
                          '✍ من الكتب التي شكّلت رحلتي في عالم الكتابة:',
                          style: TextStyle(
                              fontSize: 16,
                              height: 1.5,
                              fontWeight: FontWeight.w500),
                          textDirection: TextDirection.rtl,
                        ),
                        const SizedBox(height: 8),
                        const Text(' • كيف تكسب من كتاباتك 💰',
                            style: TextStyle(fontSize: 16),
                            textDirection: TextDirection.rtl),
                        const Text(' • قصتي مع التأليف 🎬',
                            style: TextStyle(fontSize: 16),
                            textDirection: TextDirection.rtl),
                        const Text(' • دليل وصف الشخصيات الروائية 🎭',
                            style: TextStyle(fontSize: 16),
                            textDirection: TextDirection.rtl),
                        const SizedBox(height: 10),
                        const Text(
                          'كل كتاب منها كتبته لأساعد الكتّاب المستقلين على تحويل موهبتهم إلى مهنة، وشغفهم إلى مصدر دخل.',
                          style: TextStyle(fontSize: 16, height: 1.5),
                          textDirection: TextDirection.rtl,
                        ),
                        const SizedBox(height: 15),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.storefront,
                                color: Colors.black87),
                            label: const Text(
                              'اكتشف كتبي كاملة',
                              style: TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.bold),
                            ),
                            onPressed: () =>
                                _launchURL('https://galagel.com/'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: goldColor,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // 4️⃣ مجتمع رتوش
                    _buildInfoCard(
                      context: context,
                      cardColor: cardColor,
                      title: '🌍 مجمع رتوش للكتّاب المستقلين',
                      titleColor: Colors.green,
                      icon: Icons.groups_outlined,
                      children: [
                        const Text(
                          'رتوش ليست مجرد عضوية… إنها مجتمع رقمي للكتّاب المستقلين.\nنتعلم، نكتب، ونتعاون لبناء مستقبل مهني من الحروف.',
                          style: TextStyle(fontSize: 16, height: 1.5),
                          textDirection: TextDirection.rtl,
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'ستجد في رتوش ورش عمل، كتب رقمية، وأدوات تساعدك على تطوير مهارتك خطوة بخطوة.',
                          style: TextStyle(fontSize: 16, height: 1.5),
                          textDirection: TextDirection.rtl,
                        ),
                        const SizedBox(height: 15),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.language, color: Colors.white),
                            label: const Text(
                              'انضم الآن إلى مجتمع رتوش',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                            onPressed: () => _launchURL(
                                'https://galagel.com/admission/'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: turquoiseColor,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // 5️⃣ اقتباس اليوم
                    _buildInfoCard(
                      context: context,
                      cardColor: cardColor,
                      title: '💫 اقتباس اليوم',
                      titleColor: Colors.purpleAccent,
                      icon: Icons.format_quote,
                      children: [
                        Text(
                          '💬 $_randomQuote',
                          style: const TextStyle(
                              fontSize: 17,
                              height: 1.6,
                              fontStyle: FontStyle.italic),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          '(من تأملات الكاتب عبدالله سعيد باقلاقل)',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            icon: const Icon(Icons.refresh, color: Colors.grey),
                            tooltip: 'اقتباس جديد',
                            onPressed: _loadRandomQuote,
                          ),
                        ),
                      ],
                    ),

                    // ✅✅ --- بداية التعديل (إضافة بطاقة الإعدادات) --- ✅✅
                    _buildInfoCard(
                      context: context,
                      cardColor: cardColor,
                      title: '⚙️ الإعدادات وتسجيل الخروج',
                      titleColor: Colors.blueGrey,
                      icon: Icons.settings_outlined,
                      children: [
                        // --- الوضع الليلي ---
                        ValueListenableBuilder<ThemeMode>(
                          valueListenable: themeNotifier,
                          builder: (context, currentMode, child) {
                            return SwitchListTile(
                              title: const Text('الوضع الليلي'),
                              secondary: const Icon(Icons.dark_mode_outlined),
                              value: currentMode == ThemeMode.dark,
                              onChanged: (isDark) async {
                                themeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;
                                final prefs = await SharedPreferences.getInstance();
                                await prefs.setBool('isDarkMode', isDark);
                              },
                            );
                          }
                        ),
                        const Divider(height: 10, thickness: 0.5),
                        // --- تسجيل الخروج ---
                        ListTile(
                          leading: const Icon(Icons.logout, color: Colors.redAccent),
                          title: const Text('تسجيل الخروج', style: TextStyle(color: Colors.redAccent)),
                          onTap: _logout, // استدعاء الدالة
                        ),
                      ],
                    ),
                    // ✅✅ --- نهاية التعديل --- ✅✅


                    // 6️⃣ الخاتمة
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 30.0),
                      child: Text(
                        '🖋 في كل مرة تكتب، هناك عالم ينتظرك لتخلقه 🖋\n— عبدالله سعيد باقلاقل',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required BuildContext context,
    required Color cardColor,
    required String title,
    required Color titleColor,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Card(
        color: cardColor,
        elevation: 3,
        shadowColor: Colors.black.withOpacity(0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Flexible(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: titleColor,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(icon, color: titleColor),
                ],
              ),
              const Divider(height: 20, thickness: 0.5),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}