class UserModel {
  final String? id;
  final List<String> fName;
  final List<String> mName;
  final List<String> lName;
  final String email;
  final List<String> phone;
  final List<String> DOB;
  final List<String> gender;
   final List<String> country;
  final List<String> state;
  final List<String> city;
  final List<String> area;
  final List<String> aadhaarCardImage1;
  final List<String> aadhaarCardImage2;
  final List<String> aadhaarNumber;
  final List<String> uIdNumber;
  final List<String> read;
  final List<String> write;
  final String category;
  final String userRole;
  final bool isVerified;
  bool isDeleted;
  final bool isBlocked;
  final bool isPinVerified;
  final bool isOtpVerified;
  final List<String> profilePicture;
  final String timestamps;
  bool isActive;
  final String pinCode;
  final String street1;
  final String street2;
  

  UserModel({
    this.id,
    required this.fName,
    required this.mName,
    required this.lName,
    required this.email,
    required this.phone,
    required this.DOB,
    required this.gender,
    required this.country,
    required this.state,
    required this.city,
    required this.area,
    required this.aadhaarCardImage1,
    required this.aadhaarCardImage2,
    required this.aadhaarNumber,
    required this.read,
    required this.write,
    required this.category,
    required this.userRole,
    required this.isVerified,
    required this.isDeleted,
    required this.isBlocked,
    required this.isPinVerified,
    required this.isOtpVerified,
    required this.profilePicture,
    required this.timestamps,
    required this.isActive,
    required this.pinCode,
    required this.street1,
    required this.street2,
    required this.uIdNumber,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    String extractLast(List<dynamic>? list) {
      return (list != null && list.isNotEmpty) ? list.last.toString() : '';
    }

    return UserModel(
      id: json['_id'],
      fName: List<String>.from(json['fName'] ?? []),
      mName: List<String>.from(json['mName'] ?? []),
      lName: List<String>.from(json['lName'] ?? []),
      email: json['email'] ?? '',
      phone: List<String>.from(json['phone'] ?? []),
      DOB: List<String>.from(json['DOB'] ?? []),
      gender: List<String>.from(json['gender'] ?? []),
      country: List<String>.from(json['country'] ?? []),
      state: List<String>.from(json['state'] ?? []),
      city: List<String>.from(json['city'] ?? []),
      area: List<String>.from(json['area'] ?? []),
      aadhaarCardImage1: List<String>.from(json['aadhaarCardImage1'] ?? []),
      aadhaarCardImage2: List<String>.from(json['aadhaarCardImage2'] ?? []),
      aadhaarNumber: List<String>.from(
        json['aadharNumber'] ?? [],
      ), // typo fixed
      read: List<String>.from(json['read'] ?? []),
      write: List<String>.from(json['write'] ?? []),
      category: json['userCategory'] ?? '',
      userRole: json['role'] ?? '',
      isVerified: json['isVerified'] ?? false,
      isDeleted: json['isDeleted'] ?? false,
      isBlocked: json['isBlocked'] ?? false,
      isPinVerified: json['isPinVerified'] ?? false,
      isOtpVerified: json['isOtpVerified'] ?? false,
      profilePicture: List<String>.from(json['profileImage'] ?? []),
      timestamps: json['createdAt'] ?? '',
      isActive: json['isActive'] ?? true,
      pinCode: extractLast(json['pinCode']),
      street1: extractLast(json['street1']),
      street2: extractLast(json['street2']),
      uIdNumber: List<String>.from(
        json['uIdNumber'] ?? [],
      ), // typo fixed
    );
  }
}
