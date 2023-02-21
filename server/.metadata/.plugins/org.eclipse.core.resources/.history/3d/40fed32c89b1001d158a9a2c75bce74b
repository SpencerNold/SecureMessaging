package me.spencernold.server.connection;

import me.spencernold.server.util.ByteBuffer;

public interface ConnectionHandler {

	public void onConnect(Client client);
	public void onMessage(Client client, ByteBuffer buf);
	public void onDisconnect(Client client);
}
