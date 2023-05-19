import 'dart:io';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';

import '../../widgets/MusicTile.dart';
import '../provider/music_model_provider.dart';
import '../services/DatabaseHelper.dart';
import 'NowPlaying.dart';

class AllSongs extends StatefulWidget {
  const AllSongs({Key? key}) : super(key: key);

  @override
  State<AllSongs> createState() => _AllSongsState();
}

class _AllSongsState extends State<AllSongs> {
  final OnAudioQuery _audioQuery = OnAudioQuery();
  final AudioPlayer _audioPlayer = AudioPlayer();

  List<SongModel> allSongs = [];
  List<String> favoriteSongs = [];
  DatabaseHelper _databaseHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    requestPermission();
    loadFavoriteSongs();
  }

  requestPermission() async {
    if (Platform.isAndroid) {
      bool permissionStatus = await _audioQuery.permissionsStatus();
      if (!permissionStatus) {
        await _audioQuery.permissionsRequest();
      }
      setState(() {});
    }
  }

  loadFavoriteSongs() async {
    List<String> favorites = await _databaseHelper.getFavoriteSongs();
    setState(() {
      favoriteSongs = favorites;
    });
  }

  toggleFavoriteSong(String songId) async {
    if (favoriteSongs.contains(songId)) {
      await _databaseHelper.removeFavoriteSong(songId);
    } else {
      await _databaseHelper.addFavoriteSong(songId);
    }
    loadFavoriteSongs();
  }

  bool isSongFavorite(String songId) {
    return favoriteSongs.contains(songId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Music Player",
          style: TextStyle(color: Colors.white),
        ),
        elevation: 2,
      ),
      body: FutureBuilder<List<SongModel>>(
        future: _audioQuery.querySongs(
          sortType: null,
          orderType: OrderType.ASC_OR_SMALLER,
          uriType: UriType.EXTERNAL,
          ignoreCase: true,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                children: const [
                  CircularProgressIndicator(),
                  SizedBox(
                    height: 10.0,
                  ),
                  Text("Loading")
                ],
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Nothing found!"));
          }

          allSongs.addAll(snapshot.data!);

          return Stack(
            children: [
              ListView.builder(
                itemCount: snapshot.data!.length,
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 60),
                itemBuilder: (context, index) {
                  final SongModel song = snapshot.data![index];
                  final bool isFavorite = isSongFavorite(song.id.toString());

                  return GestureDetector(
                    onTap: () {
                      context.read<SongModelProvider>().setId(song.id);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NowPlaying(
                            songModelList: [song],
                            audioPlayer: _audioPlayer,
                          ),
                        ),
                      );
                    },
                    child: ListTile(
                      title: Text(song.title),
                      subtitle: Text(song.artist ?? 'Unknown Artist'),
                      trailing: IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : null,
),
onPressed: () {
toggleFavoriteSong(song.id.toString());
},
),
),
);
},
),
Align(
alignment: Alignment.bottomRight,
child: GestureDetector(
onTap: () {
Navigator.push(
context,
MaterialPageRoute(
builder: (context) => NowPlaying(
songModelList: allSongs
.where((song) => isSongFavorite(song.id.toString()))
.toList(),
audioPlayer: _audioPlayer,
),
),
);
},
child: Container(
margin: const EdgeInsets.fromLTRB(0, 0, 15, 15),
child: const CircleAvatar(
radius: 30,
child: Icon(
Icons.play_arrow,
),
),
),
),
),
],
);
},
),
);
}
}
