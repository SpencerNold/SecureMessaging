package me.spencernold.server.util;

import java.nio.ByteBuffer;
import java.nio.ByteOrder;

public class Serializer {
	
	public static byte[] shortToBytesBE(short s) {
		ByteBuffer buf = ByteBuffer.allocate(2);
		buf = buf.order(ByteOrder.BIG_ENDIAN);
		buf.putShort(s);
		return buf.array();
	}

	public static byte[] intToBytesBE(int i) {
		ByteBuffer buf = ByteBuffer.allocate(4);
		buf = buf.order(ByteOrder.BIG_ENDIAN);
		buf.putInt(i);
		return buf.array();
	}
	
	public static byte[] longToBytesBE(long l) {
		ByteBuffer buf = ByteBuffer.allocate(8);
		buf = buf.order(ByteOrder.BIG_ENDIAN);
		buf.putLong(l);
		return buf.array();
	}
	
	public static short bytesToShortBE(byte[] bytes) {
		return ByteBuffer.wrap(bytes).order(ByteOrder.BIG_ENDIAN).getShort();
	}
	
	public static int bytesToIntBE(byte[] bytes) {
		return ByteBuffer.wrap(bytes).order(ByteOrder.BIG_ENDIAN).getInt();
	}
	
	public static long bytesToLongBE(byte[] bytes) {
		return ByteBuffer.wrap(bytes).order(ByteOrder.BIG_ENDIAN).getLong();
	}
}
