import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import 'gallery_tab.dart'; // Add this dependency to pubspec.yaml

class BookmarkScreen extends StatefulWidget {
  const BookmarkScreen({super.key});

  @override
  _BookmarkScreenState createState() => _BookmarkScreenState();
}

class _BookmarkScreenState extends State<BookmarkScreen> {
  List<String> _bookmarkedImages = [];

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  // Load the bookmarked images from SharedPreferences
  Future<void> _loadBookmarks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> bookmarks = prefs.getStringList('bookmarks') ?? [];
    setState(() {
      _bookmarkedImages = bookmarks;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bookmarked Images')),
      body: _bookmarkedImages.isEmpty
          ? const Center(child: Text('No bookmarks yet'))
          : StaggeredGridView.countBuilder(
        crossAxisCount: 4,
        itemCount: _bookmarkedImages.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              // Open the image in full-screen when clicked
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FullScreenImageScreen(
                      imageUrl: _bookmarkedImages[index]),
                ),
              );
            },
            child: CachedNetworkImage(
              imageUrl: _bookmarkedImages[index],
              placeholder: (context, url) =>
              const CircularProgressIndicator(),
              errorWidget: (context, url, error) =>
              const Icon(Icons.error),
              fit: BoxFit.cover,
            ),
          );
        },
        staggeredTileBuilder: (index) => StaggeredTile.count(2, index.isEven ? 3 : 2),
        mainAxisSpacing: 4.0,
        crossAxisSpacing: 4.0,
      ),
    );
  }
}
