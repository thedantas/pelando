import 'package:flutter/material.dart';
import 'package:pelando_play/widgets/video_player_item.dart'; // Importe o widget do vídeo aqui
import 'package:pelando_play/models/video_model.dart';

class FullScreenVideoDialog extends StatelessWidget {
  final VideoModel video;

  FullScreenVideoDialog(this.video);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black,
      child: GestureDetector(
        onTap: () {
          Navigator.pop(context); // Fecha o diálogo quando tocar na tela
        },
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: VideoPlayerItem(videoUrl: video.videoUrl), // Use o widget de vídeo aqui
        ),
      ),
    );
  }
}
