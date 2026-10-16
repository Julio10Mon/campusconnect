/// Utilidades de texto para búsquedas y comparaciones.
class TextUtils {
  TextUtils._();

  static const _from = 'áàäâãéèëêíìïîóòöôõúùüûñçÁÀÄÂÃÉÈËÊÍÌÏÎÓÒÖÔÕÚÙÜÛÑÇ';
  static const _to = 'aaaaaeeeeiiiiooooouuuuncaaaaaeeeeiiiiooooouuuunc';

  /// Minúsculas, sin acentos y con espacios colapsados.
  static String normalize(String input) {
    final buffer = StringBuffer();
    for (final rune in input.runes) {
      final ch = String.fromCharCode(rune);
      final i = _from.indexOf(ch);
      buffer.write(i >= 0 ? _to[i] : ch);
    }
    return buffer.toString().toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();
  }
}
