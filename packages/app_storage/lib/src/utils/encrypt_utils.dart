import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart' as crypto;
import 'package:encrypt/encrypt.dart' as encrypt;

/// 加密工具类
/// 
/// 提供AES加密解密、哈希生成等工具方法
class EncryptUtils {
  // 私有构造函数，防止实例化
  EncryptUtils._();
  
  /// 加密字符串
  /// 
  /// [plainText] 要加密的文本
  /// [key] 加密密钥
  /// 返回加密后的字符串，Base64编码
  static String encryptText(String plainText, String key) {
    if (plainText.isEmpty) return plainText;
    
    try {
      // 生成密钥和IV
      final keyBytes = crypto.sha256.convert(utf8.encode(key)).bytes;
      final encrypter = encrypt.Encrypter(
          encrypt.AES(encrypt.Key(Uint8List.fromList(keyBytes)),
              mode: encrypt.AESMode.cbc));
      final iv = encrypt.IV.fromLength(16);
      
      // 加密
      final encrypted = encrypter.encrypt(plainText, iv: iv);
      
      // 合并IV和密文，并Base64编码
      final combined = Uint8List(iv.bytes.length + encrypted.bytes.length);
      combined.setAll(0, iv.bytes);
      combined.setAll(iv.bytes.length, encrypted.bytes);
      return base64.encode(combined);
    } catch (e) {
      // 出错时返回原文
      return plainText;
    }
  }

  /// 解密字符串
  /// 
  /// [encryptedText] 要解密的文本，Base64编码
  /// [key] 解密密钥
  /// 返回解密后的字符串
  static String decryptText(String encryptedText, String key) {
    if (encryptedText.isEmpty) return encryptedText;
    
    try {
      // 解码Base64
      final bytes = base64.decode(encryptedText);
      if (bytes.length < 16) return encryptedText; // IV长度至少16字节
      
      // 提取IV和密文
      final iv = encrypt.IV(Uint8List.fromList(bytes.sublist(0, 16)));
      final encrypted = encrypt.Encrypted(Uint8List.fromList(bytes.sublist(16)));
      
      // 生成密钥
      final keyBytes = crypto.sha256.convert(utf8.encode(key)).bytes;
      final encrypter = encrypt.Encrypter(
          encrypt.AES(encrypt.Key(Uint8List.fromList(keyBytes)),
              mode: encrypt.AESMode.cbc));
      
      // 解密
      return encrypter.decrypt(encrypted, iv: iv);
    } catch (e) {
      // 出错时返回原文
      return encryptedText;
    }
  }

  /// 生成MD5哈希
  ///
  /// [input] 输入数据
  /// 返回MD5哈希字符串
  static String getMd5(String input) {
    return crypto.md5.convert(utf8.encode(input)).toString();
  }

  /// 生成SHA256哈希
  ///
  /// [input] 输入数据
  /// 返回SHA256哈希字符串
  static String getSha256(String input) {
    return crypto.sha256.convert(utf8.encode(input)).toString();
  }
}
