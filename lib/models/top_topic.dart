class TopTopic {
  const TopTopic({required this.topicId, required this.title, required this.label});

  final int topicId;
  final String title;
  final String label;

  factory TopTopic.fromJson(Map<String, dynamic> json) => TopTopic(
    topicId: int.tryParse('${json['topic_id']}') ?? 0,
    title: json['title']?.toString() ?? '',
    label: json['type']?.toString() ?? '公告',
  );
}
