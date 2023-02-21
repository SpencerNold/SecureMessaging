package me.spencernold.server.connection;

import java.util.HashMap;
import java.util.Map;

import me.spencernold.server.auth.UserDB;
import me.spencernold.server.encryption.KeyPair;
import me.spencernold.server.messages.ConvoDB;
import me.spencernold.server.messages.UserConvoHeader;

public class ServerData {

	public final Map<String, Client> authenticatedClients = new HashMap<>();
	
	private final KeyPair serverKeys;
	private UserDB udb;
	private ConvoDB cdb;
	private UserConvoHeader uch;
	
	public ServerData() {
		serverKeys = KeyPair.generate();
	}
	
	public KeyPair getServerKeys() {
		return serverKeys;
	}
	
	public UserDB getUserDB() {
		return udb;
	}
	
	public void setUserDB(UserDB udb) {
		this.udb = udb;
	}
	
	public ConvoDB getConvoDB() {
		return cdb;
	}
	
	public void setConvoDB(ConvoDB cdb) {
		this.cdb = cdb;
	}
	
	public UserConvoHeader getUserConvoHeader() {
		return uch;
	}
	
	public void setUserConvoHeader(UserConvoHeader uch) {
		this.uch = uch;
	}
}
