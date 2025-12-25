import 'dart:convert';
import 'package:admin_panel/local_Storage/admin_shredPreferences.dart';
import 'package:admin_panel/network_connection/apis.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../model/about_us_model.dart';

class AboutUsProvider extends ChangeNotifier {
  AboutUsModel? _aboutUs;
  bool _isLoading = false;
  String _error = '';

  AboutUsModel? get aboutUs => _aboutUs;
  bool get isLoading => _isLoading;
  String get error => _error;

  // Base URL for API
  final String _baseUrl = Apis.BASE_URL;

  // Method to fetch About Us data
  Future<void> fetchAboutUs() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    final url = Uri.parse(Apis.GET_ABOUT_US);
    try {
      String token = await AdminSharedPreferences().getAuthToken();
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data != null) {
          _aboutUs = AboutUsModel.fromJson(data);
        } else {
          _error = 'No about us data found';
        }
      } else if (response.statusCode == 401 ||
          response.statusCode == 403 ||
          response.statusCode == 423) {
        AdminSharedPreferences().logout(message: "Session Expired");
      } else {
        _error = 'Failed to load about us data: ${response.reasonPhrase}';
      }
    } catch (e) {
      _error = 'Error fetching about us data: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Method to update About Us data
  Future<bool> updateAboutUs(AboutUsModel aboutUs) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    final url = Uri.parse(Apis.UPDATE_ABOUT_US);
    try {
      String token = await AdminSharedPreferences().getAuthToken();
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(aboutUs.toJson()),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data != null) {
          _aboutUs = AboutUsModel.fromJson(data);
          return true;
        } else {
          _error = 'No data returned after update';
          return false;
        }
      } else if (response.statusCode == 401 ||
          response.statusCode == 403 ||
          response.statusCode == 423) {
        AdminSharedPreferences().logout(message: "Session Expired");
        return false;
      } else {
        _error = 'Failed to update about us data: ${response.reasonPhrase}';
        return false;
      }
    } catch (e) {
      _error = 'Error updating about us data: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Method to add new value
  void addNewValue() {
    if (_aboutUs != null) {
      _aboutUs!.ourValues.add(
        OurValueModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          icon: '',
          title: '',
          description: '',
        ),
      );
      notifyListeners();
    }
  }

  // Method to remove value at specific index
  void removeValue(int index) {
    if (_aboutUs != null && _aboutUs!.ourValues.length > index) {
      _aboutUs!.ourValues.removeAt(index);
      notifyListeners();
    }
  }

  // Clear any errors
  void clearError() {
    _error = '';
    notifyListeners();
  }
}
