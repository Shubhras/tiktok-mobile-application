import 'package:shortzz/model/contest/contest_list_model.dart';

class ContestDetailsModel {
  ContestDetailsModel({
    this.status,
    this.message,
    this.data,
  });

  ContestDetailsModel.fromJson(dynamic json) {
    status = json['status'];
    message = json['message'];
    data =
        json['data'] != null ? ContestDetailsData.fromJson(json['data']) : null;
  }

  bool? status;
  String? message;
  ContestDetailsData? data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = status;
    map['message'] = message;
    if (data != null) {
      map['data'] = data?.toJson();
    }
    return map;
  }
}

class ContestDetailsData {
  ContestDetailsData({
    this.contest,
    this.myRanking,
    this.leaderboard,
  });

  ContestDetailsData.fromJson(dynamic json) {
    contest =
        json['contest'] != null ? Contest.fromJson(json['contest']) : null;
    myRanking = json['myRanking'] != null
        ? ContestMyRanking.fromJson(json['myRanking'])
        : null;
    if (json['leaderboard'] != null) {
      leaderboard = [];
      json['leaderboard'].forEach((v) {
        leaderboard?.add(ContestLeaderboardItem.fromJson(v));
      });
    }
  }

  Contest? contest;
  ContestMyRanking? myRanking;
  List<ContestLeaderboardItem>? leaderboard;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (contest != null) {
      map['contest'] = contest?.toJson();
    }
    if (myRanking != null) {
      map['myRanking'] = myRanking?.toJson();
    }
    if (leaderboard != null) {
      map['leaderboard'] = leaderboard?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class ContestMyRanking {
  ContestMyRanking({
    this.rank,
    this.points,
  });

  ContestMyRanking.fromJson(dynamic json) {
    rank = json['rank'];
    points = json['points'];
  }

  int? rank;
  int? points;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['rank'] = rank;
    map['points'] = points;
    return map;
  }
}

class ContestLeaderboardItem {
  ContestLeaderboardItem({
    this.rank,
    this.userId,
    this.userName,
    this.points,
  });

  ContestLeaderboardItem.fromJson(dynamic json) {
    rank = json['rank'];
    userId = json['userId'];
    userName = json['userName'];
    points = json['points'];
  }

  int? rank;
  int? userId;
  String? userName;
  int? points;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['rank'] = rank;
    map['userId'] = userId;
    map['userName'] = userName;
    map['points'] = points;
    return map;
  }
}
