import 'package:audioplayers/audioplayers.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class AudioService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final AudioRecorder _audioRecorder = AudioRecorder();
   
  String? _currentRecordingPath;
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;
    // Check permissions if necessary
    await _audioPlayer.setReleaseMode(ReleaseMode.loop);
    _isInitialized = true;
  }

  Future<bool> startRecording() async {
    if (await _audioRecorder.hasPermission()) {
      final Directory docDir = await getApplicationDocumentsDirectory();
      final String id = DateTime.now().millisecondsSinceEpoch.toString();
      _currentRecordingPath = '${docDir.path}/alarm_voice_$id.m4a';

      await _audioRecorder.start(
        const RecordConfig(
          sampleRate: 44100,
          bitRate: 128000,
          encoder: AudioEncoder.aacLc,
        ),
        path: _currentRecordingPath!,
      );
      return true;
    }
    return false;
  }

  Future<String?> stopRecording() async {
    final path = await _audioRecorder.stop();
    return path ?? _currentRecordingPath;
  }

  Future<void> playAudio(String path) async {
    await _audioPlayer.stop();
    await _audioPlayer.play(DeviceFileSource(path));
  }

  Future<void> playAssetAudio(String assetPath) async {
    await _audioPlayer.stop();
    await _audioPlayer.play(AssetSource(assetPath));
  }

  Future<void> playSystemAlarm() async {
    // Play a system alarm sound
    await _audioPlayer.stop();
    await _audioPlayer.play(AssetSource('alarms/system_alarm.mp3'));
  }

  Future<void> stopAudio() async {
    await _audioPlayer.stop();
  }

  Future<void> setVolume(double volume) async {
    await _audioPlayer.setVolume(volume.clamp(0.0, 1.0));
  }

  Future<void> setLoopMode(bool loop) async {
    await _audioPlayer.setReleaseMode(loop ? ReleaseMode.loop : ReleaseMode.stop);
  }

  Stream<PlayerState> get onPlayerStateChanged => _audioPlayer.onPlayerStateChanged;
}
