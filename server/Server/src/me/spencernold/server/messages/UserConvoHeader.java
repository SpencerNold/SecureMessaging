package me.spencernold.server.messages;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;

import me.spencernold.server.util.ByteBuffer;

public class UserConvoHeader {

	private final Map<Integer, List<byte[]>> userConvos = new HashMap<>();
	private final Map<Integer, byte[]> mappedConvos = new HashMap<>();
	private final File file;
	
	private boolean saving;
	
	public UserConvoHeader(String name) {
		this.file = new File(name + ".uch");
	}
	
	public List<byte[]> getUserConvos(String user) {
		List<byte[]> convos = userConvos.get(user.hashCode());
		return convos == null ? new ArrayList<>() : convos;
	}
	
	public void addUserConvo(String user, byte[] secretKey) {
		List<byte[]> convos = userConvos.get(user.hashCode());
		convos = convos == null ? new ArrayList<>() : convos;
		convos.add(secretKey);
		userConvos.put(user.hashCode(), convos);
	}
	
	public byte[] getMappedConvo(String name) {
		return mappedConvos.get(name.hashCode());
	}
	
	public void addMappedConvo(String name, byte[] secretKey) {
		mappedConvos.put(name.hashCode(), secretKey);
	}
	
	public void load() throws IOException {
		if (!file.exists())
			return;
		ByteBuffer buf = new ByteBuffer(Files.readAllBytes(file.toPath()));
		int csize = buf.readInt();
		for (int i = 0; i < csize; i++) {
			int key = buf.readInt();
			List<byte[]> value = new ArrayList<>();
			int vsize = buf.readInt();
			for (int j = 0; j < vsize; j++)
				value.add(buf.readBytes(32));
			userConvos.put(key, value);
		}
		csize = buf.readInt();
		for (int i = 0; i < csize; i++) {
			int key = buf.readInt();
			byte[] value = buf.readBytes(32);
			mappedConvos.put(key, value);
		}
	}
	
	public void save() throws IOException {
		saving = true;
		if (!file.exists())
			file.createNewFile();
		ByteBuffer buf = new ByteBuffer();
		buf.writeInt(userConvos.size());
		for (Entry<Integer, List<byte[]>> en : userConvos.entrySet()) {
			buf.writeInt(en.getKey());
			List<byte[]> value = en.getValue();
			buf.writeInt(value.size());
			for (byte[] bytes : value)
				buf.writeBytes(bytes);
		}
		buf.writeInt(mappedConvos.size());
		for (Entry<Integer, byte[]> en : mappedConvos.entrySet()) {
			buf.writeInt(en.getKey());
			buf.writeBytes(en.getValue());
		}
		Files.write(file.toPath(), buf.toByteArray());
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
}
