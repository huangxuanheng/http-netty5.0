package com.lolaage.netty;

import io.netty.channel.ChannelFuture;
import io.netty.channel.ChannelFutureListener;
import io.netty.channel.ChannelHandlerContext;
import io.netty.handler.codec.http.DefaultHttpResponse;
import io.netty.handler.codec.http.FullHttpRequest;
import io.netty.handler.codec.http.HttpResponse;
import io.netty.handler.codec.http.HttpResponseStatus;
import io.netty.handler.stream.ChunkedStream;

import org.springframework.mock.web.MockHttpServletRequest;
import org.springframework.mock.web.MockHttpServletResponse;

import javax.servlet.Servlet;
import javax.servlet.ServletContext;
import java.io.ByteArrayInputStream;
import java.io.InputStream;

import static io.netty.handler.codec.http.HttpResponseStatus.BAD_REQUEST;
import static io.netty.handler.codec.http.HttpResponseStatus.INTERNAL_SERVER_ERROR;
import static io.netty.handler.codec.http.HttpVersion.HTTP_1_1;

/**
 * @Description : 
 * @Autor : xiongjinpeng  jpx_011@163.com
 * @Date  : 2016年10月19日 上午10:02:59 
 * @version : 
 */

public class HttpTaskSync {
	

	private Servlet servlet;
	private ChannelHandlerContext channelHandlerContext;
	private FullHttpRequest fullHttpRequest;
	private ServletContext servletContext;


	public ChannelHandlerContext getChannelHandlerContext() {
		return channelHandlerContext;
	}
	public void setChannelHandlerContext(ChannelHandlerContext channelHandlerContext) {
		this.channelHandlerContext = channelHandlerContext;
	}
	public HttpTaskSync(Servlet servlet,ChannelHandlerContext channelHandlerContext,FullHttpRequest fullHttpRequest,ServletContext servletContext){
		this.servlet=servlet;
		this.channelHandlerContext=channelHandlerContext;
		this.fullHttpRequest=fullHttpRequest;
		this.servletContext=servletContext;
	}
	public void run() {
		try {
			if (!fullHttpRequest.getDecoderResult().isSuccess()) {
				ServletNettyHandler.sendError(channelHandlerContext, BAD_REQUEST);
				return;
			}
			long beginTime=System.currentTimeMillis();
//			channelHandlerContext.channel().attr(Keys.busiStartKey).set(beginTime);
			
			MockHttpServletRequest servletRequest = ServletNettyHandler.createServletRequest(fullHttpRequest,servletContext);
			//设置uri
//			channelHandlerContext.channel().attr(Keys.uriKey).set(servletRequest.getRequestURI());
			
			MockHttpServletResponse servletResponse = new MockHttpServletResponse();
			long initTime = System.currentTimeMillis();
			this.servlet.service(servletRequest, servletResponse);
			long endTime=System.currentTimeMillis();
			if(endTime-initTime>2000){

			}
			HttpResponseStatus status = HttpResponseStatus.valueOf(servletResponse.getStatus());
			HttpResponse response = new DefaultHttpResponse(HTTP_1_1, status);

			for (String name : servletResponse.getHeaderNames()) {
				for (Object value : servletResponse.getHeaderValues(name)) {
					response.headers().add(name, value);
				}
			}

			// Write the initial line and the header.
			channelHandlerContext.write(response);

			InputStream contentStream = new ByteArrayInputStream(servletResponse.getContentAsByteArray());

			// Write the content and flush it.
			ChannelFuture writeFuture = channelHandlerContext.writeAndFlush(new ChunkedStream(contentStream));
//			channelHandlerContext.channel().attr(Keys.busiEndKey).set(System.currentTimeMillis());
//			Long startTime=channelHandlerContext.channel().attr(Keys.startTimeKey).get();
			writeFuture.addListener(ChannelFutureListener.CLOSE);
		} catch (Exception e) {
			e.printStackTrace();
			if (channelHandlerContext.channel().isActive()) {
				ServletNettyHandler.sendError(channelHandlerContext, INTERNAL_SERVER_ERROR);
			}
		} finally {
			if(fullHttpRequest.refCnt()>0){//释放计数器
				fullHttpRequest.release();
			}
		}
	}
}