String parseStr(Map<String, dynamic> jsonData, String key) {
  if (jsonData.containsKey(key) && jsonData[key] != null) {
    return jsonData[key];
  }
  return '';
}

bool parseBool(Map<String, dynamic> jsonData, String key) {
  if (jsonData.containsKey(key) && jsonData[key] != null) {
    return jsonData[key];
  }
  return false;
}

int parseInt(Map<String, dynamic> jsonData, String key) {
  if (jsonData.containsKey(key) && jsonData[key] != null) {
    return jsonData[key];
  }
  return 0;
}

double parseDouble(Map<String, dynamic> jsonData, String key) {
  if (jsonData.containsKey(key) && jsonData[key] != null) {
    return double.parse(jsonData[key]);
  }
  return 0;
}

DateTime? parseDateTime(Map<String, dynamic> jsonData, String key) {
  if (jsonData.containsKey(key) && jsonData[key] != null) {
    return DateTime.tryParse(jsonData[key])?.toLocal();
  }
  return null;
}

List<dynamic> parseList(Map<String, dynamic> jsonData, String key) {
  if (jsonData.containsKey(key) && jsonData[key] != null) {
    return jsonData[key];
  }
  return [];
}

///Khi parse data kiểu dynamic thì phải chấp nhận null
dynamic parseDynamic(Map<String, dynamic> jsonData, String key) {
  if (jsonData.containsKey(key) && jsonData[key] != null) {
    return jsonData[key];
  }
  return null;
}
