
///ShopItem
class ShopItem {
  String cycle;
  int exchangeCount;
  int exchangeId;
  String itemContext;
  int itemCount;
  String itemName;
  String itemPic;
  int maxExchangeCount;
  int useScore;

  ShopItem({
    required this.cycle,
    required this.exchangeCount,
    required this.exchangeId,
    required this.itemContext,
    required this.itemCount,
    required this.itemName,
    required this.itemPic,
    required this.maxExchangeCount,
    required this.useScore,
  });

  //下划线命名json
  factory ShopItem.fromJson(Map<String, dynamic> json) {
    return ShopItem(
      cycle: json['cycle'],
      exchangeCount: json['exchange_count'],
      exchangeId: json['exchange_id'],
      itemContext: json['item_context'],
      itemCount: json['item_count'],
      itemName: json['item_name'],
      itemPic: json['item_pic'],
      maxExchangeCount: json['max_exchange_count'],
      useScore: json['use_score'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['cycle'] = cycle;
    data['exchange_count'] = exchangeCount;
    data['exchange_id'] = exchangeId;
    data['item_context'] = itemContext;
    data['item_count'] = itemCount;
    data['item_name'] = itemName;
    data['item_pic'] = itemPic;
    data['max_exchange_count'] = maxExchangeCount;
    data['use_score'] = useScore;
    return data;
  }

}