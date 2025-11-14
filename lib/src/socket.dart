import "dart:async";
import "dart:convert";
import "dart:io";

import "package:mutex/mutex.dart";

import "errors.dart";

import "models.dart";

class NiriSocket {
  final Socket socket;
  final _SocketReader _reader;
  bool _onEventStram = false;

  NiriSocket(this.socket) : _reader = _SocketReader(socket);

  void close() {
    _reader.close();
    socket.close();
  }

  static Future<NiriSocket> connect() async {
    final path = Platform.environment["NIRI_SOCKET"];
    if (path == null) {
      throw NiriSocketEnviromentNotFound();
    }
    return connectTo(path);
  }

  static Future<NiriSocket> connectTo(String socketPath) async {
    final address = InternetAddress(socketPath, type: InternetAddressType.unix);
    try {
      final socket = await Socket.connect(address, 0);
      return NiriSocket(socket);
    } on SocketException catch (e) {
      throw NiriSocketException(e, address);
    }
  }

  final _mutex = Mutex();
  Future<Reply<T>> send<T extends Response>(Request request) async {
    assert(request is! RequestEventStream);

    if (_onEventStram) throw NiriCannotSendCommand();

    late final Reply<T> response;
    await _mutex.protect(() async {
      socket.writeln(JsonEncoder().convert(request.toJson()));

      final lastChunk = await _reader.readNext();
      final line = lastChunk.split("\n").first;
      response = Reply.fromJson(json.decode(line));
    });
    return response;
  }

  Stream<Event> eventStream() async* {
    socket.writeln(JsonEncoder().convert(RequestEventStream().toJson()));
    _onEventStram = true;
    bool isFirst = true;
    while (!_reader.done) {
      final chunk = await _reader.readNext();
      final lines = chunk.split("\n");
      if (isFirst) {
        final first = lines.removeAt(0);
        final firstReply = Reply.fromJson(json.decode(first));
        assert(firstReply is ReplyOk && firstReply.response is ResponseHandled);
      }
      isFirst = false;
      for (final line in lines) {
        if (line.isEmpty) {
          continue;
        }
        yield Event.fromJson(json.decode(line));
      }
    }
  }
}

class _SocketReader {
  final Socket socket;

  final List<String> buffer = [];

  final Set<Completer> _waitNex = {};

  bool _done = false;
  bool get done => _done;

  _SocketReader(this.socket) {
    socket.listen((data) {
      buffer.add(utf8.decode(data));
      for (var e in _waitNex) {
        e.complete();
      }
      _waitNex.clear();
    }, onDone: () => _done = true);
  }

  void close() {
    _mutex.protect(() async {
      _done = true;
    });
  }

  final _mutex = Mutex();
  Future<String> readNext() async {
    if (_done) {
      throw SocketException("socket is closed");
    }
    return _mutex.protect(() async {
      final completer = Completer();
      _waitNex.add(completer);
      await completer.future;

      final last = buffer.last;
      buffer.clear();
      return last;
    });
  }
}
