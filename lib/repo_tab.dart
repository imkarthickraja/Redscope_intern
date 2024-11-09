import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RepoTab extends StatefulWidget {
  const RepoTab({super.key});

  @override
  RepoTabState createState() => RepoTabState();
}

class RepoTabState extends State<RepoTab> {
  List<dynamic> _gists = [];

  @override
  void initState() {
    super.initState();
    fetchGists();
  }

  Future<void> fetchGists() async {
    final response = await http.get(Uri.parse('https://api.github.com/gists/public'));

    if (response.statusCode == 200) {
      setState(() {
        _gists = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load gists');
    }
  }

  void _showOwnerInfo(String ownerLogin) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Owner Information'),
          content: Text('Owner: $ownerLogin'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _onTapItem(int index) {
    // Navigate to a new screen that shows all files in the gist
    final gist = _gists[index];
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FilesListScreen(gist: gist),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _gists.length,
      itemBuilder: (context, index) {
        final gist = _gists[index];
        final description = gist['description'] ?? 'No Description';
        final ownerLogin = gist['owner']['login'];
        final createdAt = gist['created_at'];
        final updatedAt = gist['updated_at'];
        final commentCount = gist['comments'];

        return GestureDetector(
          onLongPress: () => _showOwnerInfo(ownerLogin),
          onTap: () => _onTapItem(index),
          child: ListTile(
            title: Text(description),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Comments: $commentCount'),
                Text('Created: $createdAt'),
                Text('Updated: $updatedAt'),
              ],
            ),
          ),
        );
      },
    );
  }
}

class FilesListScreen extends StatelessWidget {
  final dynamic gist;
  FilesListScreen({required this.gist});

  @override
  Widget build(BuildContext context) {
    final files = gist['files'];
    return Scaffold(
      appBar: AppBar(
        title: Text('Files in Gist'),
      ),
      body: ListView.builder(
        itemCount: files.length,
        itemBuilder: (context, index) {
          final file = files.values.elementAt(index);
          return ListTile(
            title: Text(file['filename']),
            subtitle: Text(file['language'] ?? 'No Language'),
          );
        },
      ),
    );
  }
}
