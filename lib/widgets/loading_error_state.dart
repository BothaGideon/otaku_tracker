import 'package:flutter/material.dart';

class LoadingErrorState extends StatelessWidget {
  final VoidCallback onRetry;

  const LoadingErrorState({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.sentiment_dissatisfied,
              size: 80.0,
              color: Colors.grey,
            ),
            const SizedBox(height: 20.0),
            const Text(
              'Whoa! Loading Fail',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10.0),
            const Text(
              'Uh-oh! We hit a little bump in the road while trying to load this screen. It’s probably our fault (oops!). Give it another whirl!',
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}
