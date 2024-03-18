import 'package:flutter/material.dart';
import '../models/video_model.dart';
import '../services/youtube_service.dart';
import 'dart:convert';

/// ViewModel que gerencia o estado da lista de vídeos.
class VideoListViewModel with ChangeNotifier {
  final YoutubeService _youtubeService = YoutubeService();
  List<VideoModel> _videos = [];
  List<VideoModel> _filteredVideos = []; // Lista de vídeos filtrados
  String? _filterKeyword; // Palavra-chave de filtro

  /// Retorna a lista imutável de vídeos.
  List<VideoModel> get videos => List.unmodifiable(_videos);

  /// Retorna a lista imutável de vídeos filtrados.
  List<VideoModel> get filteredVideos => List.unmodifiable(_filteredVideos);

  /// Retorna true se a lista estiver filtrada.
  bool get isFiltered => _filterKeyword != null;

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
      _applyFilter();
      notifyListeners();
    } catch (e) {
      print('Erro ao adicionar vídeo: $e');
      throw Exception('Não foi possível adicionar o vídeo.');
    }
  }

  /// Limpa a lista de vídeos.
  void clearVideos() {
    _videos.clear();
    _applyFilter(); // Aplica o filtro após limpar a lista
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
    _applyFilter(); // Aplica o filtro após remover o vídeo
    notifyListeners();
  }

  /// Filtra os vídeos com base na palavra-chave fornecida.
  void filterVideos(String keyword) {
    _filterKeyword = keyword.isNotEmpty ? keyword.toLowerCase() : null;
    _applyFilter(); // Aplica o filtro
    notifyListeners();
  }

  /// Limpa o filtro, exibindo todos os vídeos.
  void clearFilter() {
    _filterKeyword = null;
    _applyFilter(); // Aplica o filtro
    notifyListeners();
  }

  /// Aplica o filtro atual à lista de vídeos.
  void _applyFilter() {
    if (_filterKeyword == null) {
      _filteredVideos = List.from(_videos); // Sem filtro, lista filtrada é igual à lista original
    } else {
      _filteredVideos = _videos.where((video) => video.title.toLowerCase().contains(_filterKeyword!)).toList();
    }
  }
}
