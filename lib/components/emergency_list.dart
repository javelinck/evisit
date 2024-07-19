import 'package:evisit_mobile/helpers/mock_data.dart';
import 'package:flutter/material.dart';

class EmergencyList extends StatelessWidget {
  const EmergencyList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency'),
      ),
      body: ListView.builder(
        itemCount: emergencyContacts.length,
        itemBuilder: (context, index) {
          final contact = emergencyContacts[index];
          return Column(
            children: [
              ListTile(
                leading: const Icon(Icons.person),
                title: Text(contact.name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(contact.relationship),
                    Text(contact.phone),
                    Text(contact.address),
                  ],
                ),
                onTap: () {
                  // Handle tap on a contact item.
                },
              ),
              const Divider(),
            ],
          );
        },
      ),
    );
  }
}