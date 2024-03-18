import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:pelando_play/models/video_model.dart';
import 'package:pelando_play/services/youtube_service.dart';
import 'package:pelando_play/viewmodels/video_list_viewmodel.dart';

// Criando um mock do YoutubeService
class MockYoutubeService extends Mock implements YoutubeService {}

void main() {
  group('VideoListViewModel', () {
    late MockYoutubeService youtubeService;
    late VideoListViewModel viewModel;

    setUp(() {
      // Cria uma instância do mock do YoutubeService antes de cada teste
      youtubeService = MockYoutubeService();
      // Passa o mock para a VideoListViewModel
      viewModel = VideoListViewModel(youtubeService);
    });
    test('Filtra vídeos com base na palavra-chave', () {
      // Adiciona vídeos de teste
      viewModel.addVideo(VideoModel(id: '1', title: 'Flutter Tutorial', chanel: 'Flutter', thumb: ''));
      viewModel.addVideo(VideoModel(id: '2', title: 'Dart Tutorial', chanel: 'Dart', thumb: ''));

      // Filtra por palavra-chave
      viewModel.filterVideos('Flutter');

      // Verifica se a lista filtrada contém apenas o vídeo correto
      expect(viewModel.filteredVideos.length, 1);
      expect(viewModel.filteredVideos.first.title, 'Flutter Tutorial');
    });

    test('Limpa o filtro, exibindo todos os vídeos', () {
      // Adiciona vídeos de teste
      viewModel.addVideo(VideoModel(id: '1', title: 'Flutter Tutorial', chanel: 'Flutter', thumb: ''));
      viewModel.addVideo(VideoModel(id: '2', title: 'Dart Tutorial', chanel: 'Dart', thumb: ''));

      // Filtra por palavra-chave e depois limpa o filtro
      viewModel.filterVideos('Flutter');
      viewModel.clearFilter();

      // Verifica se todos os vídeos estão sendo exibidos novamente
      expect(viewModel.filteredVideos.length, 2);
    });
  });
}
