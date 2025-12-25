import 'dart:convert';

import 'package:admin_panel/local_Storage/admin_shredPreferences.dart';
import 'package:admin_panel/model/report_model/report_model.dart';
import 'package:admin_panel/services/excel_export_service.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

import '../../network_connection/apis.dart';

class ReportProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  int _reportCount = 0;
  int get reportCountValue => _reportCount;

  List<ReportModel> _reports = [];
  List<ReportModel> get reports => _reports;

  ReportModel? _selectedReport;
  ReportModel? get selectedReport => _selectedReport;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> getReports() async {
    try {
      String token = await AdminSharedPreferences().getAuthToken();
      setLoading(true);
      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
      var request = http.Request(
        'GET',
        Uri.parse('${Apis.BASE_URL}/admin/report_product'),
      );
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      String responseBody = await response.stream.bytesToString();
      Map<String, dynamic> jsonData = json.decode(responseBody);

      if (response.statusCode == 200) {
        _reports = (jsonData['data'] as List<dynamic>).map((e) {
          return ReportModel.fromJson(e as Map<String, dynamic>);
        }).toList();
      } else if (response.statusCode == 401 ||
          response.statusCode == 403 ||
          response.statusCode == 423) {
        AdminSharedPreferences().logout(message: "Session Expired");
      } else {
        print("Error: ${response.reasonPhrase}");
      }
    } catch (e) {
      print("Exception in getReports: $e");
    } finally {
      setLoading(false);
    }
  }

  Future<void> reportsDetailsByReportId(String reportId) async {
    try {
      setLoading(true);
      String token = await AdminSharedPreferences().getAuthToken();
      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
      var request = http.Request(
        'GET',
        Uri.parse(
          '${Apis.BASE_URL}/admin/get_report_product_by_id?reportId=$reportId',
        ),
      );
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final jsonData = json.decode(responseBody);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonData['data'];
        _selectedReport = ReportModel.fromJson(data);
      } else if (response.statusCode == 401 ||
          response.statusCode == 403 ||
          response.statusCode == 423) {
        AdminSharedPreferences().logout(message: "Session Expired");
        return null;
      } else {
        print("Error: ${response.reasonPhrase}");
        return null;
      }
    } catch (e) {
      print("Exception in reportsDetailsByReportId: $e");
      return null;
    } finally {
      setLoading(false);
      notifyListeners();
    }
  }

  Future<void> reportCount() async {
    try {
      String token = await AdminSharedPreferences().getAuthToken();
      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
      var request = http.Request(
        'GET',
        Uri.parse('${Apis.BASE_URL}/admin/get_report_count'),
      );
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final jsonData = json.decode(responseBody);
        _reportCount = jsonData['count'] ?? 0;
      } else if (response.statusCode == 401 ||
          response.statusCode == 403 ||
          response.statusCode == 423) {
        AdminSharedPreferences().logout(message: "Session Expired");
      } else {
        print("Error: ${response.reasonPhrase}");
      }
    } catch (e) {
      print("Exception in reportCount: $e");
    } finally {
      notifyListeners(); // Notify listeners when count changes
    }
  }

  Future<bool> updateReportStatus(
    String reportId,
    String status,
    String note,
  ) async {
    try {
      setLoading(true);
      String token = await AdminSharedPreferences().getAuthToken();
      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
      var body = json.encode({
        "reportId": reportId,
        "status": status,
        "note": note,
      });

      var request = http.Request(
        'PUT',
        Uri.parse('${Apis.BASE_URL}/admin/update-report-status'),
      );
      request.body = body;
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();
      await response.stream.bytesToString();

      if (response.statusCode == 200) {
        await getReports();
        if (_selectedReport != null && _selectedReport!.id == reportId) {
          await reportsDetailsByReportId(reportId);
        }
        return true;
      } else if (response.statusCode == 401 ||
          response.statusCode == 403 ||
          response.statusCode == 423) {
        AdminSharedPreferences().logout(message: "Session Expired");
        return false;
      } else {
        print("Error: ${response.reasonPhrase}");
        return false;
      }
    } catch (e) {
      print("Exception in updateReportStatus: $e");
      return false;
    } finally {
      setLoading(false);
    }
  }

  // --- Excel Export Logic ---
  bool _isDownloading = false;
  bool get isDownloading => _isDownloading;

  void setDownloading(bool value) {
    _isDownloading = value;
    notifyListeners();
  }

  Future<bool> downloadReportsExcel(String statusFilter) async {
    try {
      setDownloading(true);
      String token = await AdminSharedPreferences().getAuthToken();
      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      var request = http.Request(
        'GET',
        Uri.parse('${Apis.BASE_URL}/admin/export-reports?status=$statusFilter'),
      );
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();
      String responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonData = json.decode(responseBody);
        List<ReportModel> exportData = (jsonData['data'] as List<dynamic>).map((
          e,
        ) {
          return ReportModel.fromJson(e as Map<String, dynamic>);
        }).toList();

        // Use the service to download
        return await ExcelExportService.exportReportsToExcel(exportData);
      } else if (response.statusCode == 401 ||
          response.statusCode == 403 ||
          response.statusCode == 423) {
        AdminSharedPreferences().logout(message: "Session Expired");
        return false;
      } else {
        print("Error fetching reports for export: ${response.reasonPhrase}");
        return false;
      }
    } catch (e) {
      print("Exception in downloadReportsExcel: $e");
      return false;
    } finally {
      setDownloading(false);
    }
  }
}
