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
import 'package:otaku_tracker/providers/oauth_provider.dart';
import 'package:otaku_tracker/services/anime_list_service.dart';
import 'package:otaku_tracker/services/oauth_service.dart';
import 'package:otaku_tracker/widgets/my_list_controls_sheet.dart';
import 'package:otaku_tracker/widgets/my_list_detail_view.dart';
import 'package:otaku_tracker/widgets/poster_image_title.dart';
import 'package:otaku_tracker/widgets/user_avatar.dart';

Widget createTestApp({
  required List overrides,
  Widget child = const MyListPage(),
  MediaQueryData mediaQueryData = const MediaQueryData(size: Size(800, 600)),
}) {
  return ProviderScope(
    overrides: overrides.cast(),
    child: Directionality(
      textDirection: TextDirection.ltr,
      child: MediaQuery(
        data: mediaQueryData,
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
  int? numEpisodes,
  int numEpisodesWatched = 0,
  String updatedAt = '2024-01-01T00:00:00+00:00',
  bool isRewatching = false,
  int? priority,
  int? numTimesRewatched,
  int? rewatchValue,
  String? tags,
  String? comments,
}) {
  return UserAnimeData(
    node: Node(
      id: id,
      title: title,
      mean: mean,
      numEpisodes: numEpisodes,
    ),
    listStatus: ListStatus(
      status: status,
      score: score,
      numEpisodesWatched: numEpisodesWatched,
      isRewatching: isRewatching,
      priority: priority,
      numTimesRewatched: numTimesRewatched,
      rewatchValue: rewatchValue,
      tags: tags,
      comments: comments,
      updatedAt: updatedAt,
    ),
  );
}

AnimeData buildSearchAnimeData({
  required int id,
  required String title,
  required double mean,
  required int numScoringUsers,
}) {
  return AnimeData(
    node: Node(
      id: id,
      title: title,
      mainPicture: MainPicture(
        medium: 'https://cdn.example.com/anime/$id-medium.jpg',
        large: 'https://cdn.example.com/anime/$id-large.jpg',
      ),
      mean: mean,
      numScoringUsers: numScoringUsers,
    ),
  );
}

class FakeAnimeListService extends AnimeListService {
  @override
  Future<AnimeDTO> searchAnime(String query, {int limit = 30}) async {
    if (query.toLowerCase().contains('steins')) {
      return AnimeDTO(
        data: [
          buildSearchAnimeData(
            id: 10,
            title: 'Steins;Gate',
            mean: 9.1,
            numScoringUsers: 987654,
          ),
        ],
      );
    }

    return AnimeDTO(data: []);
  }

  @override
  Future<AnimeDTO> getTopAnime({int limit = 30}) async {
    return AnimeDTO(
      data: [
        buildSearchAnimeData(
          id: 1,
          title: 'Attack on Titan',
          mean: 8.8,
          numScoringUsers: 1456789,
        ),
      ],
    );
  }

  @override
  Future<AnimeDTO> getTopRatedAnime({int limit = 30}) async {
    return AnimeDTO(
      data: [
        buildSearchAnimeData(
          id: 5114,
          title: 'Fullmetal Alchemist: Brotherhood',
          mean: 9.1,
          numScoringUsers: 2100456,
        ),
      ],
    );
  }

  @override
  Future<AnimeDTO> getRecentlyAddedAnime({int limit = 30}) async {
    return AnimeDTO(
      data: [
        buildSearchAnimeData(
          id: 99999,
          title: 'New Saga',
          mean: 7.4,
          numScoringUsers: 12450,
        ),
      ],
    );
  }
}

class RecordingAnimeListService extends FakeAnimeListService {
  RecordingAnimeListService({required UserAnimeListDTO initialUserAnimeList})
      : _userAnimeList = initialUserAnimeList;

  UserAnimeListDTO _userAnimeList;
  AnimeListStatusUpdate? lastUpdate;
  int? lastDeletedAnimeId;

  @override
  Future<UserAnimeListDTO> getUserAnimeList(String accessToken) async {
    return _userAnimeList;
  }

  @override
  Future<ListStatus> updateMyAnimeListStatus(
    String accessToken,
    int animeId,
    AnimeListStatusUpdate update,
  ) async {
    lastUpdate = update;

    final updatedStatus = ListStatus(
      status: update.status ?? 'plan_to_watch',
      score: update.score ?? 0,
      numEpisodesWatched: update.numWatchedEpisodes ?? 0,
      isRewatching: update.isRewatching ?? false,
      priority: update.priority,
      numTimesRewatched: update.numTimesRewatched,
      rewatchValue: update.rewatchValue,
      tags: update.tags,
      comments: update.comments,
      updatedAt: '2024-01-02T00:00:00+00:00',
    );

    final nextData = [..._userAnimeList.data];
    final existingIndex = nextData.indexWhere((item) => item.node.id == animeId);

    final updatedItem = UserAnimeData(
      node: existingIndex >= 0
          ? nextData[existingIndex].node
          : Node(id: animeId, title: 'Anime $animeId'),
      listStatus: updatedStatus,
    );

    if (existingIndex >= 0) {
      nextData[existingIndex] = updatedItem;
    } else {
      nextData.add(updatedItem);
    }

    _userAnimeList = UserAnimeListDTO(data: nextData);

    return updatedStatus;
  }

  @override
  Future<void> deleteMyAnimeListStatus(String accessToken, int animeId) async {
    lastDeletedAnimeId = animeId;
    _userAnimeList = UserAnimeListDTO(
      data: _userAnimeList.data.where((item) => item.node.id != animeId).toList(),
    );
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
        numEpisodes: 24,
        numEpisodesWatched: 3,
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
    expect(find.text('Episodes watched', skipOffstage: false), findsOneWidget);
    expect(find.text('List breakdown', skipOffstage: false), findsOneWidget);
    expect(find.text('Completed', skipOffstage: false), findsWidgets);
    expect(find.text('Plan to watch', skipOffstage: false), findsWidgets);
    expect(find.text('Rewatches', skipOffstage: false), findsOneWidget);
    expect(find.text('412', skipOffstage: false), findsOneWidget);
    expect(find.text('123.4', skipOffstage: false), findsOneWidget);
    expect(find.text('8.56', skipOffstage: false), findsOneWidget);
    expect(find.text('183', skipOffstage: false), findsOneWidget);
  });

  testWidgets('logged in My List shows compact controls summary and trigger',
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
    expect(find.text('List controls'), findsOneWidget);
    expect(find.text('All • Last updated • Poster view'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Filter & sort'), findsOneWidget);
  });

  testWidgets('My List controls sheet applies status changes and empty state',
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

    await tester.tap(find.widgetWithText(FilledButton, 'Filter & sort'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(MyListControlsSheet), findsOneWidget);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Completed').last);
    await tester.pump();

    await tester.ensureVisible(find.widgetWithText(FilledButton, 'Apply'));
    await tester.tap(find.widgetWithText(FilledButton, 'Apply'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Cowboy Bebop'), findsOneWidget);
    expect(find.text('Frieren'), findsNothing);

    await tester.tap(find.widgetWithText(FilledButton, 'Filter & sort'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.widgetWithText(ChoiceChip, 'Dropped').last);
    await tester.pump();
    await tester.ensureVisible(find.widgetWithText(FilledButton, 'Apply'));
    await tester.tap(find.widgetWithText(FilledButton, 'Apply'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

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

    await tester.tap(find.widgetWithText(FilledButton, 'Filter & sort'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.widgetWithText(ChoiceChip, 'On hold').last);
    await tester.pump();
    await tester.ensureVisible(find.widgetWithText(FilledButton, 'Apply'));
    await tester.tap(find.widgetWithText(FilledButton, 'Apply'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Monster'), findsOneWidget);
    final monsterPoster = tester.widget<PosterImageTitle>(
      find.byWidgetPredicate(
        (widget) => widget is PosterImageTitle && widget.title == 'Monster',
      ),
    );
    expect(monsterPoster.userScore, 8.7);
  });

  testWidgets('My List switches between poster and detail views',
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

    expect(find.byType(MyListDetailView), findsNothing);
    expect(find.text('3 / 24 watched'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Filter & sort'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.ensureVisible(find.text('Detail view').last);
    await tester.tap(find.text('Detail view').last);
    await tester.pump();
    await tester.ensureVisible(find.widgetWithText(FilledButton, 'Apply'));
    await tester.tap(find.widgetWithText(FilledButton, 'Apply'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(MyListDetailView), findsOneWidget);
    expect(find.text('Title'), findsOneWidget);
    expect(find.text('Progress'), findsWidgets);
    expect(find.text('3 / 24'), findsOneWidget);
    expect(find.text('9 / 10'), findsOneWidget);
    expect(find.text('3 / 24 watched'), findsNothing);

    await tester.tap(find.widgetWithText(FilledButton, 'Filter & sort'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.ensureVisible(find.text('Poster view').last);
    await tester.tap(find.text('Poster view').last);
    await tester.pump();
    await tester.ensureVisible(find.widgetWithText(FilledButton, 'Apply'));
    await tester.tap(find.widgetWithText(FilledButton, 'Apply'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(MyListDetailView), findsNothing);
    expect(find.text('3 / 24 watched'), findsOneWidget);
  });

  testWidgets('My List defaults to last updated sorting and can switch to title sorting',
      (WidgetTester tester) async {
    final sortableUserAnimeList = UserAnimeListDTO(
      data: [
        buildUserAnimeData(
          id: 1,
          title: 'Zeta',
          status: 'watching',
          updatedAt: '2024-03-01T00:00:00+00:00',
        ),
        buildUserAnimeData(
          id: 2,
          title: 'Alpha',
          status: 'watching',
          updatedAt: '2024-02-01T00:00:00+00:00',
        ),
        buildUserAnimeData(
          id: 3,
          title: 'Middle',
          status: 'watching',
          updatedAt: '2024-01-01T00:00:00+00:00',
        ),
      ],
    );

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
          userAnimeListProvider.overrideWith((ref) async => sortableUserAnimeList),
        ],
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Filter & sort'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.ensureVisible(find.text('Detail view').last);
    await tester.tap(find.text('Detail view').last);
    await tester.pump();
    await tester.ensureVisible(find.widgetWithText(FilledButton, 'Apply'));
    await tester.tap(find.widgetWithText(FilledButton, 'Apply'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    final defaultOrder = tester
        .widgetList<MyListDetailRow>(find.byType(MyListDetailRow))
        .map((row) => row.userAnimeData.node.title)
        .toList();

    expect(defaultOrder, ['Zeta', 'Alpha', 'Middle']);

    await tester.tap(find.widgetWithText(FilledButton, 'Filter & sort'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.widgetWithText(ChoiceChip, 'Title').last);
    await tester.pump();
    await tester.ensureVisible(find.widgetWithText(FilledButton, 'Apply'));
    await tester.tap(find.widgetWithText(FilledButton, 'Apply'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    final titleSortedOrder = tester
        .widgetList<MyListDetailRow>(find.byType(MyListDetailRow))
        .map((row) => row.userAnimeData.node.title)
        .toList();

    expect(titleSortedOrder, ['Alpha', 'Middle', 'Zeta']);
  });

  testWidgets('My List controls sheet reset returns to default summary',
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

    await tester.tap(find.widgetWithText(FilledButton, 'Filter & sort'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.widgetWithText(ChoiceChip, 'Completed').last);
    await tester.pump();
    await tester.ensureVisible(find.text('Detail view').last);
    await tester.tap(find.text('Detail view').last);
    await tester.pump();
    await tester.ensureVisible(find.widgetWithText(FilledButton, 'Apply'));
    await tester.tap(find.widgetWithText(FilledButton, 'Apply'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Completed • Last updated • Detail view'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Filter & sort'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.ensureVisible(find.widgetWithText(OutlinedButton, 'Reset'));
    await tester.tap(find.widgetWithText(OutlinedButton, 'Reset'));
    await tester.pump();
    await tester.ensureVisible(find.widgetWithText(FilledButton, 'Apply'));
    await tester.tap(find.widgetWithText(FilledButton, 'Apply'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('All • Last updated • Poster view'), findsOneWidget);
  });

  testWidgets('My List quick edit updates watched progress from a grid tile',
      (WidgetTester tester) async {
    final recordingService = RecordingAnimeListService(
      initialUserAnimeList: UserAnimeListDTO(
        data: [
          buildUserAnimeData(
            id: 1,
            title: 'Frieren',
            status: 'watching',
            score: 9,
            mean: 8.9,
            numEpisodes: 24,
            numEpisodesWatched: 3,
          ),
        ],
      ),
    );

    await tester.pumpWidget(
      createTestApp(
        overrides: [
          animeListServiceProvider.overrideWith((ref) => recordingService),
          oauthProvider.overrideWith(
            (ref) => FakeOauthService(
              username: 'lumen',
              accessToken: 'token',
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

    expect(find.text('3 / 24 watched'), findsOneWidget);

    await tester.tap(find.byTooltip('Quick edit Frieren'));
    await tester.pumpAndSettle();

    expect(find.text('Quick edit'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).first, '12');
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));

    expect(recordingService.lastUpdate, isNotNull);
    expect(recordingService.lastUpdate?.numWatchedEpisodes, 12);
    expect(find.text('12 / 24 watched'), findsOneWidget);
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
    expect(find.text('Episodes watched', skipOffstage: false), findsOneWidget);
    expect(find.text('Days spent watching', skipOffstage: false), findsOneWidget);
    expect(find.text('Mean completed score', skipOffstage: false), findsOneWidget);
    expect(find.text('List breakdown', skipOffstage: false), findsOneWidget);
    expect(find.text('Watching', skipOffstage: false), findsOneWidget);
    expect(find.text('Completed', skipOffstage: false), findsWidgets);
    expect(find.text('Plan to watch', skipOffstage: false), findsOneWidget);
    expect(find.text('Total entries', skipOffstage: false), findsOneWidget);
    expect(find.text('Rewatches', skipOffstage: false), findsOneWidget);
    expect(find.text('412', skipOffstage: false), findsOneWidget);
    expect(find.text('123.4', skipOffstage: false), findsOneWidget);
    expect(find.text('8.56', skipOffstage: false), findsOneWidget);
    expect(find.text('183', skipOffstage: false), findsOneWidget);
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
    expect(find.text('Top anime'), findsOneWidget);
    expect(find.text('Top rated'), findsOneWidget);
    expect(find.text('Recently added'), findsOneWidget);
    expect(find.text('Attack on Titan'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'steins');
    await tester.pumpAndSettle();

    expect(find.text('Steins;Gate'), findsOneWidget);
    expect(find.text('9.1'), findsOneWidget);
    expect(find.text('987654'), findsOneWidget);
  });

  testWidgets('search quick filters switch between curated MAL result sets',
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

    expect(find.text('Attack on Titan'), findsOneWidget);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Top rated'));
    await tester.pumpAndSettle();

    expect(find.text('Fullmetal Alchemist: Brotherhood'), findsOneWidget);
    expect(find.text('Attack on Titan'), findsNothing);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Recently added'));
    await tester.pumpAndSettle();

    expect(find.text('New Saga'), findsOneWidget);
    expect(find.text('Fullmetal Alchemist: Brotherhood'), findsNothing);
  });

  testWidgets('search results do not overflow on compact widths',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      createTestApp(
        child: const LandingPage(),
        mediaQueryData: const MediaQueryData(size: Size(320, 640)),
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

    await tester.enterText(find.byType(TextField), 'steins');
    await tester.pumpAndSettle();

    expect(find.text('Steins;Gate'), findsOneWidget);
    expect(tester.takeException(), isNull);
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

  testWidgets('Anime details shows an add-to-list action when the title is not tracked',
      (WidgetTester tester) async {
    final recordingService = RecordingAnimeListService(
      initialUserAnimeList: UserAnimeListDTO(
        data: [
          buildUserAnimeData(
            id: 2,
            title: 'Cowboy Bebop',
            status: 'completed',
          ),
        ],
      ),
    );

    await tester.pumpWidget(
      createTestApp(
        child: const AnimeDetailsPage(animeId: 1),
        overrides: [
          animeDetailsProvider.overrideWith(
            (ref, animeId) async => AnimeDetailsData(
              anime: buildAnimeDetails(id: animeId, title: 'Frieren'),
              recommendations: const [],
            ),
          ),
          animeListServiceProvider.overrideWith((ref) => recordingService),
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

    expect(find.text('Add to list'), findsOneWidget);
    expect(find.text('Not in your list'), findsOneWidget);
  });

  test('Anime list mutation controller saves updated MAL list progress and notes',
      () async {
    final recordingService = RecordingAnimeListService(
      initialUserAnimeList: UserAnimeListDTO(
        data: [
          buildUserAnimeData(
            id: 1,
            title: 'Frieren',
            status: 'watching',
            score: 9,
            mean: 8.9,
            numEpisodesWatched: 3,
          ),
        ],
      ),
    );
    final container = ProviderContainer(
      overrides: [
        animeListServiceProvider.overrideWith((ref) => recordingService),
        oauthProvider.overrideWith(
          (ref) => FakeOauthService(
            username: 'lumen',
            accessToken: 'token',
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
    );
    addTearDown(container.dispose);

    await container.read(animeListMutationControllerProvider).updateAnimeListEntry(
          1,
          const AnimeListStatusUpdate(
            status: 'watching',
            score: 9,
            numWatchedEpisodes: 12,
            comments: 'Great mid-season arc',
          ),
        );
    final refreshedList = await container.read(userAnimeListProvider.future);

    expect(recordingService.lastUpdate, isNotNull);
    expect(recordingService.lastUpdate?.numWatchedEpisodes, 12);
    expect(recordingService.lastUpdate?.comments, 'Great mid-season arc');
    expect(refreshedList.data.first.listStatus.numEpisodesWatched, 12);
    expect(refreshedList.data.first.listStatus.comments, 'Great mid-season arc');
  });

  test('Anime list mutation controller removes a MAL list entry',
      () async {
    final recordingService = RecordingAnimeListService(
      initialUserAnimeList: UserAnimeListDTO(
        data: [
          buildUserAnimeData(
            id: 1,
            title: 'Frieren',
            status: 'watching',
            score: 9,
            mean: 8.9,
          ),
        ],
      ),
    );
    final container = ProviderContainer(
      overrides: [
        animeListServiceProvider.overrideWith((ref) => recordingService),
        oauthProvider.overrideWith(
          (ref) => FakeOauthService(
            username: 'lumen',
            accessToken: 'token',
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
    );
    addTearDown(container.dispose);

    await container.read(animeListMutationControllerProvider).removeAnimeListEntry(1);
    final refreshedList = await container.read(userAnimeListProvider.future);

    expect(recordingService.lastDeletedAnimeId, 1);
    expect(refreshedList.data, isEmpty);
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

    await tester.tap(find.byKey(const ValueKey(1)));
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

  testWidgets('PosterImageTitle fits bounded poster-only layouts without overflow',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      createTestApp(
        child: const Scaffold(
          body: Center(
            child: SizedBox(
              width: 196,
              height: 256.7,
              child: PosterImageTitle(
                imageUrl: 'https://cdn.example.com/frieren.jpg',
                title: 'Frieren',
                userStatus: 'watching',
                userScore: 9,
                showBottomTitle: false,
              ),
            ),
          ),
        ),
        overrides: const [],
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
  });
}
