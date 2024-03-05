import 'package:flutter/material.dart';

import '../constants.dart';

class ContentCard extends StatelessWidget {
  const ContentCard({
    super.key,
    required this.title,
    required this.content,
    this.media_urls,
  });

  final String title;
  final String content;
  final List<String>? media_urls;

  @override
  Widget build(BuildContext context) {
    final card_title = this.title;
    final card_content = this.content;
    final media_urls = this.media_urls;
    // TODO

    return Center(
      child: Card(
        // unless you need it.
        clipBehavior: Clip.hardEdge,
        child: InkWell(
            splashColor: Colors.blue.withAlpha(30),
            onTap: () {
                debugPrint('Card tapped.');
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.album),
                  title: Text(card_title),
                  subtitle: Text(card_content),
                ),
                if(media_urls != null)
                  Flexible(
                    flex: 1,
                    child: FadeInImage(
                      image: AssetImage(
                        this.media_urls![0],
                        package: 'flutter_gallery_assets',
                      ),
                      placeholder: MemoryImage(kTransparentImage),
                      fit: BoxFit.cover,
                      fadeInDuration: entranceAnimationDuration,
                    ),
                  ),
              ],
            ),
         ),
      ),
    );
  }
}
