import 'package:characters/characters.dart';

extension NormalizeString on String {
  String normalizeToAscii() {
    const withAccents = 'ăâîșşțţéèêëáàäóòöúùüñç';
    const withoutAccents = 'aaisstteeaaaooouuunc';

    String out = this;

    for (int i = 0; i < withAccents.length; i++) {
      out = out.replaceAll(withAccents[i], withoutAccents[i]);
    }
    return out;
  }
}


