package me.spencernold.server.connection;

import me.spencernold.server.encryption.AES;
import me.spencernold.server.encryption.Key;
import me.spencernold.server.encryption.PublicKey;
import me.spencernold.server.encryption.RSA;

public class ClientData {

	private final ServerData serverDataAccess;
	private PublicKey clientKey;
	
	private final RSA rsa = new RSA();
	private AES encryptionCipher, decryptionCipher;
	
	public ClientData(ServerData serverDataAccess) {
		this.serverDataAccess = serverDataAccess;
	}
	
	public byte[] encryptRSA(byte[] data) {
		return rsa.encrypt(clientKey, data);
	}
	
	public byte[] decryptRSA(byte[] data) {
		return rsa.decrypt(serverDataAccess.getServerKeys().getPrivateKey(), data);
	}
	
	public byte[] encryptAES(byte[] data) {
		return encryptionCipher.encryptBytes(data);
	}
	
	public byte[] decryptAES(byte[] data) {
		return decryptionCipher.decryptBytes(data);
	}
	
	public PublicKey getClientKey() {
		return clientKey;
	}
	
	public void setClientKey(PublicKey clientKey) {
		this.clientKey = clientKey;
	}
	
	public void setEncryptionKey(Key encryptionKey) {
		encryptionCipher = new AES(encryptionKey);
	}
	
	public void setDecryptionKey(Key decryptionKey) {
		decryptionCipher = new AES(decryptionKey);
	}
}
