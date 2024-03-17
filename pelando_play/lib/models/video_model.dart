class VideoModel {
  final String id;
  final String title;
  final String thumb;
  final String chanel;

  VideoModel({
    required this.id,
    required this.title,
    required this.thumb,
    required this.chanel,
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      id: json['id']?['videoId'] ?? '', // Garante um valor padrão de string vazia se null
      title: json['snippet']?['title'] ?? '',
      thumb: json['snippet']?['thumbnails']?['high']?['url'] ?? '',
      chanel: json['snippet']?['channelTitle'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'videoId': id,
      'title': title,
      'thumb': thumb,
      'chanel': chanel,
    };
  }
}
