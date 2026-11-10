class CacheException implements Exception {
  const CacheException([this.message = 'Could not access local storage']);

  final String message;

  @override
  String toString() => 'CacheException: $message';
}
