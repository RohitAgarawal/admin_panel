import 'dart:convert';

import 'package:admin_panel/local_Storage/admin_shredPreferences.dart';
import 'package:admin_panel/navigation/getX_navigation.dart';
import 'package:admin_panel/utils/toast_message/toast_message.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import '../../model/product_model/product.dart';
import '../../model/user_model/user_model.dart';
import '../../model/user_model/user_tab_model.dart';
import '../../network_connection/apis.dart';
import '../../network_connection/constants.dart';

class UserProvider extends ChangeNotifier {
  bool _isLoading = false;

  String _userRole = "";
  String get userRole => _userRole;
  bool get isLoading => _isLoading;
  String _userFName = "";
  String get userFName => _userFName;

  String _registrationDate = "";
  String get registrationDate => _registrationDate;

  String _userMName = "";
  String get userMName => _userMName;

  String _userLName = "";
  String get userLName => _userLName;

  String _userEmail = "";
  String get userEmail => _userEmail;

  String _userPhone = "";
  String get userPhone => _userPhone;

  String _userDOB = "";
  String get userDOB => _userDOB;

  String _userGender = "";
  String get userGender => _userGender;

  String _userState = "";
  String get userState => _userState;

  String _userDistrict = "";
  String get userDistrict => _userDistrict;

  String _userStreet1 = "";
  String get userStreet1 => _userStreet1;

  String _userStreet2 = "";
  String get userStreet2 => _userStreet2;
  String _userArea = "";
  String get userArea => _userArea;

  String _userPinCode = "";
  String get userPinCode => _userPinCode;

  String _userId = "";
  String get userId => _userId;

  String _userProfileImage = "";
  String get userProfileImage => _userProfileImage;

  String _userAadhaarFront = "";
  String get userAadhaarFront => _userAadhaarFront;

  String _userAadhaarBack = "";
  String get userAadhaarBack => _userAadhaarBack;

  String _userAadhaarNumber = "";
  String get userAadhaarNumber => _userAadhaarNumber;
  String _uIdNumber = "";
  String get uIdNumber => _uIdNumber;

  String _userOccupationId = "";
  String get userOccupationId => _userOccupationId;

  String _userCategory = "";
  String get userCategory => _userCategory;

  String _userAssignPin = "";
  String get userAssignPin => _userAssignPin;
  // Boolean flags
  bool _isVerified = false;
  bool get isVerified => _isVerified;

  bool _isDeleted = false;
  bool get isDeleted => _isDeleted;

  bool _isBlocked = false;
  bool get isBlocked => _isBlocked;

  bool _isPinVerified = false;
  bool get isPinVerified => _isPinVerified;

  bool _isOtpVerified = false;
  bool get isOtpVerified => _isOtpVerified;

  bool _isActive = false;
  bool get isActive => _isActive;

  //read or write list
  List<String> _userReadData = [];
  List<String> get userReadDataList => _userReadData;

  List<String> _userWriteData = [];
  List<String> get userWriteDataList => _userWriteData;

  List<UserTabModel> _userCategories = [];
  List<UserTabModel> get userCategories => _userCategories;

  String _selectedCategory = "";
  String get getSelectedCategory => _selectedCategory;

  List<UserModel> _usersByCategory = [];
  List<UserModel> get usersByCategory => _usersByCategory;

  List<UserModel> _allUsers = [];
  List<UserModel> get allUsers => _allUsers;

  String _selectedStatus = ''; // '', 'Pending', 'Disabled', 'Deleted'
  String get selectedStatus => _selectedStatus;
  void setStatus(String status) {
    _selectedStatus = status;
    notifyListeners();
  }

  void setCategories(List<UserTabModel> categories) {
    _userCategories = categories;
    notifyListeners();
  }

  void setSelectedCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  String _statusFilter = ''; // '', 'Pending', 'Disabled', 'Deleted'
  String get statusFilter => _statusFilter;

  void setStatusFilter(String val) {
    _statusFilter = val;
    notifyListeners();
  }

