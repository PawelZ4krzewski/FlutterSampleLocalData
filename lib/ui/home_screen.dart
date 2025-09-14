import 'package:flutter/material.dart';
import '../data/storage_kind.dart';
import 'run_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Storage Demo'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Choose Storage Type',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32),
            _buildStorageButton(
              context,
              'Preferences',
              'Key-Value storage using SharedPreferences',
              StorageKind.preferences,
            ),
            SizedBox(height: 16),
            _buildStorageButton(
              context,
              'JSON File',
              'File-based storage with JSON serialization',
              StorageKind.file,
            ),
            SizedBox(height: 16),
            _buildStorageButton(
              context,
              'SQLite',
              'Database storage with migrations',
              StorageKind.sqlite,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStorageButton(
    BuildContext context,
    String title,
    String subtitle,
    StorageKind kind,
  ) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Icon(Icons.arrow_forward_ios),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RunScreen(storageKind: kind),
            ),
          );
        },
      ),
    );
  }
}
