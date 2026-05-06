import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:otaku_tracker/models/response/anime.dart';
import 'package:otaku_tracker/pages/landing_page.dart';
import 'package:otaku_tracker/pages/my_list_page.dart';
import 'package:otaku_tracker/pages/my_profile_page.dart';
import 'package:otaku_tracker/providers/anime_list_provider.dart';
import 'package:otaku_tracker/providers/my_list_filter_provider.dart';
import 'package:otaku_tracker/services/anime_list_service.dart';
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
}) {
  return UserAnimeData(
    node: Node(id: id, title: title),
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

void main() {
  final fakeUserAnimeList = UserAnimeListDTO(
    data: [
      buildUserAnimeData(
        id: 1,
        title: 'Frieren',
        status: 'watching',
        score: 9,
      ),
      buildUserAnimeData(
        id: 2,
        title: 'Cowboy Bebop',
        status: 'completed',
        score: 10,
      ),
      buildUserAnimeData(
        id: 3,
        title: 'Monster',
        status: 'on_hold',
      ),
    ],
  );

  testWidgets('logged out My List shows auth button without profile action',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      createTestApp(
        overrides: [
          userDataProvider.overrideWith(
            (ref) async => {'username': null, 'accessToken': null},
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Authenticate with MyAnimeList'), findsOneWidget);
    expect(find.byIcon(Symbols.account_circle), findsNothing);
  });

  testWidgets('logged in My List shows profile action and filter chips',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      createTestApp(
        overrides: [
          userDataProvider.overrideWith(
            (ref) async => {'username': 'lumen', 'accessToken': 'token'},
          ),
          userAnimeListProvider.overrideWith((ref) async => fakeUserAnimeList),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Symbols.account_circle), findsOneWidget);
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
            (ref) async => {'username': 'lumen', 'accessToken': 'token'},
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

  testWidgets('My Profile renders the username when authenticated',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      createTestApp(
        child: const MyProfilePage(),
        overrides: [
          userDataProvider.overrideWith(
            (ref) async => {'username': 'lumen', 'accessToken': 'token'},
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('My Profile'), findsOneWidget);
    expect(find.text('lumen'), findsOneWidget);
    expect(find.byIcon(Symbols.account_circle), findsOneWidget);
  });

  testWidgets('LandingPage app bar shows profile action when logged in',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      createTestApp(
        child: const LandingPage(),
        overrides: [
          userDataProvider.overrideWith(
            (ref) async => {'username': 'lumen', 'accessToken': 'token'},
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
  });

  testWidgets('shared app bar opens universal search and shows results',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      createTestApp(
        child: const LandingPage(),
        overrides: [
          userDataProvider.overrideWith(
            (ref) async => {'username': 'lumen', 'accessToken': 'token'},
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
            (ref) async => {'username': 'lumen', 'accessToken': 'token'},
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
