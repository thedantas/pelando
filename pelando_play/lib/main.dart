import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/youtube_service.dart'; // Certifique-se de importar YoutubeService
import 'viewmodels/video_list_viewmodel.dart';
import 'views/home_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Envolve o MaterialApp com um MultiProvider se precisar adicionar mais Providers.
    return MultiProvider(
      providers: [
        // Fornece a instância de YoutubeService
        Provider<YoutubeService>(
          create: (_) => YoutubeService(),
        ),
        // Fornece a instância de VideoListViewModel e consome YoutubeService
        ChangeNotifierProvider<VideoListViewModel>(
          create: (context) => VideoListViewModel(
            Provider.of<YoutubeService>(context, listen: false),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Pelando Play',
        home: HomeScreen(),
      ),
    );
  }
}
