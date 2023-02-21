package me.spencernold.server.messages;

import java.io.File;
import java.io.IOException;
import java.util.HexFormat;
import java.util.List;
import java.util.Optional;

import me.spencernold.server.encryption.JavaSecureRandom;

public class Conversation {
	
	private final byte[] secretKey;
	private final ConvoDB convoDB;
	String name;
	Optional<String> icon;
	List<String> users;
	
	public Conversation(byte[] secretKey, String name, Optional<String> icon, List<String> users) throws IOException {
		this.secretKey = secretKey;
		this.name = name;
		this.icon = icon;
		this.users = users;
		this.convoDB = new ConvoDB("convos/" + HexFormat.of().formatHex(secretKey));
	}
	
	public Conversation(byte[] secretKey) throws IOException {
		this.secretKey = secretKey;
		this.convoDB = new ConvoDB("convos/" + HexFormat.of().formatHex(secretKey));
	}
	
	public void addMessage(Message message) throws IOException {
		convoDB.addMessage(message);
	}
	
	public Message getMessage(int index) throws IOException {
		return convoDB.readMessage(index);
	}
	
	public int getMessageCount() throws IOException {
		return convoDB.getMessageCount();
	}
	
	private void create() throws IOException {
		convoDB.create(name, icon, users);
	}
	
	private void load() throws IOException {
		convoDB.readConvo(this);
	}
	
	public String getName() {
		return name;
	}
	
	public Optional<String> getIcon() {
		return icon;
	}
	
	public List<String> getUsers() {
		return users;
	}
	
	public byte[] getSecretKey() {
		return secretKey;
	}
	
	public ConvoDB getDatabase() {
		return convoDB;
	}
	
	public static Conversation createConvo(String name, Optional<String> icon, List<String> users) throws IOException {
		byte[] secretKey = JavaSecureRandom.nextBytes(32);
		if (exists(secretKey))
			return null;
		Conversation conversation = new Conversation(secretKey, name, icon, users);
		conversation.create();
		return conversation;
	}
	
	public static Conversation loadConvo(byte[] secretKey) throws IOException {
		if (!exists(secretKey))
			return null;
		Conversation conversation = new Conversation(secretKey);
		conversation.load();
		return conversation;
	}
	
	public static boolean exists(byte[] secretKey) {
		File file = new File("convos/" + HexFormat.of().formatHex(secretKey) + ".dbh");
		return file.exists();
	}
}
