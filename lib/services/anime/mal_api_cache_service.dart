class MalApiCacheService {
  final Duration ttl;
  final DateTime Function() _now;
  final Map<String, _CacheEntry<Object>> _entries = {};

  MalApiCacheService({
    required this.ttl,
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  T? get<T>(String key) {
    final entry = _entries[key];

    if (entry == null) {
      return null;
    }

    if (entry.expiresAt.isBefore(_now())) {
      _entries.remove(key);
      return null;
    }

    return entry.value as T;
  }

  void put<T>(String key, T value) {
    _entries[key] = _CacheEntry<Object>(
      value: value as Object,
      expiresAt: _now().add(ttl),
    );
  }

  void invalidate(String key) {
    _entries.remove(key);
  }

  void invalidateWhere(bool Function(String key) test) {
    final keysToRemove = _entries.keys.where(test).toList();

    for (final key in keysToRemove) {
      _entries.remove(key);
    }
  }

  void clear() {
    _entries.clear();
  }
}

class _CacheEntry<T> {
  final T value;
  final DateTime expiresAt;

  const _CacheEntry({
    required this.value,
    required this.expiresAt,
  });
}
