import 'package:flutter/material.dart';

class ClientProvider extends ChangeNotifier {
  String? _clientId;

  String? get clientId => _clientId;

  void setClientId(String id) {
    _clientId = id;
    notifyListeners();
  }
}
