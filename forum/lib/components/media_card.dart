import 'package:flutter/material.dart';
import 'package:forum/constants.dart';

const _horizontalPadding = 32.0;
const _horizontalDesktopPadding = 81.0;
const _carouselHeightMin = 200.0;
const _carouselItemDesktopMargin = 8.0;
const _carouselItemMobileMargin = 4.0;
const _carouselItemWidth = 280.0;


class CarouselCard extends StatelessWidget {
  const CarouselCard({
    super.key,
    this.asset,
    this.assetDark,
    this.assetColor,
    this.assetDarkColor,
    this.textColor,
    required this.postId,
    required this.title,
    required this.content,
    required this.card_height,
  });

  final ImageProvider? asset;
  final ImageProvider? assetDark;
  final Color? assetColor;
  final Color? assetDarkColor;
  final Color? textColor;
  final String postId;
  final String title;
  final String content;
  final double card_height;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).colorScheme.brightness == Brightness.dark;
    final asset = isDark ? assetDark : this.asset;
    final assetColor = isDark ? assetDarkColor : this.assetColor;
    final textColor = isDark ? Colors.white.withOpacity(0.87) : this.textColor;
    final image_height = this.card_height - 40;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16.0),
      height: 300,
      child: Material(
        // Makes integration tests possible.
        // color: assetColor,
        color: Colors.lightBlue[50],
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            if (asset != null)
              FadeInImage(
                image: asset,
                placeholder: MemoryImage(kTransparentImage),
                fit: BoxFit.cover,
                width: double.infinity,
                height: image_height,
                fadeInDuration: entranceAnimationDuration,
              ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 16),
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      this.title,
                      style: textTheme.bodySmall!.apply(color: textColor),
                      maxLines: 3,
                      overflow: TextOverflow.visible,
                    ),
                    Text(
                      this.content,
                      style: textTheme.labelSmall!.apply(color: textColor),
                      maxLines: 5,
                      overflow: TextOverflow.visible,
                    ),
                  ],
                ),
              )
            ),
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    // TODO change route
                    // Navigator.of(context)
                    //     .popUntil((route) => route.settings.name == '/');
                    // Navigator.of(context).restorablePushNamed(studyRoute);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

