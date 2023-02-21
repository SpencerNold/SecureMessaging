package me.spencernold.server.auth;

import me.spencernold.server.encryption.PublicKey;
import me.spencernold.server.util.ByteBuffer;

public class User {

	private final String name;
	private final byte[] passwordHash;
	private final byte[] salt;
	private PublicKey publicKey;
	
	public User(String name, byte[] passwordHash, byte[] salt, PublicKey publicKey) {
		this.name = name;
		this.passwordHash = passwordHash;
		this.salt = salt;
		this.publicKey = publicKey;
	}
	
	public String getName() {
		return name;
	}
	
	public byte[] getPasswordHash() {
		return passwordHash;
	}
	
	public byte[] getSalt() {
		return salt;
	}
	
	public PublicKey getPublicKey() {
		return publicKey;
	}
	
	public void setPublicKey(PublicKey publicKey) {
		this.publicKey = publicKey;
	}
	
	public byte[] serialize() {
		ByteBuffer buf = new ByteBuffer();
		buf.writeString(name);
		buf.writeBytes(passwordHash);
		buf.writeBytes(salt);
		buf.writeBytes(publicKey.serialize());
		return buf.toByteArray();
	}
	
	public static User deserialize(byte[] bytes) {
		ByteBuffer buf = new ByteBuffer(bytes);
		String name = buf.readString();
		byte[] passwordHash = buf.readBytes(32);
		byte[] salt = buf.readBytes(12);
		PublicKey publicKey = PublicKey.deserialize(buf.readBytes(513));
		return new User(name, passwordHash, salt, publicKey);
	}
}
