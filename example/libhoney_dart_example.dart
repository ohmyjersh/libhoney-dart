import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:libhoney_dart/libhoney_dart.dart';
import 'package:http/http.dart' as http;

main(args) async {
  var authKey = args[0];
  var honeycomb = new Honeycomb(authKey, "heeeyyooo");
  var map = new Map<String, Object>();
  map['hi'] = 'hey';
  honeycomb.sendNow(map);
}

class BaseHoney {
  String writeKey;
  String dataset;
  String apiHost;
  int sampleRate;

  BaseHoney(String key, String setName, String host, int rate) {
    writeKey = key;
    dataset = setName;
    apiHost = host;
    sampleRate = rate;
  }
}

class HoneycombDefaults {
  static const String apihost = "https://api.honeycomb.io";
  static const int sampleRate = 1;
}

class Honeycomb extends BaseHoney {

  Honeycomb(
      [String key = null,
      String dataset = null,
      String apiHost = HoneycombDefaults.apihost,
      int sampleRate = HoneycombDefaults.sampleRate]) : super(key, dataset, apiHost, sampleRate) {
  }

  sendNow(Map<String, Object> event) async {
    var json = JSON.encode(event);
    var request =
        Transmission.generateEventRequest(dataset, json, writeKey, apiHost);
    var response =
        await Transmission.requestHandler(request, HttpClient.sendRequest);
    print(response.statusCode);
  }
}

class Transmission {
  static eventUri(apiHost, dataset) => "${apiHost}/1/events/${dataset}";

  static Future<http.StreamedResponse> requestHandler(
      http.Request request, Function client) async {
    var response = await client(request);
    return response;
  }

  static http.Request generateEventRequest(
      String dataset, String body, String writeKey, String apiHost) {
    var uri = Uri.parse(eventUri(apiHost, dataset));
    return generateRequest(uri, 'POST', writeKey, body: body);
  }

  static http.Request generateRequest(Uri uri, String method, String writeKey, { String id = null, String body = null, Map<String,String> headers = null}) {
        var request = new http.Request(method, uri);
        request.headers[HttpHeaders.CONTENT_TYPE] = 'application/json';
        request.headers["X-Honeycomb-Team"] = writeKey;
        request.headers["User-Agent"] = 'libhoney-dart/1.0.0';
       headers != null ? headers.addAll(headers) : null;
       body != null ? request.body = body : null;
        return request;
  }
}

class HttpClient {
  static http.Client client = new http.Client();
  static Future<http.StreamedResponse> sendRequest(http.Request request) async {
    var response = await client.send(request);
    client.close();
    return response;
  }
}