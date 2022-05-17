import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

Future<String> loadAsset() async {
  return await rootBundle.loadString('assets/config.json');
}

// Get icon by name from assets
// theme 0 -> clar, 1 -> fosc
Image getImage(name, theme) {
  var fullName = "assets/" + name + (theme == 0 ? "_clar.png" : "_fosc.png");
  return Image(image: AssetImage(fullName));
}

Image getSizedImage(name, theme, width, height) {
  var fullName = "assets/" + name + (theme == 0 ? "_clar.png" : "_fosc.png");
  return Image(image: AssetImage(fullName), width: width, height: height);
}


