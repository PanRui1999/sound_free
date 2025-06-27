class Plugin {
  final String name;
  final String path;
  bool canBeToProvideSoundSource;
  String scriptContent;

  Plugin({
    required this.name,
    required this.path,
    this.canBeToProvideSoundSource = false,
    this.scriptContent = ""
  });
}
