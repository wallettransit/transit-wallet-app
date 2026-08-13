import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioHapticService {
  static final AudioPlayer _audioPlayer = AudioPlayer();
  
  // A public URL for a short, satisfying "cash drop" or chime sound.
  // In a real app, this would be a bundled asset like 'assets/sounds/cash_drop.mp3'.
  static const String _cashDropUrl = 'https://actions.google.com/sounds/v1/cartoon/cartoon_boing.ogg';

  /// Plays the distinct OyaPay Cash Drop sound paired with a double heavy haptic pulse.
  static Future<void> playCashDrop() async {
    // 1. First Heavy Impact
    HapticFeedback.heavyImpact();
    
    // 2. Play Sound (if network allows, otherwise just haptics)
    try {
      await _audioPlayer.play(UrlSource(_cashDropUrl));
    } catch (e) {
      // Fallback to system sound if audioplayers fails
      SystemSound.play(SystemSoundType.click);
    }
    
    // 3. Wait a beat, then second Heavy Impact
    await Future.delayed(const Duration(milliseconds: 150));
    HapticFeedback.heavyImpact();
  }
}
