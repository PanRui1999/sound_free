import 'dart:math';

class CommonTools {
  static String generateUuid() {
    // 生成16个随机字节
    final Random random = Random();
    final List<int> bytes = List<int>.generate(16, (_) => random.nextInt(256));

    // 设置版本位（版本4 - 随机）
    bytes[6] = (bytes[6] & 0x0F) | 0x40;
    // 设置变体位（RFC4122）
    bytes[8] = (bytes[8] & 0x3F) | 0x80;

    // 转换为十六进制字符串并添加连字符
    final List<String> hexDigits = bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).toList();

    return [
      hexDigits.sublist(0, 4).join(''),
      hexDigits.sublist(4, 6).join(''),
      hexDigits.sublist(6, 8).join(''),
      hexDigits.sublist(8, 10).join(''),
      hexDigits.sublist(10, 16).join(''),
    ].join('-');
  }
}