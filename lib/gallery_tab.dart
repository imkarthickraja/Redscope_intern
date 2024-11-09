import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:photo_view/photo_view.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';

class GalleryTab extends StatefulWidget {
  const GalleryTab({super.key});

  @override
  GalleryTabState createState() => GalleryTabState();
}

class GalleryTabState extends State<GalleryTab> {
  List<dynamic> _photos = [];
  final String _accessKey =
      'nXLnH6arwe5to3WZS8_6jhwglOrmD7HAFNPDyA2Y1WE'; // Replace with your access key

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Load data from shared preferences or fetch from the network if not cached
  Future<void> _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Check if data is already cached
    String? cachedData = prefs.getString('photos_data');
    if (cachedData != null) {
      // If cached data exists, load from cache
      setState(() {
        _photos = json.decode(cachedData);
      });
    } else {
      // If no cached data, fetch from the network
      await fetchPhotos();
    }
  }

  Future<void> fetchPhotos() async {
    final response = await http.get(
      Uri.parse('https://api.unsplash.com/photos/?client_id=$_accessKey'),
    );

    if (response.statusCode == 200) {
      // Save the data in shared preferences for future use
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('photos_data', response.body);

      setState(() {
        _photos = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load photos');
    }
  }

  void _openFullScreenImage(int index) {
    final imageUrl = _photos[index]['urls']['regular'];

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenImageScreen(imageUrl: imageUrl),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 4.0,
        mainAxisSpacing: 4.0,
      ),
      itemCount: _photos.length,
      itemBuilder: (context, index) {
        final photo = _photos[index];
        final imageUrl = photo['urls']['small'];

        return GestureDetector(
          onTap: () => _openFullScreenImage(index),
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            placeholder: (context, url) => const CircularProgressIndicator(),
            errorWidget: (context, url, error) => const Icon(Icons.error),
            fit: BoxFit.cover,
          ),
        );
      },
    );
  }
}

class FullScreenImageScreen extends StatelessWidget {
  final String imageUrl;

  const FullScreenImageScreen({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Full-Screen Image'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_border),
            onPressed: () {
              // Save the image URL to bookmarks
              _bookmarkImage(context, imageUrl);
            },
          ),
        ],
      ),
      body: PhotoView(
        imageProvider: NetworkImage(imageUrl),
        minScale: PhotoViewComputedScale.contained,
        maxScale: PhotoViewComputedScale.covered * 2,
      ),
    );
  }

  // Save the image to bookmarks
  Future<void> _bookmarkImage(BuildContext context, String imageUrl) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> bookmarks = prefs.getStringList('bookmarks') ?? [];

    if (!bookmarks.contains(imageUrl)) {
      bookmarks.add(imageUrl);
      await prefs.setStringList('bookmarks', bookmarks);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image bookmarked!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This image is already bookmarked')),
      );
    }
  }
}
