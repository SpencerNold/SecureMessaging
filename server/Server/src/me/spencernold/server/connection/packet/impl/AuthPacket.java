package me.spencernold.server.connection.packet.impl;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.Arrays;

import me.spencernold.server.auth.User;
import me.spencernold.server.auth.UserDB;
import me.spencernold.server.connection.Client;
import me.spencernold.server.connection.packet.Id;
import me.spencernold.server.connection.packet.Packet;
import me.spencernold.server.encryption.JavaSecureRandom;
import me.spencernold.server.encryption.PublicKey;
import me.spencernold.server.util.ByteBuffer;
import me.spencernold.server.util.ByteTool;

@Id(id = 2)
public class AuthPacket implements Packet {

	private String username;
	private String password;
	private PublicKey publicKey;
	private boolean register;
	
	private int code;
	
	public AuthPacket(int code) {
		this.code = code;
	}
	
	public AuthPacket() {
	}
	
	public byte[] write() {
		return new byte[] {(byte) code};
	}
	
	public void read(ByteBuffer buf) throws Exception {
		username = buf.readString();
		password = buf.readString();
		register = buf.readBoolean();
		publicKey = PublicKey.deserialize(buf.readBytes(513));
	}

	public void handle(Client client) {
		UserDB udb = client.server.data.getUserDB();
		boolean exists = udb.exists(username);
		if (register) {
			if (exists) {
				client.send(new AuthPacket(1));
				return;
			}
			byte[] salt = JavaSecureRandom.nextBytes(12);
			byte[] passwordHash = ByteTool.hash(ByteTool.append(password.getBytes(StandardCharsets.UTF_8), salt));
			User user = new User(username, passwordHash, salt, publicKey);
			try {
				udb.writeUser(user);
				client.user = user;
				client.server.data.authenticatedClients.put(user.getName(), client);
				client.send(new AuthPacket(0));
			} catch (IOException e) {
				e.printStackTrace();
				client.send(new AuthPacket(1));
			}
		} else {
			if (!exists) {
				client.send(new AuthPacket(1));
				return;
			}
			try {
				User user = udb.readUser(username);
				if (!Arrays.equals(user.getPublicKey().serialize(), publicKey.serialize())) {
					user.setPublicKey(publicKey);
					udb.writeUser(user);
				}
				byte[] passwordHash = ByteTool.hash(ByteTool.append(password.getBytes(StandardCharsets.UTF_8), user.getSalt()));
				boolean success = Arrays.equals(passwordHash, user.getPasswordHash());
				client.user = success ? user : null;
				client.send(new AuthPacket(success ? 0 : 1));
				if (success)
					client.server.data.authenticatedClients.put(user.getName(), client);
			} catch (IOException e) {
				e.printStackTrace();
				client.send(new AuthPacket(1));
			}
		}
	}
}
