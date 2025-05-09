import 'package:flutter/material.dart';
import '../models/sound_model.dart';

class Constants {
  static const String appName = "TrollPro Max";
  
  // Sound paths
  static const String electricGunPath = "assets/sounds/electric_gun/electric_gun.mp3";
  // New electric sounds
  static const String electricShockPath = "assets/sounds/electric_sound/electric-shock-97989.mp3";
  static const String electricWhooshPath = "assets/sounds/electric_sound/electric-whoosh-01-204487.mp3";
  static const String electricPath = "assets/sounds/electric_sound/electric-90746.mp3";
  
  static const String mosquitoPath = "assets/sounds/mosquito/mosquito.mp3";
  // Additional mosquito sounds
  static const String windAndMosquitoPath = "assets/sounds/mosquito/wind-and-mosquito-7714.mp3";
  static const String mosquito2Path = "assets/sounds/mosquito/mosquito-22808.mp3";
  static const String flyingMosquitoPath = "assets/sounds/mosquito/flying-mosquito-105770.mp3";
  
  static const String tensionerPath = "assets/sounds/tensioner/tensioner.mp3";
  
  // Hair clipper sounds
  static const String hairTrimmerPath = "assets/sounds/hair_clipper/hair-trimmer-326191.mp3";
  static const String hairClipperMachinePath = "assets/sounds/hair_clipper/hair-clipper-machine-63593.mp3";
  static const String hairClipper2Path = "assets/sounds/hair_clipper/hair-clipper-83920.mp3";
  
  static const String fartPath = "assets/sounds/fart/fart.mp3";
  static const String alarmPath = "assets/sounds/alarm/alarm.mp3";
  
  // Icon data for each sound
  static final IconData electricGunIcon = Icons.electric_bolt;
  static final IconData electricShockIcon = Icons.bolt;
  static final IconData electricWhooshIcon = Icons.flash_on;
  static final IconData electricIcon = Icons.electrical_services;
  
  static final IconData mosquitoIcon = Icons.pest_control;
  static final IconData windAndMosquitoIcon = Icons.air;
  static final IconData mosquito2Icon = Icons.bug_report;
  static final IconData flyingMosquitoIcon = Icons.flight;
  
  static final IconData tensionerIcon = Icons.content_cut;
  
  static final IconData hairTrimmerIcon = Icons.cut;
  static final IconData hairClipperMachineIcon = Icons.cut_sharp;
  static final IconData hairClipper2Icon = Icons.cut_outlined;
  
  static final IconData fartIcon = Icons.wind_power;
  static final IconData alarmIcon = Icons.alarm;
  static final IconData errorIcon = Icons.error;
  static final IconData unclickableIcon = Icons.touch_app;
  static final IconData terminalIcon = Icons.terminal;
  
  // List of sound models
  static List<SoundModel> getSoundsList() {
    return [
      SoundModel(
        id: "electric_gun",
        name: "Electric Gun",
        soundPath: electricGunPath,
        iconName: electricGunIcon.codePoint.toString(),
      ),
      SoundModel(
        id: "electric_shock",
        name: "Electric Shock",
        soundPath: electricShockPath,
        iconName: electricShockIcon.codePoint.toString(),
      ),
      SoundModel(
        id: "electric_whoosh",
        name: "Electric Whoosh",
        soundPath: electricWhooshPath,
        iconName: electricWhooshIcon.codePoint.toString(),
      ),
      SoundModel(
        id: "electric",
        name: "Electric Sound",
        soundPath: electricPath,
        iconName: electricIcon.codePoint.toString(),
      ),
      SoundModel(
        id: "mosquito",
        name: "Mosquito",
        soundPath: mosquitoPath,
        iconName: mosquitoIcon.codePoint.toString(),
      ),
      SoundModel(
        id: "wind_and_mosquito",
        name: "Wind & Mosquito",
        soundPath: windAndMosquitoPath,
        iconName: windAndMosquitoIcon.codePoint.toString(),
      ),
      SoundModel(
        id: "mosquito2",
        name: "Mosquito 2",
        soundPath: mosquito2Path,
        iconName: mosquito2Icon.codePoint.toString(),
      ),
      SoundModel(
        id: "flying_mosquito",
        name: "Flying Mosquito",
        soundPath: flyingMosquitoPath,
        iconName: flyingMosquitoIcon.codePoint.toString(),
      ),
      SoundModel(
        id: "tensioner",
        name: "Hair Trimmer",
        soundPath: tensionerPath,
        iconName: tensionerIcon.codePoint.toString(),
      ),
      SoundModel(
        id: "hair_trimmer",
        name: "Hair Trimmer 2",
        soundPath: hairTrimmerPath,
        iconName: hairTrimmerIcon.codePoint.toString(),
      ),
      SoundModel(
        id: "hair_clipper_machine",
        name: "Hair Clipper Machine",
        soundPath: hairClipperMachinePath,
        iconName: hairClipperMachineIcon.codePoint.toString(),
      ),
      SoundModel(
        id: "hair_clipper2",
        name: "Hair Clipper 2",
        soundPath: hairClipper2Path,
        iconName: hairClipper2Icon.codePoint.toString(),
      ),
      SoundModel(
        id: "fart",
        name: "Fart",
        soundPath: fartPath,
        iconName: fartIcon.codePoint.toString(),
      ),
      SoundModel(
        id: "alarm",
        name: "Alarm",
        soundPath: alarmPath,
        iconName: alarmIcon.codePoint.toString(),
      ),
    ];
  }
  
  // Animation durations
  static const Duration buttonAnimationDuration = Duration(milliseconds: 200);
  static const Duration pageTransitionDuration = Duration(milliseconds: 300);
  static const Duration flashlightFlickerDuration = Duration(milliseconds: 100);
  static const Duration vibrationDuration = Duration(milliseconds: 300);
  static const Duration errorScreenDuration = Duration(seconds: 5);
} 