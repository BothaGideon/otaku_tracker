import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jikan_api/jikan_api.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:otaku_tracker/models/response/anime.dart';
import 'package:otaku_tracker/pages/anime_details_page.dart';
import 'package:otaku_tracker/pages/landing_page.dart';
import 'package:otaku_tracker/pages/my_list_page.dart';
import 'package:otaku_tracker/pages/my_profile_page.dart';
import 'package:otaku_tracker/providers/anime_list_provider.dart';
import 'package:otaku_tracker/providers/my_list_filter_provider.dart';
import 'package:otaku_tracker/providers/oauth_provider.dart';
import 'package:otaku_tracker/services/anime_list_service.dart';
import 'package:otaku_tracker/services/oauth_service.dart';
import 'package:otaku_tracker/widgets/poster_image_title.dart';
import 'package:otaku_tracker/widgets/user_avatar.dart';

Widget createTestApp({
  required List<Override> overrides,
  Widget child = const MyListPage(),
}) {
  return ProviderScope(
    overrides: overrides,
    child: Directionality(
      textDirection: TextDirection.ltr,
      child: MediaQuery(
        data: const MediaQueryData(),
        child: MaterialApp(home: child),
      ),
    ),
  );
}

UserAnimeData buildUserAnimeData({
  required int id,
  required String title,
  required String status,
  int score = 0,
  double? mean,
}) {
  return UserAnimeData(
    node: Node(id: id, title: title, mean: mean),
    listStatus: ListStatus(
      status: status,
      score: score,
      numEpisodesWatched: 0,
      isRewatching: false,
      updatedAt: '2024-01-01T00:00:00+00:00',
    ),
  );
}

class FakeAnimeListService extends AnimeListService {
  @override
  Future<AnimeDTO> searchAnime(String query, {int limit = 30}) async {
    if (query.toLowerCase().contains('steins')) {
      return AnimeDTO(
        data: [
          AnimeData(
            node: Node(id: 10, title: 'Steins;Gate'),
          ),
        ],
      );
    }

    return AnimeDTO(data: []);
  }
}


class FakeOauthService extends OauthService {
  FakeOauthService({
    this.username,
    this.accessToken,
    this.picture,
    this.animeStatistics,
    this.loginUsername,
    this.loginAccessToken = 'new-token',
    this.loginPicture,
    this.loginAnimeStatistics,
  });

  String? username;
  String? accessToken;
  String? picture;
  Map<String, num?>? animeStatistics;
  String? loginUsername;
  String? loginAccessToken;
  String? loginPicture;
  Map<String, num?>? loginAnimeStatistics;
  bool didLogout = false;

  @override
  Future<Map<String, Object?>> getCurrentUserData(String accessToken) async {
    return {
      'username': username,
      'picture': picture,
      'animeStatistics': animeStatistics,
    };
  }

  @override
  Future<String?> getAccessToken() async => accessToken;

  @override
  Future<String?> getUsername() async => username;

  @override
  Future<String?> getUserPicture() async => picture;

  @override
  Future<void> saveUserPicture(String? picture) async {
    this.picture = picture;
  }

  @override
  Future<String?> login() async {
    username = loginUsername;
    accessToken = loginAccessToken;
    picture = loginPicture;
    animeStatistics = loginAnimeStatistics;

    return loginUsername;
  }

  @override
  Future<void> logout() async {
    didLogout = true;
    username = null;
    accessToken = null;
    picture = null;
    animeStatistics = null;
  }
}

Anime buildAnimeDetails({
  required int id,
  required String title,
  String? synopsis,
}) {
  return Anime((b) => b
    ..malId = id
    ..url = 'https://example.com/anime/$id'
    ..imageUrl = 'https://cdn.example.com/anime/$id.jpg'
    ..title = title
    ..titleEnglish = title
    ..airing = false
    ..score = 8.9
    ..rank = 12
    ..popularity = 34
    ..type = 'TV'
    ..status = 'Finished Airing'
    ..episodes = 24
    ..synopsis = synopsis ?? 'A detailed synopsis for $title.'
    ..background = 'Background information for $title.'
    ..season = 'fall'
    ..year = 2023
    ..rating = 'PG-13'
    ..source = 'Light novel'
    ..duration = '24 min per ep'
    ..studios.add(Meta((b) => b
      ..malId = 1
      ..type = 'anime'
      ..name = 'Madhouse'
      ..url = 'https://example.com/studios/1'))
    ..genres.addAll([
      Meta((b) => b
        ..malId = 2
        ..type = 'anime'
        ..name = 'Adventure'
        ..url = 'https://example.com/genres/2'),
      Meta((b) => b
        ..malId = 3
        ..type = 'anime'
        ..name = 'Drama'
        ..url = 'https://example.com/genres/3'),
    ])
    ..relations.add(Relation((b) => b
      ..relation = 'Sequel'
      ..entry.add(Meta((b) => b
        ..malId = 999
        ..type = 'anime'
        ..name = '$title Season 2'
        ..url = 'https://example.com/anime/999')))));
}

