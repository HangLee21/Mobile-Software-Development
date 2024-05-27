// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class CarouselDemo extends StatelessWidget {
  CarouselDemo({
    super.key,
    required this.fileNames,
    this.images,
  });

  final List<String> fileNames;
  List<Widget>? images;

  Future<Uint8List?> getThumbnail(String videoUrl) async {
    final uint8list = await VideoThumbnail.thumbnailData(
      video: videoUrl,
      imageFormat: ImageFormat.PNG,
      maxWidth: 80,
      maxHeight: 80,
      quality: 100,
    );
    return uint8list;
  }



  @override
  Widget build(context) {
    // TODO
    void clickImage(String file){
      showDialog(
          context: context,
          builder: (context){
            if(file.split('.')[file.split('.').length - 1] == 'png' || file.split('.')[file.split('.').length - 1] == 'jpg' || file.split('.')[file.split('.').length - 1] == 'jpeg'){
              return Image.network(file);
            }else{
              return BetterPlayer.network(
                  file,
                  betterPlayerConfiguration: BetterPlayerConfiguration(
                      autoPlay: true
                  )
              );
            }
          }
      );
    }
    images =
        fileNames.map((file){
          if(file.split('.')[file.split('.').length - 1] == 'jpg' || file.split('.')[file.split('.').length - 1] == 'png' || file.split('.')[file.split('.').length - 1] == 'jpeg') {
            return GestureDetector(
              onTap: () {
                clickImage(file);
              },
                child: Image.network(file, fit: BoxFit.cover)
            );
          }else{
            return GestureDetector(
              onTap: (){
                clickImage(file);
              },
              child: Stack(
                fit: StackFit.expand,
                children: [
                  FutureBuilder<Uint8List?>(
                    future: getThumbnail(file),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator(); // 正在加载
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}'); // 发生错误
                      } else if (snapshot.hasData && snapshot.data != null) {
                        return Image.memory(
                            snapshot.data!,
                            // width: 80,
                            // height: 80,
                            fit: BoxFit.cover
                        ); // 显示缩略图
                      } else {
                        return Text('No Thumbnail Available'); // 没有缩略图
                      }
                    },
                  ),
                  Icon(
                      Icons.play_circle_outlined,
                      size: 80,
                      color: Colors.white,
                  )
                ],
              )

            );
          }
        }).toList();
    return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: Carousel(itemBuilder: widgetBuilder, itemCount: images!.length,),
        ),
      );
  }

  Widget widgetBuilder(BuildContext context, int index) {
    return images![index];
  }
}

typedef OnCurrentItemChangedCallback = void Function(int currentItem);

class Carousel extends StatefulWidget {
  final IndexedWidgetBuilder itemBuilder;
  final int itemCount;

  const Carousel({
    super.key,
    required this.itemBuilder,
    required this.itemCount
  });

  @override
  State<Carousel> createState() => _CarouselState();
}

class _CarouselState extends State<Carousel> {
  late final PageController _controller;
  late int _currentPage;
  bool _pageHasChanged = false;

  @override
  void initState() {
    super.initState();
    _currentPage = 0;
    _controller = PageController(
      viewportFraction: .85,
      initialPage: _currentPage,
    );
  }

  @override
  Widget build(context) {
    var size = MediaQuery.of(context).size;
    return PageView.builder(
      onPageChanged: (value) {
        setState(() {
          _pageHasChanged = true;
          _currentPage = value;
        });
      },
      controller: _controller,
      scrollBehavior: ScrollConfiguration.of(context).copyWith(
        dragDevices: {
          ui.PointerDeviceKind.touch,
          ui.PointerDeviceKind.mouse,
        },
      ),
      itemCount: widget.itemCount,
      itemBuilder: (context, index) => AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          var result = _pageHasChanged ? _controller.page! : _currentPage * 1.0;

          // The horizontal position of the page between a 1 and 0
          var value = result - index;
          value = (1 - (value.abs() * .5)).clamp(0.0, 1.0);

          return Center(
            child: SizedBox(
              height: Curves.easeOut.transform(value) * size.height,
              width: Curves.easeOut.transform(value) * size.width,
              child: child,
            ),
          );
        },
        child: widget.itemBuilder(context, index),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}