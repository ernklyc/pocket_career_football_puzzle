import 'package:equatable/equatable.dart';

/// Oyun ayarları entity'si.
class GameSettings extends Equatable {
  final String language;
  final bool musicEnabled;
  final bool soundEnabled;
  final bool hapticsEnabled;
  final bool notificationsEnabled;

  const GameSettings({
    this.language = 'tr',
    this.musicEnabled = true,
    this.soundEnabled = true,
    this.hapticsEnabled = true,
    this.notificationsEnabled = true,
  });

  GameSettings copyWith({
    String? language,
    bool? musicEnabled,
    bool? soundEnabled,
    bool? hapticsEnabled,
    bool? notificationsEnabled,
  }) {
    return GameSettings(
      language: language ?? this.language,
      musicEnabled: musicEnabled ?? this.musicEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }

  Map<String, dynamic> toJson() => {
        'language': language,
        'musicEnabled': musicEnabled,
        'soundEnabled': soundEnabled,
        'hapticsEnabled': hapticsEnabled,
        'notificationsEnabled': notificationsEnabled,
      };

  factory GameSettings.fromJson(Map<String, dynamic> json) => GameSettings(
        language: json['language'] as String? ?? 'tr',
        musicEnabled: json['musicEnabled'] as bool? ?? true,
        soundEnabled: json['soundEnabled'] as bool? ?? true,
        hapticsEnabled: json['hapticsEnabled'] as bool? ?? true,
        notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      );

  @override
  List<Object?> get props =>
      [language, musicEnabled, soundEnabled, hapticsEnabled, notificationsEnabled];
}
