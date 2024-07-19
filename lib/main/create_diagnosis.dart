import 'package:evisit_mobile/main.dart';
import 'package:evisit_mobile/network/evisit_api.dart';
import 'package:flutter/material.dart';

import '../types/evisit.dart';

class CreateDiagnosisScreen extends StatefulWidget {
  final String evisitId;
  const CreateDiagnosisScreen({super.key, required this.evisitId});

  @override
  _CreateDiagnosisScreenState createState() => _CreateDiagnosisScreenState();
}

class _CreateDiagnosisScreenState extends State<CreateDiagnosisScreen> {
  TextEditingController diagnosisController = TextEditingController();
  TextEditingController prescriptionController = TextEditingController();
  TextEditingController noteController = TextEditingController();
  List<String> prescriptions = [];

  void addPrescription() {
    setState(() {
      prescriptions.add(prescriptionController.text);
      prescriptionController.clear();
    });
  }

  void addDiagnoses() {
    Evisit eVisitData;
    setState(() {
      diagnosisController.clear();
      prescriptionController.clear();
      noteController.clear();
    });

    Diagnosis diagnosis = Diagnosis(
      text: diagnosisController.text,
      prescriptions: [...prescriptions, prescriptionController.text],
      note: noteController.text,
    );
    
    createDiagnosis(widget.evisitId, diagnosis);

    fetchDataAndTransform().then((value) {
      eVisitData = value.where((element) => element.id == widget.evisitId).first;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diagnosis and Prescription'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Diagnosis:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: diagnosisController,
              decoration: const InputDecoration(
                hintText: 'Enter diagnosis',
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Prescriptions:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Column(
              children: [
                for (var prescription in prescriptions)
                  TextField(
                    controller: TextEditingController(text: prescription),
                    onChanged: (newPrescription) {
                      prescription = newPrescription;
                    },
                  ),
              ],
            ),
            TextField(
              controller: prescriptionController,
              decoration: const InputDecoration(
                hintText: 'Enter prescription',
              ),
            ),
            ElevatedButton(
              onPressed: addPrescription,
              child: const Text('Add Prescription'),
            ),
            const SizedBox(height: 20),
            const Text(
              'Note:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(
                hintText: 'Enter notes (optional)',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                addDiagnoses();


                // Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
                //   builder: (BuildContext context) => EVisitDetailScreen(eVisitDataId: widget.evisit.id),
                // ), (route) => false);
              },
              child: const Text('DIAGNOSE'),
            ),
          ],
        ),
      ),
    );
  }
}