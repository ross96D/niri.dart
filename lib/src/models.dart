// types for communicating with niri via IPC.
//
// After connecting to the niri socket, you can send [Request]s. Niri will process them one by
// one, in order, and to each request it will respond with a single [Reply], which is a `Result`
// wrapping a [Response].
//
// If you send a [Request.eventStream], niri will *stop* reading subsequent [Request]s, and
// will start continuously writing compositor [Event]s to the socket. If you'd like to read an
// event stream and write more requests at the same time, you need to use two IPC sockets.
//
// <div class="warning">
//
// Requests are *always* processed separately. Time passes between requests, even when sending
// multiple requests to the socket at once. For example, sending [Request.workspaces] and
// [Request.windows] together may not return consistent results (e.g. a window may open on a
// new workspace in-between the two responses). This goes for actions too: sending
// [Action.focusWindow] and [Action.closeWindow] with id: null together may close
// the wrong window because a different window got focused in-between these requests.
//
// </div>
//
// You can use the [socket.Socket] helper if you're fine with blocking communication. However,
// it is a fairly simple helper, so if you need async, or if you're using a different language,
// you are encouraged to communicate with the socket manually.
//
// 1. Read the socket filesystem path from [socket.SOCKET_PATH_ENV] (`$NIRI_SOCKET`).
// 2. Connect to the socket and write a JSON-formatted [Request] on a single line. You can follow
//    up with a line break and a flush, or just flush and shutdown the write end of the socket.
// 3. Niri will respond with a single line JSON-formatted [Reply].
// 4. You can keep writing [Request]s, each on a single line, and read [Reply]s, also each on a
//    separate line.
// 5. After you request an event stream, niri will keep responding with JSON-formatted [Event]s,
//    on a single line each.

// ignore_for_file: invalid_annotation_target, constant_identifier_names, hash_and_equals

import 'package:json_annotation/json_annotation.dart';

part "models.g.dart";

/// Request from client to niri.
sealed class Request {
  const Request();

  /// Request package version
  const factory Request.version() = RequestVersion;

  /// Request information about connected outputs.
  const factory Request.outputs() = RequestOutputs;

  /// Request information about workspaces.
  const factory Request.workspaces() = RequestWorkspaces;

  /// Request information about open windows.
  const factory Request.windows() = RequestWindows;

  /// Request information about layer-shell surfaces.
  const factory Request.layers() = RequestLayers;

  /// Request information about the configured keyboard layouts.
  const factory Request.keyboardLayouts() = RequestKeyboardLayouts;

  /// Request information about the focused output.
  const factory Request.focusedOutput() = RequestFocusedOutput;

  /// Request information about the focused window.
  const factory Request.focusedWindow() = RequestFocusedWindow;

  /// Request picking a window and get its information.
  const factory Request.pickWindow() = RequestPickWindow;

  /// Request picking a color from the screen.
  const factory Request.pickColor() = RequestPickColor;

  /// Perform an action.
  const factory Request.action(Action action) = RequestAction;

  /// Change output configuration temporarily.
  ///
  /// The configuration is changed temporarily and not saved into the config file. If the output
  /// configuration subsequently changes in the config file, these temporary changes will be
  /// forgotten.
  const factory Request.output({
    /// Output name.
    required String output,

    /// Configuration to apply.
    required OutputAction action,
  }) = RequestOutput;

  /// Start continuously receiving events from the compositor.
  ///
  /// The compositor should reply with `Reply.ok(Response.handled)`, then continuously send
  /// [Event]s, one per line.
  ///
  /// The event stream will always give you the full current state up-front. For example, the
  /// first workspace-related event you will receive will be [Event.workspacesChanged]
  /// containing the full current workspaces state. You *do not* need to separately send
  /// [Request.workspaces] when using the event stream.
  ///
  /// Where reasonable, event stream state updates are atomic, though this is not always the
  /// case. For example, a window may end up with a workspace id for a workspace that had already
  /// been removed. This can happen if the corresponding [Event.workspacesChanged] arrives
  /// before the corresponding [Event.windowOpenedOrChanged].
  const factory Request.eventStream() = RequestEventStream;

  /// Respond with an error (for testing error handling).
  const factory Request.returnError() = RequestReturnError;

  /// Request information about the overview.
  const factory Request.overviewState() = RequestOverviewState;

  dynamic toJson() {
    switch (this) {
      case RequestVersion():
        return "Version";
      case RequestOutputs():
        return "Outputs";
      case RequestWorkspaces():
        return "Workspaces";
      case RequestWindows():
        return "Windows";
      case RequestLayers():
        return "Layers";
      case RequestKeyboardLayouts():
        return "KeyboardLayouts";
      case RequestFocusedOutput():
        return "FocusedOutput";
      case RequestFocusedWindow():
        return "FocusedWindow";
      case RequestPickWindow():
        return "PickWindow";
      case RequestPickColor():
        return "PickColor";
      case RequestEventStream():
        return "EventStream";
      case RequestReturnError():
        return "ReturnError";
      case RequestOverviewState():
        return "OverviewState";
      case RequestAction v:
        return {
          "Action": v.action.toJson(),
        };
      case RequestOutput v:
        return {
          "Output": {"output": v.output, "action": v.action.toJson()},
        };
    }
  }
}

/// Request package version
class RequestVersion extends Request {
  const RequestVersion();
}

/// Request information about connected outputs.
class RequestOutputs extends Request {
  const RequestOutputs();
}

/// Request information about workspaces.
class RequestWorkspaces extends Request {
  const RequestWorkspaces();
}

/// Request information about open windows.
class RequestWindows extends Request {
  const RequestWindows();
}

/// Request information about layer-shell surfaces.
class RequestLayers extends Request {
  const RequestLayers();
}

/// Request information about the configured keyboard layouts.
class RequestKeyboardLayouts extends Request {
  const RequestKeyboardLayouts();
}

/// Request information about the focused output.
class RequestFocusedOutput extends Request {
  const RequestFocusedOutput();
}

/// Request information about the focused window.
class RequestFocusedWindow extends Request {
  const RequestFocusedWindow();
}

/// Request picking a window and get its information.
class RequestPickWindow extends Request {
  const RequestPickWindow();
}

/// Request picking a color from the screen.
class RequestPickColor extends Request {
  const RequestPickColor();
}

class RequestAction extends Request {
  /// Perform an action.
  final Action action;

  const RequestAction(this.action);
}

/// Change output configuration temporarily.
///
/// The configuration is changed temporarily and not saved into the config file. If the output
/// configuration subsequently changes in the config file, these temporary changes will be
/// forgotten.
class RequestOutput extends Request {
  /// Output name.
  final String output;

  /// Configuration to apply.
  final OutputAction action;

  const RequestOutput({required this.output, required this.action});
}

/// Start continuously receiving events from the compositor.
///
/// The compositor should reply with `Reply.ok(Response.handled)`, then continuously send
/// [Event]s, one per line.
///
/// The event stream will always give you the full current state up-front. For example, the
/// first workspace-related event you will receive will be [Event.workspacesChanged]
/// containing the full current workspaces state. You *do not* need to separately send
/// [Request.workspaces] when using the event stream.
///
/// Where reasonable, event stream state updates are atomic, though this is not always the
/// case. For example, a window may end up with a workspace id for a workspace that had already
/// been removed. This can happen if the corresponding [Event.workspacesChanged] arrives
/// before the corresponding [Event.windowOpenedOrChanged].
class RequestEventStream extends Request {
  const RequestEventStream();
}

/// Respond with an error (for testing error handling).
class RequestReturnError extends Request {
  const RequestReturnError();
}

/// Request information about the overview.
class RequestOverviewState extends Request {
  const RequestOverviewState();
}

/// Successful response from niri to client.
sealed class Response {
  const Response();

  /// A request that does not need a response was handled successfully.
  const factory Response.handled() = ResponseHandled;

  /// The version string for the running niri instance.
  const factory Response.version(String version) = ResponseVersion;

  /// Information about connected outputs.
  ///
  /// Map from output name to output info.
  const factory Response.outputs(Map<String, Output> outputs) = ResponseOutputs;

  /// Information about workspaces.
  const factory Response.workspaces(List<Workspace> workspaces) = ResponseWorkspaces;

  /// Information about open windows.
  const factory Response.windows(List<Window> windows) = ResponseWindows;

  /// Information about layer-shell surfaces.
  const factory Response.layers(List<LayerSurface> layers) = ResponseLayers;

  /// Information about the keyboard layout.
  const factory Response.keyboardLayouts(KeyboardLayouts keyboardLayouts) = ResponseKeyboardLayouts;

  /// Information about the focused output.
  const factory Response.focusedOutput(Output? output) = ResponseFocusedOutput;

  /// Information about the focused window.
  const factory Response.focusedWindow(Window? window) = ResponseFocusedWindow;

  /// Information about the picked window.
  const factory Response.pickedWindow(Window? window) = ResponsePickedWindow;

  /// Information about the picked color.
  const factory Response.pickedColor(PickedColor? color) = ResponsePickedColor;

  /// Output configuration change result.
  const factory Response.outputConfigChanged(OutputConfigChanged result) =
      ResponseOutputConfigChanged;

  /// Information about the overview.
  const factory Response.overviewState(Overview overview) = ResponseOverviewState;

  // factory Response.fromJson(Map<String, dynamic> json) => _$ResponseFromJson(json);
  factory Response.fromJson(dynamic json) {
    if (json is String) {
      switch (json) {
        case "Handled":
          return ResponseHandled();
        default:
          throw "Invalid json $json";
      }
    }
    if (json is! Map) {
      throw "Invalid json $json";
    }
    switch (json.keys.first) {
      case "Version":
        final value = json["Version"];
        return Response.version(value);
      case "Outputs":
        final value = json["Outputs"] as Map<String, dynamic>;
        final outputs = {
          for (final entry in value.entries) entry.key: Output.fromJson(entry.value),
        };
        return Response.outputs(outputs);
      case "Workspaces":
        final value = json["Workspaces"];
        final workspaces = [for (final v in value) Workspace.fromJson(v)];
        return Response.workspaces(workspaces);
      case "Windows":
        final value = json["Windows"];
        final windows = [for (final v in value) Window.fromJson(v)];
        return Response.windows(windows);
      case "Layers":
        final value = json["Layers"];
        final layers = [for (final v in value) LayerSurface.fromJson(v)];
        return Response.layers(layers);
      case "KeyboardLayouts":
        final value = json["KeyboardLayouts"];
        return Response.keyboardLayouts(KeyboardLayouts.fromJson(value));
      case "FocusedOutput":
        final value = json["FocusedOutput"];
        return Response.focusedOutput(Output.fromJson(value));
      case "FocusedWindow":
        final value = json["FocusedWindow"];
        return Response.focusedWindow(Window.fromJson(value));
      case "PickedWindow":
        final value = json["PickedWindow"];
        return Response.pickedWindow(Window.fromJson(value));
      case "PickedColor":
        final value = json["PickedColor"];
        return Response.pickedColor(PickedColor.fromJson(value));
      case "OutputConfigChanged":
        final value = json["OutputConfigChanged"];
        return Response.outputConfigChanged(OutputConfigChanged.fromJson(value));
      case "OverviewState":
        final value = json["OverviewState"];
        return Response.overviewState(Overview.fromJson(value));
    }
    throw "Invalid json $json";
  }

  dynamic toJson() {
    switch (this) {
      case ResponseHandled():
        return "Handled";
      case ResponseVersion v:
        return {"Version": v.version};
      case ResponseOutputs v:
        return {"Outputs": v.outputs.map((k, v) => MapEntry(k, v.toJson()))};
      case ResponseWorkspaces v:
        return {"Workspaces": v.workspaces.map((e) => e.toJson()).toList()};
      case ResponseWindows v:
        return {"Windows": v.windows.map((e) => e.toJson()).toList()};
      case ResponseLayers v:
        return {"Layers": v.layers.map((e) => e.toJson()).toList()};
      case ResponseKeyboardLayouts v:
        return {"KeyboardLayouts": v.keyboardLayouts.toJson()};
      case ResponseFocusedOutput v:
        return {"FocusedOutput": v.output?.toJson()};
      case ResponseFocusedWindow v:
        return {"FocusedWindow": v.window?.toJson()};
      case ResponsePickedWindow v:
        return {"PickedWindow": v.window?.toJson()};
      case ResponsePickedColor v:
        return {"PickedColor": v.color?.toJson()};
      case ResponseOutputConfigChanged v:
        return {"OutputConfigChanged": v.result.toJson()};
      case ResponseOverviewState v:
        return {"OverviewState": v.overview.toJson()};
    }
  }
}

/// A request that does not need a response was handled successfully.
class ResponseHandled extends Response {
  const ResponseHandled();
}

/// The version string for the running niri instance.
class ResponseVersion extends Response {
  final String version;
  const ResponseVersion(this.version);
}

/// Information about connected outputs.
///
/// Map from output name to output info.
class ResponseOutputs extends Response {
  final Map<String, Output> outputs;
  const ResponseOutputs(this.outputs);
}

/// Information about workspaces.
class ResponseWorkspaces extends Response {
  final List<Workspace> workspaces;
  const ResponseWorkspaces(this.workspaces);
}

/// Information about open windows.
class ResponseWindows extends Response {
  final List<Window> windows;
  const ResponseWindows(this.windows);
}

/// Information about layer-shell surfaces.
class ResponseLayers extends Response {
  final List<LayerSurface> layers;
  const ResponseLayers(this.layers);
}

/// Information about the keyboard layout.
class ResponseKeyboardLayouts extends Response {
  final KeyboardLayouts keyboardLayouts;
  const ResponseKeyboardLayouts(this.keyboardLayouts);
}

/// Information about the focused output.
class ResponseFocusedOutput extends Response {
  final Output? output;
  const ResponseFocusedOutput(this.output);
}

/// Information about the focused window.
class ResponseFocusedWindow extends Response {
  final Window? window;
  const ResponseFocusedWindow(this.window);
}

/// Information about the picked window.
class ResponsePickedWindow extends Response {
  final Window? window;
  const ResponsePickedWindow(this.window);
}

/// Information about the picked color.
class ResponsePickedColor extends Response {
  final PickedColor? color;
  const ResponsePickedColor(this.color);
}

/// Output configuration change result.
class ResponseOutputConfigChanged extends Response {
  final OutputConfigChanged result;
  const ResponseOutputConfigChanged(this.result);
}

/// Information about the overview.
class ResponseOverviewState extends Response {
  final Overview overview;
  const ResponseOverviewState(this.overview);
}

/// Overview information.
class Overview {
  /// Whether the overview is currently open.
  final bool isOpen;

  const Overview({required this.isOpen});

  factory Overview.fromJson(Map<String, dynamic> json) {
    return Overview(isOpen: json["is_open"]);
  }

  @override
  bool operator ==(covariant Overview other) => isOpen == other.isOpen;

  @override
  int get hashCode => isOpen.hashCode;

  Map<String, dynamic> toJson() => {"is_open": isOpen};
}

/// Color picked from the screen.
@JsonSerializable()
class PickedColor {
  /// Color values as red, green, blue, each ranging from 0.0 to 1.0.
  final List<double> rgb;

  const PickedColor({required this.rgb});

  factory PickedColor.fromJson(Map<String, dynamic> json) => _$PickedColorFromJson(json);

  Map<String, dynamic> toJson() => _$PickedColorToJson(this);
}

/// Actions that niri can perform.
sealed class Action {
  const Action();

  /// Exit niri.
  const factory Action.quit(bool skipConfirmation) = ActionQuit;

  /// Power off all monitors via DPMS.
  const factory Action.powerOffMonitors() = ActionPowerOffMonitors;

