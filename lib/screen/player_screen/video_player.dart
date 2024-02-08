import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_video_play/di/di.dart';
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

  @override
  Widget build(BuildContext context) {
    var isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    var controller = ref.watch(videoPlayerProvider).controller;

    return Scaffold(
      appBar: isPortrait
          ? AppBar(
              title: const Text("Video Player Example"),
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
                                    ? 220
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
                      width: MediaQuery.sizeOf(context).width + 20,
                      color: Colors.black.withOpacity(0.3),
                    ))
                : const SizedBox.shrink(),
            ref.watch(videoPlayerProvider).actionScreen
                ? Positioned(
                    top: isPortrait ? 135 : 300,
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
                    top: isPortrait ? 70 : 230,
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
              : Container(
                  width: MediaQuery.sizeOf(context).width,
                  height: 200,
                  child: Row(
                    children: [
                      Column(
                        children: [
                          Text(widget.data['title']),
                        ],
                      )
                    ],
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
