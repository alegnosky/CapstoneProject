import 'dart:math';
import 'dart:async';
import 'package:flutter/services.dart' show rootBundle;

class PasswordGenerator {
  static String generate({int length = 32}) {
    const String chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$%^&*()-_=+';
    final Random random = Random.secure();
    return List.generate(length, (index) => chars[random.nextInt(chars.length)])
        .join();
  }

  static Future<String> generatePassPhrase({int wordCount = 4, String separator = '-',
  bool addNumbers = true, int maxNumberValue = 100,}) async{
    try {
      final String wordlistString = await rootBundle.loadString('assets/wordlist.txt');
      final List<String> words = wordlistString.split('\n').map((s)=>s.trim()).where((s)=>s.isNotEmpty).toList();
      if(words.isEmpty){
        return 'No Wordlist found';
      }
      final Random random = Random.secure();
      List<String> passphraseWords = [];
      for (int i = 0; i < wordCount; i++){
        passphraseWords.add(words[random.nextInt(words.length)]);
      }
      String corePassphrase = passphraseWords.join(separator);
      if (addNumbers) {
        String prefixNumber = random.nextInt(maxNumberValue).toString();
        String suffixNumber = random.nextInt(maxNumberValue).toString();
        return '$prefixNumber$separator$corePassphrase$separator$suffixNumber';
      } else {
        return corePassphrase;
      }
    }catch (e) {
      print("Error generating passphrase: $e");
      return 'Error generating passphrase';
    }
  }
}
