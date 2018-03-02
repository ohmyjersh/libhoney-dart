import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:libhoney_dart/libhoney_dart.dart';
import 'package:http/http.dart' as http;

main(args) async {
  var authKey = args[0];
  // print('init, ${authKey}');
  // var event = new Event(new Honeycomb());
  // event.AddWriteKey(authKey);
  // event.addField("hello", "world");
  // event.send();

  var honeycomb = new Honeycomb(authKey, "heeeyyooo");
  var map = new Map<String, Object>();
  map['hi'] = 'hey';
  honeycomb.sendEventImmediately(map);
}

class Event {
  Honeycomb _honeycomb;
  Map<String, Object> _fields = new Map<String, Object>();
  String _writekey;
  String _dataset;
  String _apiHost;
  int _sampleRate;
  DateTime timestamp = new DateTime.now().toUtc();

  Event(
      [Honeycomb honeycomb = null,
      String writeKey = null,
      String dataset = null,
      String apiHost = HoneycombDefaults.apihost,
      int sampleRate = HoneycombDefaults.sampleRate]) {
    if (honeycomb == null) {
      _honeycomb = new Honeycomb(_writekey, _dataset);
    } else {
      _honeycomb = honeycomb;
    }
  }

  Event addField(String key, Object value) {
    _fields[key] = value;
    return this;
  }

  Event AddWriteKey(String writeKey) {
    _honeycomb.setWriteKey(writeKey);
    return this;
  }


  void send() {
    _honeycomb._sendEvent(this);
  }
}

class HoneycombDefaults {
  static const String apihost = "https://api.honeycomb.io";
  static const int sampleRate = 1;
}

class Honeycomb {
  String _dataset;
  String _writeKey;
  String _apiHost;
  int _sampleRate;

  Honeycomb(
      [String writeKey = null,
      String dataset = null,
      String apiHost = HoneycombDefaults.apihost,
      int sampleRate = HoneycombDefaults.sampleRate]) {
    _writeKey = writeKey;
    _dataset = dataset;
    _apiHost = apiHost;
    _sampleRate = sampleRate;
  }

  _sendEvent(Event event) async {
    await this.sendEventImmediately(event._fields);
  }

  sendEventImmediately(Map<String, Object> event) async {
    var json = JSON.encode(event);
    var request =
        Transmission.generateEventRequest(_dataset, json, _writeKey, _apiHost);
    var response =
        await Transmission.requestHandler(request, HttpClient.sendRequest);
    print(response.statusCode);
  }

  void setWriteKey(String writeKey) {
    _writeKey = writeKey;
  }
}

class Transmission {
  static getEventUri(apiHost, dataset) => "${apiHost}/1/events/${dataset}";

  static Future<http.StreamedResponse> requestHandler(
      http.Request request, Function client) async {
    var response = await client(request);
    return response;
  }

  static http.Request generateEventRequest(
      String dataset, String body, String writeKey, String apiHost) {
    return generateRequest(
        dataset, body, writeKey, getEventUri(apiHost, dataset));
  }

  static http.Request generateRequest(
      String dataset, String body, String writeKey, String url) {
    var request = new http.Request('POST', Uri.parse(url));
    request.headers[HttpHeaders.CONTENT_TYPE] = 'application/json';
    request.headers["X-Honeycomb-Team"] = writeKey;
    request.headers["User-Agent"] = 'libhoney-dart/1.0.0';
    request.headers["${dataset}"] = 'dart';
    request.body = body;
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


// use Stream to queue up async calls
