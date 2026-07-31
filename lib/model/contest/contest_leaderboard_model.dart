class ContestLeaderboardModel {
  ContestLeaderboardModel({
    this.status,
    this.message,
    this.data,
  });

  ContestLeaderboardModel.fromJson(dynamic json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data?.add(ContestLeaderboardData.fromJson(v));
      });
    }
  }

  bool? status;
  String? message;
  List<ContestLeaderboardData>? data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = status;
    map['message'] = message;
    if (data != null) {
      map['data'] = data?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class ContestLeaderboardData {
  ContestLeaderboardData({
    this.rank,
    this.userId,
    this.userName,
    this.userImage,
    this.points,
  });

  ContestLeaderboardData.fromJson(dynamic json) {
    rank = json['rank'];
    userId = json['userId'];
    userName = json['userName'];
    userImage = json['userImage'];
    points = json['points'];
  }

  int? rank;
  int? userId;
  String? userName;
  String? userImage;
  int? points;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['rank'] = rank;
    map['userId'] = userId;
    map['userName'] = userName;
    map['userImage'] = userImage;
    map['points'] = points;
    return map;
  }
}
