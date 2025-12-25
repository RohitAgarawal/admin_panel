import 'dart:convert';
import 'package:admin_panel/local_Storage/admin_shredPreferences.dart';
import 'package:admin_panel/model/access_code_model/access_code_model.dart';
import 'package:admin_panel/network_connection/apis.dart';
import 'package:admin_panel/utils/toast_message/toast_message.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import '../../model/user_model/user_model.dart';

class AccessCodeProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<AccessCodeModel> _accessCodes = [];
  List<AccessCodeModel> get accessCodes => _accessCodes;
  List<UserModel> _users = [];
  List<UserModel> get users => _users;

  Future<List<dynamic>?> getUserByAccessCode(String accessCode) async {
    String token = await AdminSharedPreferences().getAuthToken();
    final encodedPin = Uri.encodeComponent(accessCode);

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    var request = http.Request(
      'GET',
      Uri.parse(
        '${Apis.BASE_URL}/admin/get-user-by-assign-pin?pin=$encodedPin',
      ),
    );

    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    String resString = await response.stream.bytesToString();
    Map<String, dynamic> json = jsonDecode(resString);
    print(json);

    if (response.statusCode == 200) {
      return json['users'];
    } else {
      print("API error: ${response.reasonPhrase}");
      return null;
    }
  }

  Future<void> getUserByAccessCode11(String accessCode) async {
    String token = await AdminSharedPreferences().getAuthToken();
    final encodedPin = Uri.encodeComponent(accessCode);
    _isLoading = true;
    notifyListeners();
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    var request = http.Request(
      'GET',
      Uri.parse(
        '${Apis.BASE_URL}/admin/get-user-by-assign-pin?pin=$encodedPin',
      ),
    );
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    String resString = await response.stream.bytesToString();
    Map<String, dynamic> json = jsonDecode(resString);
    print(json);
    if (response.statusCode == 200) {
      _isLoading = false;
      notifyListeners();
      return json['data'];
    } else {
      _isLoading = false;
      notifyListeners();
      print(response.reasonPhrase);
      return null;
    }
  }

  Future<void> getAccessCode() async {
    String token = await AdminSharedPreferences().getAuthToken();
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    var request = http.Request(
      'GET',
      Uri.parse('${Apis.BASE_URL}/admin/get-access-codes'),
    );
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    String resString = await response.stream.bytesToString();
    Map<String, dynamic> json = jsonDecode(resString);
    print(json);
    if (response.statusCode == 200) {
      // print(await response.stream.bytesToString());
      List<AccessCodeModel> tempList = [];
      for (var item in json['data']) {
        tempList.add(AccessCodeModel.fromJson(item));
      }
      _accessCodes = tempList;
      notifyListeners();
    } else if (response.statusCode == 401 ||
        response.statusCode == 403 ||
        response.statusCode == 423) {
      AdminSharedPreferences().logout(message: "Session Expired");
    } else {
      print("Error: ${response.reasonPhrase}");
    }
  }

  Future<void> userAccess(Map<String, dynamic> body) async {
    try {
      String token = await AdminSharedPreferences().getAuthToken();
      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
      var request = http.Request(
        'POST',
        Uri.parse('${Apis.BASE_URL}/admin/user-access'),
      );
      request.body = json.encode(body);
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      String resString = await response.stream.bytesToString();
      Map<String, dynamic> data = jsonDecode(resString);
      print(data);
      if (response.statusCode == 200) {
        ToastMessage.success("Success", "Access code sent successfully");
        // GetxNavigation.goBack();
      } else if (response.statusCode == 401 ||
          response.statusCode == 403 ||
          response.statusCode == 423) {
        AdminSharedPreferences().logout(message: "Session Expired");
      } else {
        ToastMessage.error("Error", data['message'] ?? "User not found");
        print(response.reasonPhrase);
      }
    } catch (e) {
      print(e);
      ToastMessage.error("Error", "Something went wrong");
    }
  }

  Future<void> sendPin(Map<String, dynamic> body) async {
    String token = await AdminSharedPreferences().getAuthToken();
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    var request = http.Request(
      'POST',
      Uri.parse('${Apis.BASE_URL}/admin/access_pin'),
    );
    request.body = json.encode(body);
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
    } else {
      print(response.reasonPhrase);
    }
  }
}
