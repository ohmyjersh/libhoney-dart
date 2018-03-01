import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:libhoney_dart/libhoney_dart.dart';
import 'package:http/http.dart' as http;

main(args) async {
  var authKey = args[0];
  print('init, ${authKey}');
  var event = new Event(new Honeycomb());
  event.AddAuthKey(authKey);
  event.addField("hello", "world");
  event.send();
}

class Event {
  Honeycomb _honeycomb;
  String _authKey;
  Map<String, Object> _fields = new Map<String, Object>();

  Event addField(String key, Object value) {
    print('add field');
    _fields[key] = value;
    return this;
  }

  Event AddAuthKey(String authKey) {
      print('in builder, ${authKey}');
    _honeycomb.setKey(authKey);
    return this;
  }

  Event(Honeycomb honeycomb) {
    if (honeycomb == null) {
      _honeycomb = new Honeycomb();
    } else {
      _honeycomb = honeycomb;
    }
  }
  void send() {
    print('send');
    _honeycomb.sendEvent(this);
  }
}

class Honeycomb {
  String _authKey;
  Honeycomb() {}

  sendEvent(Event event) async {
    print(event);
    var body = '{"hello":"world"}';
    var dataset = "fromDart";
    var transmission = new Transmission();
    var request = transmission.generateRequest(dataset, body, _authKey);
    var response =
        await transmission.requestHandler(request, HttpClient.sendRequest);
    print(response.statusCode);
  }

  sendEventImmediately() async {
    var body = '{"hello":"world"}';
    var dataset = "fromDart";
    var transmission = new Transmission();
    var request = transmission.generateRequest(dataset, body, _authKey);
    var response =
        await transmission.requestHandler(request, HttpClient.sendRequest);
    print(response.statusCode);
  }

  void setKey(String authKey) {
    _authKey = authKey;
  }
}

class Transmission {
  static const baseUrl = "https://api.honeycomb.io";
  getEventUri(dataset) => "${baseUrl}/1/events/${dataset}";

  Future<http.StreamedResponse> requestHandler(
      http.Request request, Function client) async {
    var response = await client(request);
    return response;
  }

  http.Request generateRequest(String dataset, String body, String authKey) {
    print(authKey);
    var url = Uri.parse("https://api.honeycomb.io/1/events/${dataset}");
    var request = new http.Request('POST', url);
    request.headers[HttpHeaders.CONTENT_TYPE] = 'application/json';
    request.headers["X-Honeycomb-Team"] = authKey;
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
