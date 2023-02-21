package me.spencernold.server.encryption;

import java.math.BigInteger;
import java.security.KeyFactory;
import java.security.interfaces.RSAPublicKey;
import java.security.spec.RSAPublicKeySpec;

public class PublicKey {

	private final RSAPublicKey publicKey;
	
	public PublicKey(RSAPublicKey publicKey) {
		this.publicKey = publicKey;
	}
	
	public RSAPublicKey getKeyInstance() {
		return publicKey;
	}
	
	public byte[] serialize() {
		return publicKey.getModulus().toByteArray();
	}
	
	public static PublicKey deserialize(byte[] data) {
		try {
			KeyFactory factory = KeyFactory.getInstance("RSA");
			return new PublicKey((RSAPublicKey) factory.generatePublic(new RSAPublicKeySpec(new BigInteger(data), BigInteger.valueOf(65537))));
		} catch (Exception e) {
			e.printStackTrace();
			return null;
		}
	}
}
