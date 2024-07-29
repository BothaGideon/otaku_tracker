class AnimeSeasonsHelper {
  // Helper function to convert month integer to month name
  String getMonthName(int month) {
    List<String> monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return monthNames[month - 1];
  }

  // Helper function to determine the season based on the month name
  String getSeason(String month) {
    Map<String, List<String>> seasons = {
      'winter': ['January', 'February', 'March'],
      'spring': ['April', 'May', 'June'],
      'summer': ['July', 'August', 'September'],
      'fall': ['October', 'November', 'December'],
    };

    for (var entry in seasons.entries) {
      if (entry.value.contains(month)) {
        return entry.key;
      }
    }
    return 'Unknown';
  }
}
