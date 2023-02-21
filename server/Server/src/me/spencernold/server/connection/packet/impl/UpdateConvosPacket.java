package me.spencernold.server.connection.packet.impl;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import me.spencernold.server.connection.Client;
import me.spencernold.server.connection.packet.Id;
import me.spencernold.server.connection.packet.Packet;
import me.spencernold.server.messages.Conversation;
import me.spencernold.server.messages.UserConvoHeader;
import me.spencernold.server.util.ByteBuffer;

@Id(id = 4)
public class UpdateConvosPacket implements Packet {

	private final List<Conversation> conversations;
	
	public UpdateConvosPacket(List<Conversation> conversations) {
		this.conversations = conversations;
	}
	
	public UpdateConvosPacket() {
		conversations = null;
	}
	
	public byte[] write() {
		ByteBuffer buf = new ByteBuffer();
		buf.writeInt(conversations.size());
		for (Conversation c : conversations) {
			buf.writeString(c.getName());
			buf.writeOptionalString(c.getIcon());
			List<String> users = c.getUsers();
			buf.writeInt(users.size());
			for (String s : users)
				buf.writeString(s);
		}
		return buf.toByteArray();
	}

	public void read(ByteBuffer buf) throws Exception {
	}

	public void handle(Client client) {
		if (client.user == null)
			return;
		try {
			List<Conversation> conversations = new ArrayList<>();
			UserConvoHeader header = client.server.data.getUserConvoHeader();
			for (byte[] secretKey : header.getUserConvos(client.user.getName())) {
				Conversation c = Conversation.loadConvo(secretKey);
				conversations.add(c);
			}
			client.send(new UpdateConvosPacket(conversations));
		} catch (IOException e) {
			e.printStackTrace();
		}
	}
}
