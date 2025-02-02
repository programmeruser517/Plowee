import 'package:flutter/material.dart';
import '../services/places_service.dart';
import 'dart:async';

class SearchOverlay extends StatefulWidget {
  final VoidCallback onClose;
  final Function(String) onAddressSelected;

  const SearchOverlay({
    super.key,
    required this.onClose,
    required this.onAddressSelected,
  });

  @override
  State<SearchOverlay> createState() => _SearchOverlayState();
}

class _SearchOverlayState extends State<SearchOverlay> {
  final TextEditingController _searchController = TextEditingController();
  final PlacesService _placesService =
      PlacesService('AIzaSyBfKo_6wtvIzft1w4uqT_d4uIdjnxXTFCg');
  List<PlacePrediction> _predictions = [];
  Timer? _debounce;

  Future<void> _onSearchChanged(String value) async {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (value.isNotEmpty) {
        final predictions = await _placesService.getPlacePredictions(value);
        if (mounted) {
          setState(() {
            _predictions = predictions;
          });
        }
      } else {
        setState(() {
          _predictions = [];
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          const SizedBox(height: 40), // Status bar padding
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: widget.onClose,
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(left: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      decoration: const InputDecoration(
                        hintText: 'Enter destination address',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _predictions.length,
              itemBuilder: (context, index) {
                final prediction = _predictions[index];
                return ListTile(
                  onTap: () {
                    widget.onAddressSelected(prediction.description);
                  },
                  title: Text(prediction.description),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
