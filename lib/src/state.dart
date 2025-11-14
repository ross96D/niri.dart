// Helpers for keeping track of the event stream state.
//
// 1. Create an [EventStreamState] using the default constructor, or any individual state part if
//    you only care about part of the state.
// 2. Connect to the niri socket and request an event stream.
// 3. Pass every [Event] to [EventStreamStatePart.apply] on your state.
// 4. Read the fields of the state as needed.

import "dart:collection";

import "./models.dart";

// Assuming these classes are defined elsewhere
// import 'package:your_package/events.dart';
// import 'package:your_package/workspace.dart';
// import 'package:your_package/window.dart';
// import 'package:your_package/keyboard_layouts.dart';

/// Part of the state communicated via the event stream.
abstract class EventStreamStatePart {
  /// Returns a sequence of events that replicates this state from default initialization.
  List<Event> replicate();

  /// Applies the event to this state.
  ///
  /// Returns `null` after applying the event, and the [event] if the event is ignored by this
  /// part of the state.
  Event? apply(Event event) {
    final result = _apply(event);
    if (result == null) _notify();
    return result;
  }

  Event? _apply(Event event);

  void _notify() {
    for (var cb in _listeners) {
      cb();
    }
  }

  final Set<void Function()> _listeners = {};

  /// Listen to changes in the internal state
  void addListener(void Function() cb) {
    _listeners.add(cb);
  }

  /// Stop listen to changes in the internal state
  void removeListener(void Function() cb) {
    _listeners.remove(cb);
  }
}

/// The full state communicated over the event stream.
///
/// Different parts of the state are not guaranteed to be consistent across every single event
/// sent by niri. For example, you may receive the first [Event.windowOpenedOrChanged] for a
/// just-opened window *after* an [Event.workspaceActiveWindowChanged] for that window. Between
/// these two events, the workspace active window id refers to a window that does not yet exist in
/// the windows state part.
class NiriEventStreamState extends EventStreamStatePart {
  /// State of workspaces.
  NiriWorkspacesState workspaces = NiriWorkspacesState();

  /// State of windows.
  NiriWindowsState windows = NiriWindowsState();

  /// State of the keyboard layouts.
  NiriKeyboardLayoutsState keyboardLayouts = NiriKeyboardLayoutsState();

  /// State of the overview.
  NiriOverviewState overview = NiriOverviewState();

  /// State of the config.
  NiriConfigState config = NiriConfigState();

  NiriEventStreamState();

  @override
  List<Event> replicate() {
    final events = <Event>[];
    events.addAll(workspaces.replicate());
    events.addAll(windows.replicate());
    events.addAll(keyboardLayouts.replicate());
    events.addAll(overview.replicate());
    events.addAll(config.replicate());
    return events;
  }

  @override
  Event? _apply(Event event) {
    Event? remainingEvent = event;
    remainingEvent = workspaces.apply(remainingEvent);
    if (remainingEvent == null) return null;
    remainingEvent = windows.apply(remainingEvent);
    if (remainingEvent == null) return null;
    remainingEvent = keyboardLayouts.apply(remainingEvent);
    if (remainingEvent == null) return null;
    remainingEvent = overview.apply(remainingEvent);
    if (remainingEvent == null) return null;
    remainingEvent = config.apply(remainingEvent);
    return remainingEvent;
  }
}

/// The workspaces state communicated over the event stream.
class NiriWorkspacesState extends EventStreamStatePart {
  /// Map from a workspace id to the workspace.
  final Map<int, Workspace> workspaces = HashMap();

  NiriWorkspacesState();

  @override
  List<Event> replicate() {
    return [Event.workspacesChanged(workspaces.values.toList())];
  }

  @override
  Event? _apply(Event event) {
    switch (event) {
      case EventWorkspacesChanged(workspaces: final workspaces):
        this.workspaces.clear();
        for (final ws in workspaces) {
          this.workspaces[ws.id] = ws;
        }
        break;
      case EventWorkspaceUrgencyChanged(id: final id, urgent: final urgent):
        for (final ws in workspaces.values) {
          if (ws.id == id) {
            ws.isUrgent = urgent;
          }
        }
        break;
      case EventWorkspaceActivated(id: final id, focused: final focused):
        final ws = workspaces[id];
        if (ws == null) {
          throw StateError("activated workspace was missing from the map");
        }
        final output = ws.output;

        for (final ws in workspaces.values) {
          final gotActivated = ws.id == id;
          if (ws.output == output) {
            ws.isActive = gotActivated;
          }

          if (focused) {
            ws.isFocused = gotActivated;
          }
        }
        break;
      case EventWorkspaceActiveWindowChanged(
        workspaceId: final workspaceId,
        activeWindowId: final activeWindowId,
      ):
        final ws = workspaces[workspaceId];
        if (ws == null) {
          throw StateError("changed workspace was missing from the map");
        }
        ws.activeWindowId = activeWindowId;
        break;
      default:
        return event;
    }
    return null;
  }
}

