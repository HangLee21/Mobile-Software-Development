import 'package:flutter/material.dart';

import '../constants.dart';

class ContentCard extends StatelessWidget {
  const ContentCard({
    super.key,
    required this.title,
    required this.content,
    this.media_urls,
    this.url,
  });

  final String title;
  final String content;
  final List<String>? media_urls;
  final String? url;

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
              if(this.url != null){
                Navigator.of(context)
                    .popUntil((route) => route.settings.name == '/');
                Navigator.of(context).restorablePushNamed(url!);
              }
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
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(
                          this.media_urls!.length,
                              (index) => Container(
                            margin: EdgeInsets.all(8.0),
                            child: FadeInImage(
                              image: AssetImage(
                                this.media_urls![index],
                              ),
                              placeholder: MemoryImage(kTransparentImage),
                              fit: BoxFit.cover,
                              fadeInDuration: entranceAnimationDuration,
                            ),
                          ),
                        ),
                      ),// 设置水平滚动.builder(
                    ),
                  ),

              ],
            ),
         ),
      ),
    );
  }
}
