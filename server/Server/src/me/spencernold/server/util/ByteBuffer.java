package me.spencernold.server.util;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.Optional;

public class ByteBuffer {

	private final ByteArrayOutputStream output;
	private final ByteArrayInputStream input;
	
	public ByteBuffer(byte[] bytes) {
		input = new ByteArrayInputStream(bytes);
		output = null;
	}
	
	public ByteBuffer() {
		output = new ByteArrayOutputStream();
		input = null;
	}
	
	public void writeBytes(byte[] bytes) {
		try {
			output.write(bytes);
		} catch (IOException e) {
			e.printStackTrace();
		}
	}
	
	public void writeNBytes(byte[] bytes) {
		writeInt(bytes.length);
		writeBytes(bytes);
	}
	
	public void writeByte(byte b) {
		writeBytes(new byte[] {b});
	}
	
	public void writeBoolean(boolean b) {
		writeByte((byte) (b ? 1 : 0));
	}
	
	public void writeShort(short s) {
		writeBytes(Serializer.shortToBytesBE(s));
	}
	
	public void writeInt(int i) {
		writeBytes(Serializer.intToBytesBE(i));
	}
	
	public void writeLong(long l) {
		writeBytes(Serializer.longToBytesBE(l));
	}
	
	public void writeFloat(float f) {
		writeInt(Float.floatToIntBits(f));
	}
	
	public void writeDouble(double d) {
		writeLong(Double.doubleToLongBits(d));
	}
	
	public void writeString(String s) {
		writeInt(s.length());
		writeBytes(s.getBytes(StandardCharsets.UTF_8));
	}
	
	public void writeOptionalString(Optional<String> optional) {
		boolean b = optional.isPresent();
		writeBoolean(b);
		if (b)
			writeString(optional.get());
	}
	
	public byte[] readBytes(int n) {
		try {
			return input.readNBytes(n);
		} catch (IOException e) {
			e.printStackTrace();
			return new byte[0];
		}
	}
	
	public byte[] readNBytes() {
		int length = readInt();
		return readBytes(length);
	}
	
	public byte readByte() {
		byte[] bytes = readBytes(1);
		if (bytes.length != 1)
			return (byte) 0;
		return bytes[0];
	}
	
	public boolean readBoolean() {
		return readByte() == 1;
	}
	
	public short readShort() {
		byte[] bytes = readBytes(2);
		if (bytes.length != 2)
			return (short) 0;
		return Serializer.bytesToShortBE(bytes);
	}
	
	public int readInt() {
		byte[] bytes = readBytes(4);
		if (bytes.length != 4)
			return 0;
		return Serializer.bytesToIntBE(bytes);
	}
	
	public long readLong() {
		byte[] bytes = readBytes(8);
		if (bytes.length != 8)
			return 0;
		return Serializer.bytesToLongBE(bytes);
	}
	
	public float readFloat() {
		return Float.intBitsToFloat(readInt());
	}
	
	public double readDouble() {
		return Double.longBitsToDouble(readLong());
	}
	
	public String readString() {
		int n = readInt();
		return new String(readBytes(n), StandardCharsets.UTF_8);
	}
	
	public Optional<String> readOptionalString() {
		boolean b = readBoolean();
		if (b)
			return Optional.of(readString());
		return Optional.empty();
	}
	
	public byte[] toByteArray() {
		return output == null ? input.readAllBytes() : output.toByteArray();
	}
}
