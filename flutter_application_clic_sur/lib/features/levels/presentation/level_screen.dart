import 'package:flutter/material.dart';

class LevelScreen extends StatelessWidget {
  final String themeId;
  const LevelScreen({super.key, required this.themeId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('Niveaux du thème $themeId — à construire')));
  }
}
