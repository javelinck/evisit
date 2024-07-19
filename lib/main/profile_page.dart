import 'package:evisit_mobile/components/basic_profile_info.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:random_avatar/random_avatar.dart';

import '../components/profile_buttons.dart';
import '../network/user_api.dart';
import '../providers/auth_provider.dart';
import '../types/user.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: fetchUserDataAndTransform(),
      builder: (context, snapshot) {
        final authProvider = Provider.of<AuthProvider>(context);

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(),); // Loading indicator
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.data == null) {
          return const Text('No data available');
        } else {
          User userProfile = snapshot.data!;

          return Scaffold(
            appBar: AppBar(
              title: Text(userProfile.name),
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: authProvider.logout,
                ),
              ],
              leading: userProfile.role == 1 ? IconButton(
                icon: const Icon(Icons.menu), // You can use any icon you prefer.
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              ) : null,
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: RandomAvatar(
                    userProfile.name,
                    height: 100,
                    width: 100,
                    trBackground: true,
                  )),
                  const SizedBox(height: 16),
                  BasicProfileInfo(userProfile: userProfile),
                  const SizedBox(height: 16),
                  ProfileButtons(role: userProfile.role, isProfile: true,),
                ],
              )
            ),
          );
        }
      }
    );
  }
}
