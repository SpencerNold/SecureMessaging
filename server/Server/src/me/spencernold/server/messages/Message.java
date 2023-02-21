package me.spencernold.server.messages;

public class Message {

	private final String author;
	private final byte type;
	private final byte[] data;
	private final byte[] signature;
	private final int index;
	
	public Message(String author, byte type, byte[] data, byte[] signature, int index) {
		this.author = author;
		this.type = type;
		this.data = data;
		this.signature = signature;
		this.index = index;
	}
	
	public String getAuthor() {
		return author;
	}
	
	public byte getType() {
		return type;
	}
	
	public byte[] getData() {
		return data;
	}
	
	public byte[] getSignature() {
		return signature;
	}
	
	public int getIndex() {
		return index;
	}
}
