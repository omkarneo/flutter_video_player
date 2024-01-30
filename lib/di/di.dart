import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_video_play/provider/video_provider.dart';

final videoListProvider = ChangeNotifierProvider((ref) => VideoListDataModel());

final videoPlayerProvider = ChangeNotifierProvider((ref) => VideoPlayerModel());
