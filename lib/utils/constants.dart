import 'package:flutter/material.dart';
import '../models/sound_model.dart';
import '../models/sound_category.dart';
import 'app_config.dart';

/// Application-wide constants
class Constants {
  /// App information
  static const String appName = 'Troll Sounds';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'A fun sound effects prank app';
  
  /// Shared Preferences keys
  static const String favoriteSoundsKey = 'favorite_sounds';
  static const String recentSoundsKey = 'recent_sounds';
  static const String customSoundsKey = 'custom_sounds';
  
  /// Duration constants
  static const int defaultSoundDuration = 3000; // milliseconds
  static const int vibrationDuration = 100; // milliseconds
  static const int shortAnimationDuration = 300; // milliseconds
  static const int mediumAnimationDuration = 500; // milliseconds
  static const int longAnimationDuration = 800; // milliseconds
  
  /// Volume levels
  static const double maxVolume = 1.0;
  static const double defaultVolume = 0.8;
  static const double lowVolume = 0.5;
  static const double minVolume = 0.1;
  
  /// UI Design Constants
  static const double buttonBorderRadius = 16.0;
  static const double cardBorderRadius = 20.0;
  static const double smallPadding = 8.0;
  static const double defaultPadding = 16.0;
  static const double largePadding = 24.0;
  
  /// Device-specific constants
  static const int iosBackgroundTaskDuration = 30; // seconds
  
  /// URLs
  static const String privacyPolicyUrl = 'https://quhie.github.io/hehehe';
  static const String termsUrl = 'https://quhie.github.io/hehehe';
  static const String supportEmail = 'doquanghieu.dev@gmail.com';
  
  // Storage keys
  static const String userSoundsCategoriesKey = "user_sounds_categories";
  static const String themeModeKey = "theme_mode";
  
  // Sound paths - fixed by removing extra 'assets/' prefix
  static const String electricGunPath = "sounds/electric_gun/electric_gun.mp3";
  static const String electricShockPath = "sounds/electric_sound/electric_shock.mp3";
  static const String electricWhooshPath = "sounds/electric_sound/electric_whoosh.mp3";
  static const String electricPath = "sounds/electric_sound/electric.mp3";
  
  static const String mosquitoPath = "sounds/mosquito/mosquito.mp3";
  static const String windAndMosquitoPath = "sounds/mosquito/wind_and_mosquito.mp3";
  static const String mosquito2Path = "sounds/mosquito/mosquito2.mp3";
  static const String flyingMosquitoPath = "sounds/mosquito/flying_mosquito.mp3";
  
  static const String tensionerPath = "sounds/tensioner/tensioner.mp3";
  
  // Hair clipper sounds
  static const String hairTrimmerPath = "sounds/hair_clipper/hair_trimmer.mp3";
  static const String hairClipperMachinePath = "sounds/hair_clipper/hair_clipper_machine.mp3";
  static const String hairClipper2Path = "sounds/hair_clipper/hair_clipper2.mp3";
  
  static const String fartPath = "sounds/fart/fart.mp3";
  static const String alarmPath = "sounds/alarm/alarm.mp3";
  
  // New sounds for extended functionality
  static const String policeCarPath = "sounds/alarm/police_car.mp3";
  static const String fireAlarmPath = "sounds/alarm/fire_alarm.mp3";
  static const String doorbellPath = "sounds/alarm/doorbell.mp3";
  static const String dogBarkPath = "sounds/alarm/dog_bark.mp3";
  static const String catMeowPath = "sounds/alarm/cat_meow.mp3";
  static const String explosionPath = "sounds/alarm/explosion.mp3";
  static const String glassBreakPath = "sounds/alarm/glass_break.mp3";
  
  // Phone device sounds
  static const String ringingTonePath = "sounds/340178__quhie__phone-device-sounds/676348__alex36917__ringing-tone-answering-then-hanging-up.wav";
  static const String cameraBeepPath = "sounds/340178__quhie__phone-device-sounds/624936__theplax__camera-beep-and-click.wav";
  static const String messengerNotificationPath = "sounds/340178__quhie__phone-device-sounds/400697__daphne_in_wonderland__messenger-notification-sound-imitation.wav";
  
