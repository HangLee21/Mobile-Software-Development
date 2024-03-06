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
                  SizedBox(
                    height: 200.0,
                    child: PageView.builder(
                      itemCount: this.media_urls!.length,
                      itemBuilder: (context, index) {
                        return FadeInImage(
                          image: AssetImage(
                            this.media_urls![index],
                          ),
                          placeholder: MemoryImage(kTransparentImage),
                          fit: BoxFit.cover,
                          fadeInDuration: entranceAnimationDuration,
                        );
                      },
                    ),
                  ),
              ],
            ),
         ),
      ),
    );
  }
}
