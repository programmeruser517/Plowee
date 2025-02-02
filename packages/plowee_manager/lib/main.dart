import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://vjcmzareotkixgjwvshl.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZqY216YXJlb3RraXhnand2c2hsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzg0NDcxMjksImV4cCI6MjA1NDAyMzEyOX0.9kr7vf_FmeT0uTxtDj2beJxtssb3V89UXcLpwzlqv3I',
  );
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

  void _handleSendButtonPressed(Map<String, dynamic> row) {
    // Handle the logic for sending the request here
    print('Send button pressed for row: $row');
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
                  'Processed Requests',
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
              ],
            ),
          );
        },
      ),
    );
  }
}
