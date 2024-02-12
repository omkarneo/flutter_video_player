import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_video_play/di/di.dart';
import 'package:flutter_video_play/screen/player_screen/video_player.dart';

class ListScreen extends StatefulWidget {
  const ListScreen({super.key});

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Video List", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer(builder: (context, ref, child) {
        var videoList = ref.watch(videoListProvider).data;

        return ListView.builder(
          itemCount: videoList.length,
          itemBuilder: (context, index) {
            var data = videoList[index];
            return ListTile(
              title: Text(data['title']),
              subtitle: Text(data['subtitle']),
              leading: Image.network(data['thumb']),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VideoPlayerScreen(data: data),
                    )).then((value) {
                  ref.read(videoPlayerProvider).fordispose();
                });
              },
              // leading: Image.network(
              //    data['']),
            );
          },
        );
      }),
    );
  }
}
