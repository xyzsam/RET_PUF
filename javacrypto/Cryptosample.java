import java.io.FileInputStream;
import java.io.FileOutputStream;

import java.security.Key;
import java.security.KeyPair;
import java.security.KeyPairGenerator;
import java.security.Security;

import javax.crypto.Cipher;
import javax.crypto.CipherInputStream;
import javax.crypto.CipherOutputStream;
import javax.crypto.KeyGenerator;
import javax.crypto.SecretKey;

public class Cryptosample {

  public static void main(String[] args) throws Exception {
    String[] algorithms = {"AES", "DES", "DESede", "Blowfish"};
    int[] keysize = {256, 56, 168, 448};
    String mode = "ECB";
    String padding = "NoPadding";
    for (int i = 0; i < algorithms.length; i ++) {
      System.out.println("Algorithm: " + algorithms[i]);
      encrypt(algorithms[i], mode, padding, keysize[i]);
    }
  }

  /**
   * Encrypts a hardcoded file using the given parameters.
   */
  public static void encrypt(String algorithm,
                             String mode,
                             String padding,
                             int keysize) throws Exception {
    String param = algorithm + "/" + mode + "/" + padding;
    Cipher cipher = Cipher.getInstance(param, "SunJCE");
    KeyGenerator keygen = KeyGenerator.getInstance(algorithm, "SunJCE");
    keygen.init(keysize);
    SecretKey secretKey = keygen.generateKey();
    cipher.init(Cipher.ENCRYPT_MODE, secretKey);

    String cleartextFile = "gettysburg2.txt";
    String ciphertextFile = "ciphertext"+algorithm+".txt";

    FileInputStream fis = new FileInputStream(cleartextFile);
    FileOutputStream fos = new FileOutputStream(ciphertextFile);
    CipherOutputStream cos = new CipherOutputStream(fos, cipher);

    byte[] block = new byte[8];
    int i;
    while ((i = fis.read(block)) != -1) {
      // pad the very last block with the character 'A'.
      for (int j = i; j < 8; j ++) {
        block[j] = 65;
      }
      cos.write(block, 0, i);
    }
    cos.close();

    cipher.init(Cipher.DECRYPT_MODE, secretKey);
    String decryptedTextFile = "decrypted"+algorithm+".txt";
    fis = new FileInputStream(ciphertextFile);
    CipherInputStream cis = new CipherInputStream(fis, cipher);
    fos = new FileOutputStream(decryptedTextFile);

    while ((i = cis.read(block)) != -1) {
      fos.write(block, 0, i);
    }
    fos.close();
  }
}
