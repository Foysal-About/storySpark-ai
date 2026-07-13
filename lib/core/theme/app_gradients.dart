import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppGradients {
  static const background = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.backgroundTop,
      AppColors.backgroundMid,
      AppColors.backgroundBottom,
    ],
  );

  static const accent = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [AppColors.accentStart, AppColors.accentEnd],
  );
}