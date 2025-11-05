import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // ✅ استيراد
import 'package:firebase_auth/firebase_auth.dart'; // ✅ استيراد

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  // ✅ جلب الـ Stream الخاص بالمفضلة
  Stream<QuerySnapshot>? _favoritesStream;

  @override
  void initState() {
    super.initState();
    _loadFavoritesStream();
  }

  void _loadFavoritesStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _favoritesStream = FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('favorites')
            .orderBy('timestamp', descending: true) // عرض الأحدث أولاً
            .snapshots();
      });
    }
  }

  // ✅ دالة الحذف (بنحتاج الـ ID بتاع الحبكة)
  Future<void> _removeFavorite(String docId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .doc(docId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("تم حذف الحبكة من المفضلة 🗑️")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("فشل الحذف: $e")),
      );
    }
  }

  // ✅ دالة مسح الكل
  Future<void> _clearAllFavorites(List<QueryDocumentSnapshot> docs) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final batch = FirebaseFirestore.instance.batch();
    for (var doc in docs) {
      batch.delete(doc.reference); // إضافة كل عمليات الحذف في دفعة واحدة
    }
    await batch.commit(); // تنفيذها مرة واحدة

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("تم مسح جميع المفضلة 🧹")),
    );
  }

  Future<void> _copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("تم نسخ الحبكة إلى الحافظة 📋")),
    );
  }

  void _sharePlot(String text) {
    Share.share(text);
  }

  // ✅ دالة تصدير PDF (بتحتاج قايمة الحبكات)
  Future<void> _exportFavoritesToPdf(List<String> favorites) async {
    if (favorites.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("لا توجد حبكات لتصديرها 📭")),
      );
      return;
    }
    final pdf = pw.Document();
    // ... (باقي كود الـ PDF زي ما هو بس بياخد القايمة كمتغير)
    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Center(child: pw.Text("مكتبـة الحبكات - المفضلة", style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold))),
          pw.SizedBox(height: 20),
          ...favorites.asMap().entries.map(
                (entry) => pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 8),
                  child: pw.Text(
                    "${entry.key + 1}- ${entry.value}",
                    textDirection: pw.TextDirection.rtl,
                    style: const pw.TextStyle(fontSize: 14),
                  ),
                ),
              ),
        ],
      ),
    );

    try {
      final dir = await getTemporaryDirectory();
      final file = File("${dir.path}/favorites.pdf");
      await file.writeAsBytes(await pdf.save());
      Share.shareXFiles([XFile(file.path)], text: "مفضلتي من مكتبة الحبكات 📄");
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("فشل تصدير PDF: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text("المفضلة"),
      // ),
      // ✅ استخدام StreamBuilder لبناء الواجهة
      body: StreamBuilder<QuerySnapshot>(
        stream: _favoritesStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("حدث خطأ: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "لا توجد حبكات محفوظة بعد.",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          // ✅ بناء القائمة من الـ snapshot
          final favoriteDocs = snapshot.data!.docs;
          final favoriteTexts = favoriteDocs.map((doc) => (doc.data() as Map)['text'].toString()).toList();

          // ✅ إضافة أزرار الـ AppBar هنا بعد التأكد من وجود بيانات
          return Scaffold(
            appBar: AppBar(
              title: const Text("المفضلة"),
              actions: [
                IconButton(
                  icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                  tooltip: "تصدير PDF",
                  onPressed: () => _exportFavoritesToPdf(favoriteTexts),
                ),
                IconButton(
                  icon: const Icon(Icons.cleaning_services, color: Colors.white),
                  tooltip: "مسح الكل",
                  onPressed: () => _showClearAllDialog(favoriteDocs),
                ),
              ],
            ),
            body: ListView.builder(
              itemCount: favoriteDocs.length,
              itemBuilder: (context, index) {
                final doc = favoriteDocs[index];
                final plot = doc.data() as Map<String, dynamic>;
                final plotText = plot['text'].toString();

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          plotText,
                          textAlign: TextAlign.right,
                          textDirection: TextDirection.rtl,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.copy, color: Colors.blueAccent),
                              onPressed: () => _copyToClipboard(plotText),
                              tooltip: "نسخ",
                            ),
                            IconButton(
                              icon: const Icon(Icons.share, color: Colors.green),
                              onPressed: () => _sharePlot(plotText),
                              tooltip: "مشاركة",
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.redAccent),
                              onPressed: () => _removeFavorite(doc.id), // ✅ الحذف بالـ ID
                              tooltip: "حذف",
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  // دالة مساعدة لعرض تأكيد المسح
  void _showClearAllDialog(List<QueryDocumentSnapshot> docs) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("تأكيد"),
        content: const Text("هل تريد مسح جميع المفضلة؟"),
        actions: [
          TextButton(
            child: const Text("إلغاء"),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text("مسح"),
            onPressed: () {
              Navigator.pop(context);
              _clearAllFavorites(docs);
            },
          ),
        ],
      ),
    );
  }
}