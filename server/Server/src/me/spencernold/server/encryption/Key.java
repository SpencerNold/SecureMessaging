package me.spencernold.server.encryption;

import javax.crypto.SecretKey;
import javax.crypto.spec.SecretKeySpec;

public class Key {

	private final byte[] bytes;
	
	public Key(byte[] bytes) {
		this.bytes = bytes;
	}
	
	public byte[] getBytes() {
		return bytes;
	}
	
	public SecretKey secretKey() {
		return new SecretKeySpec(bytes, "AES");
	}
	
	public static Key generate() {
		return new Key(JavaSecureRandom.nextBytes(32));
	}
}