  // Game troll sounds
  static const String victorySting1Path = "sounds/340179__quhie__game-troll-sounds/741118__victor_natas__victory-sting-1.wav";
  static const String victorySting2Path = "sounds/340179__quhie__game-troll-sounds/741973__victor_natas__victory-sting-2.wav";
  
  // Social alarm sounds
  static const String burglarAlarmPath = "sounds/340180__quhie__social-alarm-sounds/613652__melokacool__burglar-alarm.wav";
  static const String piercerPath = "sounds/340180__quhie__social-alarm-sounds/58016__guitarguy1985__piercer.wav";
  static const String fireAlarmSweepingPath = "sounds/340180__quhie__social-alarm-sounds/255181__adamweeden__bs-fire-alarm-sweeping-1-hz.wav";
  static const String scannerBeepPath = "sounds/340180__quhie__social-alarm-sounds/144418__zerolagtime__store-scanner-beep.mp3";
  
  // Jumpscare horror sounds
  static const String horrorDarkPath = "sounds/340184__quhie__jumpscare-horror-sounds/481966__rog864__horror-dark-sound-1.wav";
  static const String spookyHorrorPath = "sounds/340184__quhie__jumpscare-horror-sounds/275186__lennyboy__spookyhorrorsound.ogg";
  static const String slenderPath = "sounds/340184__quhie__jumpscare-horror-sounds/167921__commanderderp__slender.mp3";
  
  // Meme funny sounds
  static const String bruhSoundPath = "sounds/340182__quhie__meme-funny-sounds/534387__autellaem__bruh-sound-effect-1.mp3";
  static const String spaceThumpPath = "sounds/340182__quhie__meme-funny-sounds/237558__bareform__thumps-clangs-and-booms-in-space.aiff";
  static const String toBeContinuedPath = "sounds/340182__quhie__meme-funny-sounds/222374__speedenza__to-be-continued-voice.wav";
  static const String wompPath = "sounds/340182__quhie__meme-funny-sounds/178687__stonedb__womp.wav";
  
  // Icon data for each sound
  static final IconData electricGunIcon = Icons.bolt;
  static final IconData electricShockIcon = Icons.electric_bolt;
  static final IconData electricWhooshIcon = Icons.flash_on;
  static final IconData electricIcon = Icons.power;
  
  static final IconData mosquitoIcon = Icons.pest_control;
  static final IconData windAndMosquitoIcon = Icons.air;
  static final IconData mosquito2Icon = Icons.bug_report;
  static final IconData flyingMosquitoIcon = Icons.air;
  
  static final IconData tensionerIcon = Icons.cut;
  
  static final IconData hairTrimmerIcon = Icons.cut_sharp;
  static final IconData hairClipperMachineIcon = Icons.content_cut;
  static final IconData hairClipper2Icon = Icons.trending_flat;
  
  static final IconData fartIcon = Icons.whatshot;
  static final IconData alarmIcon = Icons.alarm;
  static final IconData errorIcon = Icons.error;
  static final IconData unclickableIcon = Icons.touch_app;
  static final IconData terminalIcon = Icons.terminal;
  
  // New icons for extended functionality
  static final IconData policeCarIcon = Icons.local_police;
  static final IconData fireAlarmIcon = Icons.warning;
  static final IconData doorbellIcon = Icons.doorbell;
  static final IconData dogBarkIcon = Icons.pets;
  static final IconData catMeowIcon = Icons.pets;
  static final IconData explosionIcon = Icons.emergency;
  static final IconData glassBreakIcon = Icons.broken_image;
  
