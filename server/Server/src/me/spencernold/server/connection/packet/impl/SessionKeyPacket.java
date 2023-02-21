package me.spencernold.server.connection.packet.impl;

import me.spencernold.server.connection.Client;
import me.spencernold.server.connection.Client.State;
import me.spencernold.server.connection.packet.Id;
import me.spencernold.server.connection.packet.Packet;
import me.spencernold.server.encryption.Key;
import me.spencernold.server.util.ByteBuffer;

@Id(id = 1)
public class SessionKeyPacket implements Packet {

	private Key sessionKey;
	
	public SessionKeyPacket(Key sessionKey) {
		this.sessionKey = sessionKey;
	}
	
	public SessionKeyPacket() {
	}
	
	public byte[] write() {
		return sessionKey.getBytes();
	}

	public void read(ByteBuffer buf) throws Exception {
		sessionKey = new Key(buf.toByteArray());
	}

	public void handle(Client client) {
		client.data.setDecryptionKey(sessionKey);
		Key key = Key.generate();
		client.data.setEncryptionKey(key);
		client.send(new SessionKeyPacket(key));
		client.state = State.SECURE;
	}
}
