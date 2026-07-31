import 'package:shortzz/common/manager/logger.dart';
import 'package:shortzz/common/service/api/api_service.dart';
import 'package:shortzz/common/service/utils/params.dart';
import 'package:shortzz/common/service/utils/web_service.dart';
import 'package:shortzz/model/contest/contest_details_model.dart';
import 'package:shortzz/model/contest/contest_leaderboard_model.dart';
import 'package:shortzz/model/contest/contest_list_model.dart';
import 'package:shortzz/model/contest/join_contest_model.dart';
import 'package:shortzz/model/contest/upload_contest_reel_model.dart';

class ContestService {
  ContestService._();

  static final ContestService instance = ContestService._();

  /// Set when user joins a contest and opens camera to create reel.
  static String? pendingContestId;

  Future<List<Contest>> fetchContestList() async {
    ContestListModel model = await ApiService.instance.call(
      url: WebService.contest.fetchContestList,
      param: {},
      fromJson: ContestListModel.fromJson,
    );
    return model.data?.contests ?? [];
  }

  Future<ContestDetailsData?> fetchContestDetails({
    required String contestId,
  }) async {
    ContestDetailsModel model = await ApiService.instance.call(
      url: WebService.contest.fetchContestDetails,
      param: {Params.contestId: contestId},
      fromJson: ContestDetailsModel.fromJson,
    );
    return model.data;
  }

  Future<JoinContestModel> joinContest({required String contestId}) async {
    final param = {Params.contestId: contestId};
    Loggers.info('joinContest payload: $param');
    return ApiService.instance.call(
      url: WebService.contest.joinContest,
      param: param,
      fromJson: JoinContestModel.fromJson,
    );
  }

  Future<UploadContestReelModel> uploadContestReel({
    required String contestId,
    required String videoUrl,
    required String postId,
  }) async {
    final param = {
      Params.contestId: contestId,
      Params.videoUrl: videoUrl,
      Params.contestPostId: postId,
    };
    Loggers.info('uploadContestReel payload: $param');
    return ApiService.instance.call(
      url: WebService.contest.uploadContestReel,
      param: param,
      fromJson: UploadContestReelModel.fromJson,
    );
  }

  Future<ContestLeaderboardModel> fetchContestLeaderboard({
    required String contestId,
  }) async {
    return ApiService.instance.call(
      url: WebService.contest.fetchContestLeaderboard,
      param: {Params.contestId: contestId},
      fromJson: ContestLeaderboardModel.fromJson,
    );
  }
}
