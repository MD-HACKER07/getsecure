import 'package:flutter/material.dart';

class FeaturesPage extends StatelessWidget {
  const FeaturesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Features Page'),
      ),
      body: Center(
        child: Text(
          'Welcome to Features Page!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
