import 'package:flutter/services.dart';

/// Camera flashlight used as a Morse signal lamp.
abstract class TorchDevice {
  Future<bool> isAvailable();

  /// [pattern] alternates wait and on durations in milliseconds, starting
  /// with a wait (the same format as an Android vibration pattern).
  Future<void> playPattern(List<int> pattern);

  Future<void> stop();
}

/// Talks to the native torch controller in MainActivity. The pattern is
/// scheduled natively so blink timing stays accurate at high speeds. Uses
/// CameraManager.setTorchMode, which needs no camera permission.
class MethodChannelTorchDevice implements TorchDevice {
  const MethodChannelTorchDevice({MethodChannel channel = const MethodChannel('morse/torch')}) : _channel = channel;

  final MethodChannel _channel;

  @override
  Future<bool> isAvailable() async {
    try {
      return await _channel.invokeMethod<bool>('isAvailable') ?? false;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    }
  }

  @override
  Future<void> playPattern(List<int> pattern) async {
    try {
      await _channel.invokeMethod<void>('playPattern', {'pattern': pattern});
    } on MissingPluginException {
      // Platform without a torch implementation (e.g. iOS for now).
    }
  }

  @override
  Future<void> stop() async {
    try {
      await _channel.invokeMethod<void>('stop');
    } on MissingPluginException {
      // Nothing to stop.
    }
  }
}
