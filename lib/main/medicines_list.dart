import 'dart:async';

import 'package:evisit_mobile/network/medicine_api.dart';
import 'package:evisit_mobile/types/medicines.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../helpers/request_permissions.dart';

class MedicinesListScreen extends StatefulWidget {
  const MedicinesListScreen({Key? key}) : super(key: key);

  @override
  _MedicinesListScreenState createState() => _MedicinesListScreenState();
}

class _MedicinesListScreenState extends State<MedicinesListScreen> {
  Future<List<Medicine>>? medicineList;
  final TextEditingController _searchController = TextEditingController();
  List<Medicine> _filteredMedicines = [];
  bool _isSearching = false;
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    medicineList = fetchMedicine();
    _filteredMedicines = [];
  }

  void _filterMedicines(String query) {
    if (medicineList != null) {
      medicineList!.then((medicines) {
        setState(() {
          if (query.isEmpty) {
            _filteredMedicines = medicines;
          } else {
            _filteredMedicines = medicines.where((medicine) =>
                medicine.name.toLowerCase().contains(query.toLowerCase())).toList();
          }
        });
      });
    }
  }

  void _toggleListening() async {
    if (_isListening) {
      _speech.stop();
    } else {
      final permissionStatus = await requestMicrophonePermission();

      if (permissionStatus == true) {
        if (await _speech.initialize()) {
          _speech.listen(
            onResult: (result) {
              setState(() {
                _searchController.text = result.recognizedWords;
                _filterMedicines(result.recognizedWords);
              });
            },
          );

          // Set a timer to stop speech recognition after 1 minute (60,000 milliseconds)
          const Duration oneMinute = Duration(minutes: 1);
          Timer(oneMinute, () {
            if (_isListening) {
              _speech.stop();
              voiceSearching();
            }
          });
        } else {
          print("Speech recognition failed to initialize");
        }
      }
    }

    setState(() {
      voiceSearching();
    });
  }

  void voiceSearching() {
    _isListening = !_isListening;
    if (_isListening) {
      _isSearching = true;
    }

    if (!_isListening) {
      _isSearching = false;
    }

    if (!_isSearching) {
      _searchController.clear();
      _filteredMedicines = [];
    }
  }

  void _toggleSearchField() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _filteredMedicines = [];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching ? TextField(
          controller: _searchController,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          onChanged: (query) {
            _filterMedicines(query);
          },
          cursorColor: Colors.white,
          decoration: const InputDecoration(
            hintText: 'Search Medicines',
            hintStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.normal),
            border: InputBorder.none,
          ),
        ) : const Text('Medicines'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: _toggleSearchField,
          ),
          IconButton(
            icon: Icon(_isListening ? Icons.mic_off : Icons.mic),
            onPressed: _toggleListening,
          ),
        ],
      ),
      body: FutureBuilder<List<Medicine>>(
        future: medicineList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final List<Medicine> medicines = _isSearching ? _filteredMedicines : snapshot.data!;
            return ListView.separated(
              separatorBuilder: (context, index) => const Divider(),
              itemCount: medicines.length,
              itemBuilder: (context, index) {
                final medicine = medicines[index];

                return MedicineCard(medicine: medicine);
              },
            );
          }
        },
      ),
    );
  }
}

class MedicineCard extends StatefulWidget {
  final Medicine medicine;
  const MedicineCard({super.key, required this.medicine});

  @override
  State<MedicineCard> createState() => _MedicineCardState();
}

class _MedicineCardState extends State<MedicineCard> {
  bool _showDescription = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.all(5.0),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(5.0), topRight: Radius.circular(5.0)), // Adjust the radius as needed
            child: Image.network(
              widget.medicine.image.trimRight(),
              height: 250,
              width: double.infinity,
              fit: BoxFit.fill,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  widget.medicine.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 5),
                if (_showDescription)
                  Text(widget.medicine.description, style: const TextStyle(fontSize: 16)),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _showDescription = !_showDescription;
                    });
                  },
                  child: Text(_showDescription ? 'Hide Description' : 'Show Description'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}