import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:html' as html;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://vjcmzareotkixgjwvshl.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZqY216YXJlb3RraXhnand2c2hsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzg0NDcxMjksImV4cCI6MjA1NDAyMzEyOX0.9kr7vf_FmeT0uTxtDj2beJxtssb3V89UXcLpwzlqv3I',
  );

  const String googleMapsApiKey = 'AIzaSyCcEEXbsnVt9ESSxQmPDImXuEtjl9VkP3M';

  // Inject the Google Maps API script into the HTML head
  html.document.head!.append(html.ScriptElement()
    ..src = 'https://maps.googleapis.com/maps/api/js?key=$googleMapsApiKey'
    ..type = 'text/javascript');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plowee Manager',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _future = Supabase.instance.client.from('report_audit').select();
  final _future1 = Supabase.instance.client.from('plow_update').select();
  final _stream = Supabase.instance.client
      .from('plow_update')
      .stream(primaryKey: ['id']).eq('id', 1);

  GoogleMapController? _mapController;
  Marker? _plowMarker;

  void _handleSendButtonPressed(Map<String, dynamic> row) {
    // Handle the logic for sending the request here
    print('Send button pressed for row: $row');
  }

  void _updateMarker(LatLng position) {
    if (_mapController != null) {
      setState(() {
        _plowMarker = Marker(
          markerId: const MarkerId('plow'),
          position: position,
          infoWindow: const InfoWindow(title: 'Live Plow Location'),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plowee Manager'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data as List;
          final processedData =
              data.where((row) => row['request_processed'] == 1).toList();
          final unprocessedData =
              data.where((row) => row['request_processed'] == 0).toList();

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Completed Plows',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                DataTable(
                  columns: const [
                    DataColumn(label: Text('Location')),
                    DataColumn(label: Text('Request Count')),
                  ],
                  rows: processedData
                      .map<DataRow>((row) => DataRow(
                            cells: [
                              DataCell(Text(
                                  '${row['street'] ?? ''} (${row['intersection1'] ?? ''} - ${row['intersection2'] ?? ''})')),
                              DataCell(Text(row['request_count'].toString())),
                            ],
                          ))
                      .toList(),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Unprocessed Requests',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                DataTable(
                  columns: const [
                    DataColumn(label: Text('Location')),
                    DataColumn(label: Text('Action')),
                  ],
                  rows: unprocessedData
                      .map<DataRow>((row) => DataRow(
                            cells: [
                              DataCell(Text(
                                  '${row['street'] ?? ''} (${row['intersection1'] ?? ''} - ${row['intersection2'] ?? ''})')),
                              DataCell(
                                ElevatedButton(
                                  onPressed: () =>
                                      _handleSendButtonPressed(row),
                                  child: const Text('Send'),
                                ),
                              ),
                            ],
                          ))
                      .toList(),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Plow Updates',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                FutureBuilder(
                  future: _future1,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final plowUpdateData = snapshot.data as List;

                    return DataTable(
                      columns: const [
                        DataColumn(label: Text('ID')),
                        DataColumn(label: Text('Location')),
                      ],
                      rows: plowUpdateData
                          .map<DataRow>((row) => DataRow(
                                cells: [
                                  DataCell(Text(row['id'].toString())),
                                  DataCell(Text(
                                      '${row['street'] ?? ''} (${row['intersection1'] ?? ''} - ${row['intersection2'] ?? ''})')),
                                ],
                              ))
                          .toList(),
                    );
                  },
                ),
                const SizedBox(height: 20),
                const Text(
                  'Live Plow Location',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                StreamBuilder(
                  stream: _stream,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final livePlowData = snapshot.data as List;
                    if (livePlowData.isEmpty) {
                      return const Center(child: Text('No data available'));
                    }

                    final row = livePlowData.first;
                    final position = LatLng(
                      row['latitude']?.toDouble() ?? 0.0,
                      row['longitude']?.toDouble() ?? 0.0,
                    );

                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _updateMarker(position);
                    });

                    return SizedBox(
                      height: 400,
                      child: GoogleMap(
                        onMapCreated: (controller) {
                          _mapController = controller;
                        },
                        initialCameraPosition: CameraPosition(
                          target: position,
                          zoom: 14,
                        ),
                        markers: _plowMarker != null ? {_plowMarker!} : {},
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
