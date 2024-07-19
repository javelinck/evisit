import 'package:evisit_mobile/components/profile_buttons.dart';
import 'package:flutter/material.dart';
import 'package:random_avatar/random_avatar.dart';

import '../helpers/comunications.dart';
import '../types/user.dart';

enum UsersDetails {
  Email,
  Gender,
  Phone,
  Address,
  DateOfBirth,
}

class UserDetailsScreen extends StatelessWidget {
  final User user;

  const UserDetailsScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(user.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: RandomAvatar(
              user.name,
              height: 100,
              width: 100,
              trBackground: true,
            )),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 3,
                    blurRadius: 5,
                    offset: const Offset(0, 3), // changes position of shadow
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    infoDetailsRow(UsersDetails.Email, user.email),
                    infoDetailsRow(UsersDetails.Gender, user.gender),
                    infoDetailsRow(UsersDetails.Address, '${user.address}, ${user.city}, ${user.state}'),
                    infoDetailsRow(UsersDetails.Phone, user.phone, isLastItem: true),
                  ],
                ),
              )
            ),
            const SizedBox(height: 16),
            if (user.role == 0)
            ProfileButtons(role: user.role, isProfile: false, patientId: user.id,),
          ],
        )
      )
    );
  }
}

Widget infoDetailsRow(UsersDetails title, String info, {bool isLastItem = false})  {
  void onItemTap() {
    switch (title) {
      case UsersDetails.Email:
        sendEmail(info);
        break;
      case UsersDetails.Address:
        openMapWithAddress(info);
        break;
      case UsersDetails.Phone:
        makePhoneCall(info);
        break;
      default:
        break;
    }
  }

  return GestureDetector(
    onTap: onItemTap,
    child: Column(
      children: [
        Row(
          children: [
            Text('${title.name}: '),
            Flexible(
              child: Text(
                info,
                style: const TextStyle(fontWeight: FontWeight.bold),
                softWrap: true, // Allow text to wrap to the next line
              ),
            ),
          ],
        ),
        if (!isLastItem) const Divider()
      ],
    ),
  );
}

