package me.spencernold.server.encryption;

import java.math.BigInteger;
import java.security.KeyFactory;
import java.security.interfaces.RSAPrivateKey;
import java.security.spec.RSAPrivateKeySpec;
import java.util.Arrays;

import me.spencernold.server.util.ByteTool;

public class PrivateKey {
	
	private final RSAPrivateKey privateKey;
	
	public PrivateKey(RSAPrivateKey privateKey) {
		this.privateKey = privateKey;
	}

	public RSAPrivateKey getKeyInstance() {
		return privateKey;
	}
	
	public byte[] serialize() {
		BigInteger modulus = privateKey.getModulus();
		BigInteger exponent = privateKey.getPrivateExponent();
		return ByteTool.append(modulus.toByteArray(), exponent.toByteArray());
	}
	
	public static PrivateKey deserialize(byte[] bytes) {
		BigInteger modulus = new BigInteger(Arrays.copyOfRange(bytes, 0, 513));
		BigInteger exponent = new BigInteger(Arrays.copyOfRange(bytes, 513, 1025));
		try {
			KeyFactory factory = KeyFactory.getInstance("RSA");
			return new PrivateKey((RSAPrivateKey) factory.generatePrivate(new RSAPrivateKeySpec(modulus, exponent)));
		} catch (Exception e) {
			e.printStackTrace();
			return null;
		}
	}
}
