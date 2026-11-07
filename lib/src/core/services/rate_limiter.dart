import 'dart:async';
import 'dart:collection';

/// Sliding-window limiter: at most [maxRequests] starts per [window].
///
/// The 42 API allows 2 requests per second per application. Without this,
/// parallel requests (profile + coalition + coalition score) trip HTTP 429 and
/// fail or need slow retries.
class RateLimiter {
  RateLimiter({
    this.maxRequests = 2,
    this.window = const Duration(milliseconds: 1050),
  });

  final int maxRequests;
  final Duration window;

  final _starts = Queue<DateTime>();
  Future<void> _tail = Future<void>.value();

  /// Completes when the caller may start its request. Calls are served FIFO.
  Future<void> acquire() {
    final turn = _tail.then((_) async {
      while (true) {
        final now = DateTime.now();
        while (_starts.isNotEmpty && now.difference(_starts.first) >= window) {
          _starts.removeFirst();
        }
        if (_starts.length < maxRequests) {
          _starts.addLast(now);
          return;
        }
        await Future<void>.delayed(window - now.difference(_starts.first));
      }
    });
    _tail = turn;
    return turn;
  }
}
