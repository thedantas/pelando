import 'package:flutter/material.dart';
import 'package:pelando_play/widgets/video_player_item.dart';
import 'package:provider/provider.dart';
import 'package:pelando_play/viewmodels/video_list_viewmodel.dart';
import 'package:pelando_play/models/video_model.dart';

class HomeScreen extends StatelessWidget {
  final TextEditingController searchController = TextEditingController();
  final TextEditingController filterController = TextEditingController(); // Controlador para o campo de filtro

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<VideoListViewModel>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Playando')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      labelText: 'Buscar vídeos ou inserir URL',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    String text = searchController.text.trim();
                    if (_isYoutubeUrl(text)) {
                      String text = searchController.text.trim();
      _addVideoByUrl(text, context, viewModel);
                    } else {
                      _showSearchModal(context, text, viewModel);
                    }
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: filterController,
                    onChanged: (value) {
                      // Chama o método de filtro toda vez que o texto do campo de filtro é alterado
                      viewModel.filterVideos(value.trim());
                    },
                    decoration: InputDecoration(
                      labelText: 'Filtrar por palavra-chave',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(viewModel.isFiltered ? Icons.clear : Icons.filter_list),
                  onPressed: () {
                    if (viewModel.isFiltered) {
                      filterController.clear(); // Limpa o campo de filtro
                      viewModel.clearFilter(); // Remove o filtro
                    } else {
                      viewModel.filterVideos(filterController.text.trim());
                    }
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: viewModel.filteredVideos.length, // Agora usamos a lista filtrada
              itemBuilder: (_, index) {
                final video = viewModel.filteredVideos[index]; // Usamos a lista filtrada
                return Dismissible(
                  key: Key(video.id), // Chave única para o Dismissible
                  direction: DismissDirection.endToStart, // Arrastar para excluir da direita para a esquerda
                  onDismissed: (direction) {
                    viewModel.removeVideo(video); // Remove o vídeo da lista
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("${video.title} removido")),
                    );
                  },
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(Icons.delete, color: Colors.white),
                    ),
                  ),
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        YoutubeVideoPlayer(videoId: video.id),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                video.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.headline6,
                              ),
                              Text(
                                video.chanel,
                                style: Theme.of(context).textTheme.subtitle1,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
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
    return uri != null && uri.host.contains('youtube.com') && uri.path.contains('/watch') && uri.queryParameters.containsKey('v');
  }

  void _addVideoByUrl(String url, BuildContext context, VideoListViewModel viewModel) {
    if (_isYoutubeUrl(url)) {
      viewModel.addVideoByUrl(url).catchError((e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro ao adicionar vídeo: ${e.toString()}")),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("URL inválida. Por favor, insira uma URL do YouTube válida.")),
      );
    }
  }

  // Atualize a chamada no IconButton para usar _addVideoByUrl


}
