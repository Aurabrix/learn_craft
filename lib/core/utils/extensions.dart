import 'package:flutter/material.dart';

extension NumSpacing on num {
  SizedBox get vBox => SizedBox(height: toDouble());
  SizedBox get hBox => SizedBox(width: toDouble());
}
