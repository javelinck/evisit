import 'package:maps_launcher/maps_launcher.dart';
import 'package:url_launcher/url_launcher.dart';

void makePhoneCall(String phoneNumber) async {
  final Uri telLaunchUri = Uri(
    scheme: 'tel',
    path: phoneNumber,
  );

  if (await canLaunchUrl(telLaunchUri)) {
    await launchUrl(telLaunchUri);
  } else {
    throw 'Could not launch $telLaunchUri';
  }
}

void sendEmail(String emailAddress) async {
  final Uri emailUri = Uri(
    scheme: 'mailto',
    path: emailAddress,
  );

  if (await canLaunchUrl(emailUri)) {
    await launchUrl(emailUri);
  } else {
    throw 'Could not launch $emailUri';
  }
}

void openMapWithAddress(String address) async {
  try {
    await MapsLauncher.launchQuery(address);
  } catch (e) {
    throw 'Could not launch $address';
  }
}