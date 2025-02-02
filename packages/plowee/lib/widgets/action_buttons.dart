import 'package:flutter/material.dart';
import 'search_overlay.dart';

class ActionButtons extends StatefulWidget {
const ActionButtons({super.key});

@override
State<ActionButtons> createState() => _ActionButtonsState();
}

class _ActionButtonsState extends State<ActionButtons> {
bool _showSearch = false;

void _toggleSearch() {
    setState(() {
    _showSearch = !_showSearch;
    });
}

void _onAddressSelected(String address) {
    // TODO: Handle the selected address
    _toggleSearch();
}

@override
Widget build(BuildContext context) {
    return Stack(
    children: [
        // Main buttons
        Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
            FloatingActionButton.large(
                onPressed: _toggleSearch,
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
        ),
        // Search overlay
        if (_showSearch)
        Positioned.fill(
            child: SearchOverlay(
            onClose: _toggleSearch,
            onAddressSelected: _onAddressSelected,
            ),
        ),
    ],
    );
}
}
