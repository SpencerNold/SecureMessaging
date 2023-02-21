package me.spencernold.server.connection.packet;

import me.spencernold.server.connection.Client;
import me.spencernold.server.util.ByteBuffer;

public interface Packet {

	public byte[] write();
	public void read(ByteBuffer buf) throws Exception;
	public void handle(Client client);
	
	public default int getId() {
		Class<?> clazz = getClass();
		if (!clazz.isAnnotationPresent(Id.class))
			return -1;
		Id id = clazz.getAnnotation(Id.class);
		return id.id();
	}
}
