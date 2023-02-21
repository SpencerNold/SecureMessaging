package me.spencernold.server.encryption;

import java.security.NoSuchAlgorithmException;
import java.util.Arrays;

import javax.crypto.Cipher;
import javax.crypto.NoSuchPaddingException;
import javax.crypto.spec.GCMParameterSpec;

import me.spencernold.server.util.ByteTool;

public class AES {
	
	private static final int ivLength = 12;
	
	private final Key key;
	private Cipher cipher;
	
	public AES(Key key) {
		this.key = key;
		try {
			this.cipher = Cipher.getInstance("AES/GCM/NoPadding");
		} catch (NoSuchAlgorithmException | NoSuchPaddingException e) {
			e.printStackTrace();
		}
	}
	
	public byte[] encryptBytes(byte[] data) {
		try {
			byte[] iv = JavaSecureRandom.nextBytes(ivLength);
			cipher.init(Cipher.ENCRYPT_MODE, key.secretKey(), new GCMParameterSpec(128, iv));
			byte[] cipherText = cipher.doFinal(data);
			return ByteTool.append(iv, cipherText);
		} catch (Exception e) {
			e.printStackTrace();
			return null;
		}
	}
	
	public byte[] decryptBytes(byte[] data) {
		try {
			cipher.init(Cipher.DECRYPT_MODE, key.secretKey(), new GCMParameterSpec(128, Arrays.copyOfRange(data, 0, ivLength)));
			byte[] plainText = cipher.doFinal(Arrays.copyOfRange(data, ivLength, data.length));
			return plainText;
		} catch (Exception e) {
			e.printStackTrace();
			return null;
		}
	}
	
	public Key getKey() {
		return key;
	}
}
