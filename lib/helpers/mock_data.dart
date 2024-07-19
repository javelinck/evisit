class EmergencyUser {
  String name;
  String relationship;
  String phone;
  String address;

  EmergencyUser({ required this.name, required this.relationship, required this.phone, required this.address });
}

final List<EmergencyUser> emergencyContacts = [
  EmergencyUser(name: 'Lelia Shepard', relationship: 'wife', phone: '+1 (858) 470-2681', address: '123 Main Street, St Louis, MN'),
  EmergencyUser(name: 'Dorothea Diaz', relationship: 'brother', phone: '+1 (845) 466-3122', address: '180 Foster Avenue, Delco, North Carolina'),
  EmergencyUser(name: 'Ferrell Kramer', relationship: 'father', phone: '+1 (938) 507-3035', address: '364 Anna Court, Vowinckel, North Dakota'),
];
