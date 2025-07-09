import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

class TopPlacesPage extends StatefulWidget {
  const TopPlacesPage({Key? key}) : super(key: key);

  @override
  State<TopPlacesPage> createState() => _TopPlacesPageState();
}

class _TopPlacesPageState extends State<TopPlacesPage> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController placeController = TextEditingController();
  final TextEditingController daysController = TextEditingController();
  final TextEditingController monthController = TextEditingController();
  final TextEditingController budgetController = TextEditingController();
  final TextEditingController activitiesController = TextEditingController();

  bool isEditing = false;
  String? editingId;

  Future<void> addOrUpdateItinerary() async {
    if (!_formKey.currentState!.validate()) return;

    final user = _auth.currentUser;
    if (user == null) return;

    final data = {
      'place': placeController.text.trim(),
      'days': daysController.text.trim(),
      'month': monthController.text.trim(),
      'budget': budgetController.text.trim(),
      'activities': activitiesController.text.trim(),
      'timestamp': FieldValue.serverTimestamp(),
    };

    if (isEditing && editingId != null) {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('dream_itinerary')
          .doc(editingId)
          .update(data);
    } else {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('dream_itinerary')
          .add(data);
    }

    clearForm();
    Navigator.pop(context);
  }

  Future<void> deleteItinerary(String docId) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('dream_itinerary')
          .doc(docId)
          .delete();
    }
  }

  void clearForm() {
    placeController.clear();
    daysController.clear();
    monthController.clear();
    budgetController.clear();
    activitiesController.clear();
    isEditing = false;
    editingId = null;
  }

  void showItineraryDialog({Map<String, dynamic>? itinerary, String? docId}) {
    if (itinerary != null) {
      placeController.text = itinerary['place'];
      daysController.text = itinerary['days'];
      monthController.text = itinerary['month'];
      budgetController.text = itinerary['budget'];
      activitiesController.text = itinerary['activities'];
      isEditing = true;
      editingId = docId;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isEditing ? 'Edit Itinerary' : 'Add Itinerary'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                buildTextField('Destination', placeController),
                buildTextField('Number of Days', daysController, keyboard: TextInputType.number),
                buildTextField('Best Month to Visit', monthController),
                buildTextField('Estimated Budget (MYR)', budgetController, keyboard: TextInputType.number),
                buildTextField('Activities Planned', activitiesController, maxLines: 3),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: addOrUpdateItinerary,
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF26A69A)),
            child: Text(isEditing ? 'Update' : 'Add'),
          ),
        ],
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller,
      {int maxLines = 1, TextInputType keyboard = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboard,
        validator: (val) => val == null || val.isEmpty ? 'Required' : null,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Future<void> generatePdf(List<QueryDocumentSnapshot> docs) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Text("My Dream Itinerary", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          for (var doc in docs)
            pw.Container(
              margin: const pw.EdgeInsets.symmetric(vertical: 8),
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.teal),
                borderRadius: pw.BorderRadius.circular(10),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text("Destination: ${doc['place']}"),
                  pw.Text("Days: ${doc['days']}"),
                  pw.Text("Month: ${doc['month']}"),
                  pw.Text("Budget: MYR ${doc['budget']}"),
                  pw.Text("Activities: ${doc['activities']}"),
                ],
              ),
            ),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: Text("User not logged in")));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dream Itinerary'),
        backgroundColor: const Color(0xFF26A69A),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () async {
              final snapshot = await _firestore
                  .collection('users')
                  .doc(user.uid)
                  .collection('dream_itinerary')
                  .orderBy('timestamp', descending: true)
                  .get();
              if (snapshot.docs.isNotEmpty) {
                await generatePdf(snapshot.docs);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("No itinerary to download")),
                );
              }
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF26A69A),
        child: const Icon(Icons.add),
        onPressed: () => showItineraryDialog(),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('users')
            .doc(user.uid)
            .collection('dream_itinerary')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text("No dream itinerary yet. Tap + to start."));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final docId = docs[index].id;

              return Card(
                color: const Color(0xFFB2DFDB), // ✅ Updated card color
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(data['place'] ?? 'Unknown Place'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("🕒 Days: ${data['days']}"),
                      Text("📅 Best Month: ${data['month']}"),
                      Text("💰 Budget: MYR ${data['budget']}"),
                      Text("🎯 Activities: ${data['activities']}"),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.teal),
                        onPressed: () => showItineraryDialog(itinerary: data, docId: docId),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => deleteItinerary(docId),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
