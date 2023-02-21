package me.spencernold.server.messages;

import java.io.File;
import java.io.IOException;
import java.io.RandomAccessFile;
import java.nio.file.Files;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

import me.spencernold.server.util.ByteBuffer;

public class ConvoDB {

	private final File header;
	private final RandomAccessFile database;
	
	private final List<Long> indices = new ArrayList<>();
	
	private boolean loaded;
	private boolean saving;
	
	public ConvoDB(String name) throws IOException {
		header = checkCreate(name + ".dbh");
		database = new RandomAccessFile(checkCreate(name + ".dbd"), "rw");
	}
	
	private File checkCreate(String name) throws IOException {
		File file = new File(name);
		if (!file.getAbsoluteFile().getParentFile().exists())
			file.getAbsoluteFile().getParentFile().mkdirs();
		if (!file.exists())
			file.createNewFile();
		return file;
	}
	
	public void create(String name, Optional<String> icon, List<String> users) throws IOException {
		ByteBuffer buf = new ByteBuffer();
		buf.writeString(name);
		buf.writeOptionalString(icon);
		buf.writeInt(users.size());
		for (String s : users)
			buf.writeString(s);
		database.seek(0);
		byte[] bytes = buf.toByteArray();
		database.writeInt(bytes.length);
		database.write(bytes);
	}
	
	public void readConvo(Conversation conversation) throws IOException {
		database.seek(0);
		int size = database.readInt();
		byte[] bytes = new byte[size];
		database.read(bytes);
		ByteBuffer buf = new ByteBuffer(bytes);
		conversation.name = buf.readString();
		conversation.icon = buf.readOptionalString();
		int usize = buf.readInt();
		List<String> users = new ArrayList<>();
		for (int i = 0; i < usize; i++)
			users.add(buf.readString());
		conversation.users = users;
	}
	
	public void addMessage(Message message) throws IOException {
		if (!loaded)
			load();
		ByteBuffer buffer = new ByteBuffer();
		buffer.writeString(message.getAuthor());
		buffer.writeByte(message.getType());
		buffer.writeNBytes(message.getData());
		buffer.writeNBytes(message.getSignature());
		long index = database.length();
		database.seek(index);
		byte[] bytes = buffer.toByteArray();
		database.writeInt(bytes.length);
		database.write(bytes);
		indices.add(index);
		if (!saving)
			saveAsync();
	}
	
	public Message readMessage(int index) throws IOException {
		if (!loaded)
			load();
		if (index > indices.size() - 1)
			return null;
		long pos = indices.get(index);
		database.seek(pos);
		int length = database.readInt();
		byte[] bytes = new byte[length];
		database.read(bytes);
		ByteBuffer buffer = new ByteBuffer(bytes);
		String author = buffer.readString();
		byte type = buffer.readByte();
		byte[] data = buffer.readNBytes();
		byte[] signature = buffer.readNBytes();
		return new Message(author, type, data, signature, index);
	}
	
	public int getMessageCount() throws IOException {
		if (!loaded)
			load();
		return indices.size();
	}
	
	public void load() throws IOException {
		loaded = true;
		indices.clear();
		ByteBuffer buffer = new ByteBuffer(Files.readAllBytes(header.toPath()));
		int size = buffer.readInt();
		for (int i = 0; i < size; i++)
			indices.add(buffer.readLong());
	}
	
	public void save() throws IOException {
		saving = true;
		ByteBuffer buffer = new ByteBuffer();
		buffer.writeInt(indices.size());
		for (int i = 0; i < indices.size(); i++)
			buffer.writeLong(indices.get(i));
		Files.write(header.toPath(), buffer.toByteArray());
		saving = false;
	}
	
	public void saveAsync() {
		new Thread(() -> {
			try {
				save();
			} catch (IOException e) {
				e.printStackTrace();
			}
		}).start();
	}
	
	public boolean isSaving() {
		return saving;
	}
	
	public void close() throws IOException {
		database.close();
	}
}
