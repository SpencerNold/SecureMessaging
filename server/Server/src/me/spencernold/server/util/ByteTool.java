package me.spencernold.server.util;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

public class ByteTool {

	public static byte[] hash(byte[] bytes) {
		try {
			MessageDigest digest = MessageDigest.getInstance("SHA-256");
			return digest.digest(bytes);
		} catch (NoSuchAlgorithmException e) {
			e.printStackTrace();
			return null;
		}
	}
	
	public static byte[] append(byte[] a1, byte[] a2) {
		byte[] array = new byte[a1.length + a2.length];
		System.arraycopy(a1, 0, array, 0, a1.length);
		System.arraycopy(a2, 0, array, a1.length, a2.length);
		return array;
	}
}