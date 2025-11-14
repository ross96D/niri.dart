// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PickedColor _$PickedColorFromJson(Map<String, dynamic> json) => PickedColor(
  rgb: (json['rgb'] as List<dynamic>)
      .map((e) => (e as num).toDouble())
      .toList(),
);

Map<String, dynamic> _$PickedColorToJson(PickedColor instance) =>
    <String, dynamic>{'rgb': instance.rgb};

ConfiguredMode _$ConfiguredModeFromJson(Map<String, dynamic> json) =>
    ConfiguredMode(
      width: (json['width'] as num).toInt(),
      height: (json['height'] as num).toInt(),
      refresh: (json['refresh'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$ConfiguredModeToJson(ConfiguredMode instance) =>
    <String, dynamic>{
      'width': instance.width,
      'height': instance.height,
      'refresh': instance.refresh,
    };

ConfiguredPosition _$ConfiguredPositionFromJson(Map<String, dynamic> json) =>
    ConfiguredPosition(
      x: (json['x'] as num).toInt(),
      y: (json['y'] as num).toInt(),
    );

Map<String, dynamic> _$ConfiguredPositionToJson(ConfiguredPosition instance) =>
    <String, dynamic>{'x': instance.x, 'y': instance.y};

VrrToSet _$VrrToSetFromJson(Map<String, dynamic> json) =>
    VrrToSet(vrr: json['vrr'] as bool, onDemand: json['on_demand'] as bool);

Map<String, dynamic> _$VrrToSetToJson(VrrToSet instance) => <String, dynamic>{
  'vrr': instance.vrr,
  'on_demand': instance.onDemand,
};

Output _$OutputFromJson(Map<String, dynamic> json) => Output(
  currentMode: (json['current_mode'] as num?)?.toInt(),
  isCustomMode: json['is_custom_mode'] as bool? ?? false,
  logical: json['logical'] == null
      ? null
      : LogicalOutput.fromJson(json['logical'] as Map<String, dynamic>),
  make: json['make'] as String,
  model: json['model'] as String,
  modes: (json['modes'] as List<dynamic>)
      .map((e) => Mode.fromJson(e as Map<String, dynamic>))
      .toList(),
  name: json['name'] as String,
  physicalSize: _convertRecordNullable(json['physical_size'] as List?),
  serial: json['serial'] as String?,
  vrrEnabled: json['vrr_enabled'] as bool,
  vrrSupported: json['vrr_supported'] as bool,
);

Map<String, dynamic> _$OutputToJson(Output instance) => <String, dynamic>{
  'name': instance.name,
  'make': instance.make,
  'model': instance.model,
  'serial': instance.serial,
  'physical_size': instance.physicalSize == null
      ? null
      : <String, dynamic>{
          r'$1': instance.physicalSize!.$1,
          r'$2': instance.physicalSize!.$2,
        },
  'modes': instance.modes,
  'current_mode': instance.currentMode,
  'is_custom_mode': instance.isCustomMode,
  'vrr_supported': instance.vrrSupported,
  'vrr_enabled': instance.vrrEnabled,
  'logical': instance.logical,
};

Mode _$ModeFromJson(Map<String, dynamic> json) => Mode(
  width: (json['width'] as num).toInt(),
  height: (json['height'] as num).toInt(),
  isPreferred: json['is_preferred'] as bool,
  refreshRate: (json['refresh_rate'] as num).toInt(),
);

Map<String, dynamic> _$ModeToJson(Mode instance) => <String, dynamic>{
  'width': instance.width,
  'height': instance.height,
  'refresh_rate': instance.refreshRate,
  'is_preferred': instance.isPreferred,
};

LogicalOutput _$LogicalOutputFromJson(Map<String, dynamic> json) =>
    LogicalOutput(
      height: (json['height'] as num).toInt(),
      scale: (json['scale'] as num).toDouble(),
      transform: $enumDecode(_$TransformEnumMap, json['transform']),
      width: (json['width'] as num).toInt(),
      x: (json['x'] as num).toInt(),
      y: (json['y'] as num).toInt(),
    );

Map<String, dynamic> _$LogicalOutputToJson(LogicalOutput instance) =>
    <String, dynamic>{
      'x': instance.x,
      'y': instance.y,
      'width': instance.width,
      'height': instance.height,
      'scale': instance.scale,
      'transform': instance.transform,
    };

const _$TransformEnumMap = {
  Transform.Normal: 'Normal',
  Transform.By90: 'By90',
  Transform.By180: 'By180',
  Transform.By270: 'By270',
  Transform.Flipped: 'Flipped',
  Transform.Flipped90: 'Flipped90',
  Transform.Flipped180: 'Flipped180',
  Transform.Flipped270: 'Flipped270',
};

Window _$WindowFromJson(Map<String, dynamic> json) => Window(
  id: (json['id'] as num).toInt(),
  appId: json['app_id'] as String?,
  isFloating: json['is_floating'] as bool,
  isFocused: json['is_focused'] as bool,
  isUrgent: json['is_urgent'] as bool,
  layout: WindowLayout.fromJson(json['layout'] as Map<String, dynamic>),
  pid: (json['pid'] as num?)?.toInt(),
  title: json['title'] as String?,
  workspaceId: (json['workspace_id'] as num?)?.toInt(),
);

Map<String, dynamic> _$WindowToJson(Window instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'app_id': instance.appId,
  'pid': instance.pid,
  'workspace_id': instance.workspaceId,
  'is_focused': instance.isFocused,
  'is_floating': instance.isFloating,
  'is_urgent': instance.isUrgent,
  'layout': instance.layout,
};

WindowLayout _$WindowLayoutFromJson(Map<String, dynamic> json) => WindowLayout(
  posInScrollingLayout: _convertRecordNullable(
    json['pos_in_scrolling_layout'] as List?,
  ),
  tilePosInWorkspaceView: _convertRecordNullable(
    json['tile_pos_in_workspace_view'] as List?,
  ),
  tileSize: _convertRecord(json['tile_size'] as List),
  windowOffsetInTile: _convertRecord(json['window_offset_in_tile'] as List),
  windowSize: _convertRecord(json['window_size'] as List),
);

Map<String, dynamic> _$WindowLayoutToJson(WindowLayout instance) =>
    <String, dynamic>{
      'pos_in_scrolling_layout': instance.posInScrollingLayout == null
          ? null
          : <String, dynamic>{
              r'$1': instance.posInScrollingLayout!.$1,
              r'$2': instance.posInScrollingLayout!.$2,
            },
      'tile_size': <String, dynamic>{
        r'$1': instance.tileSize.$1,
        r'$2': instance.tileSize.$2,
      },
      'window_size': <String, dynamic>{
        r'$1': instance.windowSize.$1,
        r'$2': instance.windowSize.$2,
      },
      'tile_pos_in_workspace_view': instance.tilePosInWorkspaceView == null
          ? null
          : <String, dynamic>{
              r'$1': instance.tilePosInWorkspaceView!.$1,
              r'$2': instance.tilePosInWorkspaceView!.$2,
            },
      'window_offset_in_tile': <String, dynamic>{
        r'$1': instance.windowOffsetInTile.$1,
        r'$2': instance.windowOffsetInTile.$2,
      },
    };

Workspace _$WorkspaceFromJson(Map<String, dynamic> json) => Workspace(
  id: (json['id'] as num).toInt(),
  idx: (json['idx'] as num).toInt(),
  activeWindowId: (json['active_window_id'] as num?)?.toInt(),
  isActive: json['is_active'] as bool,
  isFocused: json['is_focused'] as bool,
  isUrgent: json['is_urgent'] as bool,
  name: json['name'] as String?,
  output: json['output'] as String?,
);

Map<String, dynamic> _$WorkspaceToJson(Workspace instance) => <String, dynamic>{
  'id': instance.id,
  'idx': instance.idx,
  'name': instance.name,
  'output': instance.output,
  'is_urgent': instance.isUrgent,
  'is_active': instance.isActive,
  'is_focused': instance.isFocused,
  'active_window_id': instance.activeWindowId,
};

KeyboardLayouts _$KeyboardLayoutsFromJson(Map<String, dynamic> json) =>
    KeyboardLayouts(
      names: (json['names'] as List<dynamic>).map((e) => e as String).toList(),
      currentIdx: (json['current_idx'] as num).toInt(),
    );

Map<String, dynamic> _$KeyboardLayoutsToJson(KeyboardLayouts instance) =>
    <String, dynamic>{
      'names': instance.names,
      'current_idx': instance.currentIdx,
    };

LayerSurface _$LayerSurfaceFromJson(Map<String, dynamic> json) => LayerSurface(
  namespace: json['namespace'] as String,
  keyboardInteractivity: $enumDecode(
    _$LayerSurfaceKeyboardInteractivityEnumMap,
    json['keyboard_interactivity'],
  ),
  layer: $enumDecode(_$LayerEnumMap, json['layer']),
  output: json['output'] as String,
);

Map<String, dynamic> _$LayerSurfaceToJson(LayerSurface instance) =>
    <String, dynamic>{
      'namespace': instance.namespace,
      'output': instance.output,
      'layer': instance.layer,
      'keyboard_interactivity': instance.keyboardInteractivity,
    };

const _$LayerSurfaceKeyboardInteractivityEnumMap = {
  LayerSurfaceKeyboardInteractivity.None: 'None',
  LayerSurfaceKeyboardInteractivity.Exclusive: 'Exclusive',
  LayerSurfaceKeyboardInteractivity.OnDemand: 'OnDemand',
};

const _$LayerEnumMap = {
  Layer.Background: 'Background',
  Layer.Bottom: 'Bottom',
  Layer.Top: 'Top',
  Layer.Overlay: 'Overlay',
};
