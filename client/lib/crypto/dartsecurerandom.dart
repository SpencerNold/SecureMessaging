import 'dart:math';
import 'dart:typed_data';

class DartSecureRandom {
  static Uint8List nextBytes(int n) {
    final random = Random.secure();
    final bytes = Uint8List(n);
    for (int i = 0; i < n; i++) {
      bytes[i] = random.nextInt(256);
    }
    return Uint8List.fromList(bytes);
  }
}
