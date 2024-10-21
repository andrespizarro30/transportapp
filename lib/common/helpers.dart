
class Helpers{

  static Map<String, dynamic> convertMapValuesToString(Map<String, dynamic> map) {

    Map<String, dynamic> result = {};

    map.forEach((key, value) {
      if (value is Map) {
        result[key] = convertMapValuesToString(value as Map<String,dynamic>);
      } else if (value is List) {
        result[key] = value.map((element) {
          if (element is Map) {
            return convertMapValuesToString(element as Map<String,dynamic>);
          } else {
            return element.toString(); // Convert list elements to String
          }
        }).toList();
      } else {
        // Convert non-map, non-list values to String
        result[key] = value.toString();
      }
    });

    return result;
  }

  static List<dynamic> convertListValuesToString(List<dynamic> list) {
    return list.map((value) {
      if (value is Map) {
        return convertMapValuesToString(value as Map<String,dynamic>);
      } else if (value is List) {
        return convertListValuesToString(value);
      } else {
        // Convert non-list, non-map values to String
        return value.toString();
      }
    }).toList();
  }

}