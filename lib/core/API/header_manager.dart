class FastHttpHeader {
  // Singleton pattern to ensure only one instance of HeaderManager
  static final FastHttpHeader _instance = FastHttpHeader._internal();

  factory FastHttpHeader() {
    return _instance;
  }

  FastHttpHeader._internal();

  // This will store all static headers set by the developer
  final Map<String, String> _staticHeaders = {};

  // A callback function for dynamic headers
  final Map<String, Future<String> Function()> _dynamicHeaders = {};

  // Method to add or update static headers
  void addHeader(String key, String value) {
    _staticHeaders[key] = value;
  }

  // Method to remove a specific static header
  void removeHeader(String key) {
    _staticHeaders.remove(key);
  }

  // Method to clear all static headers
  void clearHeaders() {
    _staticHeaders.clear();
  }

  // Method to add a dynamic header (e.g., token or language)
  void addDynamicHeader(String key, Future<String> Function() valueProvider) {
    _dynamicHeaders[key] = valueProvider;
  }

  // Method to remove a dynamic header
  void removeDynamicHeader(String key) {
    _dynamicHeaders.remove(key);
  }

  // Method to get all headers, including both static and dynamic ones
  Future<Map<String, String>> getHeaders() async {
    Map<String, String> headers = {..._staticHeaders};

    // Fetch dynamic headers (e.g., token, language, etc.)
    for (var key in _dynamicHeaders.keys) {
      String value = await _dynamicHeaders[key]!();
      headers[key] = value;
    }

    return headers;
  }
}