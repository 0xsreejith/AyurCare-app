import 'package:flutter/material.dart';

class EmptyListWidget extends StatelessWidget {
  const EmptyListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/images/empty_list.png'), // Add your empty list image
          const SizedBox(height: 16),
          const Text('No patients found'),
        ],
      ),
    );
  }
}