import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_video_play/di/di.dart';
import 'package:flutter_video_play/screen/dashboard/listing_screen.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerScreen extends ConsumerStatefulWidget {
  final Map data;

  const VideoPlayerScreen({super.key, required this.data});

  @override
  ConsumerState<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends ConsumerState<VideoPlayerScreen> {
  @override
  void initState() {
    super.initState();
    ref
        .read(videoPlayerProvider)
        .videoLoadedInController(widget.data['sources'][0]);
  }

  @override
  void dispose() {
    super.dispose();
  }

  String numberFormat(int n) {
    String num = n.toString();
    int len = num.length;

    if (n >= 1000 && n < 1000000) {
      return '${num.substring(0, len - 3)}K';
    } else if (n >= 1000000 && n < 1000000000) {
      return '${num.substring(0, len - 6)}M';
    } else if (n > 1000000000) {
      return '${num.substring(0, len - 9)}B';
    } else {
      return num..toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    print(widget);
    var isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    var controller = ref.watch(videoPlayerProvider).controller;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: isPortrait
          ? AppBar(
              title: const Text(
                "Video Player Example",
                style: TextStyle(color: Colors.black),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ListScreen(),
                        ),
                        (route) => false);
                  }),
            )
          : null,
      body: Column(
        children: [
          Stack(children: [
            ref.watch(videoPlayerProvider).loading
                ? Container(
                    height:
                        isPortrait ? 250 : MediaQuery.sizeOf(context).height,
                    width: MediaQuery.sizeOf(context).width + 20,
                    color: Colors.black,
                    child: const Center(
                        child: CircularProgressIndicator(
                      color: Colors.white,
                    )),
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      controller.value.isInitialized
                          ? InkWell(
                              onTap: () {
                                ref
                                    .read(videoPlayerProvider)
                                    .actionsSheet(2, false);
                              },
                              child: SizedBox(
                                width: MediaQuery.sizeOf(context).width,
                                height: isPortrait
                                    ? 250
                                    : MediaQuery.sizeOf(context).height - 1,
                                child: AspectRatio(
                                  aspectRatio: controller.value.aspectRatio,
                                  child: VideoPlayer(controller),
                                ),
                              ),
                            )
                          : Container(),
                      !(ref.watch(videoPlayerProvider).actionScreen)
                          ? SizedBox(
                              height: isPortrait ? 1 : 0,
                              child: SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                    trackShape:
                                        CustomTrackForNonIntereactorShape(),
                                    thumbColor: Colors.transparent,
                                    thumbShape: const RoundSliderThumbShape(
                                        enabledThumbRadius: 0.0)),
                                child: Slider(
                                    min: 0,
                                    max: controller.value.duration.inSeconds
                                        .toDouble(),
                                    activeColor: Colors.red.shade500,
                                    inactiveColor: Colors.grey,
                                    value: ref
                                        .watch(videoPlayerProvider)
                                        .position
                                        .inSeconds
                                        .toDouble(),
                                    allowedInteraction:
                                        SliderInteraction.tapOnly,
                                    autofocus: false,
                                    onChanged: (value) {}),
                              ),
                            )
                          : Container(),
                    ],
                  ),
            ref.watch(videoPlayerProvider).actionScreen
                ? Positioned(

                    // top: isFullScreen ? 300 : 150,
                    // left: -10,
                    height:
                        isPortrait ? 250 : MediaQuery.sizeOf(context).height,
                    width: MediaQuery.sizeOf(context).width + 20,
                    child: Container(
                      height:
                          isPortrait ? 250 : MediaQuery.sizeOf(context).height,
                      // width: MediaQuery.sizeOf(context).width + 20,
                      color: Colors.black.withOpacity(0.3),
                      child: IconButton(
                        onPressed: () {
                          setState(() {
                            if (controller.value.isPlaying) {
                              controller.pause();
                            } else {
                              controller.play();
                              ref
                                  .read(videoPlayerProvider)
                                  .actionsSheet(1, false);
                            }
                          });

                          setState(() {});
                        },
                        icon: Icon(
                          controller.value.isPlaying
                              ? Icons.pause
                              : Icons.play_arrow,
                          color: Colors.white,
                          size: isPortrait ? 50 : 80,
                        ),
                      ),
                    ))
                : const SizedBox.shrink(),
            ref.watch(videoPlayerProvider).actionScreen
                ? Positioned(
                    top: isPortrait ? 180 : 315,
                    left: -10,
                    // height: 250,
                    width: MediaQuery.sizeOf(context).width + 20,
                    child: Column(
                      children: [
                        Slider(
                          min: 0,
                          max: controller.value.duration.inSeconds.toDouble(),
                          // ? _controller.value.duration.inMinutes.toDouble()
                          // : _controller.value.duration.inSeconds.toDouble(),
                          activeColor: Colors.red.shade500,
                          inactiveColor: Colors.grey,
                          thumbColor: Colors.red.shade900,
                          value: ref
                              .watch(videoPlayerProvider)
                              .position
                              .inSeconds
                              .toDouble(),
                          autofocus: false,
                          onChanged: (value) {
                            ref.read(videoPlayerProvider).seeker(value);
                          },
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
            ref.watch(videoPlayerProvider).actionScreen
                ? Positioned(
                    top: isPortrait ? 105 : 245,
                    left: 0,
                    height: 250,
                    width: MediaQuery.sizeOf(context).width,
                    child: Row(
                      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () {
                            setState(() {
                              if (controller.value.isPlaying) {
                                controller.pause();
                              } else {
                                controller.play();
                                ref
                                    .read(videoPlayerProvider)
                                    .actionsSheet(1, false);
                              }
                            });

                            setState(() {});
                          },
                          icon: Icon(
                            controller.value.isPlaying
                                ? Icons.pause
                                : Icons.play_arrow,
                            color: Colors.white,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            controller.value.volume == 0
                                ? controller.setVolume(1)
                                : controller.setVolume(0);
                          },
                          icon: Icon(
                            controller.value.volume != 0
                                ? Icons.volume_up
                                : Icons.volume_off,
                            color: Colors.white,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "${(ref.watch(videoPlayerProvider).position.inHours == 0) ? "" : "${ref.watch(videoPlayerProvider).position.inHours}:"}${ref.watch(videoPlayerProvider).position.inMinutes.toString()}:${(ref.watch(videoPlayerProvider).position.inSeconds % 60).toString().length == 1 ? "0${ref.watch(videoPlayerProvider).position.inSeconds % 60}" : "${ref.watch(videoPlayerProvider).position.inSeconds % 60}"} / ${controller.value.duration.inHours == 0 ? "" : "${controller.value.duration.inHours}:"}${controller.value.duration.inMinutes}:${controller.value.duration.inSeconds % 60}",
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () async {
                            ref
                                .read(videoPlayerProvider)
                                .rotationMech(isPortrait);
                          },
                          icon: const Icon(
                            Icons.fullscreen,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ]),
          !(isPortrait)
              ? SizedBox.shrink()
              : SizedBox(
                  height: MediaQuery.sizeOf(context).height * 0.57,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Theme(
                          data: Theme.of(context)
                              .copyWith(dividerColor: Colors.transparent),
                          child: ExpansionTile(
                              tilePadding: EdgeInsets.zero,
                              trailing: const SizedBox.shrink(),
                              iconColor: Colors.black,
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 20.0, top: 10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          widget.data['title'],
                                          style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          "${numberFormat(500000000)} Views",
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey.shade500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 13,
                                  ),
                                  SizedBox(
                                    // width: MediaQuery.sizeOf(context).width,
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        // mainAxisAlignment:
                                        //     MainAxisAlignment.spaceBetween,
                                        // mainAxisSize: MainAxisSize.max,
                                        children: [
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          ElevatedButton(
                                              onPressed: () {},
                                              style: ElevatedButton.styleFrom(
                                                  fixedSize: Size(50, 60),
                                                  backgroundColor: Colors.white,
                                                  elevation: 0),
                                              child: const Column(
                                                children: [
                                                  Icon(
                                                    Icons.thumb_up,
                                                    size: 30,
                                                    color: Colors.black,
                                                  ),
                                                  Text(
                                                    "10k",
                                                    style: TextStyle(
                                                        color: Colors.black),
                                                  )
                                                ],
                                              )),
                                          ElevatedButton(
                                              onPressed: () {},
                                              style: ElevatedButton.styleFrom(
                                                  fixedSize: Size(50, 60),
                                                  backgroundColor: Colors.white,
                                                  elevation: 0),
                                              child: const Column(
                                                children: [
                                                  Icon(
                                                    Icons.thumb_down,
                                                    size: 30,
                                                    color: Colors.black,
                                                  ),
                                                  Text(
                                                    '1k',
                                                    style: TextStyle(
                                                        color: Colors.black),
                                                  )
                                                ],
                                              )),
                                          ElevatedButton(
                                              onPressed: () {},
                                              style: ElevatedButton.styleFrom(
                                                  fixedSize: Size(80, 60),
                                                  elevation: 0,
                                                  backgroundColor:
                                                      Colors.white),
                                              child: const Column(
                                                children: [
                                                  Icon(
                                                    Icons.share_rounded,
                                                    size: 30,
                                                    color: Colors.black,
                                                  ),
                                                  Text("Share",
                                                      style: TextStyle(
                                                          color: Colors.black))
                                                ],
                                              )),
                                          ElevatedButton(
                                              onPressed: () {},
                                              style: ElevatedButton.styleFrom(
                                                  fixedSize: Size(100, 60),
                                                  elevation: 0,
                                                  backgroundColor:
                                                      Colors.white),
                                              child: const Column(
                                                children: [
                                                  Icon(
                                                    Icons.download_sharp,
                                                    size: 30,
                                                    color: Colors.black,
                                                  ),
                                                  Text("Download",
                                                      style: TextStyle(
                                                          color: Colors.black))
                                                ],
                                              )),
                                          ElevatedButton(
                                              onPressed: () {},
                                              style: ElevatedButton.styleFrom(
                                                fixedSize: Size(50, 60),
                                                elevation: 0,
                                                backgroundColor: Colors.white,
                                              ),
                                              child: const Column(
                                                children: [
                                                  Icon(
                                                    Icons.playlist_add,
                                                    size: 30,
                                                    color: Colors.black,
                                                  ),
                                                  Text(
                                                    "Save",
                                                    style: TextStyle(
                                                        color: Colors.black),
                                                  )
                                                ],
                                              )),
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Text(widget.data['description']),
                                )
                              ]),
                        ),
                        const Divider(),
                        SizedBox(
                          width: MediaQuery.sizeOf(context).width,
                          // height: 200,
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 15),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 55,
                                      height: 55,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(60),
                                        image: const DecorationImage(
                                          fit: BoxFit.fill,
                                          image: NetworkImage(
                                              "https://buffer.com/cdn-cgi/image/w=1000,fit=contain,q=90,f=auto/library/content/images/size/w1200/2023/09/instagram-image-size.jpg"),
                                        ),
                                      ),
                                      // backgroundImage: NetworkImage(
                                      //   widget.data['thumb'],
                                      // ),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          widget.data['channel'],
                                          style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          "${numberFormat(20000000000)} subscriber",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(),
                        Consumer(builder: (context, ref, child) {
                          var videoList = ref.watch(videoListProvider).data;

                          return SizedBox(
                            height: MediaQuery.sizeOf(context).height * 0.37,
                            child: ListView.builder(
                              itemCount: videoList.length,
                              itemBuilder: (context, index) {
                                var data = videoList[index];
                                return ListTile(
                                  selected:
                                      data.hashCode == widget.data.hashCode
                                          ? true
                                          : false,
                                  trailing:
                                      data.hashCode == widget.data.hashCode
                                          ? const Icon(Icons.check_circle)
                                          : null,
                                  title: Text(data['title']),
                                  subtitle: Text(data['subtitle']),
                                  leading: CircleAvatar(
                                      radius: 27,
                                      backgroundImage:
                                          NetworkImage(data['thumb'])),
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              VideoPlayerScreen(data: data),
                                        )).then((value) {
                                      ref
                                          .read(videoPlayerProvider)
                                          .fordispose();
                                    });
                                  },
                                  // leading: Image.network(
                                  //    data['']),
                                );
                              },
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                )
        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     setState(() {
      //       _controller.value.isPlaying
      //           ? _controller.pause()
      //           : _controller.play();
      //     });
      //   },
      //   child: Icon(
      //     _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
      //   ),
      // ),
    );
  }
}

class CustomTrackForNonIntereactorShape extends RoundedRectSliderTrackShape {
  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final trackLeft = offset.dx;
    final trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, 0, trackWidth, 2);
  }
}
