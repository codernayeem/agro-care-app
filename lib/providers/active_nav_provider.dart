import 'package:flutter/material.dart';

class ActiveNavProvider with ChangeNotifier {
  int selectedPage = 0;

  void goToMarket() {
    selectedPage = 2;
    notifyListeners();
  }

  void setPage(int idx) {
    selectedPage = idx;
  }
}
