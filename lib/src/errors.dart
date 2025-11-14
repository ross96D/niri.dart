import 'dart:io';

sealed class NiriException implements Exception {
  String get message;

  String? get help => null;
}

class NiriSocketEnviromentNotFound extends NiriException {
  String get message => "NIRI_SOCKET enviroment variable not found";

  String get help => "Is niri running?";
}

class NiriSocketException extends NiriException {
  @override
  String get message => exception.message;

  String get address => (exception.address ?? _address).host;

  final InternetAddress _address;

  final SocketException exception;

  NiriSocketException(this.exception, this._address);
}