  /// Power on all monitors via DPMS.
  const factory Action.powerOnMonitors() = ActionPowerOnMonitors;

  /// Spawn a command.
  const factory Action.spawn(
    /// Command to spawn.
    List<String> command,
  ) = ActionSpawn;

  /// Spawn a command through the shell.
  const factory Action.spawnSh(
    /// Command to run.
    String command,
  ) = ActionSpawnSh;

  /// Do a screen transition.
  const factory Action.doScreenTransition(
    /// Delay in milliseconds for the screen to freeze before starting the transition.
    int? delayMs,
  ) = ActionDoScreenTransition;

  /// Open the screenshot UI.
  const factory Action.screenshot({
    /// Whether to show the mouse pointer by default in the screenshot UI.
    required bool showPointer,

    /// Path to save the screenshot to.
    ///
    /// The path must be absolute, otherwise an error is returned.
    ///
    /// If `None`, the screenshot is saved according to the `screenshot-path` config setting.
    required String? path,
  }) = ActionScreenshot;

  /// Screenshot the focused screen.
  const factory Action.screenshotScreen({
    /// Write the screenshot to disk in addition to putting it in your clipboard.
    ///
    /// The screenshot is saved according to the `screenshot-path` config setting.
    required bool writeToDisk,

    /// Whether to include the mouse pointer in the screenshot.
    required bool showPointer,

    /// Path to save the screenshot to.
    ///
    /// The path must be absolute, otherwise an error is returned.
    ///
    /// If `None`, the screenshot is saved according to the `screenshot-path` config setting.
    required String? path,
  }) = ActionScreenshotScreen;

  /// Screenshot a window.
  const factory Action.screenshotWindow({
    /// Id of the window to screenshot.
    ///
    /// If `None`, uses the focused window.
    required int? id,

    /// Write the screenshot to disk in addition to putting it in your clipboard.
    ///
    /// The screenshot is saved according to the `screenshot-path` config setting.
    required bool writeToDisk,

    /// Path to save the screenshot to.
    ///
    /// The path must be absolute, otherwise an error is returned.
    ///
    /// If `None`, the screenshot is saved according to the `screenshot-path` config setting.
    required String? path,
  }) = ActionScreenshotWindow;

  /// Enable or disable the keyboard shortcuts inhibitor (if any) for the focused surface.
  const factory Action.toggleKeyboardShortcutsInhibit() = ActionToggleKeyboardShortcutsInhibit;

  /// Close a window.
  const factory Action.closeWindow(
    /// Id of the window to close.
    ///
    /// If `None`, uses the focused window.
    int? id,
  ) = ActionCloseWindow;

  /// Toggle fullscreen on a window.
  const factory Action.fullscreenWindow(
    /// Id of the window to toggle fullscreen of.
    ///
    /// If `None`, uses the focused window.
    int? id,
  ) = ActionFullscreenWindow;

  /// Toggle windowed (fake) fullscreen on a window.
  const factory Action.toggleWindowedFullscreen(
    /// Id of the window to toggle windowed fullscreen of.
    ///
    /// If `None`, uses the focused window.
    int? id,
  ) = ActionToggleWindowedFullscreen;

  /// Focus a window by id.
  const factory Action.focusWindow(
    /// Id of the window to focus.
    int id,
  ) = ActionFocusWindow;

  /// Focus a window in the focused column by index.
  const factory Action.focusWindowInColumn(
    /// Index of the window in the column.
    ///
    /// The index starts from 1 for the topmost window.
    int index,
  ) = ActionFocusWindowInColumn;

  /// Focus the previously focused window.
  const factory Action.focusWindowPrevious() = ActionFocusWindowPrevious;

  /// Focus the column to the left.
  const factory Action.focusColumnLeft() = ActionFocusColumnLeft;

  /// Focus the column to the right.
  const factory Action.focusColumnRight() = ActionFocusColumnRight;

  /// Focus the first column.
  const factory Action.focusColumnFirst() = ActionFocusColumnFirst;

  /// Focus the last column.
  const factory Action.focusColumnLast() = ActionFocusColumnLast;

  /// Focus the next column to the right, looping if at end.
  const factory Action.focusColumnRightOrFirst() = ActionFocusColumnRightOrFirst;

  /// Focus the next column to the left, looping if at start.
  const factory Action.focusColumnLeftOrLast() = ActionFocusColumnLeftOrLast;

  /// Focus a column by index.
  const factory Action.focusColumn(
    /// Index of the column to focus.
    ///
    /// The index starts from 1 for the first column.
    int index,
  ) = ActionFocusColumn;

  /// Focus the window or the monitor above.
  const factory Action.focusWindowOrMonitorUp() = ActionFocusWindowOrMonitorUp;

  /// Focus the window or the monitor below.
  const factory Action.focusWindowOrMonitorDown() = ActionFocusWindowOrMonitorDown;

  /// Focus the column or the monitor to the left.
  const factory Action.focusColumnOrMonitorLeft() = ActionFocusColumnOrMonitorLeft;

  /// Focus the column or the monitor to the right.
  const factory Action.focusColumnOrMonitorRight() = ActionFocusColumnOrMonitorRight;

  /// Focus the window below.
  const factory Action.focusWindowDown() = ActionFocusWindowDown;

  /// Focus the window above.
  const factory Action.focusWindowUp() = ActionFocusWindowUp;

  /// Focus the window below or the column to the left.
  const factory Action.focusWindowDownOrColumnLeft() = ActionFocusWindowDownOrColumnLeft;

  /// Focus the window below or the column to the right.
  const factory Action.focusWindowDownOrColumnRight() = ActionFocusWindowDownOrColumnRight;

  /// Focus the window above or the column to the left.
  const factory Action.focusWindowUpOrColumnLeft() = ActionFocusWindowUpOrColumnLeft;

  /// Focus the window above or the column to the right.
  const factory Action.focusWindowUpOrColumnRight() = ActionFocusWindowUpOrColumnRight;

  /// Focus the window or the workspace below.
  const factory Action.focusWindowOrWorkspaceDown() = ActionFocusWindowOrWorkspaceDown;

  /// Focus the window or the workspace above.
  const factory Action.focusWindowOrWorkspaceUp() = ActionFocusWindowOrWorkspaceUp;

  /// Focus the topmost window.
  const factory Action.focusWindowTop() = ActionFocusWindowTop;

  /// Focus the bottommost window.
  const factory Action.focusWindowBottom() = ActionFocusWindowBottom;

  /// Focus the window below or the topmost window.
  const factory Action.focusWindowDownOrTop() = ActionFocusWindowDownOrTop;

  /// Focus the window above or the bottommost window.
  const factory Action.focusWindowUpOrBottom() = ActionFocusWindowUpOrBottom;

  /// Move the focused column to the left.
  const factory Action.moveColumnLeft() = ActionMoveColumnLeft;

  /// Move the focused column to the right.
  const factory Action.moveColumnRight() = ActionMoveColumnRight;

  /// Move the focused column to the start of the workspace.
  const factory Action.moveColumnToFirst() = ActionMoveColumnToFirst;

  /// Move the focused column to the end of the workspace.
  const factory Action.moveColumnToLast() = ActionMoveColumnToLast;

  /// Move the focused column to the left or to the monitor to the left.
  const factory Action.moveColumnLeftOrToMonitorLeft() = ActionMoveColumnLeftOrToMonitorLeft;

  /// Move the focused column to the right or to the monitor to the right.
  const factory Action.moveColumnRightOrToMonitorRight() = ActionMoveColumnRightOrToMonitorRight;

  /// Move the focused column to a specific index on its workspace.
  const factory Action.moveColumnToIndex(
    /// New index for the column.
    ///
    /// The index starts from 1 for the first column.
    int index,
  ) = ActionMoveColumnToIndex;

  /// Move the focused window down in a column.
  const factory Action.moveWindowDown() = ActionMoveWindowDown;

  /// Move the focused window up in a column.
  const factory Action.moveWindowUp() = ActionMoveWindowUp;

  /// Move the focused window down in a column or to the workspace below.
  const factory Action.moveWindowDownOrToWorkspaceDown() = ActionMoveWindowDownOrToWorkspaceDown;

  /// Move the focused window up in a column or to the workspace above.
  const factory Action.moveWindowUpOrToWorkspaceUp() = ActionMoveWindowUpOrToWorkspaceUp;

  /// Consume or expel a window left.
  const factory Action.consumeOrExpelWindowLeft(
    /// Id of the window to consume or expel.
    ///
    /// If `None`, uses the focused window.
    int? id,
  ) = ActionConsumeOrExpelWindowLeft;

  /// Consume or expel a window right.
  const factory Action.consumeOrExpelWindowRight(
    /// Id of the window to consume or expel.
    ///
    /// If `None`, uses the focused window.
    int? id,
  ) = ActionConsumeOrExpelWindowRight;

  /// Consume the window to the right into the focused column.
  const factory Action.consumeWindowIntoColumn() = ActionConsumeWindowIntoColumn;

  /// Expel the focused window from the column.
  const factory Action.expelWindowFromColumn() = ActionExpelWindowFromColumn;

  /// Swap focused window with one to the right.
  const factory Action.swapWindowRight() = ActionSwapWindowRight;

  /// Swap focused window with one to the left.
  const factory Action.swapWindowLeft() = ActionSwapWindowLeft;

  /// Toggle the focused column between normal and tabbed display.
  const factory Action.toggleColumnTabbedDisplay() = ActionToggleColumnTabbedDisplay;

  /// Set the display mode of the focused column.
  const factory Action.setColumnDisplay(
    /// Display mode to set.
    ColumnDisplay display,
  ) = ActionSetColumnDisplay;

  /// Center the focused column on the screen.
  const factory Action.centerColumn() = ActionCenterColumn;

  /// Center a window on the screen.
  const factory Action.centerWindow(
    /// Id of the window to center.
    ///
    /// If `None`, uses the focused window.
    int? id,
  ) = ActionCenterWindow;

  /// Center all fully visible columns on the screen.
  const factory Action.centerVisibleColumns() = ActionCenterVisibleColumns;

  /// Focus the workspace below.
  const factory Action.focusWorkspaceDown() = ActionFocusWorkspaceDown;

  /// Focus the workspace above.
  const factory Action.focusWorkspaceUp() = ActionFocusWorkspaceUp;

  /// Focus a workspace by reference (index or name).
  const factory Action.focusWorkspace(
    /// Reference (index or name) of the workspace to focus.
    WorkspaceReferenceArg reference,
  ) = ActionFocusWorkspace;

  /// Focus the previous workspace.
  const factory Action.focusWorkspacePrevious() = ActionFocusWorkspacePrevious;

  /// Move the focused window to the workspace below.
  const factory Action.moveWindowToWorkspaceDown(
    /// Whether the focus should follow the target workspace.
    ///
    /// If `true` (the default), the focus will follow the window to the new workspace. If
    /// `false`, the focus will remain on the original workspace.
    bool focus,
  ) = ActionMoveWindowToWorkspaceDown;

  /// Move the focused window to the workspace above.
  const factory Action.moveWindowToWorkspaceUp(
    /// Whether the focus should follow the target workspace.
    ///
    /// If `true` (the default), the focus will follow the window to the new workspace. If
    /// `false`, the focus will remain on the original workspace.
    bool focus,
  ) = ActionMoveWindowToWorkspaceUp;

  /// Move a window to a workspace.
  const factory Action.moveWindowToWorkspace({
    /// Id of the window to move.
    ///
    /// If `None`, uses the focused window.
    required int? windowId,

    /// Reference (index or name) of the workspace to move the window to.
    required WorkspaceReferenceArg reference,

    /// Whether the focus should follow the moved window.
    ///
    /// If `true` (the default) and the window to move is focused, the focus will follow the
    /// window to the new workspace. If `false`, the focus will remain on the original
    /// workspace.
    required bool focus,
  }) = ActionMoveWindowToWorkspace;

  /// Move the focused column to the workspace below.
  const factory Action.moveColumnToWorkspaceDown(
    /// Whether the focus should follow the target workspace.
    ///
    /// If `true` (the default), the focus will follow the column to the new workspace. If
    /// `false`, the focus will remain on the original workspace.
    bool focus,
  ) = ActionMoveColumnToWorkspaceDown;

  /// Move the focused column to the workspace above.
  const factory Action.moveColumnToWorkspaceUp(
    /// Whether the focus should follow the target workspace.
    ///
    /// If `true` (the default), the focus will follow the column to the new workspace. If
    /// `false`, the focus will remain on the original workspace.
    bool focus,
  ) = ActionMoveColumnToWorkspaceUp;

  /// Move the focused column to a workspace by reference (index or name).
  const factory Action.moveColumnToWorkspace({
    /// Reference (index or name) of the workspace to move the column to.
    required WorkspaceReferenceArg reference,

    /// Whether the focus should follow the target workspace.
    ///
    /// If `true` (the default), the focus will follow the column to the new workspace. If
    /// `false`, the focus will remain on the original workspace.
    required bool focus,
  }) = ActionMoveColumnToWorkspace;

  /// Move the focused workspace down.
  const factory Action.moveWorkspaceDown() = ActionMoveWorkspaceDown;

  /// Move the focused workspace up.
  const factory Action.moveWorkspaceUp() = ActionMoveWorkspaceUp;

  /// Move a workspace to a specific index on its monitor.
  const factory Action.moveWorkspaceToIndex({
    /// New index for the workspace.
    required int index,

    /// Reference (index or name) of the workspace to move.
    ///
    /// If `None`, uses the focused workspace.
    required WorkspaceReferenceArg? reference,
  }) = ActionMoveWorkspaceToIndex;

  /// Set the name of a workspace.
  const factory Action.setWorkspaceName({
    /// New name for the workspace.
    required String name,

    /// Reference (index or name) of the workspace to name.
    ///
    /// If `None`, uses the focused workspace.
    required WorkspaceReferenceArg? workspace,
  }) = ActionSetWorkspaceName;

  /// Unset the name of a workspace.
  const factory Action.unsetWorkspaceName(
    /// Reference (index or name) of the workspace to unname.
    ///
    /// If `None`, uses the focused workspace.
    WorkspaceReferenceArg? reference,
  ) = ActionUnsetWorkspaceName;

  /// Focus the monitor to the left.
  const factory Action.focusMonitorLeft() = ActionFocusMonitorLeft;

  /// Focus the monitor to the right.
  const factory Action.focusMonitorRight() = ActionFocusMonitorRight;

  /// Focus the monitor below.
  const factory Action.focusMonitorDown() = ActionFocusMonitorDown;

  /// Focus the monitor above.
  const factory Action.focusMonitorUp() = ActionFocusMonitorUp;

  /// Focus the previous monitor.
  const factory Action.focusMonitorPrevious() = ActionFocusMonitorPrevious;

  /// Focus the next monitor.
  const factory Action.focusMonitorNext() = ActionFocusMonitorNext;

  /// Focus a monitor by name.
  const factory Action.focusMonitor(
    /// Name of the output to focus.
    String output,
  ) = ActionFocusMonitor;

  /// Move the focused window to the monitor to the left.
  const factory Action.moveWindowToMonitorLeft() = ActionMoveWindowToMonitorLeft;

  /// Move the focused window to the monitor to the right.
  const factory Action.moveWindowToMonitorRight() = ActionMoveWindowToMonitorRight;

  /// Move the focused window to the monitor below.
  const factory Action.moveWindowToMonitorDown() = ActionMoveWindowToMonitorDown;

  /// Move the focused window to the monitor above.
  const factory Action.moveWindowToMonitorUp() = ActionMoveWindowToMonitorUp;

  /// Move the focused window to the previous monitor.
  const factory Action.moveWindowToMonitorPrevious() = ActionMoveWindowToMonitorPrevious;

