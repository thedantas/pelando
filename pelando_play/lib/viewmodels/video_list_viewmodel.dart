import 'package:flutter/material.dart';
import '../models/video_model.dart';
import '../services/youtube_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class VideoListViewModel with ChangeNotifier {
  final YoutubeService _youtubeService = YoutubeService();
  List<VideoModel> _videos = [];

  List<VideoModel> get videos => _videos;

Future<List<VideoModel>> fetchVideos(String query) async {
  try {
    List<VideoModel> videos = await _youtubeService.fetchVideos(query);
    return videos; // Retorna a lista temporária para o modal
  } catch (e) {
    print('Erro ao buscar vídeos: $e');
    throw e; // Propaga o erro para ser tratado pelo FutureBuilder
  }
}
  // Adiciona um vídeo à lista.
  Future<void> addVideoByUrl(String url) async {
    try {
      final video = await _youtubeService.fetchVideoByUrl(url);
      _videos.add(video);
      notifyListeners();
    } catch (e) {
      print('Erro ao adicionar vídeo: $e');
      // Lide com o erro adequadamente.
    }
  }

// void clearVideos() {
//   _videos = [];
//   notifyListeners();
// }

  // Método para adicionar um vídeo diretamente à lista.
  void addVideo(VideoModel video) {
    _videos.add(video);
    notifyListeners();
  }

  // Método para remover um vídeo da lista.
  void removeVideo(VideoModel video) {
    _videos.removeWhere((v) => v.id == video.id);
    notifyListeners();
  }

}
