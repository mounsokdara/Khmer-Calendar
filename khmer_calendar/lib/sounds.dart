import 'dart:async';
import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'custom_sound.dart';
import 'haptics.dart';

const wheelSoundNone = 'none';
const wheelSoundCustom = 'custom';
const defaultWheelSoundId = 'wheel1';

enum CustomPickResult { picked, cancelled, tooLarge, failed }

class WheelConfig {
  WheelConfig._(this.raw);

  final Map<String, dynamic> raw;

  static Future<WheelConfig>? _future;

  static Future<WheelConfig> load() => _future ??= _load();

  static Future<WheelConfig> _load() async {
    try {
      final text = await rootBundle.loadString('assets/config/wheel_picker_audio.json');
      final value = jsonDecode(text);
      if (value is Map) return WheelConfig._(Map<String, dynamic>.from(value));
    } catch (e) {
      debugPrint('wheel config failed: $e');
    }
    return WheelConfig._({});
  }

  Map<String, dynamic> get wheel => raw['wheel'] is Map ? Map<String, dynamic>.from(raw['wheel']) : const {};

  List<Map<String, dynamic>> get soundOptions {
    final sounds = raw['sounds'];
    if (sounds is! List) return const [];
    return [
      for (final item in sounds)
        if (item is Map) Map<String, dynamic>.from(item),
    ];
  }

  int get minGapMs => (wheel['min_gap_ms'] as num?)?.toInt() ?? 45;
  int get maxLivePlayers => (wheel['max_live_players'] as num?)?.toInt() ?? 3;
  int get maxLifetimeMs => (wheel['max_lifetime_ms'] as num?)?.toInt() ?? 3000;
  int get customMaxBytes => (wheel['custom_max_bytes'] as num?)?.toInt() ?? 1024 * 1024;
  Map<String, dynamic>? sound(String id) {
    final sounds = raw['sounds'];
    if (sounds is! List) return null;
    for (final item in sounds) {
      if (item is Map && item['id']?.toString() == id) return Map<String, dynamic>.from(item);
    }
    return null;
  }

  String? soundAsset(String id) => sound(id)?['asset']?.toString();
  String soundLabel(String id, {required bool khmer}) =>
      sound(id)?[khmer ? 'km' : 'en']?.toString() ?? id;
}

Future<({CustomPickResult result, String? name})> pickCustomSound() async {
  try {
    final config = await WheelConfig.load();
    final file = await FilePicker.pickFile(type: FileType.audio);
    if (file == null) return (result: CustomPickResult.cancelled, name: null);
    if (await file.length() > config.customMaxBytes) {
      return (result: CustomPickResult.tooLarge, name: null);
    }
    final bytes = await file.readAsBytes();
    if (bytes.isEmpty) return (result: CustomPickResult.failed, name: null);
    await saveCustomSound(bytes, _extOf(file.name));
    return (result: CustomPickResult.picked, name: file.name);
  } catch (e) {
    debugPrint('pickCustomSound failed: $e');
    return (result: CustomPickResult.failed, name: null);
  }
}

String _extOf(String name) {
  final i = name.lastIndexOf('.');
  if (i < 0 || i == name.length - 1) return 'mp3';
  final e = name.substring(i + 1).toLowerCase();
  return RegExp(r'^[a-z0-9]{1,5}$').hasMatch(e) ? e : 'mp3';
}

class AppSounds {
  AppSounds._();
  static final AppSounds instance = AppSounds._();

  String _wheel = wheelSoundNone;
  int _gen = 0;
  Future<Source?>? _custom;
  final List<AudioPlayer> _pool = [];
  DateTime _last = DateTime.fromMillisecondsSinceEpoch(0);
  WheelConfig? _config;
  int _next = 0;

  String get wheel => _wheel;

  void setWheel(String id) {
    final normalized = id.trim();
    _wheel = normalized.isEmpty ? wheelSoundNone : normalized;
    _gen++;
    _custom = null;
    // Clear pool so next play reloads the new source
    for (final p in _pool) {
      unawaited(p.dispose());
    }
    _pool.clear();
    _next = 0;
    unawaited(_loadConfig());
  }

  Future<void> _loadConfig() async {
    _config ??= await WheelConfig.load();
  }

  void playWheel() {
    Haptics.instance.tick();
    if (_wheel == wheelSoundNone) return;
    unawaited(_play(_wheel, _gen));
  }

  Future<void> _play(String id, int gen) async {
    final config = _config ??= await WheelConfig.load();
    final minGap = Duration(milliseconds: config.minGapMs);
    final now = DateTime.now();
    if (now.difference(_last) < minGap) return;
    _last = now;

    final source = await _sourceFor(id, config);
    if (source == null || gen != _gen) return;

    // Reuse / grow a small fixed pool instead of creating+disposing every time
    final maxPlayers = config.maxLivePlayers.clamp(1, 8);
    while (_pool.length < maxPlayers) {
      final p = AudioPlayer();
      final ctx = _context();
      if (ctx != null) await p.setAudioContext(ctx);
      _pool.add(p);
    }

    final player = _pool[_next % _pool.length];
    _next++;

    try {
      // Replay: stop → set source → seek 0 → resume
      await player.stop();
      await player.setSource(source);
      await player.seek(Duration.zero);
      await player.resume();
    } catch (e) {
      debugPrint('wheel sound failed: $e');
    }
  }

  Future<Source?> _sourceFor(String id, WheelConfig config) async {
    final asset = config.soundAsset(id);
    if (asset != null && asset.isNotEmpty) return AssetSource(asset);
    if (id == wheelSoundCustom) return _custom ??= customSoundSource();
    return null;
  }

  AudioContext? _context() {
    if (kIsWeb) return null;
    final p = defaultTargetPlatform;
    if (p != TargetPlatform.android && p != TargetPlatform.iOS) return null;
    return AudioContextConfig(
      focus: AudioContextConfigFocus.mixWithOthers,
      respectSilence: p == TargetPlatform.iOS,
    ).build();
  }
}
