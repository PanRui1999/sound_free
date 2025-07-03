
import 'package:flutter_js/flutter_js.dart';
import 'package:sound_free/models/plugin.dart';
import 'package:sound_free/tools/file_tools.dart';

class JsEngine {
  static final List<JsEngine> _instances = [];
  static final JavascriptRuntime = getJavascriptRuntime(xhr: true);
  final String _key;
  final Plugin _plugin;

  static List<JsEngine> get instance => _instances;

  Plugin get plugin => _plugin;

  JsEngine._(this._key, this._plugin);

  factory JsEngine(String key, Plugin plugin) {
    // Check for key presence
    for (var item in _instances) {
      if (item._key == key) {
        return item;
      }
    }
    final instance = JsEngine._(key, plugin);
    _instances.add(instance);
    return instance;
  }

  static init() async {
    List<Plugin> plugins = await FileTools.allOfPluginsInLocal();
    // lunch lua state
    for (Plugin plugin in plugins) {
      var luaEngineN = JsEngine('${plugin.name}-${plugin.path.substring(plugin.path.lastIndexOf("/") + 1)}', plugin);

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
