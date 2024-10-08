///BannerList
class BannerItem {
  String endTime;
  int id;
  String imgAddr;
  String jumpAddr;
  int jumpType;
  int sort;
  String startTime;

  BannerItem({
    required this.endTime,
    required this.id,
    required this.imgAddr,
    required this.jumpAddr,
    required this.jumpType,
    required this.sort,
    required this.startTime,
  });

  //用下划线命名json参数
  factory BannerItem.fromJson(Map<String, dynamic> json) {
    return BannerItem(
      endTime: json['end_time'],
      id: json['id'],
      imgAddr: json['img_addr'],
      jumpAddr: json['jump_addr'],
      jumpType: json['jump_type'],
      sort: json['sort'],
      startTime: json['start_time'],
    );
  }

  //用下划线命名json参数
  Map<String, dynamic> toJson() {
    return {
      'end_time': endTime,
      'id': id,
      'img_addr': imgAddr,
      'jump_addr': jumpAddr,
      'jump_type': jumpType,
      'sort': sort,
      'start_time': startTime,
    };
  }

  //用下划线命名json参数
  BannerItem copyWith({
    String? endTime,
    int? id,
    String? imgAddr,
    String? jumpAddr,
    int? jumpType,
    int? sort,
    String? startTime,
  }) {
    return BannerItem(
      endTime: endTime ?? this.endTime,
      id: id ?? this.id,
      imgAddr: imgAddr ?? this.imgAddr,
      jumpAddr: jumpAddr ?? this.jumpAddr,
      jumpType: jumpType ?? this.jumpType,
      sort: sort ?? this.sort,
      startTime: startTime ?? this.startTime,
    );
  }

  //用下划线命名json参数
  @override
  String toString() {
    // TODO: implement toString
    return 'BannerItem{endTime: $endTime, id: $id, imgAddr: $imgAddr, jumpAddr: $jumpAddr, jumpType: $jumpType, sort: $sort, startTime: $startTime}';
  }
}
