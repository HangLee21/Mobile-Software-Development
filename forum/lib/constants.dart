// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Only put constants shared between files here.

import 'dart:typed_data';
import 'package:transparent_image/transparent_image.dart' as transparent_image;

// Height of the 'Gallery' header
const double galleryHeaderHeight = 64;

// The font size delta for headline4 font.
const double desktopDisplay1FontDelta = 16;

// The width of the settingsDesktop.
const double desktopSettingsWidth = 520;

// Sentinel value for the system text scale factor option.
const double systemTextScaleFactorOption = -1;

// The splash page animation duration.
const Duration splashPageAnimationDuration = Duration(milliseconds: 300);

// Half the splash page animation duration.
const Duration halfSplashPageAnimationDuration = Duration(milliseconds: 150);

// Duration for settings panel to open on mobile.
const Duration settingsPanelMobileAnimationDuration =
Duration(milliseconds: 200);

// Duration for settings panel to open on desktop.
const Duration settingsPanelDesktopAnimationDuration =
Duration(milliseconds: 600);

// Duration for home page elements to fade in.
const Duration entranceAnimationDuration = Duration(milliseconds: 200);

// The desktop top padding for a page's first header (e.g. Gallery, Settings)
const double firstHeaderDesktopTopPadding = 5.0;

// A transparent image used to avoid loading images when they are not needed.
final Uint8List kTransparentImage = transparent_image.kTransparentImage;

const String BASEURL = '101.200.84.216:8080';
const String WEBSOCKET_URL = 'ws://10.0.2.2:8080/websocket';

const String API_KEY = 'a333b62b0b117025f9c6f349b462436a.ZbNY1lGk2Pkvf4hG';