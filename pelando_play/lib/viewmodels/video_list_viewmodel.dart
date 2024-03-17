import 'package:flutter/material.dart';
import '../models/video_model.dart';
import '../services/youtube_service.dart';
import 'dart:convert';

/// ViewModel que gerencia o estado da lista de vídeos.
class VideoListViewModel with ChangeNotifier {
  final YoutubeService _youtubeService = YoutubeService();
  List<VideoModel> _videos = [];

  /// Retorna a lista imutável de vídeos.
  List<VideoModel> get videos => List.unmodifiable(_videos);

  /// Busca vídeos com base na query fornecida e retorna uma lista de VideoModel.
  /// 
  /// Se a busca falhar, propaga a exceção para ser tratada pelo chamador.
  Future<List<VideoModel>> fetchVideos(String query) async {
    try {
      List<VideoModel> videos = await _youtubeService.fetchVideos(query);
      return videos; // Retorna a lista temporária para o modal.
    } catch (e) {
      print('Erro ao buscar vídeos: $e');
      throw e; // Propaga o erro para ser tratado pelo FutureBuilder.
    }
  }

  /// Adiciona um vídeo à lista baseado na URL fornecida.
  /// 
  /// Se a adição falhar, loga o erro.
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

  /// Limpa a lista de vídeos.
  void clearVideos() {
    _videos.clear();
    notifyListeners();
  }

  /// Adiciona um vídeo diretamente à lista.
  void addVideo(VideoModel video) {
    _videos.add(video);
    notifyListeners();
  }

  /// Remove um vídeo da lista.
  void removeVideo(VideoModel video) {
    _videos.removeWhere((v) => v.id == video.id);
    notifyListeners();
  }
}
