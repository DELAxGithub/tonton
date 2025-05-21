import 'package:flutter/material.dart';

abstract class AppPage {
  PreferredSizeWidget? buildAppBar(BuildContext context) => null;
  Widget? buildFloatingActionButton(BuildContext context) => null;
}
