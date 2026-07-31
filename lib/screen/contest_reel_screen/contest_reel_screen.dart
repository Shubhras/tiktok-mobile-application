import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:shortzz/common/widget/custom_app_bar.dart';
import 'package:shortzz/common/widget/custom_image.dart';
import 'package:shortzz/common/widget/my_refresh_indicator.dart';
import 'package:shortzz/common/widget/theme_blur_bg.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/model/contest/contest_list_model.dart';
import 'package:shortzz/utilities/asset_res.dart';

import 'contest_leaderboard_screen.dart';
import 'contest_reel_screen_controller.dart';

class ContestReelScreen extends StatelessWidget {
  const ContestReelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ContestReelScreenController());
    return Scaffold(
      body: Stack(
        children: [
          const ThemeBlurBg(),
          SafeArea(
            top: false,
            child: Column(
              children: [
                CustomAppBar(
                  title: LKey.contestReel.tr,
                  bgColor: Colors.transparent,
                  titleStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  iconColor: Colors.white,
                ),
                Expanded(
                  child: Obx(() {
                    if (controller.isContestLoading.value &&
                        controller.contests.isEmpty) {
                      return const _ContestListShimmer();
                    }

                    return MyRefreshIndicator(
                      onRefresh: controller.onRefreshContests,
                      child: controller.contests.isEmpty
                          ? ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: [
                                const SizedBox(height: 200),
                                Center(
                                  child: Text(
                                    LKey.noContestsFound.tr,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : ListView.separated(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 10),
                              itemCount: controller.contests.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final contest = controller.contests[index];
                                return _ContestCard(
                                  contest: contest,
                                  controller: controller,
                                );
                              },
                            ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ContestListShimmer extends StatelessWidget {
  const _ContestListShimmer();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      itemCount: 4,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) => const _ContestCardShimmer(),
    );
  }
}

class _ContestCardShimmer extends StatelessWidget {
  const _ContestCardShimmer();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.white.withOpacity(0.35),
      highlightColor: Colors.white.withOpacity(0.65),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.35),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1.2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _box(width: 90, height: 26, radius: 8),
            const SizedBox(height: 15),
            _box(width: 180, height: 18, radius: 6),
            const SizedBox(height: 15),
            _box(width: 150, height: 14, radius: 6),
            const SizedBox(height: 15),
            Row(
              children: [
                _box(width: 36, height: 36, radius: 8),
                const SizedBox(width: 8),
                _box(width: 110, height: 14, radius: 6),
              ],
            ),
            const SizedBox(height: 15),
            Container(height: 1, color: Colors.white24),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _box(width: 80, height: 12, radius: 4),
                    const SizedBox(height: 6),
                    _box(width: 100, height: 13, radius: 4),
                    const SizedBox(height: 4),
                    _box(width: 70, height: 12, radius: 4),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _box(width: 80, height: 12, radius: 4),
                    const SizedBox(height: 6),
                    _box(width: 100, height: 13, radius: 4),
                    const SizedBox(height: 4),
                    _box(width: 70, height: 12, radius: 4),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _box({
    required double width,
    required double height,
    double radius = 6,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class _ContestCard extends StatelessWidget {
  const _ContestCard({
    required this.contest,
    required this.controller,
  });

  final Contest contest;
  final ContestReelScreenController controller;

  @override
  Widget build(BuildContext context) {
    final isJoined = contest.joined == true;
    final hasAudio =
        contest.audioURL != null && contest.audioURL!.trim().isNotEmpty;

                      return GestureDetector(
                        onTap: () {
        controller.onContestTap(contest);
                          Get.to(() => const ContestLeaderboardScreen());
                        },
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.35),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.25),
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: Colors.blueAccent.withOpacity(0.25),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                  child: Text(
                    '#${contest.contestId ?? ''}',
                    style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                    Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                    color: isJoined
                        ? Colors.green.withOpacity(0.25)
                        : Colors.orange.withOpacity(0.25),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                      color: isJoined
                          ? Colors.greenAccent.withOpacity(0.5)
                          : Colors.orangeAccent.withOpacity(0.5),
                                          width: 1,
                                        ),
                                      ),
                  child: Text(
                    isJoined ? LKey.joined.tr : LKey.join.tr,
                                        style: TextStyle(
                      color: isJoined ? Colors.greenAccent : Colors.orangeAccent,
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                ),
                                ],
                              ),
                              const SizedBox(height: 15),
            Text(
              contest.title ?? '',
              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 15),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.emoji_events,
                                    color: Colors.amber,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                Text(
                  '${LKey.prizePool.tr} ',
                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                Text(
                  controller.formatPrize(contest.prize),
                  style: const TextStyle(
                                      color: Colors.amber,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Image.asset(
                                    AssetRes.icCoin,
                                    width: 16,
                                    height: 16,
                                  ),
                                ],
                              ),
            if (hasAudio ||
                (contest.image != null && contest.image!.isNotEmpty)) ...[
                              const SizedBox(height: 15),
                              GestureDetector(
                onTap: hasAudio
                    ? () => controller.togglePlayPause(contest)
                    : null,
                                child: Row(
                                  children: [
                                    Obx(() {
                      final imageUrl =
                          controller.resolveImageUrl(contest.image);
                      final playing = controller.isContestPlaying(contest);
                                      return Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          CustomImage(
                                            size: const Size(36, 36),
                                            radius: 8,
                                            image: imageUrl,
                                            isShowPlaceHolder: true,
                                            placeHolderImage: AssetRes.icMusic,
                                          ),
                          if (hasAudio)
                                          Container(
                                            width: 36,
                                            height: 36,
                                            decoration: BoxDecoration(
                                              color: Colors.black38,
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            alignment: Alignment.center,
                                            child: Icon(
                                playing ? Icons.pause : Icons.play_arrow,
                                              size: 20,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      );
                                    }),
                                    const SizedBox(width: 8),
                                    Expanded(
                      child: Text(
                        hasAudio
                            ? (contest.audioName?.trim().isNotEmpty == true
                                ? contest.audioName!
                                : LKey.contestAudio.tr)
                            : LKey.contestCover.tr,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                      ),
                                    ),
                                  ],
                                ),
                              ),
            ],
                              const SizedBox(height: 15),
                              const Divider(
                                color: Colors.white24,
                                thickness: 1,
                              ),
                              const SizedBox(height: 10),
            Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                        const Icon(
                                            Icons.calendar_today,
                                            size: 14,
                                            color: Colors.white70,
                                          ),
                        const SizedBox(width: 6),
                                          Text(
                          LKey.startDate.tr,
                          style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.white70,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                    const SizedBox(height: 4),
                                      Text(
                      controller.formatContestDate(contest.startDate),
                      style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                    const SizedBox(height: 2),
                                      Text(
                      controller.formatContestTime(contest.startDate),
                      style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Row(
                                        children: [
                        const Icon(
                                            Icons.calendar_today,
                                            size: 14,
                                            color: Colors.white70,
                                          ),
                        const SizedBox(width: 6),
                                          Text(
                          LKey.endDate.tr,
                          style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.white70,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                    const SizedBox(height: 4),
                                      Text(
                      controller.formatContestDate(contest.endDate),
                      style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                    const SizedBox(height: 2),
                                      Text(
                      controller.formatContestTime(contest.endDate),
                      style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
      ),
    );
  }
}
