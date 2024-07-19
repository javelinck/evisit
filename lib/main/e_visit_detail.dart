import 'package:evisit_mobile/main/create_diagnosis.dart';
import 'package:evisit_mobile/types/evisit.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:random_avatar/random_avatar.dart';

import '../providers/auth_provider.dart';

class EVisitDetailScreen extends StatelessWidget {
  final Evisit eVisitData;

  const EVisitDetailScreen({super.key, required this.eVisitData});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text('eVisit Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: RandomAvatar(
              eVisitData.patient['name'],
              height: 100,
              width: 100,
              trBackground: true,
            )),
            const SizedBox(height: 16),
            const Text(
              'Patient:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              eVisitData.patient['name'],
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            if (eVisitData.patient['allergies'] != null)
            const Text(
              'Allergies:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              eVisitData.patient['allergies'],
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              'Diagnosis:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (eVisitData.diagnosis != null && eVisitData.diagnosis['text'] != null)
              Text(
                eVisitData.diagnosis['text'] ?? 'No diagnosis available',
                style: const TextStyle(fontSize: 16),
              ),
            if (eVisitData.diagnosis == null || eVisitData.diagnosis['text'] == null && authProvider.role == 1)
              TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) => CreateDiagnosisScreen(evisitId: eVisitData.id),
                  ));
                },
                child: const Text('Add Diagnosis'),
              ),
            if (eVisitData.diagnosis == null || eVisitData.diagnosis['text'] == null && authProvider.role == 0)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                decoration: BoxDecoration(
                  color: Colors.lightBlue.withOpacity(0.2),),
                child: const Row(
                  children: [
                    SizedBox(width: 8),
                    Icon(Icons.check_circle_outline),
                    SizedBox(width: 8),
                    Text(
                      'Waiting for a Diagnosis',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            if (eVisitData.diagnosis['prescriptions'] != null &&
                eVisitData.diagnosis['prescriptions'].isNotEmpty)
            const Text(
              'Prescriptions:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (eVisitData.diagnosis['prescriptions'] != null &&
                eVisitData.diagnosis['prescriptions'].isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(
                eVisitData.diagnosis['prescriptions'].length,
                    (index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      '- ${eVisitData.diagnosis['prescriptions'][index]}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            if (eVisitData.answers != null &&
                eVisitData.answers.isNotEmpty)
            const SizedBox(height: 8),
            const Text(
              'Patient Answers:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (eVisitData.answers != null &&
                eVisitData.answers.isNotEmpty)

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(
                  eVisitData.answers!.length,
                      (index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Text('- ${eVisitData.answers[index]['text']}', style: const TextStyle(fontSize: 16),),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Text('- ${eVisitData.answers[index]['answer']}', style: const TextStyle(fontSize: 16),),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 16),
            const Text(
              'Note:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              eVisitData.diagnosis['note'] ?? 'No note available',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}