import 'package:flutter/material.dart';
import 'package:pelando_play/widgets/video_player_item.dart';
import 'package:provider/provider.dart';
import 'package:pelando_play/viewmodels/video_list_viewmodel.dart';
import 'package:pelando_play/models/video_model.dart';

class HomeScreen extends StatelessWidget {
  final TextEditingController searchController = TextEditingController();
  final TextEditingController filterController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<VideoListViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Playando'),
      ),
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
                      _addVideoByUrl(text, context, viewModel);
                    } else {
                      _showSearchModal(context, text, viewModel);
                    }
                  },
                  tooltip: 'Buscar',
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
                      filterController.clear();
                      viewModel.clearFilter();
                    } else {
                      viewModel.filterVideos(filterController.text.trim());
                    }
                  },
                  tooltip: viewModel.isFiltered ? 'Limpar filtro' : 'Aplicar filtro',
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: viewModel.filteredVideos.length,
              itemBuilder: (_, index) {
                final video = viewModel.filteredVideos[index];
                return Dismissible(
                  key: Key(video.id),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    viewModel.removeVideo(video);
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
                        Semantics(
                          child: YoutubeVideoPlayer(videoId: video.id),
                          label: "Vídeo ${video.title}",
                        ),
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
            return Center(child: CircularProgressIndicator(semanticsLabel: 'Carregando resultados'));
          } else if (snapshot.hasError) {
            return Center(child: Text("Erro ao buscar vídeos", semanticsLabel: 'Erro ao buscar vídeos'));
          } else if (snapshot.hasData) {
            final searchResults = snapshot.data as List<VideoModel>;
            if (searchResults.isEmpty) {
              return Center(child: Text('Nenhum vídeo encontrado', semanticsLabel: 'Nenhum vídeo encontrado'));
            }
            return ListView.builder(
              itemCount: searchResults.length,
              itemBuilder: (_, index) {
                final video = searchResults[index];
                return ListTile(
                  title: Text(video.title, semanticsLabel: 'Vídeo encontrado: ${video.title}'),
                  leading: Image.network(video.thumb, semanticLabel: 'Miniatura do vídeo'),
                  trailing: IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () {
                      viewModel.addVideo(video);
                      Navigator.pop(context);
                    },
                    tooltip: 'Adicionar vídeo', // Tooltip para acessibilidade.
                  ),
                );
              },
            );
          } else {
            return Center(child: Text('Nenhum vídeo encontrado', semanticsLabel: 'Nenhum vídeo encontrado'));
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
          SnackBar(content: Text("Erro ao adicionar vídeo: ${e.toString()}", semanticsLabel: 'Erro ao adicionar vídeo')),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("URL inválida. Por favor, insira uma URL do YouTube válida.", semanticsLabel: 'URL inválida fornecida')),
      );
    }
  }
}