  /// Move the focused window to the next monitor.
  const factory Action.moveWindowToMonitorNext() = ActionMoveWindowToMonitorNext;

  /// Move a window to a specific monitor.
  const factory Action.moveWindowToMonitor({
    /// Id of the window to move.
    ///
    /// If `None`, uses the focused window.
    required int? id,

    /// The target output name.
    required String output,
  }) = ActionMoveWindowToMonitor;

  /// Move the focused column to the monitor to the left.
  const factory Action.moveColumnToMonitorLeft() = ActionMoveColumnToMonitorLeft;

  /// Move the focused column to the monitor to the right.
  const factory Action.moveColumnToMonitorRight() = ActionMoveColumnToMonitorRight;

  /// Move the focused column to the monitor below.
  const factory Action.moveColumnToMonitorDown() = ActionMoveColumnToMonitorDown;

  /// Move the focused column to the monitor above.
  const factory Action.moveColumnToMonitorUp() = ActionMoveColumnToMonitorUp;

  /// Move the focused column to the previous monitor.
  const factory Action.moveColumnToMonitorPrevious() = ActionMoveColumnToMonitorPrevious;

  /// Move the focused column to the next monitor.
  const factory Action.moveColumnToMonitorNext() = ActionMoveColumnToMonitorNext;

  /// Move the focused column to a specific monitor.
  const factory Action.moveColumnToMonitor(
    /// The target output name.
    String output,
  ) = ActionMoveColumnToMonitor;

  /// Change the width of a window.
  const factory Action.setWindowWidth({
    /// Id of the window whose width to set.
    ///
    /// If `None`, uses the focused window.
    required int? id,

    /// How to change the width.
    required SizeChange change,
  }) = ActionSetWindowWidth;

  /// Change the height of a window.
  const factory Action.setWindowHeight({
    /// Id of the window whose height to set.
    ///
    /// If `None`, uses the focused window.
    required int? id,

    /// How to change the height.
    required SizeChange change,
  }) = ActionSetWindowHeight;

  /// Reset the height of a window back to automatic.
  const factory Action.resetWindowHeight(
    /// Id of the window whose height to reset.
    ///
    /// If `None`, uses the focused window.
    int? id,
  ) = ActionResetWindowHeight;

  /// Switch between preset column widths.
  const factory Action.switchPresetColumnWidth() = ActionSwitchPresetColumnWidth;

  /// Switch between preset column widths backwards.
  const factory Action.switchPresetColumnWidthBack() = ActionSwitchPresetColumnWidthBack;

  /// Switch between preset window widths.
  const factory Action.switchPresetWindowWidth(
    /// Id of the window whose width to switch.
    ///
    /// If `None`, uses the focused window.
    int? id,
  ) = ActionSwitchPresetWindowWidth;

  /// Switch between preset window widths backwards.
  const factory Action.switchPresetWindowWidthBack(
    /// Id of the window whose width to switch.
    ///
    /// If `None`, uses the focused window.
    int? id,
  ) = ActionSwitchPresetWindowWidthBack;

  /// Switch between preset window heights.
  const factory Action.switchPresetWindowHeight(
    /// Id of the window whose height to switch.
    ///
    /// If `None`, uses the focused window.
    int? id,
  ) = ActionSwitchPresetWindowHeight;

  /// Switch between preset window heights backwards.
  const factory Action.switchPresetWindowHeightBack(
    /// Id of the window whose height to switch.
    ///
    /// If `None`, uses the focused window.
    int? id,
  ) = ActionSwitchPresetWindowHeightBack;

  /// Toggle the maximized state of the focused column.
  const factory Action.maximizeColumn() = ActionMaximizeColumn;

  /// Toggle the maximized-to-edges state of the focused window.
  const factory Action.maximizeWindowToEdges(
    /// Id of the window to maximize.
    ///
    /// If `None`, uses the focused window.
    int? id,
  ) = ActionMaximizeWindowToEdges;

  /// Change the width of the focused column.
  const factory Action.setColumnWidth(
    /// How to change the width.
    SizeChange change,
  ) = ActionSetColumnWidth;

  /// Expand the focused column to space not taken up by other fully visible columns.
  const factory Action.expandColumnToAvailableWidth() = ActionExpandColumnToAvailableWidth;

  /// Switch between keyboard layouts.
  const factory Action.switchLayout(
    /// Layout to switch to.
    LayoutSwitchTarget layout,
  ) = ActionSwitchLayout;

  /// Show the hotkey overlay.
  const factory Action.showHotkeyOverlay() = ActionShowHotkeyOverlay;

  /// Move the focused workspace to the monitor to the left.
  const factory Action.moveWorkspaceToMonitorLeft() = ActionMoveWorkspaceToMonitorLeft;

  /// Move the focused workspace to the monitor to the right.
  const factory Action.moveWorkspaceToMonitorRight() = ActionMoveWorkspaceToMonitorRight;

  /// Move the focused workspace to the monitor below.
  const factory Action.moveWorkspaceToMonitorDown() = ActionMoveWorkspaceToMonitorDown;

  /// Move the focused workspace to the monitor above.
  const factory Action.moveWorkspaceToMonitorUp() = ActionMoveWorkspaceToMonitorUp;

  /// Move the focused workspace to the previous monitor.
  const factory Action.moveWorkspaceToMonitorPrevious() = ActionMoveWorkspaceToMonitorPrevious;

  /// Move the focused workspace to the next monitor.
  const factory Action.moveWorkspaceToMonitorNext() = ActionMoveWorkspaceToMonitorNext;

  /// Move a workspace to a specific monitor.
  const factory Action.moveWorkspaceToMonitor({
    /// The target output name.
    required String output,

    /// Reference (index or name) of the workspace to move.
    ///
    /// If `None`, uses the focused workspace.
    required WorkspaceReferenceArg? reference,
  }) = ActionMoveWorkspaceToMonitor;

  /// Toggle a debug tint on windows.
  const factory Action.toggleDebugTint() = ActionToggleDebugTint;

  /// Toggle visualization of render element opaque regions.
  const factory Action.debugToggleOpaqueRegions() = ActionDebugToggleOpaqueRegions;

  /// Toggle visualization of output damage.
  const factory Action.debugToggleDamage() = ActionDebugToggleDamage;

  /// Move the focused window between the floating and the tiling layout.
  const factory Action.toggleWindowFloating(
    /// Id of the window to move.
    ///
    /// If `None`, uses the focused window.
    int? id,
  ) = ActionToggleWindowFloating;

  /// Move the focused window to the floating layout.
  const factory Action.moveWindowToFloating(
    /// Id of the window to move.
    ///
    /// If `None`, uses the focused window.
    int? id,
  ) = ActionMoveWindowToFloating;

  /// Move the focused window to the tiling layout.
  const factory Action.moveWindowToTiling(
    /// Id of the window to move.
    ///
    /// If `None`, uses the focused window.
    int? id,
  ) = ActionMoveWindowToTiling;

  /// Switches focus to the floating layout.
  const factory Action.focusFloating() = ActionFocusFloating;

  /// Switches focus to the tiling layout.
  const factory Action.focusTiling() = ActionFocusTiling;

  /// Toggles the focus between the floating and the tiling layout.
  const factory Action.switchFocusBetweenFloatingAndTiling() =
      ActionSwitchFocusBetweenFloatingAndTiling;

  /// Move a floating window on screen.
  const factory Action.moveFloatingWindow({
    /// Id of the window to move.
    ///
    /// If `None`, uses the focused window.
    required int? id,

    /// How to change the X position.
    required PositionChange x,

    /// How to change the Y position.
    required PositionChange y,
  }) = ActionMoveFloatingWindow;

  /// Toggle the opacity of a window.
  const factory Action.toggleWindowRuleOpacity(
    /// Id of the window.
    ///
    /// If `None`, uses the focused window.
    int? id,
  ) = ActionToggleWindowRuleOpacity;

  /// Set the dynamic cast target to a window.
  const factory Action.setDynamicCastWindow(
    /// Id of the window to target.
    ///
    /// If `None`, uses the focused window.
    int? id,
  ) = ActionSetDynamicCastWindow;

  /// Set the dynamic cast target to a monitor.
  const factory Action.setDynamicCastMonitor(
    /// Name of the output to target.
    ///
    /// If `None`, uses the focused output.
    String? output,
  ) = ActionSetDynamicCastMonitor;

  /// Clear the dynamic cast target, making it show nothing.
  const factory Action.clearDynamicCastTarget() = ActionClearDynamicCastTarget;

  /// Toggle (open/close) the Overview.
  const factory Action.toggleOverview() = ActionToggleOverview;

  /// Open the Overview.
  const factory Action.openOverview() = ActionOpenOverview;

  /// Close the Overview.
  const factory Action.closeOverview() = ActionCloseOverview;

  /// Toggle urgent status of a window.
  const factory Action.toggleWindowUrgent(
    /// Id of the window to toggle urgent.
    int id,
  ) = ActionToggleWindowUrgent;

  /// Set urgent status of a window.
  const factory Action.setWindowUrgent(
    /// Id of the window to set urgent.
    int id,
  ) = ActionSetWindowUrgent;

  /// Unset urgent status of a window.
  const factory Action.unsetWindowUrgent(
    /// Id of the window to unset urgent.
    int id,
  ) = ActionUnsetWindowUrgent;

  /// Reload the config file.
  ///
  /// Can be useful for scripts changing the config file, to avoid waiting the small duration for
  /// niri's config file watcher to notice the changes.
  const factory Action.loadConfigFile() = ActionLoadConfigFile;

