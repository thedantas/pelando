// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import '../models/video_model.dart';

// class YoutubeService {
//   final String apiKey = 'AIzaSyC4vdhhNbOXc6cOUCy0pWpl2ZaYxqb8xBU';
//   final String baseUrl = 'https://www.googleapis.com/youtube/v3/search';

//   Future<List<VideoModel>> fetchVideos(String query) async {
//     final response = await http.get(Uri.parse('$baseUrl?part=snippet&type=video&maxResults=10&q=$query&key=$apiKey'));

//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       List<VideoModel> videos = [];

//       for (var item in data['items']) {
//         videos.add(VideoModel.fromJson(item));
//       }

//       return videos;
//     } else {
//       throw Exception('Failed to load videos');
//     }
//   }
  
// }

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/video_model.dart';

class YoutubeService {
  final String apiKey = 'AIzaSyC4vdhhNbOXc6cOUCy0pWpl2ZaYxqb8xBU';
 final String baseUrl = 'https://www.googleapis.com/youtube/v3/search';


  Future<List<VideoModel>> fetchVideos(String query) async {
    final response = await http.get(Uri.parse('$baseUrl?part=snippet&type=video&maxResults=10&q=$query&key=$apiKey'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<VideoModel> videos = [];

      for (var item in data['items']) {
        videos.add(VideoModel.fromJson(item));
      }

      return videos;
    } else {
      throw Exception('Failed to load videos');
    }
  }

 Future<VideoModel> fetchVideoByUrl(String url) async {
    final videoId = extractVideoIdFromUrl(url);
    final response = await http.get(Uri.parse('$baseUrl?part=snippet&type=video&maxResults=10&q=$videoId&key=$apiKey'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final items = data['items'];
      if (items != null && items.isNotEmpty) {
        return VideoModel.fromJson(items[0]);
      } else {
        throw Exception('Vídeo não encontrado');
      }
    } else {
      throw Exception('Falha ao carregar os detalhes do vídeo');
    }
  }

  String extractVideoIdFromUrl(String url) {
    final uri = Uri.parse(url);
    final videoId = uri.queryParameters['v'];
    if (videoId != null) {
      return videoId;
    } else {
      throw Exception('URL inválida');
    }
  }
}