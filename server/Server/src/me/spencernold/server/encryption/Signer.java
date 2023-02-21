package me.spencernold.server.encryption;

import java.security.NoSuchAlgorithmException;
import java.security.Signature;

public class Signer {

	private Signature signer;
	
	public Signer() {
		try {
			signer = Signature.getInstance("SHA256withRSA");
		} catch (NoSuchAlgorithmException e) {
			e.printStackTrace();
		}
	}
	
	public boolean verify(PublicKey publicKey, byte[] message, byte[] signature) {
		try {
			signer.initVerify(publicKey.getKeyInstance());
			signer.update(message);
			return signer.verify(signature);
		} catch (Exception e) {
			e.printStackTrace();
			return false;
		}
	}
}
