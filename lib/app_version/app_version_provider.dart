import 'dart:convert';

import 'package:admin_panel/local_Storage/admin_shredPreferences.dart';
import 'package:admin_panel/app_version/app_version_model.dart';
import 'package:admin_panel/navigation/getX_navigation.dart';
import 'package:admin_panel/utils/toast_message/toast_message.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import '../network_connection/apis.dart';

class AppVersionProvider extends ChangeNotifier {
  List<AppVersionModel> _appVersions = [];

  List<AppVersionModel> get appVersions => _appVersions;

  Future<void> getAllAppVersion() async {
    try {
      _appVersions = []; // Clear the list before fetching new data
      String token = await AdminSharedPreferences().getAuthToken();
      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
      var request = http.Request('GET', Uri.parse(Apis.GET_ALL_APP_VERSIONS));
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      String responseBody = await response.stream.bytesToString();
      Map<String, dynamic> resJson = jsonDecode(responseBody);
      print(resJson);
      if (response.statusCode == 200) {
        _appVersions = (resJson['data'] as List<dynamic>).map((e) {
          return AppVersionModel.fromJson(e as Map<String, dynamic>);
        }).toList();
      } else if (response.statusCode == 401 ||
          response.statusCode == 403 ||
          response.statusCode == 423) {
        AdminSharedPreferences().logout(message: "Session Expired");
      } else {
        print("Error: ${response.reasonPhrase}");
      }
    } catch (e) {
      print("Exception in getAllAppVersion: $e");
    } finally {
      notifyListeners();
    }
  }

  // create app version
  Future<void> createAppVersion(AppVersionModel appVersion) async {
    try {
      String token = await AdminSharedPreferences().getAuthToken();
      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
      var request = http.Request('POST', Uri.parse(Apis.CREATE_APP_VERSION));
      request.headers.addAll(headers);
      request.body = jsonEncode(appVersion.toJson());
      http.StreamedResponse response = await request.send();
      print("Response body: ${request.body}");
      String responseBody = await response.stream.bytesToString();
      Map<String, dynamic> resJson = jsonDecode(responseBody);
      print("Response JSON: $resJson");
      if (response.statusCode == 201) {
        ToastMessage.success("Success", "App version created successfully");
        await getAllAppVersion(); // Refresh the list after creation
        GetxNavigation.goBack();
      } else if (response.statusCode == 401 ||
          response.statusCode == 403 ||
          response.statusCode == 423) {
        AdminSharedPreferences().logout(message: "Session Expired");
      } else {
        print("Error: ${response.reasonPhrase}");
        ToastMessage.error(
          "Error",
          "Failed to create app version: ${resJson['message'] ?? 'Unknown error'}",
        );
        GetxNavigation.goBack();
      }
    } catch (e) {
      print("Exception in createAppVersion: $e");
      ToastMessage.error("Error", "Failed to create app version: $e");
      GetxNavigation.goBack();
    } finally {
      notifyListeners();
    }
  }
}
