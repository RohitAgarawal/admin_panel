import 'dart:convert';

import 'package:admin_panel/local_Storage/admin_shredPreferences.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../network_connection/apis.dart';

class TotalUserProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  int _categoryAUnverifiedPinCount = 0;
  int _categoryBOtpUnverifiedCount = 0;
  int get categoryAUnverifiedPinCount => _categoryAUnverifiedPinCount;
  int get categoryBOtpUnverifiedCount => _categoryBOtpUnverifiedCount;

  int _category1UnverifiedOtpCount = 0;
  int _category2UnverifiedOtpCount = 0;
  int get category1UnverifiedPinCount => _category1UnverifiedOtpCount;
  int get category2UnverifiedPinCount => _category2UnverifiedOtpCount;

  // report count
  int _totalReport = 0;
  int get totalReport => _totalReport;
  //total user
  int _totalUser = 0;
  int get totalUser => _totalUser;
  int _totalUserA = 0;
  int get totalUserA => _totalUserA;
  int _totalUserB = 0;
  int get totalUserB => _totalUserB;
  int _totalUser1 = 0;
  int get totalUser1 => _totalUser1;
  int _totalUser2 = 0;
  int get totalUser2 => _totalUser2;

  //verified user
  int _verifiedUser = 0;
  int get verifiedUser => _verifiedUser;
  int _verifiedUserA = 0;
  int get verifiedUserA => _verifiedUserA;
  int _verifiedUserB = 0;
  int get verifiedUserB => _verifiedUserB;
  int _verifiedUser1 = 0;
  int get verifiedUser1 => _verifiedUser1;
  int _verifiedUser2 = 0;
  int get verifiedUser2 => _verifiedUser2;

  //pending user
  int _pendingUser = 0;
  int get pendingUser => _pendingUser;
  int _pendingUserA = 0;
  int get pendingUserA => _pendingUserA;
  int _pendingUserB = 0;
  int get pendingUserB => _pendingUserB;
  int _pendingUser1 = 0;
  int get pendingUser1 => _pendingUser1;
  int _pendingUser2 = 0;
  int get pendingUser2 => _pendingUser2;

  //deleted user
  int _deletedUser = 0;
  int get deletedUser => _deletedUser;
  int _deletedUserA = 0;
  int get deletedUserA => _deletedUserA;
  int _deletedUserB = 0;
  int get deletedUserB => _deletedUserB;
  int _deletedUser1 = 0;
  int get deletedUser1 => _deletedUser1;
  int _deletedUser2 = 0;
  int get deletedUser2 => _deletedUser2;

  //disable user
  int _disableUser = 0;
  int get disableUser => _disableUser;
  int _disableUserA = 0;
  int get disableUserA => _disableUserA;
  int _disableUserB = 0;
  int get disableUserB => _disableUserB;
  int _disableUser1 = 0;
  int get disableUser1 => _disableUser1;
  int _disableUser2 = 0;
  int get disableUser2 => _disableUser2;

  set verifiedUser(int value) {
    _verifiedUser = value;
    notifyListeners();
  }

  set pendingUser(int value) {
    _pendingUser = value;
    notifyListeners();
  }

  set deletedUser(int value) {
    _deletedUser = value;
    notifyListeners();
  }

  set totalUser(int value) {
    _totalUser = value;
    notifyListeners();
  }

  set disableUser(int value) {
    _disableUser = value;
    notifyListeners();
  }

  int _categoryACount = 0;
  int get categoryACount => _categoryACount;
  set categoryACount(int value) {
    _categoryACount = value;
    notifyListeners();
  }

  int _categoryBCount = 0;
  int get categoryBCount => _categoryBCount;
  set categoryBCount(int value) {
    _categoryBCount = value;
    notifyListeners();
  }

  int _category1ACount = 0;
  int get category1ACount => _category1ACount;
  set category1ACount(int value) {
    _category1ACount = value;
    notifyListeners();
  }

  int _category2ACount = 0;
  int get category2ACount => _category2ACount;
  set category2ACount(int value) {
    _category2ACount = value;
    notifyListeners();
  }

  int _totalProductCount = 0;
  int get totalProductCount => _totalProductCount;
  int _totalProductA = 0;
  int get totalProductA => _totalProductA;

  int _totalProductB = 0;
  int get totalProductB => _totalProductB;

  int _totalProductC = 0;
  int get totalProductC => _totalProductC;

  int _totalProductD = 0;
  int get totalProductD => _totalProductD;

  int _totalProductE = 0;
  int get totalProductE => _totalProductE;

  Future<void> userCount() async {
    try {
      String token = await AdminSharedPreferences().getAuthToken();
      _isLoading = true;
      notifyListeners();

      final response = await http.get(
        Uri.parse(Apis.GET_ALL_USER),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print("🟢 Status Code: ${response.statusCode}");
      print("🟢 Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);

        if (json['success'] == true) {
          totalUser = json['totalUsers'] ?? 0;
          verifiedUser = json['verifiedUsers'] ?? 0;
          pendingUser = json['pendingAccessUsers'] ?? 0;
          deletedUser = json['deletedUsers'] ?? 0;
          disableUser = json['disabledUsers'] ?? 0;

          final categoryStats = json['categoryStats'] ?? {};
          _totalUserA = categoryStats['Category_A']?['total'] ?? 0;
          _totalUserB = categoryStats['Category_B']?['total'] ?? 0;
          _totalUser1 = categoryStats['Category_α']?['total'] ?? 0;
          _totalUser2 = categoryStats['Category_β']?['total'] ?? 0;

          _verifiedUserA = categoryStats['Category_A']?['verified'] ?? 0;
          _verifiedUserB = categoryStats['Category_B']?['verified'] ?? 0;
          _verifiedUser1 = categoryStats['Category_α']?['verified'] ?? 0;
          _verifiedUser2 = categoryStats['Category_β']?['verified'] ?? 0;

          _pendingUserA = categoryStats['Category_A']?['pending'] ?? 0;
          _pendingUserB = categoryStats['Category_B']?['pending'] ?? 0;
          _pendingUser1 = categoryStats['Category_α']?['pending'] ?? 0;
          _pendingUser2 = categoryStats['Category_β']?['pending'] ?? 0;

          _deletedUserA = categoryStats['Category_A']?['deleted'] ?? 0;
          _deletedUserB = categoryStats['Category_B']?['deleted'] ?? 0;
          _deletedUser1 = categoryStats['Category_α']?['deleted'] ?? 0;
          _deletedUser2 = categoryStats['Category_β']?['deleted'] ?? 0;

          _disableUserA = categoryStats['Category_A']?['disable'] ?? 0;
          _disableUserB = categoryStats['Category_B']?['disable'] ?? 0;
          _disableUser1 = categoryStats['Category_α']?['disable'] ?? 0;
          _disableUser2 = categoryStats['Category_β']?['disable'] ?? 0;

          final productStats = json['productStats'] ?? {};
          _totalProductCount = productStats['totalProductCount'] ?? 0;

          final productCategoryCounts = productStats['categoryCounts'] ?? {};
          _totalProductA = productCategoryCounts['A'] ?? 0;
          _totalProductB = productCategoryCounts['B'] ?? 0;
          _totalProductC = productCategoryCounts['C'] ?? 0;
          _totalProductD = productCategoryCounts['D'] ?? 0;
          _totalProductE = productCategoryCounts['E'] ?? 0;

          final reportStats = json['reportStats'] ?? {};
          _totalReport = reportStats['totalReportedProducts'] ?? 0;

          notifyListeners();
        } else {
          print("⚠️ API returned success: false");
        }
      } else if (response.statusCode == 401 ||
          response.statusCode == 403 ||
          response.statusCode == 423) {
        AdminSharedPreferences().logout(message: "Session Expired");
      } else {
        print("❌ Error: ${response.statusCode}");
        print("❌ Response Body: ${response.body}");
      }
    } catch (e) {
      print("❌ Exception occurred: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Future<void> userCount() async {
  //
  //   try {
  //     _isLoading = true;
  //     notifyListeners();
  //     String token = await AdminSharedPreferences().getAuthToken();
  //     var request = http.Request(
  //       'GET',
  //       Uri.parse('https://api.bhavnika.shop/api/admin/get_all_user'),
  //     );
  //     request.headers.addAll({
  //       'Content-Type': 'application/json',
  //       'Authorization' : 'Bearer $token',
  //     });
  //     http.StreamedResponse response = await request.send();
  //
  //     if (response.statusCode == 200) {
  //       final resString = await response.stream.bytesToString();
  //       print(resString);
  //
  //       final Map<String, dynamic> json = jsonDecode(resString);
  //
  //       if (json['success'] == true) {
  //         totalUser = json['totalUsers'] ?? 0;
  //         verifiedUser = json['verifiedUsers'] ?? 0;
  //         pendingUser = json['pendingAccessUsers'] ?? 0;
  //         deletedUser = json['deletedUsers'] ?? 0;
  //         disableUser = json['disabledUsers'] ?? 0;
  //
  //         final categoryStats = json['categoryStats'] ?? {};
  //         _totalUserA = categoryStats['Category_A']?['total'] ?? 0;
  //         _totalUserB = categoryStats['Category_B']?['total'] ?? 0;
  //         _totalUser1 = categoryStats['Category_α']?['total'] ?? 0;
  //         _totalUser2 = categoryStats['Category_β']?['total'] ?? 0;
  //
  //         _verifiedUserA = categoryStats['Category_A']?['verified'] ?? 0;
  //         _verifiedUserB = categoryStats['Category_B']?['verified'] ?? 0;
  //         _verifiedUser1 = categoryStats['Category_α']?['verified'] ?? 0;
  //         _verifiedUser2 = categoryStats['Category_β']?['verified'] ?? 0;
  //
  //         _pendingUserA = categoryStats['Category_A']?['pending'] ?? 0;
  //         _pendingUserB = categoryStats['Category_B']?['pending'] ?? 0;
  //         _pendingUser1 = categoryStats['Category_α']?['pending'] ?? 0;
  //         _pendingUser2 = categoryStats['Category_β']?['pending'] ?? 0;
  //
  //         _deletedUserA = categoryStats['Category_A']?['deleted'] ?? 0;
  //         _deletedUserB = categoryStats['Category_B']?['deleted'] ?? 0;
  //         _deletedUser1 = categoryStats['Category_α']?['deleted'] ?? 0;
  //         _deletedUser2 = categoryStats['Category_β']?['deleted'] ?? 0;
  //
  //         _disableUserA = categoryStats['Category_A']?['disable'] ?? 0;
  //         _disableUserB = categoryStats['Category_B']?['disable'] ?? 0;
  //         _disableUser1 = categoryStats['Category_α']?['disable'] ?? 0;
  //         _disableUser2 = categoryStats['Category_β']?['disable'] ?? 0;
  //
  //         final productStats = json['productStats'] ?? {};
  //         _totalProductCount = productStats['totalProductCount'] ?? 0;
  //
  //         final productCategoryCounts = productStats['categoryCounts'] ?? {};
  //         _totalProductA = productCategoryCounts['A'] ?? 0;
  //         _totalProductB = productCategoryCounts['B'] ?? 0;
  //         _totalProductC = productCategoryCounts['C'] ?? 0;
  //         _totalProductD = productCategoryCounts['D'] ?? 0;
  //         _totalProductE = productCategoryCounts['E'] ?? 0;
  //
  //         //report count
  //         final reportStats = json['reportStats'] ?? {};
  //         _totalReport = reportStats['totalReportedProducts'] ?? 0;
  //
  //         notifyListeners();
  //       }
  //
  //     } else {
  //       print(response.reasonPhrase);
  //     }
  //
  //     _isLoading = false;
  //     notifyListeners();
  //   } on Exception catch (e) {
  //     print(e);
  //   }
  // }
}
