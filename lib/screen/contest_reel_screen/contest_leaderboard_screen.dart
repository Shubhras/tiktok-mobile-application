import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/widget/custom_app_bar.dart';
import 'package:shortzz/common/widget/custom_image.dart';
import 'package:shortzz/common/widget/theme_blur_bg.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/utilities/asset_res.dart';

import 'contest_reel_screen_controller.dart';

class ContestLeaderboardScreen extends StatefulWidget {
  const ContestLeaderboardScreen({super.key});

  @override
  State<ContestLeaderboardScreen> createState() => _ContestLeaderboardScreenState();
}

class _ContestLeaderboardScreenState extends State<ContestLeaderboardScreen> {
  late final ContestReelScreenController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<ContestReelScreenController>();
    controller.startTimer(); // Countdown until contest startDate
  }

  @override
  void dispose() {
    controller.stopContestAudio();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const ThemeBlurBg(),
          SafeArea(
            top: false,
            child: Column(
              children: [
                CustomAppBar(
                  title: LKey.contestDetailsLeaderboard.tr,
                  bgColor: Colors.transparent,
                  titleStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  iconColor: Colors.white,
                ),
                Expanded(
                  child: Stack(
                    children: [
                      SingleChildScrollView(
                        padding: const EdgeInsets.only(
                          left: 15,
                          right: 15,
                          top: 10,
                          bottom: 80, // Extra padding to avoid overlap with bottom button
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 1. Same Contest Card details at the top (Read-only representation)
                            Container(
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
                                  Obx(() {
                                    final contest = controller.selectedContest.value;
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 10, vertical: 5),
                                              decoration: BoxDecoration(
                                                color: Colors.blueAccent.withOpacity(0.25),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                '#${contest?.contestId ?? ''}',
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            if (controller.selectedOption.value == 'Joined')
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                    horizontal: 12, vertical: 6),
                                                decoration: BoxDecoration(
                                                  color: Colors.green.withOpacity(0.25),
                                                  borderRadius: BorderRadius.circular(8),
                                                  border: Border.all(
                                                    color: Colors.greenAccent.withOpacity(0.5),
                                                    width: 1,
                                                  ),
                                                ),
                                                child: Text(
                                                  LKey.joined.tr,
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.greenAccent,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 15),
                                        Text(
                                          contest?.title ?? '',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        if ((contest?.description ?? '')
                                            .isNotEmpty) ...[
                                          const SizedBox(height: 8),
                                          Text(
                                            contest?.description ?? '',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color:
                                                  Colors.white.withOpacity(0.8),
                                            ),
                                          ),
                                        ],
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
                                              controller.formatPrize(contest?.prize),
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
                                        const SizedBox(height: 15),
                                        GestureDetector(
                                          onTap: contest == null
                                              ? null
                                              : () => controller.togglePlayPause(contest),
                                          child: Row(
                                            children: [
                                              Stack(
                                                alignment: Alignment.center,
                                                children: [
                                                  CustomImage(
                                                    size: const Size(36, 36),
                                                    radius: 8,
                                                    image: controller
                                                        .resolveImageUrl(contest?.image),
                                                    isShowPlaceHolder: true,
                                                    placeHolderImage: AssetRes.icMusic,
                                                  ),
                                                  Container(
                                                    width: 36,
                                                    height: 36,
                                                    decoration: BoxDecoration(
                                                      color: Colors.black38,
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    alignment: Alignment.center,
                                                    child: Icon(
                                                      contest != null &&
                                                              controller.isContestPlaying(contest)
                                                          ? Icons.pause
                                                          : Icons.play_arrow,
                                                      size: 20,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  contest?.audioName
                                                              ?.trim()
                                                              .isNotEmpty ==
                                                          true
                                                      ? contest!.audioName!
                                                      : LKey.contestAudio.tr,
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
                                                  controller
                                                      .formatContestDate(contest?.startDate),
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  controller
                                                      .formatContestTime(contest?.startDate),
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
                                                  controller
                                                      .formatContestDate(contest?.endDate),
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  controller
                                                      .formatContestTime(contest?.endDate),
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
                                    );
                                  }),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),

                            // 2. Self User Info Card
                            Obx(() {
                              final isJoined =
                                  controller.selectedOption.value == 'Joined';
                              final rank = controller.myRanking.value?.rank;
                              return Container(
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.4),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.blueAccent.withOpacity(0.6),
                                    width: 1.2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.15),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 20,
                                          backgroundColor:
                                              Colors.white.withOpacity(0.2),
                                          child: const Icon(Icons.person,
                                              color: Colors.white),
                                        ),
                                        const SizedBox(width: 12),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              controller.selfUserName,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              controller.selfUserIdLabel,
                                              style: const TextStyle(
                                                color: Colors.white70,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: isJoined
                                            ? Colors.white.withOpacity(0.15)
                                            : Colors.blueAccent
                                                .withOpacity(0.25),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: isJoined
                                              ? Colors.white24
                                              : Colors.blueAccent
                                                  .withOpacity(0.5),
                                        ),
                                      ),
                                      child: Text(
                                        isJoined
                                            ? LKey.rankNumber.trParams({
                                                'rank': '${rank ?? '-'}',
                                              })
                                            : LKey.join.tr,
                                        style: TextStyle(
                                          color: isJoined
                                              ? Colors.white
                                              : Colors.blueAccent[100],
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),

                            // 3. Conditional Countdown Timer & Leaderboard Lists
                            Obx(() {
                              if (controller.isContestDetailsLoading.value) {
                                return const Padding(
                                  padding: EdgeInsets.only(top: 40),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                        color: Colors.white),
                                  ),
                                );
                              }

                              final isJoined =
                                  controller.selectedOption.value == 'Joined';
                              final isTimerRunning =
                                  controller.timeRemainingSeconds.value > 0;

                              if (!isJoined && isTimerRunning) {
                                return _buildCountdownTimer();
                              }

                              final items = controller.leaderboard;
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 25),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          LKey.topLeaderboard.tr,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      Obx(() {
                                        return _SpinningRefreshButton(
                                          isRefreshing: controller
                                              .isLeaderboardRefreshing.value,
                                          onPressed:
                                              controller.refreshLeaderboard,
                                        );
                                      }),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  if (items.isEmpty)
                                     Text(
                                      LKey.noLeaderboardData.tr,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 13,
                                      ),
                                    )
                                  else
                                    ...items.map(
                                      (item) => _buildLeaderboardItem(
                                        item.rank ?? 0,
                                        item.userName ?? LKey.user.tr,
                                        '${item.points ?? 0}',
                                      ),
                                    ),
                                ],
                              );
                            }),
                          ],
                        ),
                      ),

                      // 5. Sticky Join Button at the bottom (only visible when not joined)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Obx(() {
                          final isJoined =
                              controller.selectedOption.value == 'Joined';
                          if (isJoined) {
                            return const SizedBox();
                          }

                          final isTimerRunning =
                              controller.timeRemainingSeconds.value > 0;

                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF15161A).withOpacity(0.95),
                              border: const Border(
                                top: BorderSide(
                                    color: Colors.white10, width: 0.5),
                              ),
                            ),
                            child: SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isTimerRunning
                                      ? Colors.white.withOpacity(0.12)
                                      : Colors.blueAccent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  elevation: isTimerRunning ? 0 : 2,
                                ),
                                onPressed: isTimerRunning
                                    ? null
                                    : () {
                                        controller.onJoinContest();
                                      },
                                child: Text(
                                  LKey.joinContest.tr,
                                  style: TextStyle(
                                    color: isTimerRunning
                                        ? Colors.white38
                                        : Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountdownTimer() {
    return Container(
      margin: const EdgeInsets.only(top: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.amber.withOpacity(0.5),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.hourglass_empty,
                color: Colors.amber,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                LKey.contestStartsIn.tr,
                style: const TextStyle(
                  color: Colors.amber,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Obx(() {
            final totalSeconds = controller.timeRemainingSeconds.value;
            final days = totalSeconds ~/ (24 * 3600);
            final hours = (totalSeconds % (24 * 3600)) ~/ 3600;
            final minutes = (totalSeconds % 3600) ~/ 60;
            final seconds = totalSeconds % 60;

            final daysStr = days.toString().padLeft(2, '0');
            final hoursStr = hours.toString().padLeft(2, '0');
            final minutesStr = minutes.toString().padLeft(2, '0');
            final secondsStr = seconds.toString().padLeft(2, '0');

            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTimeDigit(daysStr, LKey.days.tr),
                _buildTimeDivider(),
                _buildTimeDigit(hoursStr, LKey.hours.tr),
                _buildTimeDivider(),
                _buildTimeDigit(minutesStr, LKey.min.tr),
                _buildTimeDivider(),
                _buildTimeDigit(secondsStr, LKey.sec.tr),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTimeDigit(String value, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white12),
          ),
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeDivider() {
    return const Padding(
      padding: EdgeInsets.only(left: 6, right: 6, bottom: 15),
      child: Text(
        ":",
        style: TextStyle(
          color: Colors.amber,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildLeaderboardItem(int rank, String name, String points) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.12),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Rank Badge
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _getRankColor(rank),
              shape: BoxShape.circle,
            ),
            child: Text(
              "$rank",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // User Avatar
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.blueAccent.withOpacity(0.2),
            child: Text(
              name[0],
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Name
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // Coins / Points with Coin Icon
          Text(
            points,
            style: const TextStyle(
              color: Colors.amber,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 4),
          Image.asset(
            AssetRes.icCoin,
            width: 14,
            height: 14,
          ),
        ],
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber;
      default:
        return Colors.white.withOpacity(0.12);
    }
  }
}

class _SpinningRefreshButton extends StatefulWidget {
  const _SpinningRefreshButton({
    required this.isRefreshing,
    required this.onPressed,
  });

  final bool isRefreshing;
  final VoidCallback onPressed;

  @override
  State<_SpinningRefreshButton> createState() => _SpinningRefreshButtonState();
}

class _SpinningRefreshButtonState extends State<_SpinningRefreshButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    if (widget.isRefreshing) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant _SpinningRefreshButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRefreshing && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.isRefreshing && _controller.isAnimating) {
      _controller
        ..stop()
        ..reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: widget.isRefreshing ? null : widget.onPressed,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      icon: RotationTransition(
        turns: _controller,
        child: const Icon(
          Icons.refresh,
          color: Colors.white70,
          size: 22,
        ),
      ),
    );
  }
}
