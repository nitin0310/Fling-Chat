import 'package:encrypt/encrypt.dart' as encrypt;

class EncryptDecrypt {

  static final key = encrypt.Key.fromLength(32);
  static final iv = encrypt.IV.fromLength(16);
  static final encrypter = encrypt.Encrypter(encrypt.AES(key));

  static String encryptMessage(String message){
  final encryptedInstance = encrypter.encrypt(message,iv: iv);
  String encryptedText = encryptedInstance.base16;

  return encryptedText;
  }

  static decryptMessage(String message){
  String decryptedText = encrypter.decrypt16(message,iv: iv);
  return decryptedText;
  }


}