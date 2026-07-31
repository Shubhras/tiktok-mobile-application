import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';
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
            hideGallery: true,
          ));
    } catch (e) {
      stopLoader();
      ContestService.pendingContestId = null;
      showSnackBar('$e');
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
