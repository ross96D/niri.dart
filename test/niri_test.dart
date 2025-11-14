import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:niri/niri.dart';
import 'package:test/test.dart';

Future<dynamic> callNiriCmd(List<String> args) async {
  final result = await Process.run(
    "niri",
    ["msg", "--json", ...args],
    stderrEncoding: utf8,
    stdoutEncoding: utf8,
  );
  return json.decode(result.stdout);
}

void expectOk(Reply reply) {
  String? error;
  if (reply is ReplyError) {
    error = reply.error;
  }
  expect(reply, TypeMatcher<ReplyOk>(), reason: error);
}

void main() {
  test('call send several times', () async {
    final socket = await NiriSocket.connect();
    final version = await socket.send<ResponseVersion>(Request.version());
    final versionStr = version.unwrap().version;

    for (final _ in List.generate(100, (i) => i)) {
      final version = await socket.send<ResponseVersion>(Request.version());
      expect(versionStr, equals(version.unwrap().version));
    }
  });

  test("focused window", () async {
    final socket = await NiriSocket.connect();
    final focusedWindow = await socket.send<ResponseFocusedWindow>(Request.focusedWindow());
    expect(
      focusedWindow.unwrap().window,
      equals(Window.fromJson(await callNiriCmd(["focused-window"]))),
    );
  });

  test("focused output", () async {
    final socket = await NiriSocket.connect();
    final actual = await socket.send<ResponseFocusedOutput>(Request.focusedOutput());
    expect(actual.unwrap().output, equals(Output.fromJson(await callNiriCmd(["focused-output"]))));
  });

  test("layers", () async {
    final socket = await NiriSocket.connect();
    final actual = await socket.send<ResponseLayers>(Request.layers());
    final expected = [
      for (final e in await callNiriCmd(["layers"])) LayerSurface.fromJson(e),
    ];
    expect(actual.unwrap().layers, equals(expected));
  });

  test("windows", () async {
    final socket = await NiriSocket.connect();
    final actual = await socket.send<ResponseWindows>(Request.windows());
    final expected = [
      for (final e in await callNiriCmd(["windows"])) Window.fromJson(e),
    ];
    expect(actual.unwrap().windows, equals(expected));
  });

  test("outputs", () async {
    return markTestSkipped(
      "This fails because niri msg --json outputs returns a "
      "single object when there is one output. But i cannot test how it "
      "answers when there is several outptus",
    );
    // final socket = await NiriSocket.connect();
    // final actual = await socket.send<ResponseOutputs>(Request.outputs());
    // final expected = [
    //   for (final e in await callNiriCmd(["outputs"])) Output.fromJson(e),
    // ];
    // expect(actual.unwrap().outputs, equals(expected));
  });

  test("keyboard layouts", () async {
    final socket = await NiriSocket.connect();
    final focusedWindow = await socket.send<ResponseKeyboardLayouts>(Request.keyboardLayouts());
    expect(
      focusedWindow.unwrap().keyboardLayouts,
      equals(KeyboardLayouts.fromJson(await callNiriCmd(["keyboard-layouts"]))),
    );
  });

  test("error", () async {
    final socket = await NiriSocket.connect();
    final error = await socket.send(Request.returnError());
    expect(error, TypeMatcher<ReplyError>());
  });

  test("overview state", () async {
    final socket = await NiriSocket.connect();
    final actual = await socket.send<ResponseOverviewState>(Request.overviewState());
    expect(actual.unwrap().overview, equals(Overview.fromJson(await callNiriCmd(["overview-state"]))));
  });

  group("actions", () {
    test("debug toogle damage", () async {
      final socket = await NiriSocket.connect();
      expectOk(await socket.send(Request.action(Action.debugToggleDamage())));
      expectOk(await socket.send(Request.action(Action.debugToggleDamage())));
    });

    test("debug toogle opaque regions", () async {
      final socket = await NiriSocket.connect();
      expectOk(await socket.send(Request.action(Action.debugToggleOpaqueRegions())));
      expectOk(await socket.send(Request.action(Action.debugToggleOpaqueRegions())));
    });

    test("do screen transition", () async {
      final socket = await NiriSocket.connect();
      expectOk(await socket.send(Request.action(Action.doScreenTransition(null))));
    });
  });
}
