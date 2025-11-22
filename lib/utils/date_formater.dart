class DateFormater {
  // 2025-11-12T01:16:02.690Z -> 12 Nov 2025, 06:46 AM
  // take ISO date string which is in UTC format (with 'Z' at the end
  // its universal time format convert it into local time format
  static String formatDate(String isoDate) {
    try {
      DateTime parsedDate = DateTime.parse(isoDate).toLocal();
      String day = parsedDate.day.toString().padLeft(2, '0');
      String month = _getMonthAbbreviation(parsedDate.month);
      String year = parsedDate.year.toString();
      String hour = parsedDate.hour.toString().padLeft(2, '0');
      String minute = parsedDate.minute.toString().padLeft(2, '0');
      String amPm = parsedDate.hour >= 12 ? 'PM' : 'AM';

      return '$day $month $year, $hour:$minute $amPm';
    } catch (e) {
      return isoDate; // return original string if parsing fails
    }
  }
  static String _getMonthAbbreviation(int month) {
    const monthAbbreviations = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return monthAbbreviations[month - 1];
  }
}