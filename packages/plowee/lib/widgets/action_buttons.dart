import 'package:flutter/material.dart';

class ActionButtons extends StatelessWidget {
  const ActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.large(
            onPressed: () {},
            heroTag: 'centerButton',
            child: const Icon(Icons.navigation_rounded),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: FloatingActionButton(
                onPressed: () {},
                heroTag: 'warningButton',
                backgroundColor: Colors.red,
                child: const Icon(Icons.warning_amber_rounded),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
