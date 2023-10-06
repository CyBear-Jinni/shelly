import 'dart:io';

import 'package:shelly/src/shelly_api/shelly_api_device_abstract.dart';

class ShellyApiColorBulb extends ShellyApiDeviceAbstract {
  ShellyApiColorBulb({
    required super.lastKnownIp,
    required super.mDnsName,
    required super.hostName,
    this.bulbMode = ShellyBulbMode.white,
  });

  // The mod of the bulb, an be white or color
  ShellyBulbMode bulbMode;

  Future<String> turnOn() async {
    final HttpClientRequest httpClientRequest =
        await HttpClient().getUrl(Uri.parse('$url/color/0?turn=on'));
    final HttpClientResponse response = await httpClientRequest.close();

    return response.reasonPhrase;
  }

  Future<String> turnOff() async {
    final HttpClientRequest httpClientRequest =
        await HttpClient().getUrl(Uri.parse('$url/color/0?turn=off'));
    final HttpClientResponse response = await httpClientRequest.close();

    return response.reasonPhrase;
  }

  Future<String> changeModeToWhite() async {
    bulbMode = ShellyBulbMode.white;
    final HttpClientRequest httpClientRequest =
        await HttpClient().getUrl(Uri.parse('$url/settings/?mode=white'));
    final HttpClientResponse response = await httpClientRequest.close();

    return response.reasonPhrase;
  }

  Future<String> changeModeToColor() async {
    bulbMode = ShellyBulbMode.colore;
    final HttpClientRequest httpClientRequest =
        await HttpClient().getUrl(Uri.parse('$url/settings/?mode=color'));
    final HttpClientResponse response = await httpClientRequest.close();

    return response.reasonPhrase;
  }

  /// Changing brightness alone called gain and it is 0-100.
  /// I think works only on color mode
  Future<String> changeBrightnessColorGain(String brightness) async {
    final HttpClientRequest httpClientRequest = await HttpClient()
        .getUrl(Uri.parse('$url/color/0?turn=on&gain=$brightness'));
    final HttpClientResponse response = await httpClientRequest.close();
    return response.reasonPhrase;
  }

  /// Change temperature
  Future<String> changTemperature({
    required String temperature,
  }) async {
    if (bulbMode != ShellyBulbMode.white) {
      await changeModeToWhite();
    }

    final HttpClientRequest httpClientRequest = await HttpClient().getUrl(
      Uri.parse(
        '$url/color/0?turn=on&temp=$temperature',
      ),
    );
    final HttpClientResponse response = await httpClientRequest.close();
    return response.reasonPhrase;
  }

  /// Chang brightness
  Future<String> changBrightness({
    required String brightness,
  }) async {
    HttpClientRequest httpClientRequest;

    switch (bulbMode) {
      case ShellyBulbMode.white:
        httpClientRequest = await HttpClient().getUrl(
          Uri.parse(
            '$url/color/0?turn=on&brightness=$brightness',
          ),
        );
        break;
      case ShellyBulbMode.colore:
        httpClientRequest = await HttpClient().getUrl(
          Uri.parse(
            '$url/color/0?turn=on&gain=$brightness',
          ),
        );
        break;
    }

    final HttpClientResponse response = await httpClientRequest.close();
    return response.reasonPhrase;
  }

  /// Change color of the bulb, I think will also change to color mode
  Future<String> changeColor({
    required String red,
    required String green,
    required String blue,
    String white = "0",
  }) async {
    if (bulbMode != ShellyBulbMode.colore) {
      await changeModeToColor();
    }

    final HttpClientRequest httpClientRequest = await HttpClient().getUrl(
      Uri.parse(
        '$url/color/0?turn=on&red=$red&green=$green&blue=$blue&white=$white',
      ),
    );
    final HttpClientResponse response = await httpClientRequest.close();
    return response.reasonPhrase;
  }
}

enum ShellyBulbMode { white, colore }
