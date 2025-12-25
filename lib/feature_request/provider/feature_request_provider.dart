import 'dart:convert';

import 'package:admin_panel/feature_request/model/feature_request_data_list_model.dart';
import 'package:admin_panel/local_Storage/admin_shredPreferences.dart';
import 'package:admin_panel/network_connection/apis.dart';
import 'package:admin_panel/utils/toast_message/toast_message.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class FeatureRequestProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  FeatureRequestDataListModel? _featureRequestData;

  // Getters
  bool get isLoading => _isLoading;

  bool get hasError => _hasError;

  String get errorMessage => _errorMessage;

  FeatureRequestDataListModel? get featureRequestData => _featureRequestData;

  List<FeatureRequestData> get featureRequests =>
      _featureRequestData?.data ?? [];

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String message) {
    _hasError = true;
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    _hasError = false;
    _errorMessage = '';
    notifyListeners();
  }

  Future<void> getAllFeatureRequest() async {
    _setLoading(true);
    clearError();

    try {
      String token = await AdminSharedPreferences().getAuthToken();
      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'accept': 'application/json',
      };
      var request = http.Request('GET', Uri.parse(Apis.GET_FEATURE_REQUEST));
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();
      String responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonData = jsonDecode(responseBody);
        _featureRequestData = FeatureRequestDataListModel.fromJson(jsonData);
        notifyListeners();
      } else if (response.statusCode == 401 ||
          response.statusCode == 403 ||
          response.statusCode == 423) {
        AdminSharedPreferences().logout(message: "Session Expired");
      } else {
        _setError(response.reasonPhrase ?? 'Failed to load feature requests');
      }
    } catch (e) {
      _setError('Error fetching feature requests: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateFeatureRequestStatus({
    required String featureRequestId,
    required String featureStatus,
    required featureRequestStatusMessage,
  }) async {
    _setLoading(true);
    clearError();

    try {
      String token = await AdminSharedPreferences().getAuthToken();
      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'accept': 'application/json',
      };
      var request = http.Request(
        'PUT',
        Uri.parse(Apis.UPDATE_FEATURE_REQUEST_STATUS(featureRequestId)),
      );
      request.body = jsonEncode({
        "status": featureStatus,
        "statusMessage": featureRequestStatusMessage,
      });
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      String responseBody = await response.stream.bytesToString();
      Map<String, dynamic> jsonData = jsonDecode(responseBody);

      if (response.statusCode == 200) {
        // Optionally, refresh the feature requests list
        // Show confirmation message
        if (featureStatus.toLowerCase() == FeatureRequestStatus.accepted.name) {
          ToastMessage.success(
            "Success",
            'Feature request ${featureStatus.toLowerCase()}ed with note',
          );
        } else {
          ToastMessage.success(
            "Success",
            'Feature request ${featureStatus.toLowerCase()}ed with note',
          );
        }
        await getAllFeatureRequest();
      } else if (response.statusCode == 401 ||
          response.statusCode == 403 ||
          response.statusCode == 423) {
        AdminSharedPreferences().logout(message: "Session Expired");
      } else {
        ToastMessage.error(
          "Error",
          jsonData['error'] ?? 'Failed to update feature request status',
        );
      }
    } catch (e) {
      ToastMessage.error(
        "Error",
        'Error updating feature request status: ${e.toString()}',
      );
    } finally {
      _setLoading(false);
    }
  }
}