  // factory Action.fromJson(Map<String, dynamic> json) => _$ActionFromJson(json);
  dynamic toJson() {
    switch (this) {
      case ActionQuit v:
        return {
          "Quit": {"skip_confirmation": v.skipConfirmation},
        };
      case ActionPowerOffMonitors _:
        return {"PowerOffMonitors": {}};
      case ActionPowerOnMonitors _:
        return {"PowerOnMonitors": {}};
      case ActionSpawn v:
        return {
          "Spawn": {"command": v.command},
        };
      case ActionSpawnSh v:
        return {
          "SpawnSh": {"command": v.command},
        };
      case ActionDoScreenTransition v:
        return {
          "DoScreenTransition": {"delay_ms": v.delayMs},
        };
      case ActionScreenshot v:
        return {
          "Screenshot": {"show_pointer": v.showPointer, "path": v.path},
        };
      case ActionScreenshotScreen v:
        return {
          "ScreenshotScreen": {
            "write_to_disk": v.writeToDisk,
            "show_pointer": v.showPointer,
            "path": v.path,
          },
        };
      case ActionScreenshotWindow v:
        return {
          "ScreenshotWindow": {"id": v.id, "write_to_disk": v.writeToDisk, "path": v.path},
        };
      case ActionToggleKeyboardShortcutsInhibit _:
        return {"ToggleKeyboardShortcutsInhibit": {}};
      case ActionCloseWindow v:
        return {
          "CloseWindow": {"id": v.id},
        };
      case ActionFullscreenWindow v:
        return {
          "FullscreenWindow": {"id": v.id},
        };
      case ActionToggleWindowedFullscreen v:
        return {
          "ToggleWindowedFullscreen": {"id": v.id},
        };
      case ActionFocusWindow v:
        return {
          "FocusWindow": {"id": v.id},
        };
      case ActionFocusWindowInColumn v:
        return {
          "FocusWindowInColumn": {"index": v.index},
        };
      case ActionFocusWindowPrevious _:
        return {"FocusWindowPrevious": {}};
      case ActionFocusColumnLeft _:
        return {"FocusColumnLeft": {}};
      case ActionFocusColumnRight _:
        return {"FocusColumnRight": {}};
      case ActionFocusColumnFirst _:
        return {"FocusColumnFirst": {}};
      case ActionFocusColumnLast _:
        return {"FocusColumnLast": {}};
      case ActionFocusColumnRightOrFirst _:
        return {"FocusColumnRightOrFirst": {}};
      case ActionFocusColumnLeftOrLast _:
        return {"FocusColumnLeftOrLast": {}};
      case ActionFocusColumn v:
        return {
          "FocusColumn": {"index": v.index},
        };
      case ActionFocusWindowOrMonitorUp _:
        return {"FocusWindowOrMonitorUp": {}};
      case ActionFocusWindowOrMonitorDown _:
        return {"FocusWindowOrMonitorDown": {}};
      case ActionFocusColumnOrMonitorLeft _:
        return {"FocusColumnOrMonitorLeft": {}};
      case ActionFocusColumnOrMonitorRight _:
        return {"FocusColumnOrMonitorRight": {}};
      case ActionFocusWindowDown _:
        return {"FocusWindowDown": {}};
      case ActionFocusWindowUp _:
        return {"FocusWindowUp": {}};
      case ActionFocusWindowDownOrColumnLeft _:
        return {"FocusWindowDownOrColumnLeft": {}};
      case ActionFocusWindowDownOrColumnRight _:
        return {"FocusWindowDownOrColumnRight": {}};
      case ActionFocusWindowUpOrColumnLeft _:
        return {"FocusWindowUpOrColumnLeft": {}};
      case ActionFocusWindowUpOrColumnRight _:
        return {"FocusWindowUpOrColumnRight": {}};
      case ActionFocusWindowOrWorkspaceDown _:
        return {"FocusWindowOrWorkspaceDown": {}};
      case ActionFocusWindowOrWorkspaceUp _:
        return {"FocusWindowOrWorkspaceUp": {}};
      case ActionFocusWindowTop _:
        return {"FocusWindowTop": {}};
      case ActionFocusWindowBottom _:
        return {"FocusWindowBottom": {}};
      case ActionFocusWindowDownOrTop _:
        return {"FocusWindowDownOrTop": {}};
      case ActionFocusWindowUpOrBottom _:
        return {"FocusWindowUpOrBottom": {}};
      case ActionMoveColumnLeft _:
        return {"MoveColumnLeft": {}};
      case ActionMoveColumnRight _:
        return {"MoveColumnRight": {}};
      case ActionMoveColumnToFirst _:
        return {"MoveColumnToFirst": {}};
      case ActionMoveColumnToLast _:
        return {"MoveColumnToLast": {}};
      case ActionMoveColumnLeftOrToMonitorLeft _:
        return {"MoveColumnLeftOrToMonitorLeft": {}};
      case ActionMoveColumnRightOrToMonitorRight _:
        return {"MoveColumnRightOrToMonitorRight": {}};
      case ActionMoveColumnToIndex v:
        return {
          "MoveColumnToIndex": {"index": v.index},
        };
      case ActionMoveWindowDown _:
        return {"MoveWindowDown": {}};
      case ActionMoveWindowUp _:
        return {"MoveWindowUp": {}};
      case ActionMoveWindowDownOrToWorkspaceDown _:
        return {"MoveWindowDownOrToWorkspaceDown": {}};
      case ActionMoveWindowUpOrToWorkspaceUp _:
        return {"MoveWindowUpOrToWorkspaceUp": {}};
      case ActionConsumeOrExpelWindowLeft v:
        return {
          "ConsumeOrExpelWindowLeft": {"id": v.id},
        };
      case ActionConsumeOrExpelWindowRight v:
        return {
          "ConsumeOrExpelWindowRight": {"id": v.id},
        };
      case ActionConsumeWindowIntoColumn _:
        return {"ConsumeWindowIntoColumn": {}};
      case ActionExpelWindowFromColumn _:
        return {"ExpelWindowFromColumn": {}};
      case ActionSwapWindowRight _:
        return {"SwapWindowRight": {}};
      case ActionSwapWindowLeft _:
        return {"SwapWindowLeft": {}};
      case ActionToggleColumnTabbedDisplay _:
        return {"ToggleColumnTabbedDisplay": {}};
      case ActionSetColumnDisplay v:
        return {
          "SetColumnDisplay": {"display": v.display.toJson()},
        };
      case ActionCenterColumn _:
        return {"CenterColumn": {}};
      case ActionCenterWindow v:
        return {
          "CenterWindow": {"id": v.id},
        };
      case ActionCenterVisibleColumns _:
        return {"CenterVisibleColumns": {}};
      case ActionFocusWorkspaceDown _:
        return {"FocusWorkspaceDown": {}};
      case ActionFocusWorkspaceUp _:
        return {"FocusWorkspaceUp": {}};
      case ActionFocusWorkspace v:
        return {
          "FocusWorkspace": {"reference": v.reference.toJson()},
        };
      case ActionFocusWorkspacePrevious _:
        return {"FocusWorkspacePrevious": {}};
      case ActionMoveWindowToWorkspaceDown v:
        return {
          "MoveWindowToWorkspaceDown": {"focus": v.focus},
        };
      case ActionMoveWindowToWorkspaceUp v:
        return {
          "MoveWindowToWorkspaceUp": {"focus": v.focus},
        };
      case ActionMoveWindowToWorkspace v:
        return {
          "MoveWindowToWorkspace": {
            "focus": v.focus,
            "reference": v.reference.toJson(),
            "windowId": v.windowId,
          },
        };
      case ActionMoveColumnToWorkspaceDown _:
        return {"MoveColumnToWorkspaceDown": {}};
      case ActionMoveColumnToWorkspaceUp v:
        return {
          "MoveColumnToWorkspaceUp": {"focus": v.focus},
        };
      case ActionMoveColumnToWorkspace v:
        return {
          "MoveColumnToWorkspace": {"reference": v.reference.toJson(), "focus": v.focus},
        };
      case ActionMoveWorkspaceDown _:
        return {"MoveWorkspaceDown": {}};
      case ActionMoveWorkspaceUp _:
        return {"MoveWorkspaceUp": {}};
      case ActionMoveWorkspaceToIndex v:
        return {
          "MoveWorkspaceToIndex": {"index": v.index},
        };
      case ActionSetWorkspaceName v:
        return {
          "SetWorkspaceName": {"name": v.name, "workspace": v.workspace},
        };
      case ActionUnsetWorkspaceName v:
        return {
          "UnsetWorkspaceName": {"reference": v.reference?.toJson()},
        };
      case ActionFocusMonitorLeft _:
        return {"FocusMonitorLeft": {}};
      case ActionFocusMonitorRight _:
        return {"FocusMonitorRight": {}};
      case ActionFocusMonitorDown _:
        return {"FocusMonitorDown": {}};
      case ActionFocusMonitorUp _:
        return {"FocusMonitorUp": {}};
      case ActionFocusMonitorPrevious _:
        return {"FocusMonitorPrevious": {}};
      case ActionFocusMonitorNext _:
        return {"FocusMonitorNext": {}};
      case ActionFocusMonitor v:
        return {
          "FocusMonitor": {"output": v.output},
        };
      case ActionMoveWindowToMonitorLeft _:
        return {"MoveWindowToMonitorLeft": {}};
      case ActionMoveWindowToMonitorRight _:
        return {"MoveWindowToMonitorRight": {}};
      case ActionMoveWindowToMonitorDown _:
        return {"MoveWindowToMonitorDown": {}};
      case ActionMoveWindowToMonitorUp _:
        return {"MoveWindowToMonitorUp": {}};
      case ActionMoveWindowToMonitorPrevious _:
        return {"MoveWindowToMonitorPrevious": {}};
      case ActionMoveWindowToMonitorNext _:
        return {"MoveWindowToMonitorNext": {}};
      case ActionMoveWindowToMonitor v:
        return {
          "MoveWindowToMonitor": {"id": v.id, "output": v.output},
        };
      case ActionMoveColumnToMonitorLeft _:
        return {"MoveColumnToMonitorLeft": {}};
      case ActionMoveColumnToMonitorRight _:
        return {"MoveColumnToMonitorRight": {}};
      case ActionMoveColumnToMonitorDown _:
        return {"MoveColumnToMonitorDown": {}};
      case ActionMoveColumnToMonitorUp _:
        return {"MoveColumnToMonitorUp": {}};
      case ActionMoveColumnToMonitorPrevious _:
        return {"MoveColumnToMonitorPrevious": {}};
      case ActionMoveColumnToMonitorNext _:
        return {"MoveColumnToMonitorNext": {}};
      case ActionMoveColumnToMonitor v:
        return {
          "MoveColumnToMonitor": {"output": v.output},
        };
      case ActionSetWindowWidth v:
        return {
          "SetWindowWidth": {"id": v.id, "change": v.change.toJson()},
        };
      case ActionSetWindowHeight v:
        return {
          "SetWindowHeight": {"id": v.id, "change": v.change.toJson()},
        };
      case ActionResetWindowHeight v:
        return {
          "ResetWindowHeight": {"id": v.id},
        };
      case ActionSwitchPresetColumnWidth _:
        return {"SwitchPresetColumnWidth": {}};
      case ActionSwitchPresetColumnWidthBack _:
        return {"SwitchPresetColumnWidthBack": {}};
      case ActionSwitchPresetWindowWidth v:
        return {
          "SwitchPresetWindowWidth": {"id": v.id},
        };
      case ActionSwitchPresetWindowWidthBack v:
        return {
          "SwitchPresetWindowWidthBack": {"id": v.id},
        };
      case ActionSwitchPresetWindowHeight v:
        return {
          "SwitchPresetWindowHeight": {"id": v.id},
        };
      case ActionSwitchPresetWindowHeightBack v:
        return {
          "SwitchPresetWindowHeightBack": {"id": v.id},
        };
      case ActionMaximizeColumn _:
        return {"MaximizeColumn": {}};
      case ActionMaximizeWindowToEdges v:
        return {
          "MaximizeWindowToEdges": {"id": v.id},
        };
      case ActionSetColumnWidth v:
        return {
          "SetColumnWidth": {"change": v.change.toJson()},
        };
      case ActionExpandColumnToAvailableWidth _:
        return {"ExpandColumnToAvailableWidth": {}};
      case ActionSwitchLayout v:
        return {
          "SwitchLayout": {"layout": v.layout.toJson()},
        };
      case ActionShowHotkeyOverlay _:
        return {"ShowHotkeyOverlay": {}};
      case ActionMoveWorkspaceToMonitorLeft _:
        return {"MoveWorkspaceToMonitorLeft": {}};
      case ActionMoveWorkspaceToMonitorRight _:
        return {"MoveWorkspaceToMonitorRight": {}};
      case ActionMoveWorkspaceToMonitorDown _:
        return {"MoveWorkspaceToMonitorDown": {}};
      case ActionMoveWorkspaceToMonitorUp _:
        return {"MoveWorkspaceToMonitorUp": {}};
      case ActionMoveWorkspaceToMonitorPrevious _:
        return {"MoveWorkspaceToMonitorPrevious": {}};
      case ActionMoveWorkspaceToMonitorNext _:
        return {"MoveWorkspaceToMonitorNext": {}};
      case ActionMoveWorkspaceToMonitor v:
        return {
          "MoveWorkspaceToMonitor": {"output": v.output, "reference": v.reference?.toJson()},
        };
      case ActionToggleDebugTint _:
        return {"ToggleDebugTint": {}};
      case ActionDebugToggleOpaqueRegions _:
        return {"DebugToggleOpaqueRegions": {}};
      case ActionDebugToggleDamage _:
        return {"DebugToggleDamage": {}};
      case ActionToggleWindowFloating v:
        return {
          "ToggleWindowFloating": {"id": v.id},
        };
      case ActionMoveWindowToFloating v:
        return {
          "MoveWindowToFloating": {"id": v.id},
        };
      case ActionMoveWindowToTiling v:
        return {
          "MoveWindowToTiling": {"id": v.id},
        };
      case ActionFocusFloating _:
        return {"FocusFloating": {}};
      case ActionFocusTiling _:
        return {"FocusTiling": {}};
      case ActionSwitchFocusBetweenFloatingAndTiling _:
        return {"SwitchFocusBetweenFloatingAndTiling": {}};
      case ActionMoveFloatingWindow v:
        return {
          "MoveFloatingWindow": {"id": v.id, "x": v.x.toJson(), "y": v.y.toJson()},
        };
      case ActionToggleWindowRuleOpacity v:
        return {
          "ToggleWindowRuleOpacity": {"id": v.id},
        };
      case ActionSetDynamicCastWindow v:
        return {
          "SetDynamicCastWindow": {"id": v.id},
        };
      case ActionSetDynamicCastMonitor v:
        return {
          "SetDynamicCastMonitor": {"output": v.output},
        };
      case ActionClearDynamicCastTarget _:
        return {"ClearDynamicCastTarget": {}};
      case ActionToggleOverview _:
        return {"ToggleOverview": {}};
      case ActionOpenOverview _:
        return {"OpenOverview": {}};
      case ActionCloseOverview _:
        return {"CloseOverview": {}};
      case ActionToggleWindowUrgent v:
        return {
          "ToggleWindowUrgent": {"id": v.id},
        };
      case ActionSetWindowUrgent v:
        return {
          "SetWindowUrgent": {"id": v.id},
        };
      case ActionUnsetWindowUrgent v:
        return {
          "UnsetWindowUrgent": {"id": v.id},
        };
      case ActionLoadConfigFile _:
        return {"LoadConfigFile": {}};
    }
  }
}

/// Exit niri.
class ActionQuit extends Action {
  /// Skip the "Press Enter to confirm" prompt.
  final bool skipConfirmation;

  const ActionQuit(this.skipConfirmation);
}

/// Power off all monitors via DPMS.
class ActionPowerOffMonitors extends Action {
  const ActionPowerOffMonitors();
}

/// Power on all monitors via DPMS.
class ActionPowerOnMonitors extends Action {
  const ActionPowerOnMonitors();
}

/// Spawn a command.
class ActionSpawn extends Action {
  /// Command to spawn.
  final List<String> command;

  const ActionSpawn(this.command);
}

/// Spawn a command through the shell.
class ActionSpawnSh extends Action {
  /// Command to run.
  final String command;

  const ActionSpawnSh(this.command);
}

/// Do a screen transition.
class ActionDoScreenTransition extends Action {
  /// Delay in milliseconds for the screen to freeze before starting the transition.
  final int? delayMs;

  const ActionDoScreenTransition(this.delayMs);
}

// /// Open the screenshot UI.
class ActionScreenshot extends Action {
  /// Whether to show the mouse pointer by default in the screenshot UI.
  final bool showPointer;

  /// Path to save the screenshot to.
  ///
  /// The path must be absolute, otherwise an error is returned.
  ///
  /// If `None`, the screenshot is saved according to the `screenshot-path` config setting.
  final String? path;

  const ActionScreenshot({required this.showPointer, required this.path});
}

/// Screenshot the focused screen.
class ActionScreenshotScreen extends Action {
  /// Write the screenshot to disk in addition to putting it in your clipboard.
  ///
  /// The screenshot is saved according to the `screenshot-path` config setting.
  final bool writeToDisk;

  /// Whether to include the mouse pointer in the screenshot.
  final bool showPointer;

  /// Path to save the screenshot to.
  ///
  /// The path must be absolute, otherwise an error is returned.
  ///
  /// If `None`, the screenshot is saved according to the `screenshot-path` config setting.
  final String? path;

  const ActionScreenshotScreen({
    required this.writeToDisk,
    required this.showPointer,
    required this.path,
  });
}

/// Screenshot a window.
class ActionScreenshotWindow extends Action {
  /// Id of the window to screenshot.
  ///
  /// If `None`, uses the focused window.
  final int? id;

  /// Write the screenshot to disk in addition to putting it in your clipboard.
  ///
  /// The screenshot is saved according to the `screenshot-path` config setting.
  final bool writeToDisk;

  /// Path to save the screenshot to.
  ///
  /// The path must be absolute, otherwise an error is returned.
  ///
  /// If `None`, the screenshot is saved according to the `screenshot-path` config setting.
  final String? path;

  const ActionScreenshotWindow({required this.id, required this.writeToDisk, required this.path});
}

/// Enable or disable the keyboard shortcuts inhibitor (if any) for the focused surface.
class ActionToggleKeyboardShortcutsInhibit extends Action {
  const ActionToggleKeyboardShortcutsInhibit();
}

/// Close a window.
class ActionCloseWindow extends Action {
  /// Id of the window to close.
  ///
  /// If `None`, uses the focused window.
  final int? id;

  const ActionCloseWindow(this.id);
}

/// Toggle fullscreen on a window.
class ActionFullscreenWindow extends Action {
  /// Id of the window to toggle fullscreen of.
  ///
  /// If `None`, uses the focused window.
  final int? id;

  const ActionFullscreenWindow(this.id);
}

/// Toggle windowed (fake) fullscreen on a window.
class ActionToggleWindowedFullscreen extends Action {
  /// Id of the window to toggle windowed fullscreen of.
  ///
  /// If `None`, uses the focused window.
  final int? id;

  const ActionToggleWindowedFullscreen(this.id);
}

/// Focus a window by id.
class ActionFocusWindow extends Action {
  /// Id of the window to focus.
  final int id;

  const ActionFocusWindow(this.id);
}

/// Focus a window in the focused column by index.
class ActionFocusWindowInColumn extends Action {
  /// Index of the window in the column.
  ///
  /// The index starts from 1 for the topmost window.
  final int index;

  const ActionFocusWindowInColumn(this.index);
}

/// Focus the previously focused window.
class ActionFocusWindowPrevious extends Action {
  const ActionFocusWindowPrevious();
}

/// Focus the column to the left.
class ActionFocusColumnLeft extends Action {
  const ActionFocusColumnLeft();
}

/// Focus the column to the right.
class ActionFocusColumnRight extends Action {
  const ActionFocusColumnRight();
}

/// Focus the first column.
class ActionFocusColumnFirst extends Action {
  const ActionFocusColumnFirst();
}

/// Focus the last column.
class ActionFocusColumnLast extends Action {
  const ActionFocusColumnLast();
}

/// Focus the next column to the right, looping if at end.
class ActionFocusColumnRightOrFirst extends Action {
  const ActionFocusColumnRightOrFirst();
}

/// Focus the next column to the left, looping if at start.
class ActionFocusColumnLeftOrLast extends Action {
  const ActionFocusColumnLeftOrLast();
}

/// Focus a column by index.
class ActionFocusColumn extends Action {
  /// Index of the column to focus.
  ///
  /// The index starts from 1 for the first column.
  final int index;

  const ActionFocusColumn(this.index);
}

/// Focus the window or the monitor above.
class ActionFocusWindowOrMonitorUp extends Action {
  const ActionFocusWindowOrMonitorUp();
}

/// Focus the window or the monitor below.
class ActionFocusWindowOrMonitorDown extends Action {
  const ActionFocusWindowOrMonitorDown();
}

/// Focus the column or the monitor to the left.
class ActionFocusColumnOrMonitorLeft extends Action {
  const ActionFocusColumnOrMonitorLeft();
}

/// Focus the column or the monitor to the right.
class ActionFocusColumnOrMonitorRight extends Action {
  const ActionFocusColumnOrMonitorRight();
}

/// Focus the window below.
class ActionFocusWindowDown extends Action {
  const ActionFocusWindowDown();
}

/// Focus the window above.
class ActionFocusWindowUp extends Action {
  const ActionFocusWindowUp();
}

/// Focus the window below or the column to the left.
class ActionFocusWindowDownOrColumnLeft extends Action {
  const ActionFocusWindowDownOrColumnLeft();
}

/// Focus the window below or the column to the right.
class ActionFocusWindowDownOrColumnRight extends Action {
  const ActionFocusWindowDownOrColumnRight();
}

