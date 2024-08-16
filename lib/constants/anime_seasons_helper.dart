class AnimeSeasonsHelper {
  final List<String> seasonOrder = ['winter', 'spring', 'summer', 'fall'];

  final Map<String, List<String>> seasons = {
    'winter': ['January', 'February', 'March'],
    'spring': ['April', 'May', 'June'],
    'summer': ['July', 'August', 'September'],
    'fall': ['October', 'November', 'December'],
  };

  final List<String> monthNames = [
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

  // Helper function to convert month integer to month name
  String getMonthName(int month) {
    return monthNames[month - 1];
  }

  // Helper function to determine the season based on the month name
  (String, int) getCurrentSeason() {
    final month = getMonthName(DateTime.now().month);

    for (var entry in seasons.entries) {
      if (entry.value.contains(month)) {
        return (entry.key, DateTime.now().year);
      }
    }
    return ('Unknown', DateTime.now().year);
  }

  (String, int) getPreviousSeason() {
    int currentIndex = seasonOrder.indexOf(getCurrentSeason().$1);
    int previousIndex = (currentIndex - 1) % seasonOrder.length;
    final String month = getMonthName(DateTime.now().month);
    final String currentSeason = getCurrentSeason().$1;
    int year = DateTime.now().year;

    if (previousIndex < 0) {
      previousIndex += seasonOrder.length;
    }

    // Handles the year transition
    if (month == 'January' && currentSeason == 'winter') {
      year -= 1;
    }

    return (seasonOrder[previousIndex], year);
  }
}
