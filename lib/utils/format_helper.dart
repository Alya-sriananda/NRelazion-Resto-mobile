import 'package:intl/intl.dart';

class FormatHelper {
  static String formatRupiah(num number) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(number);
  }
}