/// Focus the window above or the column to the left.
class ActionFocusWindowUpOrColumnLeft extends Action {
  const ActionFocusWindowUpOrColumnLeft();
}

/// Focus the window above or the column to the right.
class ActionFocusWindowUpOrColumnRight extends Action {
  const ActionFocusWindowUpOrColumnRight();
}

/// Focus the window or the workspace below.
class ActionFocusWindowOrWorkspaceDown extends Action {
  const ActionFocusWindowOrWorkspaceDown();
}

/// Focus the window or the workspace above.
class ActionFocusWindowOrWorkspaceUp extends Action {
  const ActionFocusWindowOrWorkspaceUp();
}

/// Focus the topmost window.
class ActionFocusWindowTop extends Action {
  const ActionFocusWindowTop();
}

/// Focus the bottommost window.
class ActionFocusWindowBottom extends Action {
  const ActionFocusWindowBottom();
}

/// Focus the window below or the topmost window.
class ActionFocusWindowDownOrTop extends Action {
  const ActionFocusWindowDownOrTop();
}

/// Focus the window above or the bottommost window.
class ActionFocusWindowUpOrBottom extends Action {
  const ActionFocusWindowUpOrBottom();
}

/// Move the focused column to the left.
class ActionMoveColumnLeft extends Action {
  const ActionMoveColumnLeft();
}

/// Move the focused column to the right.
class ActionMoveColumnRight extends Action {
  const ActionMoveColumnRight();
}

/// Move the focused column to the start of the workspace.
class ActionMoveColumnToFirst extends Action {
  const ActionMoveColumnToFirst();
}

/// Move the focused column to the end of the workspace.
class ActionMoveColumnToLast extends Action {
  const ActionMoveColumnToLast();
}

/// Move the focused column to the left or to the monitor to the left.
class ActionMoveColumnLeftOrToMonitorLeft extends Action {
  const ActionMoveColumnLeftOrToMonitorLeft();
}

/// Move the focused column to the right or to the monitor to the right.
class ActionMoveColumnRightOrToMonitorRight extends Action {
  const ActionMoveColumnRightOrToMonitorRight();
}

/// Move the focused column to a specific index on its workspace.
class ActionMoveColumnToIndex extends Action {
  /// New index for the column.
  ///
  /// The index starts from 1 for the first column.
  final int index;

  const ActionMoveColumnToIndex(this.index);
}

/// Move the focused window down in a column.
class ActionMoveWindowDown extends Action {
  const ActionMoveWindowDown();
}

/// Move the focused window up in a column.
class ActionMoveWindowUp extends Action {
  const ActionMoveWindowUp();
}

/// Move the focused window down in a column or to the workspace below.
class ActionMoveWindowDownOrToWorkspaceDown extends Action {
  const ActionMoveWindowDownOrToWorkspaceDown();
}

/// Move the focused window up in a column or to the workspace above.
class ActionMoveWindowUpOrToWorkspaceUp extends Action {
  const ActionMoveWindowUpOrToWorkspaceUp();
}

/// Consume or expel a window left.
class ActionConsumeOrExpelWindowLeft extends Action {
  /// Id of the window to consume or expel.
  ///
  /// If `None`, uses the focused window.
  final int? id;

  const ActionConsumeOrExpelWindowLeft(this.id);
}

/// Consume or expel a window right.
class ActionConsumeOrExpelWindowRight extends Action {
  /// Id of the window to consume or expel.
  ///
  /// If `None`, uses the focused window.
  final int? id;

  const ActionConsumeOrExpelWindowRight(this.id);
}

/// Consume the window to the right into the focused column.
class ActionConsumeWindowIntoColumn extends Action {
  const ActionConsumeWindowIntoColumn();
}

/// Expel the focused window from the column.
class ActionExpelWindowFromColumn extends Action {
  const ActionExpelWindowFromColumn();
}

/// Swap focused window with one to the right.
class ActionSwapWindowRight extends Action {
  const ActionSwapWindowRight();
}

/// Swap focused window with one to the left.
class ActionSwapWindowLeft extends Action {
  const ActionSwapWindowLeft();
}

/// Toggle the focused column between normal and tabbed display.
class ActionToggleColumnTabbedDisplay extends Action {
  const ActionToggleColumnTabbedDisplay();
}

/// Set the display mode of the focused column.
class ActionSetColumnDisplay extends Action {
  /// Display mode to set.
  final ColumnDisplay display;

  const ActionSetColumnDisplay(this.display);
}

/// Center the focused column on the screen.
class ActionCenterColumn extends Action {
  const ActionCenterColumn();
}

/// Center a window on the screen.
class ActionCenterWindow extends Action {
  /// Id of the window to center.
  ///
  /// If `None`, uses the focused window.
  final int? id;
  const ActionCenterWindow(this.id);
}

/// Center all fully visible columns on the screen.
class ActionCenterVisibleColumns extends Action {
  const ActionCenterVisibleColumns();
}

/// Focus the workspace below.
class ActionFocusWorkspaceDown extends Action {
  const ActionFocusWorkspaceDown();
}

/// Focus the workspace above.
class ActionFocusWorkspaceUp extends Action {
  const ActionFocusWorkspaceUp();
}

/// Focus a workspace by reference (index or name).
class ActionFocusWorkspace extends Action {
  /// Reference (index or name) of the workspace to focus.
  final WorkspaceReferenceArg reference;

  const ActionFocusWorkspace(this.reference);
}

/// Focus the previous workspace.
class ActionFocusWorkspacePrevious extends Action {
  const ActionFocusWorkspacePrevious();
}

/// Move the focused window to the workspace below.
class ActionMoveWindowToWorkspaceDown extends Action {
  /// Whether the focus should follow the target workspace.
  ///
  /// If `true` (the default), the focus will follow the window to the new workspace. If
  /// `false`, the focus will remain on the original workspace.
  final bool focus;

  const ActionMoveWindowToWorkspaceDown(this.focus);
}

/// Move the focused window to the workspace above.
class ActionMoveWindowToWorkspaceUp extends Action {
  /// Whether the focus should follow the target workspace.
  ///
  /// If `true` (the default), the focus will follow the window to the new workspace. If
  /// `false`, the focus will remain on the original workspace.
  final bool focus;

  const ActionMoveWindowToWorkspaceUp(this.focus);
}

/// Move a window to a workspace.
class ActionMoveWindowToWorkspace extends Action {
  /// Id of the window to move.
  ///
  /// If `None`, uses the focused window.
  final int? windowId;

  /// Reference (index or name) of the workspace to move the window to.
  final WorkspaceReferenceArg reference;

  /// Whether the focus should follow the moved window.
  ///
  /// If `true` (the default) and the window to move is focused, the focus will follow the
  /// window to the new workspace. If `false`, the focus will remain on the original
  /// workspace.
  final bool focus;

  const ActionMoveWindowToWorkspace({
    required this.windowId,
    required this.reference,
    required this.focus,
  });
}

/// Move the focused column to the workspace below.
class ActionMoveColumnToWorkspaceDown extends Action {
  /// Whether the focus should follow the target workspace.
  ///
  /// If `true` (the default), the focus will follow the column to the new workspace. If
  /// `false`, the focus will remain on the original workspace.
  final bool focus;

  const ActionMoveColumnToWorkspaceDown(this.focus);
}

/// Move the focused column to the workspace above.
class ActionMoveColumnToWorkspaceUp extends Action {
  /// Whether the focus should follow the target workspace.
  ///
  /// If `true` (the default), the focus will follow the column to the new workspace. If
  /// `false`, the focus will remain on the original workspace.
  final bool focus;

  const ActionMoveColumnToWorkspaceUp(this.focus);
}

/// Move the focused column to a workspace by reference (index or name).
class ActionMoveColumnToWorkspace extends Action {
  /// Reference (index or name) of the workspace to move the column to.
  final WorkspaceReferenceArg reference;

  /// Whether the focus should follow the target workspace.
  ///
  /// If `true` (the default), the focus will follow the column to the new workspace. If
  /// `false`, the focus will remain on the original workspace.
  final bool focus;

  const ActionMoveColumnToWorkspace({required this.reference, required this.focus});
}

/// Move the focused workspace down.
class ActionMoveWorkspaceDown extends Action {
  const ActionMoveWorkspaceDown();
}

/// Move the focused workspace up.
class ActionMoveWorkspaceUp extends Action {
  const ActionMoveWorkspaceUp();
}

/// Move a workspace to a specific index on its monitor.
class ActionMoveWorkspaceToIndex extends Action {
  /// New index for the workspace.
  final int index;

  /// Reference (index or name) of the workspace to move.
  ///
  /// If `None`, uses the focused workspace.
  final WorkspaceReferenceArg? reference;

  const ActionMoveWorkspaceToIndex({required this.index, required this.reference});
}

/// Set the name of a workspace.
class ActionSetWorkspaceName extends Action {
  /// New name for the workspace.
  final String name;

  /// Reference (index or name) of the workspace to name.
  ///
  /// If `None`, uses the focused workspace.
  final WorkspaceReferenceArg? workspace;

  const ActionSetWorkspaceName({required this.name, required this.workspace});
}

/// Unset the name of a workspace.
class ActionUnsetWorkspaceName extends Action {
  /// Reference (index or name) of the workspace to unname.
  ///
  /// If `None`, uses the focused workspace.
  final WorkspaceReferenceArg? reference;

  const ActionUnsetWorkspaceName(this.reference);
}

/// Focus the monitor to the left.
class ActionFocusMonitorLeft extends Action {
  const ActionFocusMonitorLeft();
}

/// Focus the monitor to the right.
class ActionFocusMonitorRight extends Action {
  const ActionFocusMonitorRight();
}

/// Focus the monitor below.
class ActionFocusMonitorDown extends Action {
  const ActionFocusMonitorDown();
}

/// Focus the monitor above.
class ActionFocusMonitorUp extends Action {
  const ActionFocusMonitorUp();
}

/// Focus the previous monitor.
class ActionFocusMonitorPrevious extends Action {
  const ActionFocusMonitorPrevious();
}

/// Focus the next monitor.
class ActionFocusMonitorNext extends Action {
  const ActionFocusMonitorNext();
}

/// Focus a monitor by name.
class ActionFocusMonitor extends Action {
  /// Name of the output to focus.
  final String output;

  const ActionFocusMonitor(this.output);
}

/// Move the focused window to the monitor to the left.
class ActionMoveWindowToMonitorLeft extends Action {
  const ActionMoveWindowToMonitorLeft();
}

/// Move the focused window to the monitor to the right.
class ActionMoveWindowToMonitorRight extends Action {
  const ActionMoveWindowToMonitorRight();
}

/// Move the focused window to the monitor below.
class ActionMoveWindowToMonitorDown extends Action {
  const ActionMoveWindowToMonitorDown();
}

/// Move the focused window to the monitor above.
class ActionMoveWindowToMonitorUp extends Action {
  const ActionMoveWindowToMonitorUp();
}

/// Move the focused window to the previous monitor.
class ActionMoveWindowToMonitorPrevious extends Action {
  const ActionMoveWindowToMonitorPrevious();
}

/// Move the focused window to the next monitor.
class ActionMoveWindowToMonitorNext extends Action {
  const ActionMoveWindowToMonitorNext();
}

/// Move a window to a specific monitor.
class ActionMoveWindowToMonitor extends Action {
  /// Id of the window to move.
  ///
  /// If `None`, uses the focused window.
  final int? id;

  /// The target output name.
  final String output;

  const ActionMoveWindowToMonitor({required this.id, required this.output});
}

/// Move the focused column to the monitor to the left.
class ActionMoveColumnToMonitorLeft extends Action {
  const ActionMoveColumnToMonitorLeft();
}

/// Move the focused column to the monitor to the right.
class ActionMoveColumnToMonitorRight extends Action {
  const ActionMoveColumnToMonitorRight();
}

/// Move the focused column to the monitor below.
class ActionMoveColumnToMonitorDown extends Action {
  const ActionMoveColumnToMonitorDown();
}

/// Move the focused column to the monitor above.
class ActionMoveColumnToMonitorUp extends Action {
  const ActionMoveColumnToMonitorUp();
}

/// Move the focused column to the previous monitor.
class ActionMoveColumnToMonitorPrevious extends Action {
  const ActionMoveColumnToMonitorPrevious();
}

/// Move the focused column to the next monitor.
class ActionMoveColumnToMonitorNext extends Action {
  const ActionMoveColumnToMonitorNext();
}

/// Move the focused column to a specific monitor.
class ActionMoveColumnToMonitor extends Action {
  /// The target output name.
  final String output;

  const ActionMoveColumnToMonitor(this.output);
}

/// Change the width of a window.
class ActionSetWindowWidth extends Action {
  /// Id of the window whose width to set.
  ///
  /// If `None`, uses the focused window.
  final int? id;

  /// How to change the width.
  final SizeChange change;
  const ActionSetWindowWidth({required this.id, required this.change});
}

/// Change the height of a window.
class ActionSetWindowHeight extends Action {
  /// Id of the window whose height to set.
  ///
  /// If `None`, uses the focused window.
  final int? id;

  /// How to change the height.
  final SizeChange change;

  const ActionSetWindowHeight({required this.id, required this.change});
}

/// Reset the height of a window back to automatic.
class ActionResetWindowHeight extends Action {
  /// Id of the window whose height to reset.
  ///
  /// If `None`, uses the focused window.
  final int? id;

  const ActionResetWindowHeight(this.id);
}

/// Switch between preset column widths.
class ActionSwitchPresetColumnWidth extends Action {
  const ActionSwitchPresetColumnWidth();
}

/// Switch between preset column widths backwards.
class ActionSwitchPresetColumnWidthBack extends Action {
  const ActionSwitchPresetColumnWidthBack();
}

/// Switch between preset window widths.
class ActionSwitchPresetWindowWidth extends Action {
  /// Id of the window whose width to switch.
  ///
  /// If `None`, uses the focused window.
  final int? id;

  const ActionSwitchPresetWindowWidth(this.id);
}

/// Switch between preset window widths backwards.
class ActionSwitchPresetWindowWidthBack extends Action {
  /// Id of the window whose width to switch.
  ///
  /// If `None`, uses the focused window.
  final int? id;

  const ActionSwitchPresetWindowWidthBack(this.id);
}

/// Switch between preset window heights.
class ActionSwitchPresetWindowHeight extends Action {
  /// Id of the window whose height to switch.
  ///
  /// If `None`, uses the focused window.
  final int? id;

  const ActionSwitchPresetWindowHeight(this.id);
}

/// Switch between preset window heights backwards.
class ActionSwitchPresetWindowHeightBack extends Action {
  /// Id of the window whose height to switch.
  ///
  /// If `None`, uses the focused window.
  final int? id;

  const ActionSwitchPresetWindowHeightBack(this.id);
}

/// Toggle the maximized state of the focused column.
class ActionMaximizeColumn extends Action {
  const ActionMaximizeColumn();
}

/// Toggle the maximized-to-edges state of the focused window.
class ActionMaximizeWindowToEdges extends Action {
  /// Id of the window to maximize.
  ///
  /// If `None`, uses the focused window.
  final int? id;
  const ActionMaximizeWindowToEdges(this.id);
}

/// Change the width of the focused column.
class ActionSetColumnWidth extends Action {
  /// How to change the width.
  final SizeChange change;

  const ActionSetColumnWidth(this.change);
}

/// Expand the focused column to space not taken up by other fully visible columns.
class ActionExpandColumnToAvailableWidth extends Action {
  const ActionExpandColumnToAvailableWidth();
}

/// Switch between keyboard layouts.
class ActionSwitchLayout extends Action {
  /// Layout to switch to.
  final LayoutSwitchTarget layout;