  Future<void> getUserCategory() async {
    String token = await AdminSharedPreferences().getAuthToken();
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    var request = http.Request('GET', Uri.parse(Apis.GET_USER_CATEGORY));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    final responseBody = await response.stream.bytesToString();
    final data = json.decode(responseBody);

    if (response.statusCode == 200) {
      List<UserTabModel> apiCategories = (data['userCategories'] as List)
          .map((e) => UserTabModel.fromJson(e))
          .toList();

      List<String> defaults = ['A', 'B', 'α', 'β'];
      List<UserTabModel> finalCategories = [];

      for (var def in defaults) {
        var existing = apiCategories.firstWhere(
          (element) => element.category == def,
          orElse: () => UserTabModel(category: def, count: 0),
        );
        finalCategories.add(existing);
      }

      // Add any other categories returned by API that are not in defaults
      for (var cat in apiCategories) {
        if (!defaults.contains(cat.category)) {
          finalCategories.add(cat);
        }
      }

      _userCategories = finalCategories;

      int totalCount = _userCategories.fold(0, (sum, item) => sum + item.count);
      _userCategories.insert(
        0,
        UserTabModel(category: 'All', count: totalCount),
      ); // Add "All" category

      notifyListeners(); // update UI
      print("Categories: $_userCategories");
    } else if (response.statusCode == 401 ||
        response.statusCode == 403 ||
        response.statusCode == 423) {
      AdminSharedPreferences().logout(message: "Session Expired");
    } else {
      print("Error: ${response.reasonPhrase}");
    }
  }

