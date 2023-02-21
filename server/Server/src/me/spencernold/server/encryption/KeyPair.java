package me.spencernold.server.encryption;

import java.security.KeyPairGenerator;
import java.security.NoSuchAlgorithmException;
import java.security.interfaces.RSAPrivateKey;
import java.security.interfaces.RSAPublicKey;
import java.util.Arrays;

import me.spencernold.server.util.ByteTool;

public class KeyPair {

	private final PrivateKey privateKey;
	private final PublicKey publicKey;
	
	public KeyPair(PrivateKey privateKey, PublicKey publicKey) {
		this.privateKey = privateKey;
		this.publicKey = publicKey;
	}
	
	public PrivateKey getPrivateKey() {
		return privateKey;
	}
	
	public PublicKey getPublicKey() {
		return publicKey;
	}
	
	public byte[] serialize() {
		return ByteTool.append(privateKey.serialize(), publicKey.serialize());
	}
	
	public static KeyPair deserialize(byte[] bytes) {
		PrivateKey privateKey = PrivateKey.deserialize(bytes);
		PublicKey publicKey = PublicKey.deserialize(Arrays.copyOfRange(bytes, 1025, bytes.length));
		return new KeyPair(privateKey, publicKey);
	}
	
	public static KeyPair generate() {
		try {
			KeyPairGenerator generator = KeyPairGenerator.getInstance("RSA");
			generator.initialize(4096);
			java.security.KeyPair javaKeyPair = generator.generateKeyPair();
			return new KeyPair(new PrivateKey((RSAPrivateKey) javaKeyPair.getPrivate()), new PublicKey((RSAPublicKey) javaKeyPair.getPublic()));
		} catch (NoSuchAlgorithmException e) {
			e.printStackTrace();
			return null;
		}
	}
}
