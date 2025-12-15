import 'package:flutter/material.dart';

// Returns screen size and orientation
class SizeConfig {
  final BuildContext _context;
  double? _screenWidth;
  double? _screenHeight;
  static const double _portraitWidth = 428.0;
  static const double _portraitHeight = 926.0;
  static const double _landscapeWidth = 926.0;
  static const double _landscapeHeight = 428.0;

  SizeConfig(this._context) {
    final mediaQuery = MediaQuery.of(_context);
    _screenWidth = mediaQuery.size.width;
    _screenHeight = mediaQuery.size.height;
  }

  // Returns proportionate height
  double getProportionateScreenHeight(double inputHeight) {
    final orientation = MediaQuery.of(_context).orientation;
    return (inputHeight / (orientation == Orientation.portrait ? _portraitHeight : _landscapeHeight)) * _screenHeight!;
  }

  // Returns proportionate width
  double getProportionateScreenWidth(double inputWidth) {
    final orientation = MediaQuery.of(_context).orientation;
    return (inputWidth / (orientation == Orientation.portrait ? _portraitWidth : _landscapeWidth)) * _screenWidth!;
  }

  // Static method to get an instance of SizeConfig
  static SizeConfig of(BuildContext context) => SizeConfig(context);

  // Check if device is mobile
  bool isMobile() => _screenWidth! < 650;

  // Check if device is tablet
  bool isTablet() => _screenWidth! >= 650 && _screenWidth! < 1100;

  // Check if device is desktop
  bool isDesktop() => _screenWidth! >= 1100;
}