  const ActionSwitchLayout(this.layout);
}

/// Show the hotkey overlay.
class ActionShowHotkeyOverlay extends Action {
  const ActionShowHotkeyOverlay();
}

/// Move the focused workspace to the monitor to the left.
class ActionMoveWorkspaceToMonitorLeft extends Action {
  const ActionMoveWorkspaceToMonitorLeft();
}

/// Move the focused workspace to the monitor to the right.
class ActionMoveWorkspaceToMonitorRight extends Action {
  const ActionMoveWorkspaceToMonitorRight();
}

/// Move the focused workspace to the monitor below.
class ActionMoveWorkspaceToMonitorDown extends Action {
  const ActionMoveWorkspaceToMonitorDown();
}

/// Move the focused workspace to the monitor above.
class ActionMoveWorkspaceToMonitorUp extends Action {
  const ActionMoveWorkspaceToMonitorUp();
}

/// Move the focused workspace to the previous monitor.
class ActionMoveWorkspaceToMonitorPrevious extends Action {
  const ActionMoveWorkspaceToMonitorPrevious();
}

/// Move the focused workspace to the next monitor.
class ActionMoveWorkspaceToMonitorNext extends Action {
  const ActionMoveWorkspaceToMonitorNext();
}

/// Move a workspace to a specific monitor.
class ActionMoveWorkspaceToMonitor extends Action {
  /// The target output name.
  final String output;

  /// Reference (index or name) of the workspace to move.
  ///
  /// If `None`, uses the focused workspace.
  final WorkspaceReferenceArg? reference;

  const ActionMoveWorkspaceToMonitor({required this.output, required this.reference});
}

/// Toggle a debug tint on windows.
class ActionToggleDebugTint extends Action {
  const ActionToggleDebugTint();
}

/// Toggle visualization of render element opaque regions.
class ActionDebugToggleOpaqueRegions extends Action {
  const ActionDebugToggleOpaqueRegions();
}

/// Toggle visualization of output damage.
class ActionDebugToggleDamage extends Action {
  const ActionDebugToggleDamage();
}

/// Move the focused window between the floating and the tiling layout.
class ActionToggleWindowFloating extends Action {
  /// Id of the window to move.
  ///
  /// If `None`, uses the focused window.
  final int? id;

  const ActionToggleWindowFloating(this.id);
}

/// Move the focused window to the floating layout.
class ActionMoveWindowToFloating extends Action {
  /// Id of the window to move.
  ///
  /// If `None`, uses the focused window.
  final int? id;

  const ActionMoveWindowToFloating(this.id);
}

/// Move the focused window to the tiling layout.
class ActionMoveWindowToTiling extends Action {
  /// Id of the window to move.
  ///
  /// If `None`, uses the focused window.
  final int? id;

  const ActionMoveWindowToTiling(this.id);
}

/// Switches focus to the floating layout.
class ActionFocusFloating extends Action {
  const ActionFocusFloating();
}

/// Switches focus to the tiling layout.
class ActionFocusTiling extends Action {
  const ActionFocusTiling();
}

/// Toggles the focus between the floating and the tiling layout.
class ActionSwitchFocusBetweenFloatingAndTiling extends Action {
  const ActionSwitchFocusBetweenFloatingAndTiling();
}

/// Move a floating window on screen.
class ActionMoveFloatingWindow extends Action {
  /// Id of the window to move.
  ///
  /// If `None`, uses the focused window.
  final int? id;

  /// How to change the X position.
  final PositionChange x;

  /// How to change the Y position.
  final PositionChange y;

  const ActionMoveFloatingWindow({required this.id, required this.x, required this.y});
}

/// Toggle the opacity of a window.
class ActionToggleWindowRuleOpacity extends Action {
  /// Id of the window.
  ///
  /// If `None`, uses the focused window.
  final int? id;

  const ActionToggleWindowRuleOpacity(this.id);
}

/// Set the dynamic cast target to a window.
class ActionSetDynamicCastWindow extends Action {
  /// Id of the window to target.
  ///
  /// If `None`, uses the focused window.
  final int? id;

  const ActionSetDynamicCastWindow(this.id);
}

/// Set the dynamic cast target to a monitor.
class ActionSetDynamicCastMonitor extends Action {
  /// Name of the output to target.
  ///
  /// If `None`, uses the focused output.
  final String? output;

  const ActionSetDynamicCastMonitor(this.output);
}

/// Clear the dynamic cast target, making it show nothing.
class ActionClearDynamicCastTarget extends Action {
  const ActionClearDynamicCastTarget();
}

/// Toggle (open/close) the Overview.
class ActionToggleOverview extends Action {
  const ActionToggleOverview();
}

/// Open the Overview.
class ActionOpenOverview extends Action {
  const ActionOpenOverview();
}

/// Close the Overview.
class ActionCloseOverview extends Action {
  const ActionCloseOverview();
}

/// Toggle urgent status of a window.
class ActionToggleWindowUrgent extends Action {
  /// Id of the window to toggle urgent.
  final int id;

  const ActionToggleWindowUrgent(this.id);
}

/// Set urgent status of a window.
class ActionSetWindowUrgent extends Action {
  /// Id of the window to set urgent.
  final int id;

  const ActionSetWindowUrgent(this.id);
}

/// Unset urgent status of a window.
class ActionUnsetWindowUrgent extends Action {
  /// Id of the window to unset urgent.
  final int id;

  const ActionUnsetWindowUrgent(this.id);
}

/// Reload the config file.
///
/// Can be useful for scripts changing the config file, to avoid waiting the small duration for
/// niri's config file watcher to notice the changes.
class ActionLoadConfigFile extends Action {
  const ActionLoadConfigFile();
}

/// Change in window or column size.
sealed class SizeChange {
  const SizeChange();

  /// Set the size in logical pixels.
  const factory SizeChange.setFixed(int value) = SizeChangeSetFixed;

  /// Set the size as a proportion of the working area.
  const factory SizeChange.setProportion(double value) = SizeChangeSetProportion;

  /// Add or subtract to the current size in logical pixels.
  const factory SizeChange.adjustFixed(int value) = SizeChangeAdjustFixed;

  /// Add or subtract to the current size as a proportion of the working area.
  const factory SizeChange.adjustProportion(double value) = SizeChangeAdjustProportion;

  dynamic toJson() {
    return switch (this) {
      SizeChangeSetFixed v => {"SetFixed": v.value},
      SizeChangeSetProportion v => {"SetProportion": v.value},
      SizeChangeAdjustFixed v => {"AdjustFixed": v.value},
      SizeChangeAdjustProportion v => {"AdjustProportion": v.value},
    };
  }
}

/// Set the size in logical pixels.
class SizeChangeSetFixed extends SizeChange {
  final int value;
  const SizeChangeSetFixed(this.value);
}

/// Set the size as a proportion of the working area.
class SizeChangeSetProportion extends SizeChange {
  final double value;
  const SizeChangeSetProportion(this.value);
}

/// Add or subtract to the current size in logical pixels.
class SizeChangeAdjustFixed extends SizeChange {
  final int value;
  const SizeChangeAdjustFixed(this.value);
}

/// Add or subtract to the current size as a proportion of the working area.
class SizeChangeAdjustProportion extends SizeChange {
  final double value;
  const SizeChangeAdjustProportion(this.value);
}

/// Change in floating window position.
sealed class PositionChange {
  const PositionChange();

  /// Set the position in logical pixels.
  const factory PositionChange.setFixed(double value) = PositionChangeSetFixed;

  /// Set the position as a proportion of the working area.
  const factory PositionChange.setProportion(double value) = PositionChangeSetProportion;

  /// Add or subtract to the current position in logical pixels.
  const factory PositionChange.adjustFixed(double value) = PositionChangeAdjustFixed;

  /// Add or subtract to the current position as a proportion of the working area.
  const factory PositionChange.adjustProportion(double value) = PositionChangeAdjustProportion;

  dynamic toJson() {
    return switch (this) {
      PositionChangeSetFixed v => {"SetFixed": v.value},
      PositionChangeSetProportion v => {"SetProportion": v.value},
      PositionChangeAdjustFixed v => {"AdjustFixed": v.value},
      PositionChangeAdjustProportion v => {"AdjustProportion": v.value},
    };
  }
}

/// Set the position in logical pixels.
class PositionChangeSetFixed extends PositionChange {
  final double value;

  const PositionChangeSetFixed(this.value);
}

/// Set the position as a proportion of the working area.
class PositionChangeSetProportion extends PositionChange {
  final double value;

  const PositionChangeSetProportion(this.value);
}

/// Add or subtract to the current position in logical pixels.
class PositionChangeAdjustFixed extends PositionChange {
  final double value;

  const PositionChangeAdjustFixed(this.value);
}

/// Add or subtract to the current position as a proportion of the working area.
class PositionChangeAdjustProportion extends PositionChange {
  final double value;

  const PositionChangeAdjustProportion(this.value);
}

/// Workspace reference (id, index or name) to operate on.
sealed class WorkspaceReferenceArg {
  const WorkspaceReferenceArg();

  /// Id of the workspace.
  const factory WorkspaceReferenceArg.id(int id) = WorkspaceReferenceArgId;

  /// Index of the workspace.
  const factory WorkspaceReferenceArg.index(int index) = WorkspaceReferenceArgIndex;

  /// Name of the workspace.
  const factory WorkspaceReferenceArg.name(String name) = WorkspaceReferenceArgName;

  dynamic toJson() {
    return switch (this) {
      WorkspaceReferenceArgId v => {"Id": v.id},
      WorkspaceReferenceArgIndex v => {"Index": v.index},
      WorkspaceReferenceArgName v => {"Name": v.name},
    };
  }
}

/// Id of the workspace.
class WorkspaceReferenceArgId extends WorkspaceReferenceArg {
  final int id;
  const WorkspaceReferenceArgId(this.id);
}

/// Index of the workspace.
class WorkspaceReferenceArgIndex extends WorkspaceReferenceArg {
  final int index;
  const WorkspaceReferenceArgIndex(this.index);
}

/// Name of the workspace.
class WorkspaceReferenceArgName extends WorkspaceReferenceArg {
  final String name;
  const WorkspaceReferenceArgName(this.name);
}

/// Layout to switch to.
sealed class LayoutSwitchTarget {
  const LayoutSwitchTarget();

  /// The next configured layout.
  const factory LayoutSwitchTarget.next() = LayoutSwitchTargetNext;

  /// The previous configured layout.
  const factory LayoutSwitchTarget.prev() = LayoutSwitchTargetPrev;

  /// The specific layout by index.
  const factory LayoutSwitchTarget.index(int index) = LayoutSwitchTargetIndex;

  dynamic toJson() {
    return switch (this) {
      LayoutSwitchTargetNext _ => "Next",
      LayoutSwitchTargetPrev _ => "Prev",
      LayoutSwitchTargetIndex v => {"Index": v.index},
    };
  }
}

/// The next configured layout.
class LayoutSwitchTargetNext extends LayoutSwitchTarget {
  const LayoutSwitchTargetNext();
}

/// The previous configured layout.
class LayoutSwitchTargetPrev extends LayoutSwitchTarget {
  const LayoutSwitchTargetPrev();
}

/// The specific layout by index.
class LayoutSwitchTargetIndex extends LayoutSwitchTarget {
  final int index;

  const LayoutSwitchTargetIndex(this.index);
}

/// How windows display in a column.
enum ColumnDisplay {
  /// Windows are tiled vertically across the working area height.
  Normal,

  /// Windows are in tabs.
  Tabbed;

  dynamic toJson() {
    return name;
  }
}

/// Output actions that niri can perform.
sealed class OutputAction {
  const OutputAction();

  /// Turn off the output.
  const factory OutputAction.off() = OutputActionOff;

  /// Turn on the output.
  const factory OutputAction.on() = OutputActionOn;

  /// Set the output mode.
  const factory OutputAction.mode(
    /// Mode to set, or "auto" for automatic selection.
    ///
    /// Run `niri msg outputs` to see the available modes.
    ModeToSet mode,
  ) = OutputActionMode;

  /// Set a custom output mode.
  const factory OutputAction.customMode(
    /// Custom mode to set.
    ConfiguredMode mode,
  ) = OutputActionCustomMode;

  /// Set a custom VESA CVT modeline.
  const factory OutputAction.modeline({
    /// The rate at which pixels are drawn in MHz.
    required double clock,

    /// Horizontal active pixels.
    required int hdisplay,

    /// Horizontal sync pulse start position in pixels.
    required int hsyncStart,

    /// Horizontal sync pulse end position in pixels.
    required int hsyncEnd,

    /// Total horizontal number of pixels before resetting the horizontal drawing position to
    /// zero.
    required int htotal,

    /// Vertical active pixels.
    required int vdisplay,

    /// Vertical sync pulse start position in pixels.
    required int vsyncStart,

    /// Vertical sync pulse end position in pixels.
    required int vsyncEnd,

    /// Total vertical number of pixels before resetting the vertical drawing position to zero.
    required int vtotal,

    /// Horizontal sync polarity: "+hsync" or "-hsync".
    required HSyncPolarity hsyncPolarity,

    /// Vertical sync polarity: "+vsync" or "-vsync".
    required VSyncPolarity vsyncPolarity,
  }) = OutputActionModeline;

  /// Set the output scale.
  const factory OutputAction.scale(
    /// Scale factor to set, or "auto" for automatic selection.
    ScaleToSet scale,
  ) = OutputActionScale;

  /// Set the output transform.
  const factory OutputAction.transform(
    /// Transform to set, counter-clockwise.
    Transform transform,
  ) = OutputActionTransform;

  /// Set the output position.
  const factory OutputAction.position(
    /// Position to set, or "auto" for automatic selection.
    PositionToSet position,
  ) = OutputActionPosition;

  /// Set the variable refresh rate mode.
  const factory OutputAction.vrr(
    /// Variable refresh rate mode to set.
    VrrToSet vrr,
  ) = OutputActionVrr;

  dynamic toJson() {
    return switch (this) {
      OutputActionOff _ => "Off",
      OutputActionOn _ => "On",
      OutputActionMode v => {
        "Mode": {"mode": v.mode.toJson()},
      },
      OutputActionCustomMode v => {
        "CustomMode": {"mode": v.mode.toJson()},
      },
      OutputActionModeline v => {
        "Modeline": {
          "clock": v.clock,
          "hdisplay": v.hdisplay,
          "hsyncEnd": v.hsyncEnd,
          "hsyncPolarity": v.hsyncPolarity.toJson(),
          "hsyncStart": v.hsyncStart,
          "htotal": v.htotal,
          "vdisplay": v.vdisplay,
          "vsyncEnd": v.vsyncEnd,
          "vsyncPolarity": v.vsyncPolarity.toJson(),
          "vsyncStart": v.vsyncStart,
          "vtotal": v.vtotal,
        },
      },
      OutputActionScale v => {
        "Scale": {"scale": v.scale.toJson()},
      },
      OutputActionTransform v => {
        "Transform": {"transform": v.transform.toJson()},
      },
      OutputActionPosition v => {
        "Position": {"position": v.position.toJson()},
      },
      OutputActionVrr v => {
        "Vrr": {"vrr": v.vrr.toJson()},
      },
    };
  }
}

/// Turn off the output.
class OutputActionOff extends OutputAction {
  const OutputActionOff();
}

/// Turn on the output.
class OutputActionOn extends OutputAction {
  const OutputActionOn();
}

/// Set the output mode.
class OutputActionMode extends OutputAction {
  /// Mode to set, or "auto" for automatic selection.
  ///
  /// Run `niri msg outputs` to see the available modes.
  final ModeToSet mode;

  const OutputActionMode(this.mode);
}

