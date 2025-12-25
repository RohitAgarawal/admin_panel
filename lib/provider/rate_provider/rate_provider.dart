import 'dart:convert';

import 'package:admin_panel/model/pagination/pagination_model.dart';
import 'package:admin_panel/model/rating/rating_model.dart';
import 'package:admin_panel/network_connection/apis.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import '../../local_Storage/admin_shredPreferences.dart';

class RateProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  List<RatingModel> _ratingList = [];
  List<RatingModel> get ratingList => _ratingList;
  PaginationModel? _paginationData;
  PaginationModel? get paginationData => _paginationData;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Future<void> getAllRatings({required int page, required int limit}) async {
    setLoading(true);
    try {
      String token = await AdminSharedPreferences().getAuthToken();
      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
      var request = http.Request(
        'GET',
        Uri.parse('${Apis.GET_ALL_RATINGS}?page=$page&limit=$limit'),
      );
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      String resString = await response.stream.bytesToString();
      Map<String, dynamic> json = jsonDecode(resString);
      print(json);
      if (response.statusCode == 200) {
        List<RatingModel> tempList = [];
        for (var item in json['data']) {
          tempList.add(RatingModel.fromJson(item));
        }
        _ratingList = tempList;

        // Parse pagination data
        if (json.containsKey('pagination')) {
          _paginationData = PaginationModel.fromJson(json['pagination']);
        }

        notifyListeners();
      } else if (response.statusCode == 401 ||
          response.statusCode == 403 ||
          response.statusCode == 423) {
        AdminSharedPreferences().logout(message: "Session Expired");
      } else {
        print(response.reasonPhrase);
      }
    } catch (e) {
      // Handle exception
      print(e);
    } finally {
      setLoading(false);
    }
  }
}
