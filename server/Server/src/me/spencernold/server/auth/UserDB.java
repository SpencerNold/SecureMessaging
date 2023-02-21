package me.spencernold.server.auth;

import java.io.File;
import java.io.IOException;
import java.io.RandomAccessFile;
import java.nio.file.Files;
import java.util.HashMap;
import java.util.Map;
import java.util.Map.Entry;

import me.spencernold.server.util.ByteBuffer;

public class UserDB {

	private final Map<Integer, Long> indices = new HashMap<>();
	private final File header;
	private final RandomAccessFile database;
	private boolean loaded = false;
	
	public UserDB(String name) throws IOException {
		header = checkCreate(name + ".dbh");
		database = new RandomAccessFile(checkCreate(name + ".dbd"), "rw");
	}
	
	private File checkCreate(String name) throws IOException {
		File file = new File(name);
		if (!file.getParentFile().exists())
			file.getParentFile().mkdirs();
		if (!file.exists())
			file.createNewFile();
		return file;
	}
	
	public void writeUser(User user) throws IOException {
		int hash = user.getName().hashCode();
		long index = indices.containsKey(hash) ? indices.get(hash) : database.length();
		indices.put(hash, index);
		database.seek(index);
		byte[] data = user.serialize();
		database.writeInt(data.length);
		database.write(data);
		save();
	}
	
	public User readUser(String name) throws IOException {
		int hash = name.hashCode();
		if (!exists(name))
			return null;
		long index = indices.get(hash);
		database.seek(index);
		int size = database.readInt();
		byte[] data = new byte[size];
		database.read(data);
		return User.deserialize(data);
	}
	
	public boolean exists(String name)  {
		try {
			if (!loaded)
				load();
		} catch (IOException e) {
			e.printStackTrace();
			return false;
		}
		return indices.containsKey(name.hashCode());
	}
	
	public void load() throws IOException {
		loaded = true;
		ByteBuffer buf = new ByteBuffer(Files.readAllBytes(header.toPath()));
		int size = buf.readInt();
		for (int i = 0; i < size; i++) {
			int key = buf.readInt();
			long value = buf.readLong();
			indices.put(key, value);
		}
	}
	
	public void save() throws IOException {
		ByteBuffer buf = new ByteBuffer();
		buf.writeInt(indices.size());
		for (Entry<Integer, Long> en : indices.entrySet()) {
			buf.writeInt(en.getKey());
			buf.writeLong(en.getValue());
		}
		Files.write(header.toPath(), buf.toByteArray());
	}
	
	public void close() throws IOException {
		database.close();
	}
}
