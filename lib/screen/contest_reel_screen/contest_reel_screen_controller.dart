import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shortzz/common/controller/base_controller.dart';
import 'package:shortzz/common/extensions/string_extension.dart';
import 'package:shortzz/common/manager/session_manager.dart';
import 'package:shortzz/common/service/api/contest_service.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/model/contest/contest_details_model.dart';
import 'package:shortzz/model/contest/contest_list_model.dart';
import 'package:shortzz/model/post_story/music/music_model.dart';
import 'package:shortzz/screen/camera_screen/camera_screen.dart';
import 'package:shortzz/screen/contest_reel_screen/contest_leaderboard_screen.dart';
import 'package:shortzz/screen/selected_music_sheet/selected_music_sheet_controller.dart';

class ContestReelScreenController extends BaseController {
  final List<String> dropdownItems = ['Join', 'Joined'];
  final RxString selectedOption = 'Join'.obs;

  final RxInt timeRemainingSeconds = 0.obs;
  Timer? _timer;

  final AudioPlayer audioPlayer = AudioPlayer();
  final RxBool isPlaying = false.obs;
  final RxBool isAudioLoading = false.obs;
  final RxnString playingContestId = RxnString();

  final RxList<Contest> contests = <Contest>[].obs;
  final RxBool isContestLoading = false.obs;
  final RxBool isContestDetailsLoading = false.obs;
  final RxBool isLeaderboardRefreshing = false.obs;
  final Rxn<Contest> selectedContest = Rxn<Contest>();
  final Rxn<ContestMyRanking> myRanking = Rxn<ContestMyRanking>();
  final RxList<ContestLeaderboardItem> leaderboard =
      <ContestLeaderboardItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchContestList();
    _listenToPlayerState();
  }

  Future<void> fetchContestList({bool showLoader = true}) async {
    if (showLoader) isContestLoading.value = true;
    try {
      final list = await ContestService.instance.fetchContestList();
      contests.assignAll(list);
    } catch (e) {
      contests.clear();
    } finally {
      if (showLoader) isContestLoading.value = false;
    }
  }

  Future<void> onRefreshContests() async {
    await fetchContestList(showLoader: false);
  }

  Future<void> fetchContestDetails(String contestId) async {
    isContestDetailsLoading.value = true;
    try {
      final data = await ContestService.instance.fetchContestDetails(
        contestId: contestId,
      );
      if (data?.contest != null) {
        final previousJoined = selectedContest.value?.joined;
        selectedContest.value = data!.contest!
          ..joined = data.contest?.joined ?? previousJoined;
      }
      myRanking.value = data?.myRanking;
      leaderboard.assignAll(data?.leaderboard ?? []);

      final hasRank = data?.myRanking?.rank != null;
      selectedOption.value =
          (hasRank || selectedContest.value?.joined == true) ? 'Joined' : 'Join';
      _syncCountdownFromStartDate();
    } catch (e) {
      myRanking.value = null;
      leaderboard.clear();
    } finally {
      isContestDetailsLoading.value = false;
    }
  }

  Future<void> refreshLeaderboard() async {
    final contestId = selectedContest.value?.contestId;
    if (contestId == null || contestId.isEmpty) return;
    if (isLeaderboardRefreshing.value) return;

    isLeaderboardRefreshing.value = true;
    try {
      final model = await ContestService.instance.fetchContestLeaderboard(
        contestId: contestId,
      );
      final list = (model.data ?? [])
          .map((e) => ContestLeaderboardItem(
                rank: e.rank,
                userId: e.userId,
                userName: e.userName,
                points: e.points,
              ))
          .toList();
      leaderboard.assignAll(list);

      // Update self Rank # from refreshed leaderboard
      final myUserId = SessionManager.instance.getUserID();
      ContestLeaderboardItem? myEntry;
      for (final item in list) {
        if (item.userId == myUserId) {
          myEntry = item;
          break;
        }
      }
      if (myEntry != null) {
        myRanking.value = ContestMyRanking(
          rank: myEntry.rank,
          points: myEntry.points,
        );
      }

      _showBottomSnackBar(
        model.message ?? LKey.leaderboardRefreshed.tr,
      );
    } catch (e) {
      _showBottomSnackBar('$e');
    } finally {
      isLeaderboardRefreshing.value = false;
    }
  }

  void _showBottomSnackBar(String message) {
    if (Get.isSnackbarOpen) {
      Get.closeCurrentSnackbar();
    }
    Get.rawSnackbar(
      messageText: Text(
        message,
        style: const TextStyle(color: Colors.white, fontSize: 14),
      ),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.black87,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      borderRadius: 10,
      duration: const Duration(seconds: 2),
      isDismissible: true,
    );
  }

  void _listenToPlayerState() {
    audioPlayer.playerStateStream.listen((state) {
      isPlaying.value =
          state.playing && state.processingState != ProcessingState.completed;
      if (state.processingState == ProcessingState.completed) {
        playingContestId.value = null;
      }
    });
  }

  Future<void> togglePlayPause(Contest contest) async {
    final soundUrl = contest.audioURL;
    if (soundUrl == null || soundUrl.isEmpty) return;

    if (playingContestId.value == contest.contestId && audioPlayer.playing) {
      await audioPlayer.pause();
      return;
    }

    isAudioLoading.value = true;
    playingContestId.value = contest.contestId;
    try {
      final fullUrl =
          soundUrl.startsWith('http') ? soundUrl : soundUrl.addBaseURL();
      await audioPlayer.setUrl(fullUrl);
      await audioPlayer.seek(Duration.zero);
      await audioPlayer.play();
    } catch (e) {
      playingContestId.value = null;
    } finally {
      isAudioLoading.value = false;
    }
  }

  Future<void> stopContestAudio() async {
    try {
      if (audioPlayer.playing || isAudioLoading.value) {
        await audioPlayer.stop();
      }
    } catch (_) {}
    isPlaying.value = false;
    isAudioLoading.value = false;
    playingContestId.value = null;
  }

  void onDownloadContestAudioTap() {
    final contest = selectedContest.value;
    final audioUrl = contest?.audioURL?.trim() ?? '';
    if (audioUrl.isEmpty) {
      showSnackBar(LKey.contestAudioNotAvailable.tr);
      return;
    }

    final songName = contest?.audioName?.trim().isNotEmpty == true
        ? contest!.audioName!.trim()
        : LKey.contestAudio.tr;

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 28),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1B2A4A),
                Color(0xFF15161A),
                Color(0xFF0F1A2E),
              ],
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.12),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF42A5F5).withValues(alpha: 0.25),
                blurRadius: 28,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF42A5F5),
                      Color(0xFF1E88E5),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF42A5F5).withValues(alpha: 0.45),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.download_rounded,
                  color: Colors.white,
                  size: 34,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                LKey.contest.tr,
                style: const TextStyle(
                  color: Color(0xFF90CAF9),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                songName,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                LKey.downloadContestSongConfirm.tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.75),
                  fontSize: 14,
                  height: 1.4,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white70,
                        side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.25),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        LKey.cancel.tr,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF42A5F5),
                            Color(0xFF1E88E5),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color:
                                const Color(0xFF1E88E5).withValues(alpha: 0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          Get.back();
                          downloadContestAudio();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          LKey.yes.tr,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierColor: Colors.black.withValues(alpha: 0.65),
    );
  }

  Future<void> downloadContestAudio() async {
    final contest = selectedContest.value;
    final audioUrl = contest?.audioURL?.trim() ?? '';
    if (audioUrl.isEmpty) {
      showSnackBar(LKey.contestAudioNotAvailable.tr);
      return;
    }

    showLoader();
    try {
      if (Platform.isAndroid) {
        await Permission.storage.request();
      }

      final fullUrl = resolveImageUrl(audioUrl);
      final cachedFile = await DefaultCacheManager().getSingleFile(fullUrl);

      final rawName = contest?.audioName?.trim().isNotEmpty == true
          ? contest!.audioName!.trim()
          : 'contest_song';
      final safeName = rawName
          .replaceAll(RegExp(r'[^\w\s\-.]'), '_')
          .replaceAll(RegExp(r'\s+'), '_');
      final extension = _audioExtension(fullUrl, cachedFile.path);
      final contestId = contest?.contestId ?? 'song';
      final fileName = '${safeName}_$contestId$extension';

      final savedPath = await _saveAudioToDownloads(cachedFile, fileName);
      stopLoader();
      if (savedPath != null) {
        _showDownloadSuccessSnackBar(savedPath);
      } else {
        showSnackBar(LKey.musicDownloadFailed.tr);
      }
    } catch (_) {
      stopLoader();
      showSnackBar(LKey.musicDownloadFailed.tr);
    }
  }

  void _showDownloadSuccessSnackBar(String filePath) {
    if (Get.isSnackbarOpen) {
      Get.closeCurrentSnackbar();
    }

    Get.rawSnackbar(
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF1B2A4A),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      padding: const EdgeInsets.fromLTRB(14, 14, 8, 14),
      borderRadius: 14,
      duration: const Duration(seconds: 6),
      isDismissible: true,
      messageText: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            LKey.downloadCompletedSuccessfully.tr,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            filePath,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.65),
              fontSize: 11,
              height: 1.3,
            ),
          ),
        ],
      ),
      mainButton: TextButton(
        onPressed: () async {
          if (Get.isSnackbarOpen) {
            Get.closeCurrentSnackbar();
          }
          await SharePlus.instance.share(
            ShareParams(files: [XFile(filePath)]),
          );
        },
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFF90CAF9),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        child: Text(
          LKey.open.tr,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  String _audioExtension(String url, String localPath) {
    final fromPath = localPath.contains('.')
        ? '.${localPath.split('.').last.split('?').first}'
        : '';
    if (fromPath.length <= 5 &&
        RegExp(r'^\.(mp3|m4a|aac|wav|ogg)$', caseSensitive: false)
            .hasMatch(fromPath)) {
      return fromPath.toLowerCase();
    }
    final uriPath = Uri.tryParse(url)?.path ?? '';
    if (uriPath.contains('.')) {
      final ext = '.${uriPath.split('.').last}';
      if (RegExp(r'^\.(mp3|m4a|aac|wav|ogg)$', caseSensitive: false)
          .hasMatch(ext)) {
        return ext.toLowerCase();
      }
    }
    return '.mp3';
  }

  Future<String?> _saveAudioToDownloads(File source, String fileName) async {
    Directory? directory;
    if (Platform.isAndroid) {
      directory = Directory('/storage/emulated/0/Download');
      if (!await directory.exists()) {
        directory = await getExternalStorageDirectory();
      }
    } else {
      directory = await getApplicationDocumentsDirectory();
    }
    if (directory == null) return null;
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    final destination = File('${directory.path}${Platform.pathSeparator}$fileName');
    await source.copy(destination.path);
    return destination.path;
  }

  bool isContestPlaying(Contest contest) {
    return playingContestId.value == contest.contestId &&
        (isPlaying.value || isAudioLoading.value);
  }

  void onOptionChanged(String? value) {
    if (value != null) {
      selectedOption.value = value;
    }
  }

  Future<void> onContestTap(Contest contest) async {
    await stopContestAudio();
    selectedContest.value = contest;
    selectedOption.value = (contest.joined == true) ? 'Joined' : 'Join';
    myRanking.value = null;
    leaderboard.clear();
    final contestId = contest.contestId;
    if (contestId == null || contestId.isEmpty) return;
    await fetchContestDetails(contestId);
  }

  /// Open contest details from notification (or deep link).
  Future<void> openContestById(String contestId) async {
    await stopContestAudio();
    Contest? contest;
    for (final item in contests) {
      if (item.contestId == contestId) {
        contest = item;
        break;
      }
    }
    contest ??= Contest(contestId: contestId);

    selectedContest.value = contest;
    selectedOption.value = (contest.joined == true) ? 'Joined' : 'Join';
    myRanking.value = null;
    leaderboard.clear();

    await fetchContestDetails(contestId);
    Get.to(() => const ContestLeaderboardScreen());
  }

  Future<void> onJoinContest() async {
    final contest = selectedContest.value;
    final contestId = contest?.contestId;
    if (contestId == null || contestId.isEmpty) {
      showSnackBar(LKey.contestNotFound.tr);
      return;
    }

    if (isContestExpired(contest)) {
      showSnackBar(LKey.contestExpired.tr);
      return;
    }

    final audioUrl = contest?.audioURL;
    if (audioUrl == null || audioUrl.isEmpty) {
      showSnackBar(LKey.contestAudioNotAvailable.tr);
      return;
    }

    showLoader();
    try {
      final fullAudioUrl = resolveImageUrl(audioUrl);
      final localPath =
          (await DefaultCacheManager().getSingleFile(fullAudioUrl)).path;

      final music = Music(
        title: contest?.audioName?.trim().isNotEmpty == true
            ? contest!.audioName!
            : (contest?.title ?? LKey.contestAudio.tr),
        sound: audioUrl,
        image: contest?.image,
        artist: LKey.contest.tr,
      );
      final selectedMusic = SelectedMusic(music, 0, localPath, 0);

      ContestService.pendingContestId = contestId;
      await audioPlayer.stop();
      stopLoader();

      Get.to(() => CameraScreen(
            cameraType: CameraScreenType.post,
            selectedMusic: selectedMusic,
            isContestFlow: true,
          ));
    } catch (e) {
      stopLoader();
      ContestService.pendingContestId = null;
      showSnackBar('$e');
    }
  }

  /// Returns true when contest [endDate] is already in the past.
  bool isContestExpired([Contest? contest]) {
    final endDateStr = (contest ?? selectedContest.value)?.endDate;
    if (endDateStr == null || endDateStr.isEmpty) return false;
    try {
      final end = DateTime.parse(endDateStr).toLocal();
      return DateTime.now().isAfter(end);
    } catch (_) {
      return false;
    }
  }

  void onContestUploadSuccess(String contestId) {
    selectedOption.value = 'Joined';
    selectedContest.update((c) {
      if (c?.contestId == contestId) {
        c?.joined = true;
      }
    });

    final index = contests.indexWhere((e) => e.contestId == contestId);
    if (index != -1) {
      contests[index].joined = true;
      contests.refresh();
    }

    fetchContestList();
  }

  void startTimer() {
    _syncCountdownFromStartDate();
  }

  void _syncCountdownFromStartDate() {
    _timer?.cancel();

    // ---------- TEST (30 sec) ----------
    // timeRemainingSeconds.value = 30;

    // ---------- REAL (startDate) ----------
    final startDateStr = selectedContest.value?.startDate;
    if (startDateStr == null || startDateStr.isEmpty) {
      timeRemainingSeconds.value = 0;
      return;
    }
    try {
      final start = DateTime.parse(startDateStr).toLocal();
      final remaining = start.difference(DateTime.now()).inSeconds;
      timeRemainingSeconds.value = remaining > 0 ? remaining : 0;
    } catch (_) {
      timeRemainingSeconds.value = 0;
      return;
    }
    if (timeRemainingSeconds.value <= 0) return;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timeRemainingSeconds.value > 0) {
        timeRemainingSeconds.value--;
      } else {
        _timer?.cancel();
      }
    });
  }

  String formatContestDate(String? dateTime) {
    if (dateTime == null || dateTime.isEmpty) return '-';
    try {
      return DateFormat('dd MMMM yyyy')
          .format(DateTime.parse(dateTime).toLocal());
    } catch (_) {
      return dateTime;
    }
  }

  String formatContestTime(String? dateTime) {
    if (dateTime == null || dateTime.isEmpty) return '-';
    try {
      return DateFormat('hh:mm a').format(DateTime.parse(dateTime).toLocal());
    } catch (_) {
      return '';
    }
  }

  String formatPrize(String? prize) {
    if (prize == null || prize.isEmpty) return '0';
    final value = double.tryParse(prize);
    if (value == null) return prize;
    return NumberFormat('#,###').format(value.toInt());
  }

  String resolveImageUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    return url.startsWith('http') ? url : url.addBaseURL();
  }

  String get selfUserIdLabel {
    final id = SessionManager.instance.getUserID();
    return LKey.userIdLabel.trParams({'id': id > 0 ? '$id' : '-'});
  }

  String get selfUserName {
    return SessionManager.instance.getUser()?.fullname ??
        SessionManager.instance.getUser()?.username ??
        LKey.youSelf.tr;
  }

  @override
  void onClose() {
    _timer?.cancel();
    audioPlayer.stop();
    audioPlayer.dispose();
    super.onClose();
  }
}
