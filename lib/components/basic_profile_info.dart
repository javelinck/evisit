import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../main/user_details.dart';
import '../types/user.dart';

class BasicProfileInfo extends StatelessWidget {
  final User? userProfile;
  const BasicProfileInfo({super.key, required this.userProfile});

  @override
  Widget build(BuildContext context) {
    return Container(
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
            infoRow(UsersDetails.Email, userProfile!.email),
            infoRow(UsersDetails.Gender, userProfile!.gender),
            infoRow(UsersDetails.DateOfBirth, transformDate(userProfile!.dob)),
            infoRow(UsersDetails.Address, '${userProfile!.address}, ${userProfile!.city}, ${userProfile!.state}'),
            infoRow(UsersDetails.Phone, userProfile!.phone, isLastItem: true),
          ],
        ),
      )
    );
  }
}

Widget infoRow(UsersDetails title, String info, {bool isLastItem = false})  {
  return Column(
    children: [
      Row(
        children: [
          Text('${title.name}: '),
          Text(
            info,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
      if (!isLastItem) const Divider()
    ],
  );
}

String transformDate(String inputDate) {
  final dateTime = DateTime.parse(inputDate);
  final formattedDate = DateFormat('MMMM d, y').format(dateTime);
  return formattedDate;
}