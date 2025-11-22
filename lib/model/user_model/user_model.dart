
//
// class UserModel {
//   String? id;
//   List<String> fName;
//   List<String> mName;
//   List<String> lName;
//   String email;
//   List<String> phone;
//   List<String> DOB;
//   List<String> gender;
//   List<String> state;
//   List<String> district;
//   List<String> area;
//   List<String> aadhaarCardImage1;
//   List<String> aadhaarCardImage2;
//   List<String> aadhaarNumber;
//   List<String> read;
//   List<String> write;
//   String category;
//   String userRole;
//   bool isVerified;
//   bool isDeleted;
//   bool isBlocked;
//   bool isPinVerified;
//   bool isOtpVerified;
//   List<String> profilePicture;
//   String timestamps;
//   bool isActive;
// String pinCode;
// String street1;
// String street2;
//
//   UserModel({
//     this.id,
//     required this.fName,
//     required this.mName,
//     required this.email,
//     required this.phone,
//     required this.profilePicture,
//     required this.lName,
//     required this.DOB,
//     required this.category,
//     required this.area,
//     required this.aadhaarCardImage1,
//     required this.aadhaarCardImage2,
//     required this.aadhaarNumber,
//     required this.district,
//     required this.gender,
//     required this.isDeleted,
//     required this.isBlocked,
//     required this.isOtpVerified,
//     required this.isPinVerified,
//     required this.isVerified,
//     required this.read,
//     required this.state,
//     required this.userRole,
//     required this.write,
//     required this.timestamps,
//     required this.isActive,
//     required this.pinCode,
//     required this.street1,
//     required this.street2,
//   });
//
//   factory UserModel.fromJson(Map<String, dynamic> json) {
//     return UserModel(
//       id: json['_id'],
//       fName: List<String>.from(json['fName'] ?? []),
//       mName: List<String>.from(json['mName'] ?? []),
//       lName: List<String>.from(json['lName'] ?? []),
//       street1: List<String>.from(json['street1'] ?? []),
//       street2: List<String>.from(json['street2'] ?? []),
//       email: json['email'] ?? '',
//       phone: List<String>.from(json['phone'] ?? []),
//       profilePicture: List<String>.from(json['profileImage'] ?? []),
//       DOB: List<String>.from(json['DOB'] ?? []),
//       category: json['userCategory'] ?? '',
//       area: List<String>.from(json['area'] ?? []),
//       pinCode: json['pinCode']is List ? json['pinCode'].length > 0
//           ? json['pinCode'][json['pinCode'].length - 1] : '':'',
//       aadhaarCardImage1: List<String>.from(json['aadhaarCardImage1'] ?? []),
//       aadhaarCardImage2: List<String>.from(json['aadhaarCardImage2'] ?? []),
//       aadhaarNumber: List<String>.from(json['aadharNumber'] ?? []), // fixed typo
//       district: List<String>.from(json['district'] ?? []),
//       gender: List<String>.from(json['gender'] ?? []),
//       isDeleted: json['isDeleted'] ?? false,
//       isBlocked: json['isBlocked'] ?? false,
//       isOtpVerified: json['isOtpVerified'] ?? false,
//       isPinVerified: json['isPinVerified'] ?? false,
//       isVerified: json['isVerified'] ?? false,
//       isActive: json['isActive'] ?? true,
//       read: List<String>.from(json['read'] ?? []),
//       state: List<String>.from(json['state'] ?? []),
//       userRole: json['role'] ?? '', // changed from userRole
//       write: List<String>.from(json['write'] ?? []),
//       timestamps: json['createdAt'] ?? '',
//     );
//   }
// }

class UserModel {
  final String? id;
  final List<String> fName;
  final List<String> mName;
  final List<String> lName;
  final String email;
  final List<String> phone;
  final List<String> DOB;
  final List<String> gender;
  final List<String> state;
  final List<String> district;
  final List<String> area;
  final List<String> aadhaarCardImage1;
  final List<String> aadhaarCardImage2;
  final List<String> aadhaarNumber;
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
    required this.state,
    required this.district,
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
      state: List<String>.from(json['state'] ?? []),
      district: List<String>.from(json['district'] ?? []),
      area: List<String>.from(json['area'] ?? []),
      aadhaarCardImage1: List<String>.from(json['aadhaarCardImage1'] ?? []),
      aadhaarCardImage2: List<String>.from(json['aadhaarCardImage2'] ?? []),
      aadhaarNumber: List<String>.from(json['aadharNumber'] ?? []), // typo fixed
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
    );
  }
  
}



