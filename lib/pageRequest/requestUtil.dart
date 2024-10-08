//筛选条件
enum SortType {
  reply(1, "最近回复"),
  post(2, "最新发布"),
  hot(3, "热度");

  final int type;
  final String description;

  const SortType(this.type, this.description);
}

//发现，休息室，攻略，同人，世界观，官方
enum CategoryId {
  none(100, "没有这一栏"),
  recommend(1, "发现"),
  restroom(2, "休息室"),
  strategy(3, "攻略");

  final int type;
  final String description;

  const CategoryId(this.type, this.description);
}

//主页下栏目
enum QueryType {
  homepage(1, "主页"),
  follow(3, "关注"),
  identity(4, "我的");

  final int type;
  final String description;

  const QueryType(this.type, this.description);
}