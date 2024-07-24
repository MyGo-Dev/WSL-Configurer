import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/services.dart';

const utf16 = Utf16Codec();

final class Utf16Codec extends Encoding {
  const Utf16Codec();
  @override
  Converter<List<int>, String> get decoder => Utf16Decoder();

  @override
  Converter<String, List<int>> get encoder => Utf16Encoder();

  @override
  String get name => "utf-16";
}

class Utf16Decoder extends Converter<List<int>, String> {
  @override
  String convert(List<int> input) {
    return String.fromCharCodes(
        Uint16List.sublistView(Uint8List.fromList(input)));
  }
}

class Utf16Encoder extends Converter<String, List<int>> {
  @override
  List<int> convert(String input) {
    return input.codeUnits;
  }
}
