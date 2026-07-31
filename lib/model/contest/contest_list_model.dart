class ContestListModel {
  ContestListModel({
    this.status,
    this.message,
    this.data,
  });

  ContestListModel.fromJson(dynamic json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? ContestListData.fromJson(json['data']) : null;
  }

  bool? status;
  String? message;
  ContestListData? data;

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

class ContestListData {
  ContestListData({
    this.contests,
    this.currentPage,
    this.perPage,
    this.totalRecords,
    this.totalPages,
  });

  ContestListData.fromJson(dynamic json) {
    if (json['contests'] != null) {
      contests = [];
      json['contests'].forEach((v) {
        contests?.add(Contest.fromJson(v));
      });
    }
    currentPage = json['currentPage'];
    perPage = json['perPage'];
    totalRecords = json['totalRecords'];
    totalPages = json['totalPages'];
  }

  List<Contest>? contests;
  int? currentPage;
  int? perPage;
  int? totalRecords;
  int? totalPages;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (contests != null) {
      map['contests'] = contests?.map((v) => v.toJson()).toList();
    }
    map['currentPage'] = currentPage;
    map['perPage'] = perPage;
    map['totalRecords'] = totalRecords;
    map['totalPages'] = totalPages;
    return map;
  }
}

class Contest {
  Contest({
    this.contestId,
    this.title,
    this.description,
    this.image,
    this.prize,
    this.audioURL,
    this.audioName,
    this.startDate,
    this.endDate,
    this.status,
    this.joined,
  });

  Contest.fromJson(dynamic json) {
    contestId = json['contestId'];
    title = json['title'];
    description = json['description'];
    image = json['image'];
    prize = json['prize'];
    audioURL = json['audioURL'];
    audioName = json['audioName'];
    startDate = json['startDate'];
    endDate = json['endDate'];
    status = json['status'];
    joined = json['joined'];
  }

  String? contestId;
  String? title;
  String? description;
  String? image;
  String? prize;
  String? audioURL;
  String? audioName;
  String? startDate;
  String? endDate;
  String? status;
  bool? joined;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['contestId'] = contestId;
    map['title'] = title;
    map['description'] = description;
    map['image'] = image;
    map['prize'] = prize;
    map['audioURL'] = audioURL;
    map['audioName'] = audioName;
    map['startDate'] = startDate;
    map['endDate'] = endDate;
    map['status'] = status;
    map['joined'] = joined;
    return map;
  }
}