/// The windows state communicated over the event stream.
class NiriWindowsState extends EventStreamStatePart {
  /// Map from a window id to the window.
  final Map<int, Window> windows = HashMap();

  NiriWindowsState();

  @override
  List<Event> replicate() {
    return [Event.windowsChanged(windows.values.toList())];
  }

  @override
  Event? _apply(Event event) {
    switch (event) {
      case EventWindowsChanged(windows: final windows):
        this.windows.clear();
        for (final win in windows) {
          this.windows[win.id] = win;
        }
        break;
      case EventWindowOpenedOrChanged(window: final window):
        final entry = windows[window.id];
        int id;
        bool isFocused;
        if (entry != null) {
          windows[window.id] = window;
          id = window.id;
          isFocused = window.isFocused;
        } else {
          windows[window.id] = window;
          id = window.id;
          isFocused = window.isFocused;
        }

        if (isFocused) {
          for (final win in windows.values) {
            if (win.id != id) {
              win.isFocused = false;
            }
          }
        }
        break;
      case EventWindowClosed(id: final id):
        final removed = windows.remove(id);
        if (removed == null) {
          throw StateError("closed window was missing from the map");
        }
        break;
      case EventWindowFocusChanged(id: final id):
        for (final win in windows.values) {
          win.isFocused = win.id == id;
        }
        break;
      case EventWindowUrgencyChanged(id: final id, urgent: final urgent):
        for (final win in windows.values) {
          if (win.id == id) {
            win.isUrgent = urgent;
            break;
          }
        }
        break;
      case EventWindowLayoutsChanged(changes: final changes):
        for (final (id, update) in changes) {
          final win = windows[id];
          if (win == null) {
            throw StateError("changed window was missing from the map");
          }
          win.layout = update;
        }
        break;
      default:
        return event;
    }
    return null;
  }
}

/// The keyboard layout state communicated over the event stream.
class NiriKeyboardLayoutsState extends EventStreamStatePart {
  /// Configured keyboard layouts.
  KeyboardLayouts? keyboardLayouts;

  NiriKeyboardLayoutsState();

  @override
  List<Event> replicate() {
    if (keyboardLayouts != null) {
      return [Event.keyboardLayoutsChanged(keyboardLayouts!)];
    }
    return [];
  }

  @override
  Event? _apply(Event event) {
    switch (event) {
      case EventKeyboardLayoutsChanged(keyboardLayouts: final keyboardLayouts):
        this.keyboardLayouts = keyboardLayouts;
        break;
      case EventKeyboardLayoutSwitched(idx: final idx):
        final kb = keyboardLayouts;
        if (kb == null) {
          throw StateError("keyboard layouts must be set before a layout can be switched");
        }
        kb.currentIdx = idx;
        break;
      default:
        return event;
    }
    return null;
  }
}

/// The overview state communicated over the event stream.
class NiriOverviewState extends EventStreamStatePart {
  /// Whether the overview is currently open.
  bool isOpen = false;

  NiriOverviewState();

  @override
  List<Event> replicate() {
    return [Event.overviewOpenedOrClosed(isOpen)];
  }

  @override
  Event? _apply(Event event) {
    switch (event) {
      case EventOverviewOpenedOrClosed(isOpen: final isOpen):
        this.isOpen = isOpen;
        break;
      default:
        return event;
    }
    return null;
  }
}

/// The config state communicated over the event stream.
class NiriConfigState extends EventStreamStatePart {
  /// Whether the last config load attempt had failed.
  bool failed = false;

  NiriConfigState();

  @override
  List<Event> replicate() {
    return [Event.configLoaded(failed)];
  }

  @override
  Event? _apply(Event event) {
    switch (event) {
      case EventConfigLoaded(failed: final failed):
        this.failed = failed;
        break;
      default:
        return event;
    }
    return null;
  }
}
