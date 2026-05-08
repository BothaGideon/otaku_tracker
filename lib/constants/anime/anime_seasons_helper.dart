import 'package:jikan_api/jikan_api.dart';

enum SeasonSelectionFilter { upcoming, current, past }

class SeasonYearType {
  SeasonType seasonType;
  int year;

  SeasonYearType({required this.seasonType, required this.year});
}

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
  SeasonYearType getCurrentSeason() {
    final month = getMonthName(DateTime.now().month);

    for (var entry in seasons.entries) {
      if (entry.value.contains(month)) {
        return SeasonYearType(seasonType: entry.key, year: DateTime.now().year);
      }
    }
    return SeasonYearType(
        seasonType: SeasonType.summer, year: DateTime.now().year);
  }

  SeasonYearType getPreviousSeason() {
    int currentIndex = seasonOrder.indexOf(getCurrentSeason().seasonType);
    int previousIndex = (currentIndex - 1) % seasonOrder.length;
    final String month = getMonthName(DateTime.now().month);
    final SeasonType currentSeason = getCurrentSeason().seasonType;
    int year = DateTime.now().year;

    if (previousIndex < 0) {
      previousIndex += seasonOrder.length;
    }

    // Handles the year transition
    if (month == 'January' && currentSeason == SeasonType.winter) {
      year -= 1;
    }

    return SeasonYearType(seasonType: seasonOrder[previousIndex], year: year);
  }

  SeasonYearType getUpcomingSeason() {
    SeasonType upcomingSeasonType;
    final SeasonType currentSeason = getCurrentSeason().seasonType;
    final String currentMonth = getMonthName(DateTime.now().month);
    final int currentYear = DateTime.now().year;
    int currentSeasonIndex = seasonOrder.indexOf(currentSeason);

    // Handles the year transition
    if (currentMonth == 'December' && currentSeason == SeasonType.fall) {
      return SeasonYearType(
          seasonType: SeasonType.winter, year: currentYear + 1);
    } else {
      upcomingSeasonType = seasonOrder[currentSeasonIndex + 1];
      return SeasonYearType(seasonType: upcomingSeasonType, year: currentYear);
    }
  }
}
