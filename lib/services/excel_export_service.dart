import 'dart:typed_data';
import 'package:admin_panel/model/user_model/user_model.dart';
import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:universal_date_parser/universal_date_parser.dart';
import 'package:universal_html/html.dart' as html;

/// Service class for exporting user data to Excel format
class ExcelExportService {
  /// Exports a list of users to an Excel file and triggers download
  ///
  /// [users] - List of UserModel objects to export
  /// Returns true if export was successful, false otherwise
  static Future<bool> exportUsersToExcel(List<UserModel> users) async {
    try {
      // Create a new Excel document
      var excel = Excel.createExcel();

      // Get the default sheet
      Sheet sheetObject = excel['Sheet1'];

      // Rename sheet to something meaningful
      excel.rename('Sheet1', 'Users Data');
      sheetObject = excel['Users Data'];

      // Define headers with all UserModel fields
      List<String> headers = [
        'ID',
        'First Name',
        'Middle Name',
        'Last Name',
        'Email',
        'Phone',
        'Date of Birth',
        'Gender',
        'Country',
        'State',
        'City',
        'Area',
        'Street 1',
        'Street 2',
        'Pin Code',
        'Aadhaar Number',
        'UID Number',
        'Category',
        'User Role',
        'Is Verified',
        'Is Deleted',
        'Is Blocked',
        'Is PIN Verified',
        'Is OTP Verified',
        'Is Active',
        'Date',
        'Time',
      ];

      // Add headers to first row
      for (int i = 0; i < headers.length; i++) {
        var cell = sheetObject.cell(
          CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0),
        );
        cell.value = TextCellValue(headers[i]);

        // Style header cells
        cell.cellStyle = CellStyle(
          bold: true,
          fontSize: 12,
          backgroundColorHex: ExcelColor.fromHexString('#4CAF50'),
          fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
        );
      }

      // Add user data rows
      for (int i = 0; i < users.length; i++) {
        UserModel user = users[i];
        int rowIndex = i + 1; // +1 because row 0 is headers

        List<String> rowData = [
          user.id ?? '',
          user.fName.isNotEmpty ? user.fName.last : '',
          user.mName.isNotEmpty ? user.mName.last : '',
          user.lName.isNotEmpty ? user.lName.last : '',
          user.email,
          user.phone.isNotEmpty ? user.phone.last : '',
          user.DOB.isNotEmpty ? _formatDate(user.DOB.last) : '',
          user.gender.isNotEmpty ? user.gender.last : '',
          user.country.isNotEmpty ? user.country.last : '',
          user.state.isNotEmpty ? user.state.last : '',
          user.city.isNotEmpty ? user.city.last : '',
          user.area.isNotEmpty ? user.area.last : '',
          user.street1,
          user.street2,
          user.pinCode,
          user.aadhaarNumber.isNotEmpty ? user.aadhaarNumber.last : '',
          user.uIdNumber.isNotEmpty ? user.uIdNumber.last : '',
          user.category,
          user.userRole,
          user.isVerified ? 'Yes' : 'No',
          user.isDeleted ? 'Yes' : 'No',
          user.isBlocked ? 'Yes' : 'No',
          user.isPinVerified ? 'Yes' : 'No',
          user.isOtpVerified ? 'Yes' : 'No',
          user.isActive ? 'Yes' : 'No',
          UniversalDateParser().formatDate(
            date: user.timestamps,
            outputDateFormat: 'dd-MM-yyyy',
          ),
          _formatTime(user.timestamps),
        ];

        for (int j = 0; j < rowData.length; j++) {
          var cell = sheetObject.cell(
            CellIndex.indexByColumnRow(columnIndex: j, rowIndex: rowIndex),
          );
          cell.value = TextCellValue(rowData[j]);
        }
      }

      // Auto-fit columns (set reasonable widths)
      for (int i = 0; i < headers.length; i++) {
        sheetObject.setColumnWidth(i, 20);
      }

      // Generate Excel file as bytes
      var fileBytes = excel.encode();

      if (fileBytes == null) {
        return false;
      }

      // Generate filename with timestamp
      String timestamp = DateFormat(
        'yyyy-MM-dd_HH-mm-ss',
      ).format(DateTime.now());
      String filename = 'users_data_$timestamp.xlsx';

      // Download file for web
      _downloadFile(fileBytes, filename);

      return true;
    } catch (e) {
      print('Error exporting to Excel: $e');
      return false;
    }
  }

  /// Format date string to readable format
  static String _formatDate(String dateStr) {
    try {
      if (dateStr.isEmpty) return '';
      DateTime date = DateTime.parse(dateStr);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  /// Format datetime string to readable format with time
  static String _formatDateTime(String dateStr) {
    try {
      if (dateStr.isEmpty) return '';

      // 1. Parse the string. If it contains a timezone offset (e.g., +00:00 or Z),
      // it's parsed as that time.
      DateTime date = DateTime.parse(dateStr);

      // 2. CRITICAL FIX: Convert the parsed time to the device's local timezone.
      DateTime localDate = date.toLocal();

      // 3. Format the local date and time.
      return DateFormat('MMM dd, yyyy HH:mm').format(localDate);
    } catch (e) {
      // If parsing fails (e.g., bad string format), return the original string.
      return dateStr;
    }
  }

  /// Format datetime string to readable format with time
  static String _formatTime(String dateStr) {
    try {
      if (dateStr.isEmpty) return '';

      // 1. Parse the string. If it contains a timezone offset (e.g., +00:00 or Z),
      // it's parsed as that time.
      DateTime date = DateTime.parse(dateStr);

      // 2. CRITICAL FIX: Convert the parsed time to the device's local timezone.
      DateTime localDate = date.toLocal();

      // 3. Format the local date and time.
      return DateFormat('HH:mm:ss').format(localDate);
    } catch (e) {
      // If parsing fails (e.g., bad string format), return the original string.
      return dateStr;
    }
  }

  /// Triggers file download in web browser
  static void _downloadFile(List<int> bytes, String filename) {
    // Create a Blob from the bytes
    final blob = html.Blob([Uint8List.fromList(bytes)]);

    // Create a download link
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', filename)
      ..click();

    // Clean up
    html.Url.revokeObjectUrl(url);
  }
}