  Future<void> getUser({String category = ""}) async {
    _isLoading = true;
    notifyListeners();
    try {
      String token = await AdminSharedPreferences().getAuthToken();
      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
      var request = http.Request(
        'GET',
        Uri.parse(Apis.GET_USER_BY_CATEGORY(_selectedCategory)),
      );
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      String responseBody = await response.stream.bytesToString();

      final data = json.decode(responseBody);
      print(data);

      if (response.statusCode == 200) {
        List<dynamic> usersJson = data['users'];
        List<UserModel> list = usersJson
            .map((e) => UserModel.fromJson(e))
            .toList();
        if (_statusFilter == 'Pending') {
          list = list
              .where(
                (u) => (u.category == 'A' || u.category == 'α')
                    ? !u.isPinVerified
                    : !u.isOtpVerified,
              )
              .toList();
        } else if (_statusFilter == 'Disabled') {
          list = list.where((u) => !u.isActive).toList();
        } else if (_statusFilter == 'Deleted') {
          list = list.where((u) => u.isDeleted).toList();
        }

        _usersByCategory = list;
      } else if (response.statusCode == 401 ||
          response.statusCode == 403 ||
          response.statusCode == 423) {
        AdminSharedPreferences().logout(message: "Session Expired");
      } else {
        print("Error: ${response.reasonPhrase}");
      }
    } catch (e) {
      print("Exception: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearUserData() {
    _userId = "";
    _userFName = "";
    _userMName = "";
    _userLName = "";
    _userGender = "";
    _userDOB = "";
    _userEmail = "";
    _userPhone = "";
    _userStreet1 = "";
    _userStreet2 = "";
    _userState = "";
    _userDistrict = "";
    _userArea = "";
    _userPinCode = "";
    _userAadhaarNumber = "";
    _uIdNumber = "";
    _userProfileImage = "";
    _userAadhaarFront = "";
    _userAadhaarBack = "";
    _userOccupationId = "";
    _userCategory = "";
    _userRole = "";
    _isDeleted = false;
    _isBlocked = false;
    _isPinVerified = false;
    _isOtpVerified = false;
    _isActive = true;
    _userAssignPin = "";
    _userReadData = [];
    _userWriteData = [];
    notifyListeners();
  }

  Future<void> fetchUserData(String userId) async {
    _userId = userId;
    _userFName = "";
    _userMName = "";
    _userLName = "";
    _userGender = "";
    _userDOB = "";
    _userEmail = "";
    _userPhone = "";
    _userStreet1 = "";
    _userStreet2 = "";
    _userState = "";
    _userDistrict = "";
    _userArea = "";
    _userPinCode = "";
    _userAadhaarNumber = "";
    _uIdNumber = "";
    _userProfileImage = "";
    _userAadhaarFront = "";
    _userAadhaarBack = "";
    _userOccupationId = "";
    _userCategory = "";
    _userRole = "";
    _isDeleted = false;
    _isBlocked = false;
    _isPinVerified = false;
    _isOtpVerified = false;
    _isActive = true;
    _userAssignPin = "";
    _userReadData = [];
    _userWriteData = [];
    notifyListeners();
    final uri = Uri.parse(Apis.GET_USER_BY_ID(userId));
    print(uri);
    print("--------->");
    try {
      String token = await AdminSharedPreferences().getAuthToken();
      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
      var request = http.Request('GET', uri);
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      String res = await response.stream.bytesToString();
      print(res);
      print("++++++++++++++");

      Map<String, dynamic> data = jsonDecode(res);

      if (response.statusCode == 200 && data['success'] == true) {
        Map<String, dynamic> userData = data['user'];

        // Assign data...
        _userId = userId;
        _userFName = (userData['fName'] as List).isNotEmpty
            ? userData['fName'].last
            : "";
        _registrationDate = userData['createdAt'].toString().isNotEmpty
            ? userData['createdAt'].toString()
            : "";
        _userMName = (userData['mName'] as List).isNotEmpty
            ? userData['mName'].last
            : "";
        _userLName = (userData['lName'] as List).isNotEmpty
            ? userData['lName'].last
            : "";
        _userGender = (userData['gender'] as List).isNotEmpty
            ? userData['gender'].last
            : "";
        _userDOB = (userData['DOB'] as List).isNotEmpty
            ? userData['DOB'].last
            : "";
        _userEmail = userData['email'] ?? "";
        _userPhone = (userData['phone'] as List).isNotEmpty
            ? userData['phone'].last
            : "";
        _userStreet1 = (userData['street1'] as List).isNotEmpty
            ? userData['street1'].last
            : "";
        _userStreet2 = (userData['street2'] as List).isNotEmpty
            ? userData['street2'].last
            : "";
        _userState = (userData['state'] as List).isNotEmpty
            ? userData['state'].last
            : "";
        _userDistrict = (userData['city'] as List).isNotEmpty
            ? userData['city'].last
            : "";
        _userArea = (userData['area'] as List).isNotEmpty
            ? userData['area'].last
            : "";
        _userPinCode = (userData['pinCode'] as List).isNotEmpty
            ? userData['pinCode'].last
            : "";
        _userAadhaarNumber = (userData['aadharNumber'] as List).isNotEmpty
            ? userData['aadharNumber'].last
            : "";
        _uIdNumber = (userData['uIdNumber'] as List).isNotEmpty
            ? userData['uIdNumber'].last
            : "";
        _userProfileImage = (userData['profileImage'] as List).isNotEmpty
            ? Apis.BASE_URL_IMAGE + userData['profileImage'].last
            : "";
        _userAadhaarFront = (userData['aadhaarCardImage1'] as List).isNotEmpty
            ? Apis.BASE_URL_IMAGE + userData['aadhaarCardImage1'].last
            : "";
        _userAadhaarBack = (userData['aadhaarCardImage2'] as List).isNotEmpty
            ? Apis.BASE_URL_IMAGE + userData['aadhaarCardImage2'].last
            : "";
        _userOccupationId = userData['occupationId']["name"] ?? "";
        _userCategory = userData['userCategory'] ?? "";
        _userRole = userData['role'] ?? "";
        _isDeleted = userData['isDeleted'] ?? false;
        _isBlocked = userData['isBlocked'] ?? false;
        _isPinVerified = userData['isPinVerified'] ?? false;
        _isOtpVerified = userData['isOtpVerified'] ?? false;
        _isActive = userData['isActive'] ?? true;
        _userAssignPin = userData['assignedPins'] ?? "";
        _userReadData = [];
        _userWriteData = [];

        for (var item in userData['read']) {
          _userReadData.add(item);
        }

        for (var item in userData['write']) {
          _userWriteData.add(item);
        }

        notifyListeners();
      } else if (response.statusCode == 401 ||
          response.statusCode == 403 ||
          response.statusCode == 423) {
        AdminSharedPreferences().logout(message: "Session Expired");
      } else {
        print("Error: ${data['message'] ?? response.reasonPhrase}");
      }
    } catch (e) {
      print("Exception during fetching user data: $e");
    } finally {
      setLoading(false);
      notifyListeners();
    }
  }

  Future<void> deleteUser(String userId) async {
    String token = await AdminSharedPreferences().getAuthToken();
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    var request = http.Request(
      'DELETE',
      Uri.parse(Apis.DELETE_USER_BY_ADMIN(userId)),
    );
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String result = await response.stream.bytesToString();
      print(result);

      // Find user and toggle isDeleted
      _usersByCategory = _usersByCategory.map((user) {
        if (user.id == userId) {
          user.isDeleted = !user.isDeleted;

          // Show toast based on action
          if (user.isDeleted) {
            ToastMessage.success("Deleted", "User soft deleted successfully");
          } else {
            ToastMessage.success("Restored", "User restored successfully");
          }
        }
        return user;
      }).toList();

      notifyListeners();
      GetxNavigation.goBack(); // optional: only if you're closing a modal/screen
    } else if (response.statusCode == 401 ||
        response.statusCode == 403 ||
        response.statusCode == 423) {
      AdminSharedPreferences().logout(message: "Session Expired");
    } else {
      ToastMessage.error("Error", "Failed to delete/restore user");
      print(response.reasonPhrase);
    }
  }

  Future<void> getAllUser() async {
    setLoading(true);
    _allUsers = [];
    String token = await AdminSharedPreferences().getAuthToken();
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    var request = http.Request('GET', Uri.parse(Apis.GET_ALL_USER));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    String res = await response.stream.bytesToString();

    Map<String, dynamic> data = jsonDecode(res);
    setLoading(false);
    if (response.statusCode == 200 && data['success'] == true) {
      _allUsers = (data['users'] as List)
          .map((userJson) => UserModel.fromJson(userJson))
          .toList();
      notifyListeners(); // 🔔 Update UI
    } else if (response.statusCode == 401 ||
        response.statusCode == 403 ||
        response.statusCode == 423) {
      AdminSharedPreferences().logout(message: "Session Expired");
    } else {
      print("Error: ${data['message'] ?? response.reasonPhrase}");
    }
  }

  Future<bool> userActiveInactive(String userId) async {
    try {
      setLoading(true); // Set loading state to true
      String token = await AdminSharedPreferences().getAuthToken();
      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
      final url = Uri.parse(Apis.USER_ACTIVE_INACTIVE(userId));
      final request = http.Request('POST', url);
      request.headers.addAll(headers);
      final response = await request.send();

      if (response.statusCode == 200) {
        final resBody = await response.stream.bytesToString();
        final data = json.decode(resBody);
        final statusMessage = data['message']?.toLowerCase() ?? '';

        if (statusMessage.contains('deactivated')) {
          ToastMessage.success("Success", "User deactivated successfully");
        } else if (statusMessage.contains('activated')) {
          ToastMessage.success("Success", "User activated successfully");
        } else {
          ToastMessage.success("Success", data['message']);
        }

        return true;
      } else if (response.statusCode == 401 ||
          response.statusCode == 403 ||
          response.statusCode == 423) {
        AdminSharedPreferences().logout(message: "Session Expired");
        return false;
      } else {
        ToastMessage.error("Error", "Failed to update user status");
        return false;
      }
    } catch (e) {
      ToastMessage.error("Exception", "Something went wrong: $e");
      return false;
    } finally {
      setLoading(false); // Reset loading state when done
    }
  }
}