/// Set a custom output mode.
class OutputActionCustomMode extends OutputAction {
  /// Custom mode to set.
  final ConfiguredMode mode;

  const OutputActionCustomMode(this.mode);
}

/// Set a custom VESA CVT modeline.
class OutputActionModeline extends OutputAction {
  /// The rate at which pixels are drawn in MHz.
  final double clock;

  /// Horizontal active pixels.
  final int hdisplay;

  /// Horizontal sync pulse start position in pixels.
  final int hsyncStart;

  /// Horizontal sync pulse end position in pixels.
  final int hsyncEnd;

  /// Total horizontal number of pixels before resetting the horizontal drawing position to
  /// zero.
  final int htotal;

  /// Vertical active pixels.
  final int vdisplay;

  /// Vertical sync pulse start position in pixels.
  final int vsyncStart;

  /// Vertical sync pulse end position in pixels.
  final int vsyncEnd;

  /// Total vertical number of pixels before resetting the vertical drawing position to zero.
  final int vtotal;

  /// Horizontal sync polarity: "+hsync" or "-hsync".
  final HSyncPolarity hsyncPolarity;

  /// Vertical sync polarity: "+vsync" or "-vsync".
  final VSyncPolarity vsyncPolarity;

  const OutputActionModeline({
    required this.clock,
    required this.hdisplay,
    required this.hsyncStart,
    required this.hsyncEnd,
    required this.htotal,
    required this.vdisplay,
    required this.vsyncStart,
    required this.vsyncEnd,
    required this.vtotal,
    required this.hsyncPolarity,
    required this.vsyncPolarity,
  });
}

/// Set the output scale.
class OutputActionScale extends OutputAction {
  /// Scale factor to set, or "auto" for automatic selection.
  final ScaleToSet scale;

  const OutputActionScale(this.scale);
}

/// Set the output transform.
class OutputActionTransform extends OutputAction {
  /// Transform to set, counter-clockwise.
  final Transform transform;

  const OutputActionTransform(this.transform);
}

/// Set the output position.
class OutputActionPosition extends OutputAction {
  /// Position to set, or "auto" for automatic selection.
  final PositionToSet position;

  const OutputActionPosition(this.position);
}

/// Set the variable refresh rate mode.
class OutputActionVrr extends OutputAction {
  /// Variable refresh rate mode to set.
  final VrrToSet vrr;

  const OutputActionVrr(this.vrr);
}

/// Output mode to set.
sealed class ModeToSet {
  const ModeToSet();

  /// Niri will pick the mode automatically.
  const factory ModeToSet.automatic() = ModeToSetAutomatic;

  /// Specific mode.
  const factory ModeToSet.specific(ConfiguredMode mode) = ModeToSetSpecific;

  dynamic toJson() {
    return switch (this) {
      ModeToSetAutomatic _ => "Automatic",
      ModeToSetSpecific v => {"Specific": v.toJson()},
    };
  }
}

/// Niri will pick the mode automatically.
class ModeToSetAutomatic extends ModeToSet {
  const ModeToSetAutomatic();
}

/// Specific mode.
class ModeToSetSpecific extends ModeToSet {
  final ConfiguredMode mode;

  const ModeToSetSpecific(this.mode);
}

/// Output mode as set in the config file.
@JsonSerializable()
final class ConfiguredMode {
  /// Width in physical pixels.
  final int width;

  /// Height in physical pixels.
  final int height;

  /// Refresh rate.
  final double? refresh;

  const ConfiguredMode({required this.width, required this.height, required this.refresh});

  factory ConfiguredMode.fromJson(Map<String, dynamic> json) => _$ConfiguredModeFromJson(json);
  Map<String, dynamic> toJson() => _$ConfiguredModeToJson(this);
}

/// Modeline horizontal syncing polarity.
enum HSyncPolarity {
  /// Positive polarity.
  PHSync,

  /// Negative polarity.
  NHSync;

  dynamic toJson() {
    return name;
  }
}

/// Modeline vertical syncing polarity.
enum VSyncPolarity {
  /// Positive polarity.
  PVSync,

  /// Negative polarity.
  NVSync;

  dynamic toJson() {
    return name;
  }
}

/// Output scale to set.
sealed class ScaleToSet {
  const ScaleToSet();

  /// Niri will pick the scale automatically.
  const factory ScaleToSet.automatic() = ScaleToSetAutomatic;

  /// Specific scale.
  const factory ScaleToSet.specific(double scale) = ScaleToSetSpecific;

  dynamic toJson() {
    return switch (this) {
      ScaleToSetAutomatic _ => "Automatic",
      ScaleToSetSpecific v => {"Specific": v.scale},
    };
  }
}

/// Niri will pick the scale automatically.
class ScaleToSetAutomatic extends ScaleToSet {
  const ScaleToSetAutomatic();
}

/// Specific scale.
class ScaleToSetSpecific extends ScaleToSet {
  final double scale;

  const ScaleToSetSpecific(this.scale);
}

/// Output position to set.
sealed class PositionToSet {
  const PositionToSet();

  /// Position the output automatically.
  const factory PositionToSet.automatic() = PositionToSetAutomatic;

  /// Set a specific position.
  const factory PositionToSet.specific(ConfiguredPosition position) = PositionToSetSpecific;

  dynamic toJson() {
    return switch (this) {
      PositionToSetAutomatic _ => "Automatic",
      PositionToSetSpecific v => {"Specific": v.position},
    };
  }
}

/// Niri will pick the scale automatically.
class PositionToSetAutomatic extends PositionToSet {
  const PositionToSetAutomatic();
}

/// Specific scale.
class PositionToSetSpecific extends PositionToSet {
  final ConfiguredPosition position;

  const PositionToSetSpecific(this.position);
}

/// Output position as set in the config file.
@JsonSerializable()
class ConfiguredPosition {
  /// Logical X position.
  final int x;

  /// Logical Y position.
  final int y;

  const ConfiguredPosition({required this.x, required this.y});

  factory ConfiguredPosition.fromJson(Map<String, dynamic> json) =>
      _$ConfiguredPositionFromJson(json);

  Map<String, dynamic> toJson() => _$ConfiguredPositionToJson(this);
}

/// Output VRR to set.
@JsonSerializable()
class VrrToSet {
  /// Whether to enable variable refresh rate.
  final bool vrr;

  /// Only enable when the output shows a window matching the variable-refresh-rate window rule.
  @JsonKey(name: "on_demand")
  final bool onDemand;

  const VrrToSet({required this.vrr, required this.onDemand});

  factory VrrToSet.fromJson(Map<String, dynamic> json) => _$VrrToSetFromJson(json);

  Map<String, dynamic> toJson() => _$VrrToSetToJson(this);
}

/// Connected output.
@JsonSerializable()
class Output {
  /// Name of the output.
  final String name;

  /// Textual description of the manufacturer.
  final String make;

  /// Textual description of the model.
  final String model;

  /// Serial of the output, if known.
  final String? serial;

  /// Physical width and height of the output in millimeters, if known.
  @JsonKey(name: "physical_size", fromJson: _convertRecordNullable<int>)
  final (int, int)? physicalSize;

  /// Available modes for the output.
  final List<Mode> modes;

  /// Index of the current mode in [Output.modes].
  ///
  /// `None` if the output is disabled.
  @JsonKey(name: "current_mode")
  final int? currentMode;

  /// Whether the currentMode is a custom mode.
  @JsonKey(name: "is_custom_mode", defaultValue: false)
  final bool isCustomMode;

  /// Whether the output supports variable refresh rate.
  @JsonKey(name: "vrr_supported")
  final bool vrrSupported;

  /// Whether variable refresh rate is enabled on the output.
  @JsonKey(name: "vrr_enabled")
  final bool vrrEnabled;

  /// Logical output information.
  ///
  /// `None` if the output is not mapped to any logical output (for example, if it is disabled).
  final LogicalOutput? logical;

  const Output({
    required this.currentMode,
    required this.isCustomMode,
    required this.logical,
    required this.make,
    required this.model,
    required this.modes,
    required this.name,
    required this.physicalSize,
    required this.serial,
    required this.vrrEnabled,
    required this.vrrSupported,
  });

  @override
  operator ==(covariant Output other) {
    return other.name == name;
  }

  factory Output.fromJson(Map<String, dynamic> json) => _$OutputFromJson(json);

  Map<String, dynamic> toJson() => _$OutputToJson(this);
}

/// Output mode.
@JsonSerializable()
class Mode {
  /// Width in physical pixels.
  final int width;

  /// Height in physical pixels.
  final int height;

  /// Refresh rate in millihertz.
  @JsonKey(name: "refresh_rate")
  final int refreshRate;

  /// Whether this mode is preferred by the monitor.
  @JsonKey(name: "is_preferred")
  final bool isPreferred;

  const Mode({
    required this.width,
    required this.height,
    required this.isPreferred,
    required this.refreshRate,
  });

  factory Mode.fromJson(Map<String, dynamic> json) => _$ModeFromJson(json);

  Map<String, dynamic> toJson() => _$ModeToJson(this);
}

/// Logical output in the compositor's coordinate space.
@JsonSerializable()
class LogicalOutput {
  /// Logical X position.
  final int x;

  /// Logical Y position.
  final int y;

  /// Width in logical pixels.
  final int width;

  /// Height in logical pixels.
  final int height;

  /// Scale factor.
  final double scale;

  /// Transform.
  final Transform transform;

  const LogicalOutput({
    required this.height,
    required this.scale,
    required this.transform,
    required this.width,
    required this.x,
    required this.y,
  });

  factory LogicalOutput.fromJson(Map<String, dynamic> json) => _$LogicalOutputFromJson(json);

  Map<String, dynamic> toJson() => _$LogicalOutputToJson(this);
}

/// Output transform, which goes counter-clockwise.
enum Transform {
  /// Untransformed.
  Normal,

  /// Rotated by 90°.
  By90,

  /// Rotated by 180°.
  By180,

  /// Rotated by 270°.
  By270,

  /// Flipped horizontally.
  Flipped,

  /// Rotated by 90° and flipped horizontally.
  Flipped90,

  /// Flipped vertically.
  Flipped180,

  /// Rotated by 270° and flipped horizontally.
  Flipped270;

  dynamic toJson() {
    return switch (this) {
      Normal || Flipped || Flipped90 || Flipped180 || Flipped270 => name,
      By90 => "90",
      By180 => "180",
      By270 => "270",
    };
  }
}

/// Toplevel window.
@JsonSerializable()
class Window {
  /// Unique id of this window.
  ///
  /// This id remains constant while this window is open.
  ///
  /// Do not assume that window ids will always increase without wrapping, or start at 1. That is
  /// an implementation detail subject to change. For example, ids may change to be randomly
  /// generated for each new window.
  final int id;

  /// Title, if set.
  String? title;

  /// Application ID, if set.
  @JsonKey(name: "app_id")
  String? appId;

  /// Process ID that created the Wayland connection for this window, if known.
  ///
  /// Currently, windows created by xdg-desktop-portal-gnome will have a `None` PID, but this may
  /// change in the future.
  int? pid;

  /// Id of the workspace this window is on, if any.
  @JsonKey(name: "workspace_id")
  int? workspaceId;

  /// Whether this window is currently focused.
  ///
  /// There can be either one focused window or zero (e.g. when a layer-shell surface has focus).
  @JsonKey(name: "is_focused")
  bool isFocused;

  /// Whether this window is currently floating.
  ///
  /// If the window isn't floating then it is in the tiling layout.
  @JsonKey(name: "is_floating")
  bool isFloating;

  /// Whether this window requests your attention.
  @JsonKey(name: "is_urgent")
  bool isUrgent;

  /// Position- and size-related properties of the window.
  WindowLayout layout;
  Window({
    required this.id,
    required this.appId,
    required this.isFloating,
    required this.isFocused,
    required this.isUrgent,
    required this.layout,
    required this.pid,
    required this.title,
    required this.workspaceId,
  });

  @override
  operator ==(covariant Window other) {
    return id == other.id;
  }

  factory Window.fromJson(Map<String, dynamic> json) => _$WindowFromJson(json);

  Map<String, dynamic> toJson() => _$WindowToJson(this);
}

/// Position- and size-related properties of a [Window].
///
/// Optional properties will be unset for some windows, do not rely on them being present. Whether
/// some optional properties are present or absent for certain window types may change across niri
/// releases.
///
/// All sizes and positions are in *logical pixels* unless stated otherwise. Logical sizes may be
/// fractional. For example, at 1.25 monitor scale, a 2-physical-pixel-wide window border is 1.6
/// logical pixels wide.
///
/// This struct contains positions and sizes both for full tiles ([WindowLayout.tileSize],
/// [WindowLayout.tilePosInWorkspaceView]) and the window geometry ([WindowLayout.windowSize],
/// [WindowLayout.windowOffsetInTile]). For visual displays, use the tile properties, as they
/// correspond to what the user visually considers "window". The window properties on the other
/// hand are mainly useful when you need to know the underlying Wayland window sizes, e.g. for
/// application debugging.
@JsonSerializable()
class WindowLayout {
  /// Location of a tiled window within a workspace: (column index, tile index in column).
  ///
  /// The indices are 1-based, i.e. the leftmost column is at index 1 and the topmost tile in a
  /// column is at index 1. This is consistent with [Action.focusColumn] and
  /// [Action.focusWindowInColumn].
  @JsonKey(name: "pos_in_scrolling_layout", fromJson: _convertRecordNullable<int>)
  final (int, int)? posInScrollingLayout;

  /// Size of the tile this window is in, including decorations like borders.
  @JsonKey(name: "tile_size", fromJson: _convertRecord<double>)
  final (double, double) tileSize;

  /// Size of the window's visual geometry itself.
  ///
  /// Does not include niri decorations like borders.
  ///
  /// Currently, Wayland toplevel windows can only be integer-sized in logical pixels, even
  /// though it doesn't necessarily align to physical pixels.
  @JsonKey(name: "window_size", fromJson: _convertRecord<int>)
  final (int, int) windowSize;

  /// Tile position within the current view of the workspace.
  ///
  /// This is the same "workspace view" as in gradients' `relative-to` in the niri config.
  @JsonKey(name: "tile_pos_in_workspace_view", fromJson: _convertRecordNullable<double>)
  final (double, double)? tilePosInWorkspaceView;

  /// Location of the window's visual geometry within its tile.
  ///
  /// This includes things like border sizes. For fullscreened fixed-size windows this includes
  /// the distance from the corner of the black backdrop to the corner of the (centered) window
  /// contents.
  @JsonKey(name: "window_offset_in_tile", fromJson: _convertRecord<double>)
  final (double, double) windowOffsetInTile;

  const WindowLayout({
    required this.posInScrollingLayout,
    required this.tilePosInWorkspaceView,
    required this.tileSize,
    required this.windowOffsetInTile,
    required this.windowSize,
  });

  factory WindowLayout.fromJson(Map<String, dynamic> json) => _$WindowLayoutFromJson(json);

  Map<String, dynamic> toJson() => _$WindowLayoutToJson(this);
}

/// Output configuration change result.
// @Freezed(unionKey: "type", unionValueCase: FreezedUnionCase.snake, makeCollectionsUnmodifiable: false)
sealed class OutputConfigChanged {
  const OutputConfigChanged();

  /// The target output was connected and the change was applied.
  const factory OutputConfigChanged.applied() = OutputConfigChangedApplied;

  /// The target output was not found, the change will be applied when it is connected.
  const factory OutputConfigChanged.outputWasMissing() = OutputConfigChangedOutputWasMissing;

  factory OutputConfigChanged.fromJson(dynamic json) {
    return switch (json) {
      "Applied" => OutputConfigChanged.applied(),
      "OutputWasMissing" => OutputConfigChanged.outputWasMissing(),
      _ => throw "Invalid $json", // TODO throw a more especific error?
    };
  }

