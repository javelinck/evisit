import 'package:evisit_mobile/main/e_visits.dart';
import 'package:flutter/material.dart';

import 'emergency_list.dart';

class ProfileButtons extends StatefulWidget {
  final int role;
  final bool isProfile;
  final String? patientId;

  const ProfileButtons({Key? key, required this.role, required this.isProfile, this.patientId}) : super(key: key);

  @override
  _ProfileButtonsState createState() => _ProfileButtonsState();
}

class _ProfileButtonsState extends State<ProfileButtons> {
  void _onTapEmergency(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const EmergencyList(),
      ),
    );
  }

  void _onTapEvisits(BuildContext context) {
    if (widget.patientId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EvisitListScreen(patientId: widget.patientId,),
        ),
      );
    }
  }

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
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            if (widget.role == 0)
              Wrap(
                children: [
                  ProfileButton(
                    title: 'Emergency contact',
                    onTap: () {
                      _onTapEmergency(context);
                    },
                  ),
                  const Divider(),
                  ProfileButton(title: 'Evisits', onTap: () {
                    _onTapEvisits(context);
                  }),
                  if (widget.isProfile) const Divider(),
                ],
              ),
              if (widget.isProfile) ProfileButton(title: 'Settings', onTap: () {}),
          ],
        ),
      ),
    );
  }
}

class ProfileButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  const ProfileButton({super.key, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold),),
          const Spacer(),
          const Icon(Icons.arrow_forward_ios, size: 15),
        ],
      ),
    );
  }
}