  // New icons for added sounds
  static final IconData ringingToneIcon = Icons.phone;
  static final IconData cameraBeepIcon = Icons.camera_alt;
  static final IconData messengerNotificationIcon = Icons.message;
  static final IconData victorySting1Icon = Icons.emoji_events;
  static final IconData victorySting2Icon = Icons.celebration;
  static final IconData burglarAlarmIcon = Icons.home;
  static final IconData piercerIcon = Icons.hearing;
  static final IconData fireAlarmSweepingIcon = Icons.fire_extinguisher;
  static final IconData scannerBeepIcon = Icons.qr_code_scanner;
  static final IconData horrorDarkIcon = Icons.dark_mode;
  static final IconData spookyHorrorIcon = Icons.front_hand;
  static final IconData slenderIcon = Icons.person_outline;
  static final IconData bruhSoundIcon = Icons.record_voice_over;
  static final IconData spaceThumpIcon = Icons.stars;
  static final IconData toBeContinuedIcon = Icons.arrow_right_alt;
  static final IconData wompIcon = Icons.waves;
  
  // Default sound category options
  static final List<String> defaultSoundCategories = [
    'Favorites',
    'Animals',
    'Alarms',
    'Electric',
    'Pranks',
    'Household',
    'Phone',
    'Game',
    'Meme',
    'Horror'
  ];
  
