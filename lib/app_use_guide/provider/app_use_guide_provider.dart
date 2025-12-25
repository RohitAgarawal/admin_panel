// app_use_guide_provider.dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:admin_panel/local_Storage/admin_shredPreferences.dart';
import 'package:admin_panel/app_use_guide/model/app_use_guide_model.dart';
import 'package:admin_panel/app_use_guide/model/video_metadata_model.dart';
import 'package:admin_panel/network_connection/apis.dart';
import 'package:admin_panel/utils/toast_message/toast_message.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:admin_panel/navigation/getX_navigation.dart';

class AppUseGuideProvider extends ChangeNotifier {
  String? title;
  String? description;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Video metadata
  VideoMetadataModel _videoMetadata = VideoMetadataModel();
  List<AppUseGuideModel> _appUseGuideVideoList = [];
  List<AppUseGuideModel> get appUseGuideVideoList => _appUseGuideVideoList;

  // String? videoName;
  // String? videoExtension;
  // int? videoSize; // in bytes
  // Uint8List? videoBytes;
  // String? videoBase64;

  bool get hasVideo => _videoMetadata.videoName != null;

  void setTitle(String value) {
    title = value;
    notifyListeners();
  }

  void setDescription(String value) {
    description = value;
    notifyListeners();
  }

  void setVideo(Uint8List bytes, String fileName) {
    _videoMetadata = VideoMetadataModel(
      videoName: fileName,
      videoExtension: fileName.split('.').last,
      videoSize: bytes.lengthInBytes,
      videoBytes: bytes,
      videoBase64: base64UrlEncode(bytes),
    );
    notifyListeners();
  }

  void removeVideo() {
    _videoMetadata = VideoMetadataModel();
    notifyListeners();
  }

  VideoMetadataModel get videoMetaData => _videoMetadata;

  void isLoadingSet(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> uploadVideo(Map<String, dynamic> body) async {
    try {
      _isLoading = true;
      notifyListeners();

      String token = await AdminSharedPreferences().getAuthToken();
      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
      var request = http.Request(
        'POST',
        Uri.parse(Apis.UPLOAD_APP_GUIDE_VIDEO),
      );
      request.headers.addAll(headers);
      request.body = jsonEncode(body);

      http.StreamedResponse response = await request.send();
      String respStr = await response.stream.bytesToString();
      Map<String, dynamic> respJson = json.decode(respStr);
      print(respJson);
      if (response.statusCode == 201) {
        ToastMessage.success("Success", "Video uploaded successfully");
        await getAppGuideVideo();
        GetxNavigation.goBack();
      } else if (response.statusCode == 401 ||
          response.statusCode == 403 ||
          response.statusCode == 423) {
        AdminSharedPreferences().logout(message: "Session Expired");
      } else {
        ToastMessage.error(
          "Error",
          "Failed to upload video: ${respJson['message'] ?? 'Unknown error'}",
        );
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error uploading video: $e');
      _isLoading = false;
      notifyListeners();
      ToastMessage.error("Error", 'Error uploading video');
    }
  }

  Future<void> getAppGuideVideo() async {
    try {
      _isLoading = true;
      notifyListeners();

      String token = await AdminSharedPreferences().getAuthToken();
      final response = await http.get(
        Uri.parse(Apis.GET_APP_GUIDE_VIDEO),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        _appUseGuideVideoList = (data['data'] as List)
            .map((videoJson) => AppUseGuideModel.fromJson(videoJson))
            .toList();
        notifyListeners();
      } else if (response.statusCode == 401 ||
          response.statusCode == 403 ||
          response.statusCode == 423) {
        AdminSharedPreferences().logout(message: "Session Expired");
      } else {
        final data = json.decode(response.body);
        print('Failed to fetch app guide video: ${response.reasonPhrase}');
        ToastMessage.error(
          "Error",
          data['message'] ?? 'Failed to fetch app guide video',
        );
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error fetching app guide video: $e');
      ToastMessage.error("Error", 'Error fetching app guide video');
      _isLoading = false;
      notifyListeners();
    }
  }

  // New: update visibility for a video by id
  Future<void> updateAppGuideVisibility(String id, bool visibility) async {
    try {
      // Optimistically update UI
      int idx = _appUseGuideVideoList.indexWhere((v) => v.id == id);
      bool previousValue = true;
      if (idx != -1) {
        previousValue = _appUseGuideVideoList[idx].visibility;
        _appUseGuideVideoList[idx].visibility = visibility;
        notifyListeners();
      }

      String token = await AdminSharedPreferences().getAuthToken();
      final url = Apis.APP_GUIDE_VIDEO_VISIBILITY_BY_ID(id);
      final response = await http.patch(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'visibility': visibility}),
      );

      if (response.statusCode == 200) {
        ToastMessage.success('Success', 'Visibility updated');
        getAppGuideVideo();
      } else if (response.statusCode == 401 ||
          response.statusCode == 403 ||
          response.statusCode == 423) {
        AdminSharedPreferences().logout(message: "Session Expired");
      } else {
        // revert on error
        if (idx != -1) {
          _appUseGuideVideoList[idx].visibility = previousValue;
          notifyListeners();
        }
        final data = json.decode(response.body);
        ToastMessage.error(
          'Error',
          data['message'] ?? 'Failed to update visibility',
        );
      }
    } catch (e) {
      print('Error updating visibility: $e');
      ToastMessage.error('Error', 'Failed to update visibility');
    }
  }
}
