import 'dart:convert';
import 'dart:typed_data';

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

  @override
  Sink<List<int>> startChunkedConversion(Sink<String> sink) => _Utf16Sink(
      sink is StringConversionSink ? sink : StringConversionSink.from(sink));
}

class Utf16Encoder extends Converter<String, List<int>> {
  @override
  List<int> convert(String input) {
    return Uint8List.sublistView(Uint16List.fromList(input.codeUnits));
  }
}

class _Utf16Sink extends ByteConversionSinkBase {
  final StringConversionSink output;

  const _Utf16Sink(this.output);

  @override
  void add(List<int> chunk) {
    output.add(utf16.decode(chunk));
  }

  @override
  void close() {
    output.close();
  }
}
