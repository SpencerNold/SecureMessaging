package me.spencernold.server.connection.packet.impl;

import me.spencernold.server.connection.Client;
import me.spencernold.server.connection.Client.State;
import me.spencernold.server.connection.packet.Id;
import me.spencernold.server.connection.packet.Packet;
import me.spencernold.server.encryption.PublicKey;
import me.spencernold.server.util.ByteBuffer;

@Id(id = 0)
public class PublicKeyPacket implements Packet {
	
	private PublicKey key;
	
	public PublicKeyPacket(PublicKey key) {
		this.key = key;
	}
	
	public PublicKeyPacket() {
	}

	public byte[] write() {
		return key.serialize();
	}

	public void read(ByteBuffer buf) throws Exception {
		key = PublicKey.deserialize(buf.toByteArray());
	}

	public void handle(Client client) {
		 client.data.setClientKey(key);
		 client.send(new PublicKeyPacket(client.server.data.getServerKeys().getPublicKey()));
		 client.state = State.HANDSHAKING;
	}
}