  // List of sound models
  static List<SoundModel> getSoundsList() {
    return [
      SoundModel(
        id: "electric_gun",
        name: "Electric Gun",
        soundPath: electricGunPath,
        iconName: electricGunIcon.codePoint.toString(),
        category: CategoryType.phone,
      ),
      SoundModel(
        id: "electric_shock",
        name: "Electric Shock",
        soundPath: electricShockPath,
        iconName: electricShockIcon.codePoint.toString(),
        category: CategoryType.phone,
      ),
      SoundModel(
        id: "electric_whoosh",
        name: "Electric Whoosh",
        soundPath: electricWhooshPath,
        iconName: electricWhooshIcon.codePoint.toString(),
        category: CategoryType.meme,
      ),
      SoundModel(
        id: "electric",
        name: "Electric Sound",
        soundPath: electricPath,
        iconName: electricIcon.codePoint.toString(),
        category: CategoryType.meme,
      ),
      SoundModel(
        id: "mosquito",
        name: "Mosquito",
        soundPath: mosquitoPath,
        iconName: mosquitoIcon.codePoint.toString(),
        category: CategoryType.horror,
      ),
      SoundModel(
        id: "wind_and_mosquito",
        name: "Wind & Mosquito",
        soundPath: windAndMosquitoPath,
        iconName: windAndMosquitoIcon.codePoint.toString(),
        category: CategoryType.horror,
      ),
      SoundModel(
        id: "mosquito2",
        name: "Mosquito 2",
        soundPath: mosquito2Path,
        iconName: mosquito2Icon.codePoint.toString(),
        category: CategoryType.horror,
      ),
      SoundModel(
        id: "flying_mosquito",
        name: "Flying Mosquito",
        soundPath: flyingMosquitoPath,
        iconName: flyingMosquitoIcon.codePoint.toString(),
        category: CategoryType.horror,
      ),
      SoundModel(
        id: "tensioner",
        name: "Hair Trimmer",
        soundPath: tensionerPath,
        iconName: tensionerIcon.codePoint.toString(),
        category: CategoryType.meme,
      ),
      SoundModel(
        id: "hair_trimmer",
        name: "Hair Trimmer 2",
        soundPath: hairTrimmerPath,
        iconName: hairTrimmerIcon.codePoint.toString(),
        category: CategoryType.meme,
      ),
      SoundModel(
        id: "hair_clipper_machine",
        name: "Hair Clipper Machine",
        soundPath: hairClipperMachinePath,
        iconName: hairClipperMachineIcon.codePoint.toString(),
        category: CategoryType.meme,
      ),
      SoundModel(
        id: "hair_clipper2",
        name: "Hair Clipper 2",
        soundPath: hairClipper2Path,
        iconName: hairClipper2Icon.codePoint.toString(),
        category: CategoryType.meme,
      ),
      SoundModel(
        id: "fart",
        name: "Fart",
        soundPath: fartPath,
        iconName: fartIcon.codePoint.toString(),
        category: CategoryType.meme,
      ),
      SoundModel(
        id: "alarm",
        name: "Alarm",
        soundPath: alarmPath,
        iconName: alarmIcon.codePoint.toString(),
        category: CategoryType.alarm,
      ),
      // New sounds for expanded functionality
      SoundModel(
        id: "police_car",
        name: "Police Siren",
        soundPath: policeCarPath,
        iconName: policeCarIcon.codePoint.toString(),
        category: CategoryType.alarm,
      ),
      SoundModel(
        id: "fire_alarm",
        name: "Fire Alarm",
        soundPath: fireAlarmPath,
        iconName: fireAlarmIcon.codePoint.toString(),
        category: CategoryType.alarm,
      ),
      SoundModel(
        id: "doorbell",
        name: "Doorbell",
        soundPath: doorbellPath,
        iconName: doorbellIcon.codePoint.toString(),
        category: CategoryType.phone,
      ),
      SoundModel(
        id: "dog_bark",
        name: "Dog Bark",
        soundPath: dogBarkPath,
        iconName: dogBarkIcon.codePoint.toString(),
        category: CategoryType.meme,
      ),
      SoundModel(
        id: "cat_meow",
        name: "Cat Meow",
        soundPath: catMeowPath,
        iconName: catMeowIcon.codePoint.toString(),
        category: CategoryType.meme,
      ),
      SoundModel(
        id: "explosion",
        name: "Explosion",
        soundPath: explosionPath,
        iconName: explosionIcon.codePoint.toString(),
        category: CategoryType.game,
      ),
      SoundModel(
        id: "glass_break",
        name: "Glass Breaking",
        soundPath: glassBreakPath,
        iconName: glassBreakIcon.codePoint.toString(),
        category: CategoryType.horror,
      ),
      
      // Phone device sounds
      SoundModel(
        id: "ringing_tone",
        name: "Phone Ringing",
        soundPath: ringingTonePath,
        iconName: ringingToneIcon.codePoint.toString(),
        category: CategoryType.phone,
      ),
      SoundModel(
        id: "camera_beep",
        name: "Camera Beep & Click",
        soundPath: cameraBeepPath,
        iconName: cameraBeepIcon.codePoint.toString(),
        category: CategoryType.phone,
      ),
      SoundModel(
        id: "messenger_notification",
        name: "Messenger Notification",
        soundPath: messengerNotificationPath,
        iconName: messengerNotificationIcon.codePoint.toString(),
        category: CategoryType.phone,
      ),
      
      // Game troll sounds
      SoundModel(
        id: "victory_sting1",
        name: "Victory Sting 1",
        soundPath: victorySting1Path,
        iconName: victorySting1Icon.codePoint.toString(),
        category: CategoryType.game,
      ),
      SoundModel(
        id: "victory_sting2",
        name: "Victory Sting 2",
        soundPath: victorySting2Path,
        iconName: victorySting2Icon.codePoint.toString(),
        category: CategoryType.game,
      ),
      
      // Social alarm sounds
      SoundModel(
        id: "burglar_alarm",
        name: "Burglar Alarm",
        soundPath: burglarAlarmPath,
        iconName: burglarAlarmIcon.codePoint.toString(),
        category: CategoryType.alarm,
      ),
      SoundModel(
        id: "piercer",
        name: "Piercer Sound",
        soundPath: piercerPath,
        iconName: piercerIcon.codePoint.toString(),
        category: CategoryType.alarm,
      ),
      SoundModel(
        id: "fire_alarm_sweeping",
        name: "Fire Alarm Sweeping",
        soundPath: fireAlarmSweepingPath,
        iconName: fireAlarmSweepingIcon.codePoint.toString(),
        category: CategoryType.alarm,
      ),
      SoundModel(
        id: "scanner_beep",
        name: "Scanner Beep",
        soundPath: scannerBeepPath,
        iconName: scannerBeepIcon.codePoint.toString(),
        category: CategoryType.phone,
      ),
      
      // Jumpscare horror sounds
      SoundModel(
        id: "horror_dark",
        name: "Horror Dark Sound",
        soundPath: horrorDarkPath,
        iconName: horrorDarkIcon.codePoint.toString(),
        category: CategoryType.horror,
      ),
      SoundModel(
        id: "spooky_horror",
        name: "Spooky Horror Sound",
        soundPath: spookyHorrorPath,
        iconName: spookyHorrorIcon.codePoint.toString(),
        category: CategoryType.horror,
      ),
      SoundModel(
        id: "slender",
        name: "Slender Sound",
        soundPath: slenderPath,
        iconName: slenderIcon.codePoint.toString(),
        category: CategoryType.horror,
      ),
      
      // Meme funny sounds
      SoundModel(
        id: "bruh_sound",
        name: "Bruh Sound Effect",
        soundPath: bruhSoundPath,
        iconName: bruhSoundIcon.codePoint.toString(),
        category: CategoryType.meme,
      ),
      SoundModel(
        id: "space_thump",
        name: "Space Thumps & Booms",
        soundPath: spaceThumpPath,
        iconName: spaceThumpIcon.codePoint.toString(),
        category: CategoryType.meme,
      ),
      SoundModel(
        id: "to_be_continued",
        name: "To Be Continued",
        soundPath: toBeContinuedPath,
        iconName: toBeContinuedIcon.codePoint.toString(),
        category: CategoryType.meme,
      ),
      SoundModel(
        id: "womp",
        name: "Womp Sound",
        soundPath: wompPath,
        iconName: wompIcon.codePoint.toString(),
        category: CategoryType.meme,
      ),
    ];
  }
  
