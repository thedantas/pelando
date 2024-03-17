import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'viewmodels/video_list_viewmodel.dart';
import 'views/home_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => VideoListViewModel(),
      child: MaterialApp(
        title: 'Pelando Play',
        home: HomeScreen(),
      ),
    );
  }
}

