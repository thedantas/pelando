import 'package:flutter/material.dart';
import '../models/video_model.dart';
import '../services/youtube_service.dart';
import 'dart:convert';

/// ViewModel que gerencia o estado da lista de vídeos.
class VideoListViewModel with ChangeNotifier {
  final YoutubeService _youtubeService = YoutubeService();
  List<VideoModel> _videos = [];
  List<VideoModel> _filteredVideos = []; // Lista para armazenar vídeos filtrados
  bool _isFiltered = false; // Variável para controlar se o filtro está ativo

  /// Retorna a lista imutável de vídeos.
  List<VideoModel> get videos => List.unmodifiable(_videos);

  /// Retorna a lista imutável de vídeos filtrados ou a lista completa se não houver filtro.
  List<VideoModel> get filteredVideos => _isFiltered ? List.unmodifiable(_filteredVideos) : List.unmodifiable(_videos);

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
    _applyFilter(); // Aplica o filtro novamente após adicionar o vídeo
    notifyListeners();
  } catch (e) {
    print('Erro ao adicionar vídeo: $e');
    // Lide com o erro adequadamente.
  }
}

  /// Limpa a lista de vídeos.
  void clearVideos() {
    _videos.clear();
    _filteredVideos.clear(); // Limpa a lista de vídeos filtrados
    _isFiltered = false; // Desativa o filtro
    notifyListeners();
  }

  /// Adiciona um vídeo diretamente à lista.
  void addVideo(VideoModel video) {
    _videos.add(video);
    _applyFilter(); // Aplica o filtro após adicionar o vídeo
    notifyListeners();
  }

  /// Remove um vídeo da lista.
  void removeVideo(VideoModel video) {
    _videos.removeWhere((v) => v.id == video.id);
    _filteredVideos.removeWhere((v) => v.id == video.id); // Remove da lista de vídeos filtrados também
    notifyListeners();
  }

  /// Aplica o filtro aos vídeos com base na palavra-chave fornecida.
  void filterVideos(String keyword) {
    _filteredVideos.clear(); // Limpa a lista de vídeos filtrados
    _filteredVideos.addAll(_videos.where((video) => video.title.toLowerCase().contains(keyword.toLowerCase())));
    _isFiltered = true; // Ativa o filtro
    notifyListeners();
  }

  /// Remove o filtro e restaura a lista de vídeos original.
  void clearFilter() {
    _filteredVideos.clear(); // Limpa a lista de vídeos filtrados
    _isFiltered = false; // Desativa o filtro
    notifyListeners();
  }

  /// Aplica o filtro, se houver, à lista de vídeos.
  void _applyFilter() {
    if (_filteredVideos.isNotEmpty) {
      _filteredVideos.clear();
      _filteredVideos.addAll(_videos.where((video) => _filteredVideos.any((filteredVideo) => filteredVideo.id == video.id)));
    }
  }
}