Recommendation buildRecommendation({
  required int id,
  required String title,
  int votes = 123,
}) {
  return Recommendation((b) => b
    ..entry.malId = id
    ..entry.url = 'https://example.com/anime/$id'
    ..entry.imageUrl = 'https://cdn.example.com/anime/$id.jpg'
    ..entry.title = title
    ..url = 'https://example.com/recommendations/$id'
    ..votes = votes);
}

void main() {
  final fakeUserAnimeList = UserAnimeListDTO(
    data: [
      buildUserAnimeData(
        id: 1,
        title: 'Frieren',
        status: 'watching',
        score: 9,
        mean: 8.9,
      ),
      buildUserAnimeData(
        id: 2,
        title: 'Cowboy Bebop',
        status: 'completed',
        score: 10,
        mean: 8.8,
      ),
      buildUserAnimeData(
        id: 3,
        title: 'Monster',
        status: 'on_hold',
        mean: 8.7,
      ),
    ],
  );

  testWidgets('logged out My List shows auth button without profile action',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      createTestApp(
        overrides: [
          userDataProvider.overrideWith(
            (ref) async =>
                {'username': null, 'accessToken': null, 'picture': null},
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Log in with MyAnimeList'), findsOneWidget);
    expect(find.text('Login with MyAnimeList'), findsOneWidget);
    expect(find.textContaining('We do not store your anime data'), findsOneWidget);
    expect(find.byIcon(Symbols.account_circle), findsNothing);
  });

  testWidgets('logging in from My List refreshes My Profile statistics after a logout state',
      (WidgetTester tester) async {
    final fakeOauthService = FakeOauthService(
      loginUsername: 'lumen',
      loginAccessToken: 'token',
      loginPicture: 'https://cdn.myanimelist.net/images/userimages/2.jpg',
      loginAnimeStatistics: {
        'numItemsWatching': 5,
        'numItemsCompleted': 120,
        'numItemsOnHold': 8,
        'numItemsDropped': 3,
        'numItemsPlanToWatch': 47,
        'numItems': 183,
        'numEpisodes': 412,
        'numDaysWatched': 123.4,
        'numTimesRewatched': 6,
        'meanScore': 8.56,
      },
    );

    await tester.pumpWidget(
      createTestApp(
        overrides: [
          oauthProvider.overrideWith((ref) => fakeOauthService),
          userAnimeListProvider.overrideWith((ref) async => fakeUserAnimeList),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Log in with MyAnimeList'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Login with MyAnimeList'));
    await tester.pumpAndSettle();

    expect(find.byTooltip('My Profile'), findsOneWidget);

    await tester.tap(find.byTooltip('My Profile'));
    await tester.pumpAndSettle();

    expect(find.text('Your anime journey'), findsOneWidget);
    expect(find.text('Episodes watched'), findsOneWidget);
    expect(find.text('List breakdown'), findsOneWidget);
    expect(find.text('Completed'), findsOneWidget);
    expect(find.text('Plan to watch'), findsOneWidget);
    expect(find.text('Rewatches'), findsOneWidget);
    expect(find.text('412'), findsOneWidget);
    expect(find.text('123.4'), findsOneWidget);
    expect(find.text('8.56'), findsOneWidget);
    expect(find.text('183'), findsOneWidget);
  });

  testWidgets('logged in My List shows profile action and filter chips',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      createTestApp(
        overrides: [
          userDataProvider.overrideWith(
            (ref) async => {
              'username': 'lumen',
              'accessToken': 'token',
              'picture': 'https://cdn.myanimelist.net/images/userimages/1.jpg',
            },
          ),
          userAnimeListProvider.overrideWith((ref) async => fakeUserAnimeList),
        ],
      ),
    );
    await tester.pumpAndSettle();

    final avatar = tester.widget<UserAvatar>(find.byType(UserAvatar).first);
    expect(avatar.pictureUrl,
        'https://cdn.myanimelist.net/images/userimages/1.jpg');
    expect(find.byType(ChoiceChip), findsNWidgets(MyListStatusFilter.values.length));
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Plan to watch'), findsOneWidget);
  });

  testWidgets('tapping a filter chip updates the visible list and empty state',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      createTestApp(
        overrides: [
          userDataProvider.overrideWith(
            (ref) async => {
              'username': 'lumen',
              'accessToken': 'token',
              'picture': null,
            },
          ),
          userAnimeListProvider.overrideWith((ref) async => fakeUserAnimeList),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Frieren'), findsOneWidget);
    expect(find.text('Cowboy Bebop'), findsOneWidget);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Completed'));
    await tester.pumpAndSettle();

    expect(find.text('Cowboy Bebop'), findsOneWidget);
    expect(find.text('Frieren'), findsNothing);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Dropped'));
    await tester.pumpAndSettle();

    expect(find.text('No titles in Dropped'), findsOneWidget);
  });

  testWidgets('My List falls back to the community mean when no user score exists',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      createTestApp(
        overrides: [
          userDataProvider.overrideWith(
            (ref) async => {
              'username': 'lumen',
              'accessToken': 'token',
              'picture': null,
            },
          ),
          userAnimeListProvider.overrideWith((ref) async => fakeUserAnimeList),
        ],
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ChoiceChip, 'On hold'));
    await tester.pumpAndSettle();

    expect(find.text('Monster'), findsOneWidget);
    final monsterPoster = tester.widget<PosterImageTitle>(
      find.byWidgetPredicate(
        (widget) => widget is PosterImageTitle && widget.title == 'Monster',
      ),
    );
    expect(monsterPoster.userScore, 8.7);
  });

  testWidgets('My Profile renders journey stats and separated logout action',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      createTestApp(
        child: const MyProfilePage(),
        overrides: [
          currentUserProfileProvider.overrideWith(
            (ref) async => {
              'username': 'lumen',
              'accessToken': 'token',
              'picture': 'https://cdn.myanimelist.net/images/userimages/2.jpg',
              'animeStatistics': {
                'numItemsWatching': 5,
                'numItemsCompleted': 120,
                'numItemsOnHold': 8,
                'numItemsDropped': 3,
                'numItemsPlanToWatch': 47,
                'numItems': 183,
                'numEpisodes': 412,
                'numDaysWatched': 123.4,
                'numTimesRewatched': 6,
                'meanScore': 8.56,
              },
            },
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('My Profile'), findsOneWidget);
    expect(find.text('lumen'), findsOneWidget);
    expect(find.text('Your anime journey'), findsOneWidget);
    expect(find.text('Episodes watched'), findsOneWidget);
    expect(find.text('Days spent watching'), findsOneWidget);
    expect(find.text('Mean completed score'), findsOneWidget);
    expect(find.text('List breakdown'), findsOneWidget);
    expect(find.text('Watching'), findsOneWidget);
    expect(find.text('Completed'), findsOneWidget);
    expect(find.text('Plan to watch'), findsOneWidget);
    expect(find.text('Total entries'), findsOneWidget);
    expect(find.text('Rewatches'), findsOneWidget);
    expect(find.text('412'), findsOneWidget);
    expect(find.text('123.4'), findsOneWidget);
    expect(find.text('8.56'), findsOneWidget);
    expect(find.text('183'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Logout'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.text('Logout'), findsWidgets);
    expect(find.text('Log out'), findsOneWidget);
    expect(find.text('A live snapshot of the anime statistics from your MyAnimeList profile.'), findsOneWidget);
  });

  testWidgets('My Profile logout journey clears the session',
      (WidgetTester tester) async {
    final fakeOauthService = FakeOauthService(
      username: 'lumen',
      accessToken: 'token',
      picture: 'https://cdn.myanimelist.net/images/userimages/2.jpg',
      animeStatistics: {
        'numItemsWatching': 5,
        'numItemsCompleted': 120,
        'numItemsOnHold': 8,
        'numItemsDropped': 3,
        'numItemsPlanToWatch': 47,
        'numItems': 183,
        'numEpisodes': 412,
        'numDaysWatched': 123.4,
        'numTimesRewatched': 6,
        'meanScore': 8.56,
      },
    );

    await tester.pumpWidget(
      createTestApp(
        child: const MyProfilePage(),
        overrides: [
          oauthProvider.overrideWith((ref) => fakeOauthService),
        ],
      ),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Log out'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Log out').first);
    await tester.pumpAndSettle();

    expect(find.text('Log out of MyAnimeList?'), findsOneWidget);

    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.widgetWithText(FilledButton, 'Log out'),
      ),
    );
    await tester.pumpAndSettle();

    expect(fakeOauthService.didLogout, isTrue);
    expect(find.text('Please sign in from My List to view your profile.'),
        findsOneWidget);
  });

  testWidgets('LandingPage app bar shows profile action when logged in',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      createTestApp(
        child: const LandingPage(),
        overrides: [
          userDataProvider.overrideWith(
            (ref) async => {
              'username': 'lumen',
              'accessToken': 'token',
              'picture': 'https://cdn.myanimelist.net/images/userimages/3.jpg',
            },
          ),
          combinedAnimeListProvider.overrideWith(
            (ref) async => CombinedData(
              currentSeasonAnimeList: const [],
              previousSeasonAnimeList: const [],
              upcomingSeasonAnimeList: const [],
              topUpcoming: const [],
              topAiring: const [],
              mostPopular: const [],
            ),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byTooltip('My Profile'), findsOneWidget);
    final avatar = tester.widget<UserAvatar>(find.byType(UserAvatar).first);
    expect(avatar.pictureUrl,
        'https://cdn.myanimelist.net/images/userimages/3.jpg');
  });

  testWidgets('shared app bar opens universal search and shows results',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      createTestApp(
        child: const LandingPage(),
        overrides: [
          userDataProvider.overrideWith(
            (ref) async => {
              'username': 'lumen',
              'accessToken': 'token',
              'picture': null,
            },
          ),
          animeListServiceProvider.overrideWith((ref) => FakeAnimeListService()),
          combinedAnimeListProvider.overrideWith(
            (ref) async => CombinedData(
              currentSeasonAnimeList: const [],
              previousSeasonAnimeList: const [],
              upcomingSeasonAnimeList: const [],
              topUpcoming: const [],
              topAiring: const [],
              mostPopular: const [],
            ),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Search anime'));
    await tester.pumpAndSettle();

    expect(find.text('Search for an anime title'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'steins');
    await tester.pumpAndSettle();

    expect(find.text('Steins;Gate'), findsOneWidget);
  });

  testWidgets('universal search shows an empty state when nothing matches',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      createTestApp(
        child: const MyListPage(),
        overrides: [
          userDataProvider.overrideWith(
            (ref) async => {
              'username': 'lumen',
              'accessToken': 'token',
              'picture': null,
            },
          ),
          animeListServiceProvider.overrideWith((ref) => FakeAnimeListService()),
          userAnimeListProvider.overrideWith((ref) async => fakeUserAnimeList),
        ],
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Search anime'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'zzzz');
    await tester.pumpAndSettle();

    expect(find.text('No results for "zzzz"'), findsOneWidget);
  });

  testWidgets('AnimeDetailsPage renders synopsis, score, and related media',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      createTestApp(
        child: const AnimeDetailsPage(animeId: 1),
        overrides: [
          animeDetailsProvider.overrideWith(
            (ref, animeId) async => AnimeDetailsData(
              anime: buildAnimeDetails(id: animeId, title: 'Frieren'),
              recommendations: [
                buildRecommendation(id: 5, title: 'Delicious in Dungeon'),
              ],
            ),
          ),
          userDataProvider.overrideWith(
            (ref) async => {
              'username': 'lumen',
              'accessToken': 'token',
              'picture': null,
            },
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Anime Details'), findsOneWidget);
    expect(find.text('Frieren'), findsAtLeastNWidgets(1));
    expect(find.text('SYNOPSIS'), findsOneWidget);
    expect(find.textContaining('A detailed synopsis for Frieren.'),
        findsOneWidget);
    expect(find.text('RELATED MEDIA'), findsOneWidget);
    expect(find.text('Frieren Season 2'), findsOneWidget);
    expect(find.text('RECOMMENDED NEXT'), findsOneWidget);
    expect(find.text('Delicious in Dungeon'), findsOneWidget);
  });

  testWidgets('tapping an anime from My List opens the details page',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      createTestApp(
        overrides: [
          userDataProvider.overrideWith(
            (ref) async => {
              'username': 'lumen',
              'accessToken': 'token',
              'picture': null,
            },
          ),
          userAnimeListProvider.overrideWith((ref) async => fakeUserAnimeList),
          animeDetailsProvider.overrideWith(
            (ref, animeId) async => AnimeDetailsData(
              anime: buildAnimeDetails(id: animeId, title: 'Frieren'),
              recommendations: const [],
            ),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Frieren').first);
    await tester.pumpAndSettle();

    expect(find.text('Anime Details'), findsOneWidget);
    expect(find.text('SYNOPSIS'), findsOneWidget);
    expect(find.textContaining('A detailed synopsis for Frieren.'),
        findsOneWidget);
  });

  testWidgets('PosterImageTitle shows the fallback state without an image',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      createTestApp(
        child: const Scaffold(
          body: PosterImageTitle(
            title: 'Frieren',
            userStatus: 'watching',
            userScore: 9,
          ),
        ),
        overrides: const [],
      ),
    );
    await tester.pump();

    expect(find.byIcon(Icons.image_not_supported), findsOneWidget);
    expect(find.text('Frieren'), findsOneWidget);
  });
}
