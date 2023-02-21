package me.spencernold.server.connection;

import java.io.IOException;
import java.net.ServerSocket;
import java.net.Socket;

public class Server {

	private final ServerSocket server;
	private final ConnectionHandler handler;
	private boolean running;
	
	public final ServerData data;
	
	public Server(int port, ConnectionHandler handler) throws IOException {
		this.server = new ServerSocket(port);
		this.handler = handler;
		this.data = new ServerData();
	}
	
	public void listen() throws IOException {
		if (running)
			return;
		running = true;
		while (running) {
			Socket socket = server.accept();
			Client client = new Client(this, socket, handler);
			new Thread(client).start();
			handler.onConnect(client);
		}
	}
	
	public void close() throws IOException {
		running = false;
		server.close();
	}
	
	public int getPort() {
		return server.getLocalPort();
	}
}
