package com.lolaage;

import io.netty.bootstrap.ServerBootstrap;
import io.netty.channel.ChannelOption;
import io.netty.channel.nio.NioEventLoopGroup;
import io.netty.channel.socket.nio.NioServerSocketChannel;


import com.lolaage.netty.DispatcherServletChannelInitializer;

public class Main {

	private final int port;

	public Main(int port) {
		this.port = port;
	}

	public void run() throws Exception {
		ServerBootstrap server = new ServerBootstrap();
		NioEventLoopGroup group = new NioEventLoopGroup();
		NioEventLoopGroup work = new NioEventLoopGroup(64);
		try {
			server.group(group, work).channel(NioServerSocketChannel.class)
					.localAddress(port)
					.childHandler(new DispatcherServletChannelInitializer())
					.option(ChannelOption.SO_KEEPALIVE, false)
					.option(ChannelOption.SO_BACKLOG, 1024)
					.childOption(ChannelOption.SO_REUSEADDR, true);

			System.out.println("从端口号："+port+"启动");
			server.bind().sync().channel().closeFuture().sync();
		} finally {
			group.shutdownGracefully();
			work.shutdownGracefully();
		}
	}

	public static void main(String[] args) throws Exception {
		int port = 7200;
		if (args.length > 0) {
			port = Integer.parseInt(args[0]);
		}
		new Main(port).run();
	}
}
