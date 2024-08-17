import 'package:jikan_api/jikan_api.dart';

class AnimeSeasonsHelper {
  final List<SeasonType> seasonOrder = [
    SeasonType.winter,
    SeasonType.spring,
    SeasonType.summer,
    SeasonType.fall
  ];

  final Map<SeasonType, List<String>> seasons = {
    SeasonType.winter: ['January', 'February', 'March'],
    SeasonType.spring: ['April', 'May', 'June'],
    SeasonType.summer: ['July', 'August', 'September'],
    SeasonType.fall: ['October', 'November', 'December'],
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
  (SeasonType, int) getCurrentSeason() {
    final month = getMonthName(DateTime.now().month);

    for (var entry in seasons.entries) {
      if (entry.value.contains(month)) {
        return (entry.key, DateTime.now().year);
      }
    }
    return (SeasonType.summer, DateTime.now().year);
  }

  (SeasonType, int) getPreviousSeason() {
    int currentIndex = seasonOrder.indexOf(getCurrentSeason().$1);
    int previousIndex = (currentIndex - 1) % seasonOrder.length;
    final String month = getMonthName(DateTime.now().month);
    final SeasonType currentSeason = getCurrentSeason().$1;
    int year = DateTime.now().year;

    if (previousIndex < 0) {
      previousIndex += seasonOrder.length;
    }

    // Handles the year transition
    if (month == 'January' && currentSeason == SeasonType.winter) {
      year -= 1;
    }

    return (seasonOrder[previousIndex], year);
  }
}
