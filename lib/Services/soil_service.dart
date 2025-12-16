import 'dart:convert';
import 'package:http/http.dart' as http;

class SoilService {
  static Future<String> getSoilType(double lat, double lon) async {
    final url =
        "https://rest.isric.org/soilgrids/v2.0/properties/query"
        "?lat=$lat&lon=$lon&property=texture_class&depth=0-5cm";
    final response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) {
      throw Exception("Soil API Failed");
    }
    final data = json.decode(response.body);

    //Extract texture class
    final layers = data['propreties']['layers'];
    final texture = layers[0]['depths'][0]['values']['values'];

    return texture.toString();
  }
}
