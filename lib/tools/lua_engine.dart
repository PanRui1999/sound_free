import 'package:lua_dardo/lua.dart';
import 'package:sound_free/models/plugin.dart';
import 'package:sound_free/tools/file_tools.dart';

class LuaEngineN {
  static final List<LuaEngineN> _instances = [];
  final String key;
  final LuaState _stateMachine = LuaState.newState();

  LuaEngineN._(this.key);

  factory LuaEngineN(String key) {
    // Check for key presence
    for (var item in _instances) {
      if (item.key == key) {
        return item;
      }
    }
    final instance = LuaEngineN._(key);
    instance._stateMachine.openLibs();
    _instances.add(instance);
    return instance;
  }

  static init() async {
    List<Plugin> plugins = await FileTools.allOfPluginsInLocal();
    // lunch lua state
    for (Plugin plugin in plugins) {
      _instances.add(LuaEngineN('${plugin.name}-${plugin.path.substring(plugin.path.lastIndexOf("/") + 1)}'));
    }
  }
}
