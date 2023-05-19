import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';

import '../provider/music_model_provider.dart';
import '../services/DatabaseHelper.dart';
import 'NowPlaying.dart';

class FavoritesScreen extends StatelessWidget {
  final AudioPlayer audioPlayer;
  final DatabaseHelper databaseHelper;

  const FavoritesScreen({
    Key? key,
    required this.audioPlayer,
    required this.databaseHelper,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Favorites',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: FutureBuilder<List<String>>(
        future: databaseHelper.getFavoriteSongs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return const Center(
              child: Text('Error occurred.'),
            );
          }
          final List<String> favoriteSongs = snapshot.data ?? [];

          return ListView.builder(
            itemCount: favoriteSongs.length,
            itemBuilder: (context, index) {
              final String song = favoriteSongs[index];

              return ListTile(
                title: Text('favorites'),

                  
                
              );
            },
          );
        },
      ),
    );
  }
}