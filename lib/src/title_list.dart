import 'dart:math';

import 'package:flutter/material.dart';

class TitleListScroll extends StatelessWidget {
  final double _currentPage;
  final List<String> _titles;

  TitleListScroll({@required currentPage, @required titles})
      : _currentPage = currentPage,
        _titles = titles;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, contraints) {
        List<Widget> children = [];

        for (var i = 0; i < _titles.length; i++) {
          var delta = i - _currentPage;

          var bottom = max(-55 * delta, 0.0);
          var opacity = 1.0 - max(delta, 0.0);
          var fontSize = 34.0 - max(-20 * delta, 0.0);

          var colorAlpha = 222 - max(-115 * delta, 0.0).toInt();
          var fontColor =
              Color.fromARGB(colorAlpha < 115 ? 115 : colorAlpha, 0, 0, 0);

          children.add(
            Positioned.directional(
              textDirection: TextDirection.ltr,
              bottom: MediaQuery.of(context).size.height * .55 +
                  24 +
                  (bottom < 0 ? 0 : bottom),
              top: 32,
              start: 32,
              end: 32,
              child: Container(
                alignment: Alignment.bottomLeft,
                child: Opacity(
                  opacity: opacity < 0 ? 0 : opacity,
                  child: Text(
                    _titles[i],
                    style: TextStyle(
                      color: fontColor,
                      fontSize: fontSize < 20 ? 20 : fontSize,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.25,
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        return Stack(
          fit: StackFit.expand,
          children: children,
        );
      },
    );
  }
}
