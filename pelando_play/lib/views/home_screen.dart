import 'package:flutter/material.dart';
import 'package:pelando_play/widgets/video_player_item.dart';
import 'package:provider/provider.dart';
import 'package:pelando_play/viewmodels/video_list_viewmodel.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pelando_play/models/video_model.dart';

class HomeScreen extends StatelessWidget {
  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<VideoListViewModel>(context);
    return Scaffold(
      appBar: AppBar(title: Text('Pelando Play')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Buscar vídeos ou inserir URL',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    String text = searchController.text.trim();
                    if (_isYoutubeUrl(text)) {
                      viewModel.addVideoByUrl(text);
                    } else {
                      _showSearchModal(context, text, viewModel);
                    }
                  },
                ),
              ),
            ),
          ),
          Expanded(
  child: ListView.builder(
    itemCount: viewModel.videos.length,
    itemBuilder: (_, index) {
      final video = viewModel.videos[index];
      // Assumindo que você tenha o ID do vídeo do YouTube em `video.id`
      return YoutubeVideoPlayer(videoId: video.id);
    },
  ),
),
        ],
      ),
    );
  }

  void _showSearchModal(BuildContext context, String query, VideoListViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      builder: (_) => FutureBuilder(
        future: viewModel.fetchVideos(query),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Erro ao buscar vídeos"));
          } else if (snapshot.hasData) {
            // Cria uma lista temporária com os resultados da busca
            final searchResults = snapshot.data as List<VideoModel>;
            return ListView.builder(
              itemCount: searchResults.length,
              itemBuilder: (_, index) {
                final video = searchResults[index];
                return ListTile(
                  title: Text(video.title),
                  leading: Image.network(video.thumb),
                  trailing: IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () {
                      viewModel.addVideo(video);
                      Navigator.pop(context); // Fecha o modal.
                    },
                  ),
                );
              },
            );
          } else {
            return Center(child: Text('Nenhum vídeo encontrado'));
          }
        },
      ),
    );
  }

  bool _isYoutubeUrl(String url) {
    Uri? uri = Uri.tryParse(url);
    return uri != null && uri.host.contains('youtube.com');
  }
}