import 'dart:async';

import 'package:evisit_mobile/helpers/filter_users_by_name.dart';
import 'package:evisit_mobile/main/user_details.dart';
import 'package:flutter/material.dart';
import 'package:random_avatar/random_avatar.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../helpers/request_permissions.dart';
import '../network/user_api.dart';
import '../types/user.dart';

class PatientListScreen extends StatefulWidget {
  const PatientListScreen({Key? key}) : super(key: key);

  @override
  _PatientListScreenState createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen> {
  Future<List<User>>? patientList;
  final TextEditingController _searchController = TextEditingController();
  List<User> _filteredPatients = [];
  bool _isSearching = false;
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    patientList = fetchPatientList();
    _filteredPatients = [];
  }

  void _filterPatients(String query) {
    if (patientList != null) {
      patientList!.then((patients) {
        setState(() {
          if (query.isEmpty) {
            _filteredPatients = patients;
          } else {
            _filteredPatients = filterUsersByName(patients, query);
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
                _filterPatients(result.recognizedWords);
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
      _filteredPatients = [];
    }
  }

  void _toggleSearchField() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _filteredPatients = [];
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
            _filterPatients(query);
          },
          cursorColor: Colors.white,
          decoration: const InputDecoration(
            hintText: 'Search Patients',
            hintStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.normal),
            border: InputBorder.none,
          ),
        ) : const Text('Patients List'),
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
        leading: IconButton(
          icon: const Icon(Icons.menu), // You can use any icon you prefer.
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
      ),
      body: FutureBuilder<List<User>>(
        future: patientList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final List<User> patients = _isSearching ? _filteredPatients : snapshot.data!;
            return ListView.separated(
              separatorBuilder: (context, index) => const Divider(),
              itemCount: patients.length,
              itemBuilder: (context, index) {
                final patient = patients[index];
                return ListTile(
                  title: Text(patient.name),
                  subtitle: Text(patient.email),
                  leading: RandomAvatar(
                    patient.name,
                    height: 50,
                    width: 50,
                    trBackground: true,
                  ),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserDetailsScreen(user: patient),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}