package me.spencernold.server.encryption;

import java.security.SecureRandom;

public class JavaSecureRandom {

	private static SecureRandom random = new SecureRandom();
	
	public static byte[] nextBytes(int count) {
		byte[] bytes = new byte[count];
		random.nextBytes(bytes);
		return bytes;
	}
}
