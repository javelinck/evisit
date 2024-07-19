import 'package:evisit_mobile/main/e_visit_detail.dart';
import 'package:evisit_mobile/network/user_api.dart';
import 'package:evisit_mobile/types/evisit.dart';
import 'package:flutter/material.dart';

import '../network/evisit_api.dart';
import '../types/user.dart';
import 'create_new_evisit.dart';

class EvisitListScreen extends StatefulWidget {
  final String? patientId;
  const EvisitListScreen({Key? key, this.patientId}) : super(key: key);

  @override
  _EvisitListScreenState createState() => _EvisitListScreenState();
}

class _EvisitListScreenState extends State<EvisitListScreen> {
  List<Evisit> _evisits = [];
  User? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final List<dynamic> results = await Future.wait([
      fetchDataAndTransform(),
      fetchUserDataAndTransform(),
    ]);

    setState(() {
      if (widget.patientId != null) {
        _evisits = results[0].where((element) => element.patient['_id'] == widget.patientId).toList();
      } else {
        _evisits = results[0];
      }

      _user = results[1];
      _isLoading = false;
    });
  }

  void _handleCreateEvisit() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const EVisitCreationScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EVisits'),
        actions: [
          if (_user?.role == 0)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _handleCreateEvisit,
            ),
        ],
        leading: widget.patientId == null ? IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ) : null,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: _isLoading ? const Center(child: CircularProgressIndicator())
          : _evisits.isNotEmpty ? ListView.separated(
            itemCount: _evisits.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              return EvisitListItem(eVisitData: _evisits[index],);
            },
          ) : const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Text('No data', style: TextStyle(fontSize: 18.0),)],
          ),
      ),
    );
  }
}

class EvisitListItem extends StatelessWidget {
  final Evisit eVisitData;

  const EvisitListItem({super.key, required this.eVisitData});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EVisitDetailScreen(
              eVisitData: eVisitData,
            ),
          ),
        );
      },
      child: ListTile(
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildRow('Patient', eVisitData.patient['name'] ?? ''),
            buildRow('Doctor', eVisitData.doctor['name'] ?? ''),
            buildRow('Created', eVisitData.createdAt),
          ],
        ),
        trailing: eVisitData.status == 0
            ? const Icon(Icons.medical_information_outlined, color: Colors.grey)
            : const Icon(Icons.check_circle, color: Colors.green),
      ),
    );
  }

  Widget buildRow(String type, String title) {
    return Row(
      children: [
        Text('$type: '),
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
