import 'package:flutter/material.dart';
import 'package:otaku_tracker/pages/landing/LandingPageService.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  late LandingPageService _landingPageService;
  Map<String, dynamic>? animeList;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _landingPageService = LandingPageService();
    _fetchAnimeList();
  }

  void _fetchAnimeList() async {
    Map<String, dynamic> fetchedList = await _landingPageService.getAnimeList();

    setState(() {
      animeList = fetchedList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Landing'),
      ),
      body: animeList == null
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: animeList?.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Image.network(
                    animeList?["data"][index]["node"]["main_picture"]["medium"] ?? "https://via.placeholder.com/150",
                    fit: BoxFit.cover,
                    width: 50.0,
                    height: 50.0,
                  ),
                  title: Text(animeList?["data"][index]["node"]["title"] ?? "null"),
                  onTap: () {
                    print('Tapped on ${animeList?["data"][index]["node"]["title"]}');
                  },
                );
              },
            ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.bookmark), label: 'Seasonal'),
          BottomNavigationBarItem(
              icon: Icon(Icons.notifications), label: 'Saved')
        ],
      ),
    );
  }
}