  // Get sounds by category
  static List<SoundModel> getSoundsByCategory(String category) {
    final allSounds = getSoundsList();
    
    switch (category.toLowerCase()) {
      case 'animals':
        return allSounds.where((sound) => 
          sound.id.contains('mosquito') || 
          sound.id.contains('dog') || 
          sound.id.contains('cat')
        ).toList();
      case 'alarms':
        return allSounds.where((sound) => 
          sound.id.contains('alarm') || 
          sound.id.contains('police') || 
          sound.id.contains('fire') ||
          sound.id.contains('doorbell') ||
          sound.id.contains('piercer') ||
          sound.id.contains('burglar')
        ).toList();
      case 'electric':
        return allSounds.where((sound) => 
          sound.id.contains('electric')
        ).toList();
      case 'pranks':
        return allSounds.where((sound) => 
          sound.id.contains('fart') || 
          sound.id.contains('mosquito') ||
          sound.id.contains('explosion') ||
          sound.id.contains('glass') ||
          sound.id.contains('bruh') ||
          sound.id.contains('womp')
        ).toList();
      case 'household':
        return allSounds.where((sound) => 
          sound.id.contains('door') || 
          sound.id.contains('glass') || 
          sound.id.contains('trimmer') ||
          sound.id.contains('clipper')
        ).toList();
      case 'phone':
        return allSounds.where((sound) => 
          sound.category == CategoryType.phone
        ).toList();
      case 'game':
        return allSounds.where((sound) => 
          sound.category == CategoryType.game
        ).toList();
      case 'meme':
        return allSounds.where((sound) => 
          sound.category == CategoryType.meme
        ).toList();
      case 'horror':
        return allSounds.where((sound) => 
          sound.category == CategoryType.horror
        ).toList();
      default:
        return allSounds;
    }
  }
  
  // Animation durations
  static const Duration buttonAnimationDuration = Duration(milliseconds: 200);
  static const Duration pageTransitionDuration = Duration(milliseconds: 300);
  static const Duration flashlightFlickerDuration = Duration(milliseconds: 100);
  static const Duration errorScreenDuration = Duration(seconds: 5);
  
  // App settings constants
  static const String settingsStorageKey = 'troll_app_settings';
  static const String usernameKey = 'username';
  static const String appThemeKey = 'app_theme';
  static const String hapticFeedbackKey = 'haptic_feedback';
  static const String animationSpeedKey = 'animation_speed';
  static const String alarmHistoryKey = 'alarm_history';
}

/// App constants
class AppConstants {
  static const String APP_NAME = 'Troll Sounds';
  static const String APP_VERSION = '1.0.0';
  static const String APP_FEEDBACK_EMAIL = 'doquanghieu.dev@gmail.com';
  
  static const String appName = 'app_name';
  static const String tagline = 'app_tagline';
} 