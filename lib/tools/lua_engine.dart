import 'package:lua_dardo/lua.dart';
import 'package:sound_free/models/plugin.dart';
import 'package:sound_free/tools/file_tools.dart';

class LuaEngineN {
  static final List<LuaEngineN> _instances = [];
  final String _key;
  final LuaState _stateMachine = LuaState.newState();
  final Plugin _plugin;

  static List<LuaEngineN> get instance => _instances;

  Plugin get plugin => _plugin;

  LuaEngineN._(this._key, this._plugin);

  factory LuaEngineN(String key, Plugin plugin) {
    // Check for key presence
    for (var item in _instances) {
      if (item._key == key) {
        return item;
      }
    }
    final instance = LuaEngineN._(key, plugin);
    instance._stateMachine.openLibs();
    _instances.add(instance);
    return instance;
  }

  static init() async {
    List<Plugin> plugins = await FileTools.allOfPluginsInLocal();
    // lunch lua state
    for (Plugin plugin in plugins) {
      LuaEngineN('${plugin.name}-${plugin.path.substring(plugin.path.lastIndexOf("/") + 1)}', plugin);
    }
  }

  void uninstall({bool deleteFile = true}) {
    var index = 0;
    for (var i = 0; i < _instances.length; i++) {
      var instance = _instances[i];
      if (instance._key == _key) {
        index = i;
        break;
      }
    }
    if (deleteFile) {
      FileTools.deletePluginFile(plugin);
    }
    _instances.removeAt(index);
  }
}
