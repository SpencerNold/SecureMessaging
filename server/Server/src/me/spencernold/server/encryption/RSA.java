package me.spencernold.server.encryption;

import java.security.spec.MGF1ParameterSpec;

import javax.crypto.Cipher;
import javax.crypto.spec.OAEPParameterSpec;
import javax.crypto.spec.PSource;

public class RSA {
	
	private Cipher cipher;
	
	public RSA() {
		try {
			cipher = Cipher.getInstance("RSA/ECB/OAEPWithSHA-256AndMGF1Padding");
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	public byte[] encrypt(PublicKey publicKey, byte[] data) {
		OAEPParameterSpec param = new OAEPParameterSpec("SHA-256", "MGF1", MGF1ParameterSpec.SHA256, PSource.PSpecified.DEFAULT);
		try {
			cipher.init(Cipher.ENCRYPT_MODE, publicKey.getKeyInstance(), param);
			return cipher.doFinal(data);
		} catch (Exception e) {
			e.printStackTrace();
			return null;
		}
	}
	
	public byte[] decrypt(PrivateKey privateKey, byte[] data) {
		OAEPParameterSpec param = new OAEPParameterSpec("SHA-256", "MGF1", MGF1ParameterSpec.SHA256, PSource.PSpecified.DEFAULT);
		try {
			cipher.init(Cipher.DECRYPT_MODE, privateKey.getKeyInstance(), param);
			return cipher.doFinal(data);
		} catch (Exception e) {
			e.printStackTrace();
			return null;
		}
	}
}
