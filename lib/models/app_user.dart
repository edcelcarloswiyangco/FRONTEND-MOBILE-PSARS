class AppUser {
  const AppUser({
    required this.id,
    required this.fullName,
    this.firstName,
    this.middleName,
    this.lastName,
    this.suffix,
    required this.email,
    required this.contactNumber,
    required this.address,
    required this.isAdmin,
    this.countryCode,
    this.phoneNumber,
    this.houseNumber,
    this.buildingName,
    this.streetName,
    this.barangay,
    this.cityMunicipality,
    this.province,
    this.zipCode,
  });

  final int id;
  final String fullName;
  final String? firstName;
  final String? middleName;
  final String? lastName;
  final String? suffix;
  final String email;
  final String contactNumber;
  final String address;
  final bool isAdmin;
  final String? countryCode;
  final String? phoneNumber;
  final String? houseNumber;
  final String? buildingName;
  final String? streetName;
  final String? barangay;
  final String? cityMunicipality;
  final String? province;
  final String? zipCode;

  String get name => fullName;

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as int,
      fullName: (json['full_name'] ?? json['name']) as String,
      firstName: json['first_name'] as String?,
      middleName: json['middle_name'] as String?,
      lastName: json['last_name'] as String?,
      suffix: json['suffix'] as String?,
      email: json['email'] as String,
      contactNumber: (json['contact_number'] ?? '') as String,
      address: (json['address'] ?? '') as String,
      isAdmin: json['is_admin'] == true,
      countryCode: json['country_code'] as String?,
      phoneNumber: json['phone_number'] as String?,
      houseNumber: json['house_number'] as String?,
      buildingName: json['building_name'] as String?,
      streetName: json['street_name'] as String?,
      barangay: json['barangay'] as String?,
      cityMunicipality: json['city_municipality'] as String?,
      province: json['province'] as String?,
      zipCode: json['zip_code'] as String?,
    );
  }
}