  dynamic toJson() {
    return switch (this) {
      OutputConfigChangedApplied() => "Applied",
      OutputConfigChangedOutputWasMissing() => "OutputWasMissing",
    };
  }
}

/// The target output was connected and the change was applied.
class OutputConfigChangedApplied extends OutputConfigChanged {
  const OutputConfigChangedApplied();
}

/// The target output was not found, the change will be applied when it is connected.
class OutputConfigChangedOutputWasMissing extends OutputConfigChanged {
  const OutputConfigChangedOutputWasMissing();
}

/// A workspace.
@JsonSerializable()
class Workspace {
  /// Unique id of this workspace.
  ///
  /// This id remains constant regardless of the workspace moving around and across monitors.
  ///
  /// Do not assume that workspace ids will always increase without wrapping, or start at 1. That
  /// is an implementation detail subject to change. For example, ids may change to be randomly
  /// generated for each new workspace.
  final int id;

  /// Index of the workspace on its monitor.
  ///
  /// This is the same index you can use for requests like `niri msg action focus-workspace`.
  ///
  /// This index *will change* as you move and re-order workspace. It is merely the workspace's
  /// current position on its monitor. Workspaces on different monitors can have the same index.
  ///
  /// If you need a unique workspace id that doesn't change, see [Workspace.id].
  int idx;

  /// Optional name of the workspace.
  String? name;

  /// Name of the output that the workspace is on.
  ///
  /// Can be `None` if no outputs are currently connected.
  String? output;

  /// Whether the workspace currently has an urgent window in its output.
  @JsonKey(name: "is_urgent")
  bool isUrgent;

  /// Whether the workspace is currently active on its output.
  ///
  /// Every output has one active workspace, the one that is currently visible on that output.
  @JsonKey(name: "is_active")
  bool isActive;

  /// Whether the workspace is currently focused.
  ///
  /// There's only one focused workspace across all outputs.
  @JsonKey(name: "is_focused")
  bool isFocused;

  /// Id of the active window on this workspace, if any.
  @JsonKey(name: "active_window_id")
  int? activeWindowId;

  Workspace({
    required this.id,
    required this.idx,
    required this.activeWindowId,
    required this.isActive,
    required this.isFocused,
    required this.isUrgent,
    required this.name,
    required this.output,
  });

  factory Workspace.fromJson(Map<String, dynamic> json) => _$WorkspaceFromJson(json);

  Map<String, dynamic> toJson() => _$WorkspaceToJson(this);
}

/// Configured keyboard layouts.
@JsonSerializable()
class KeyboardLayouts {
  /// XKB names of the configured layouts.
  final List<String> names;

  /// Index of the currently active layout in `names`.
  @JsonKey(name: "current_idx")
  int currentIdx;

  KeyboardLayouts({required this.names, required this.currentIdx});

  @override
  bool operator ==(covariant KeyboardLayouts other) {
    return currentIdx == other.currentIdx &&
        names.length == other.names.length &&
        names.indexed.every((e) => e.$2 == other.names[e.$1]);
  }

  factory KeyboardLayouts.fromJson(Map<String, dynamic> json) => _$KeyboardLayoutsFromJson(json);

  Map<String, dynamic> toJson() => _$KeyboardLayoutsToJson(this);
}

/// A layer-shell layer.
enum Layer {
  /// The background layer.
  Background,

  /// The bottom layer.
  Bottom,

  /// The top layer.
  Top,

  /// The overlay layer.
  Overlay;

  dynamic toJson() {
    return name;
  }
}

/// Keyboard interactivity modes for a layer-shell surface.
enum LayerSurfaceKeyboardInteractivity {
  /// Surface cannot receive keyboard focus.
  None,

  /// Surface receives keyboard focus whenever possible.
  Exclusive,

  /// Surface receives keyboard focus on demand, e.g. when clicked.
  OnDemand;

  dynamic toJson() {
    return name;
  }
}

/// A layer-shell surface.
@JsonSerializable()
class LayerSurface {
  /// Namespace provided by the layer-shell client.
  final String namespace;

  /// Name of the output the surface is on.
  final String output;

  /// Layer that the surface is on.
  final Layer layer;

  /// The surface's keyboard interactivity mode.
  @JsonKey(name: "keyboard_interactivity")
  final LayerSurfaceKeyboardInteractivity keyboardInteractivity;

  const LayerSurface({
    required this.namespace,
    required this.keyboardInteractivity,
    required this.layer,
    required this.output,
  });

  @override
  bool operator ==(covariant LayerSurface other) {
    return namespace == other.namespace &&
        keyboardInteractivity == other.keyboardInteractivity &&
        layer == other.layer &&
        output == other.output;
  }

  factory LayerSurface.fromJson(Map<String, dynamic> json) => _$LayerSurfaceFromJson(json);

  Map<String, dynamic> toJson() => _$LayerSurfaceToJson(this);
}

/// A compositor event.
sealed class Event {
  const Event();

  /// The workspace configuration has changed.
  const factory Event.workspacesChanged(List<Workspace> workspaces) = EventWorkspacesChanged;

  /// The workspace urgency changed.
  const factory Event.workspaceUrgencyChanged({required int id, required bool urgent}) =
      EventWorkspaceUrgencyChanged;

  /// A workspace was activated on an output.
  ///
  /// This doesn't always mean the workspace became focused, just that it's now the active
  /// workspace on its output. All other workspaces on the same output become inactive.
  const factory Event.workspaceActivated({required int id, required bool focused}) =
      EventWorkspaceActivated;

  /// An active window changed on a workspace.
  const factory Event.workspaceActiveWindowChanged({
    required int workspaceId,
    required int? activeWindowId,
  }) = EventWorkspaceActiveWindowChanged;

  /// The window configuration has changed.
  const factory Event.windowsChanged(List<Window> windows) = EventWindowsChanged;

  /// A new toplevel window was opened, or an existing toplevel window changed.
  const factory Event.windowOpenedOrChanged(Window window) = EventWindowOpenedOrChanged;

  /// A toplevel window was closed.
  const factory Event.windowClosed(int id) = EventWindowClosed;

  /// Window focus changed.
  ///
  /// All other windows are no longer focused.
  const factory Event.windowFocusChanged(int? id) = EventWindowFocusChanged;

  /// Window urgency changed.
  const factory Event.windowUrgencyChanged({required int id, required bool urgent}) =
      EventWindowUrgencyChanged;

  /// The layout of one or more windows has changed.
  const factory Event.windowLayoutsChanged(List<(int, WindowLayout)> changes) =
      EventWindowLayoutsChanged;

  /// The configured keyboard layouts have changed.
  const factory Event.keyboardLayoutsChanged(KeyboardLayouts keyboardLayouts) =
      EventKeyboardLayoutsChanged;

  /// The keyboard layout switched.
  const factory Event.keyboardLayoutSwitched(int idx) = EventKeyboardLayoutSwitched;

  /// The overview was opened or closed.
  const factory Event.overviewOpenedOrClosed(bool isOpen) = EventOverviewOpenedOrClosed;

  /// The configuration was reloaded.
  ///
  /// You will always receive this event when connecting to the event stream, indicating the last
  /// config load attempt.
  const factory Event.configLoaded(bool failed) = EventConfigLoaded;

  /// A screenshot was captured.
  const factory Event.screenshotCaptured(String? path) = EventScreenshotCaptured;

  // factory Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);
  factory Event.fromJson(dynamic json) {
    final key = json is String ? json : (json as Map).keys.first;
    switch (key) {
      case "WorkspacesChanged":
        final value = json["WorkspacesChanged"];
        return Event.workspacesChanged([
          for (final w in value["workspaces"]) Workspace.fromJson(w),
        ]);
      case "WindowsChanged":
        final value = json["WindowsChanged"];
        return Event.windowsChanged([for (final w in value["windows"]) Window.fromJson(w)]);
      case "KeyboardLayoutsChanged":
        final value = json["KeyboardLayoutsChanged"];
        return Event.keyboardLayoutsChanged(KeyboardLayouts.fromJson(value["keyboard_layouts"]));
      case "OverviewOpenedOrClosed":
        final value = json["OverviewOpenedOrClosed"];
        return Event.overviewOpenedOrClosed(value["is_open"]);
      case "ConfigLoaded":
        final value = json["ConfigLoaded"];
        return Event.configLoaded(value["failed"]);
      case "WorkspaceActiveWindowChanged":
        final value = json["WorkspaceActiveWindowChanged"];
        return Event.workspaceActiveWindowChanged(
          workspaceId: value["workspace_id"],
          activeWindowId: value["active_window_id"],
        );
      case "WindowFocusChanged":
        final value = json["WindowFocusChanged"];
        return Event.windowFocusChanged(value["id"]);
      case "WorkspaceUrgencyChanged":
        final value = json["WorkspaceUrgencyChanged"];
        return Event.workspaceUrgencyChanged(id: value["id"], urgent: value["urgent"]);
      case "WorkspaceActivated":
        final value = json["WorkspaceActivated"];
        return Event.workspaceActivated(id: value["id"], focused: value["focused"]);
      case "WindowOpenedOrChanged":
        final value = json["WindowOpenedOrChanged"];
        return Event.windowOpenedOrChanged(Window.fromJson(value["window"]));
      case "WindowClosed":
        final value = json["WindowClosed"];
        return Event.windowClosed(value["id"]);
      case "WindowUrgencyChanged":
        final value = json["WindowUrgencyChanged"];
        return Event.windowUrgencyChanged(id: value["id"], urgent: value["urgent"]);
      case "WindowLayoutsChanged":
        final value = json["WindowLayoutsChanged"];
        return Event.windowLayoutsChanged([
          for (final change in value["changes"]) (change[0], WindowLayout.fromJson(change[1])),
        ]);
      case "KeyboardLayoutSwitched":
        final value = json["KeyboardLayoutSwitched"];
        return Event.keyboardLayoutSwitched(value["idx"]);
      case "ScreenshotCaptured":
        final value = json["ScreenshotCaptured"];
        return Event.screenshotCaptured(value["path"]);
    }
    throw "Invalid json $json";
  }
}

/// The workspace configuration has changed.
class EventWorkspacesChanged extends Event {
  /// The new workspace configuration.
  ///
  /// This configuration completely replaces the previous configuration. I.e. if any
  /// workspaces are missing from here, then they were deleted.
  final List<Workspace> workspaces;

  const EventWorkspacesChanged(this.workspaces);
}

/// The workspace urgency changed.
class EventWorkspaceUrgencyChanged extends Event {
  /// Id of the workspace.
  final int id;

  /// Whether this workspace has an urgent window.
  final bool urgent;

  const EventWorkspaceUrgencyChanged({required this.id, required this.urgent});
}

/// A workspace was activated on an output.
///
/// This doesn't always mean the workspace became focused, just that it's now the active
/// workspace on its output. All other workspaces on the same output become inactive.
class EventWorkspaceActivated extends Event {
  /// Id of the newly active workspace.
  final int id;

  /// Whether this workspace also became focused.
  ///
  /// If `true`, this is now the single focused workspace. All other workspaces are no longer
  /// focused, but they may remain active on their respective outputs.
  final bool focused;

  const EventWorkspaceActivated({required this.id, required this.focused});
}

/// An active window changed on a workspace.
class EventWorkspaceActiveWindowChanged extends Event {
  /// Id of the workspace on which the active window changed.
  final int workspaceId;

  /// Id of the new active window, if any.
  final int? activeWindowId;

  const EventWorkspaceActiveWindowChanged({
    required this.workspaceId,
    required this.activeWindowId,
  });
}

/// The window configuration has changed.
class EventWindowsChanged extends Event {
  /// The new window configuration.
  ///
  /// This configuration completely replaces the previous configuration. I.e. if any windows
  /// are missing from here, then they were closed.
  final List<Window> windows;

  const EventWindowsChanged(this.windows);
}

/// A new toplevel window was opened, or an existing toplevel window changed.
class EventWindowOpenedOrChanged extends Event {
  /// The new or updated window.
  ///
  /// If the window is focused, all other windows are no longer focused.
  final Window window;

  const EventWindowOpenedOrChanged(this.window);
}

/// A toplevel window was closed.
class EventWindowClosed extends Event {
  /// Id of the removed window.
  final int id;
  const EventWindowClosed(this.id);
}

/// Window focus changed.
///
/// All other windows are no longer focused.
class EventWindowFocusChanged extends Event {
  /// Id of the newly focused window, or `None` if no window is now focused.
  final int? id;
  const EventWindowFocusChanged(this.id);
}

/// Window urgency changed.
class EventWindowUrgencyChanged extends Event {
  /// Id of the window.
  final int id;

  /// The new urgency state of the window.
  final bool urgent;
  const EventWindowUrgencyChanged({required this.id, required this.urgent});
}

/// The layout of one or more windows has changed.
class EventWindowLayoutsChanged extends Event {
  /// Pairs consisting of a window id and new layout information for the window.
  final List<(int, WindowLayout)> changes;

  const EventWindowLayoutsChanged(this.changes);
}

/// The configured keyboard layouts have changed.
class EventKeyboardLayoutsChanged extends Event {
  /// The new keyboard layout configuration.
  final KeyboardLayouts keyboardLayouts;

  const EventKeyboardLayoutsChanged(this.keyboardLayouts);
}

/// The keyboard layout switched.
class EventKeyboardLayoutSwitched extends Event {
  /// Index of the newly active layout.
  final int idx;

  const EventKeyboardLayoutSwitched(this.idx);
}

/// The overview was opened or closed.
class EventOverviewOpenedOrClosed extends Event {
  /// The new state of the overview.
  final bool isOpen;

  const EventOverviewOpenedOrClosed(this.isOpen);
}

/// The configuration was reloaded.
///
/// You will always receive this event when connecting to the event stream, indicating the last
/// config load attempt.
class EventConfigLoaded extends Event {
  /// Whether the loading failed.
  ///
  /// For example, the config file couldn't be parsed.
  final bool failed;

  const EventConfigLoaded(this.failed);
}

/// A screenshot was captured.
class EventScreenshotCaptured extends Event {
  /// The file path where the screenshot was saved, if it was written to disk.
  ///
  /// If `None`, the screenshot was either only copied to the clipboard, or the path couldn't
  /// be converted to a `String` (e.g. contained invalid UTF-8 bytes).
  final String? path;

  const EventScreenshotCaptured(this.path);
}

/// Reply from niri to client.
///
/// Every request gets one reply.
///
/// * If an error had occurred, it will be an `Reply.err`.
/// * If the request does not need any particular response, it will be
///   `Reply.ok(Response.handled)`. Kind of like an `Ok(())`.
/// * Otherwise, it will be `Reply.ok(response)` with one of the other [Response] variants.
sealed class Reply<T extends Response> {
  const Reply();

  const factory Reply.ok(T response) = ReplyOk;

  const factory Reply.err(String error) = ReplyError;

  factory Reply.fromJson(Map<String, dynamic> json) {
    return switch (json.keys.first) {
      "Ok" => Reply.ok(Response.fromJson(json["Ok"]) as T),
      "Err" => Reply.err(json["Err"]),
      _ => throw "Invalid json $json",
    };
  }

  T unwrap() => (this as ReplyOk<T>).response;
}

class ReplyOk<T extends Response> extends Reply<T> {
  final T response;

  const ReplyOk(this.response);
}

class ReplyError<T extends Response> extends Reply<T> {
  final String error;

  const ReplyError(this.error);
}

(T, T)? _convertRecordNullable<T extends num>(List<dynamic>? json) {
  if (json == null) return null;
  return _convertRecord(json);
}

(T, T) _convertRecord<T extends num>(List<dynamic> json) {
  return (json[0], json[1]);
}
