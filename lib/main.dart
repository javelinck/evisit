import 'package:evisit_mobile/auth/login_page.dart';
import 'package:evisit_mobile/main/doctor_list.dart';
import 'package:evisit_mobile/main/e_visits.dart';
import 'package:evisit_mobile/main/profile_page.dart';
import 'package:evisit_mobile/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:random_avatar/random_avatar.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'main/medicines_list.dart';
import 'main/patient_list.dart';
import 'main/protocol_questions.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey = 'pk_test_51JQbGlIQqPF6WWB3uyGwlXsT93txWKDz9IMriafUkQC6X44fWpHGPlQl0TOM77AsalDx44eYvDCkq8S1SgDQTpXU002pHAMlOe';
  await dotenv.load(fileName: "assets/.env");
  await _loadSavedPref();
  runApp(const MyApp());
}

Future<void> _loadSavedPref() async {
  final authProvider = AuthProvider();
  await authProvider.loadSavedId();
  await authProvider.loadSavedRole();
  await authProvider.loadSavedName();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AuthProvider(),
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'App Authentication Example',
        home: AppWrapper(),
      ),
    );
  }
}

class AppWrapper extends StatefulWidget {
  const AppWrapper({super.key});

  @override
  _AppWrapperState createState() => _AppWrapperState();
}

class _AppWrapperState extends State<AppWrapper> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    authProvider.loadSavedId();
    authProvider.loadSavedRole();
    authProvider.loadSavedName();

    if (authProvider.id != null) {
      return const MainScreen();
    } else {
      return const LoginPage();
    }
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _patientPages = [
    const EvisitListScreen(),
    const DoctorListScreen(),
    const ProfileScreen(),
  ];

  final List<Widget> _doctorPages = [
    const EvisitListScreen(),
    const PatientListScreen(),
    const ProfileScreen(),
  ];

  final List<BottomNavigationBarItem> _patientItems = [
    const BottomNavigationBarItem(
      icon: Icon(Icons.home),
      label: 'Home',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.people),
      label: 'Doctors',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.person),
      label: 'Profile',
    ),
  ];

  final List<BottomNavigationBarItem> _doctorItems = [
    const BottomNavigationBarItem(
      icon: Icon(Icons.home),
      label: 'Home',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.people),
      label: 'Patients',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.person),
      label: 'Profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
      body: authProvider.role == 0 ? _patientPages[_currentIndex] : _doctorPages[_currentIndex],
      drawer: authProvider.role == 1 ? buildDoctorDrawer(context, authProvider.name) : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: authProvider.role == 0 ? _patientItems : _doctorItems,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

Drawer buildDoctorDrawer(BuildContext context, String? name) {
  return Drawer(
    child: ListView(
      children: [
        Center(child: RandomAvatar(
          name!,
          height: 100,
          width: 100,
          trBackground: true,
        )),
        const SizedBox(height: 16,),
        ListTile(
          title: const Text('Protocols'),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ProtocolQuestionsScreen(),
              ),
            );
          },
        ),
        ListTile(
          title: const Text('Medicines'),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const MedicinesListScreen(),
              ),
            );
          },
        ),
      ],
    ),
  );
}