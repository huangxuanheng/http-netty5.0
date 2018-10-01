package com.lolaage.netty;

import static io.netty.handler.codec.http.HttpHeaders.Names.CONTENT_TYPE;
import static io.netty.handler.codec.http.HttpResponseStatus.INTERNAL_SERVER_ERROR;
import static io.netty.handler.codec.http.HttpVersion.HTTP_1_1;
import io.netty.buffer.ByteBuf;
import io.netty.buffer.Unpooled;
import io.netty.channel.ChannelFutureListener;
import io.netty.channel.ChannelHandlerContext;
import io.netty.channel.SimpleChannelInboundHandler;
import io.netty.handler.codec.http.DefaultFullHttpResponse;
import io.netty.handler.codec.http.FullHttpRequest;
import io.netty.handler.codec.http.FullHttpResponse;
import io.netty.handler.codec.http.HttpHeaders;
import io.netty.handler.codec.http.HttpMethod;
import io.netty.handler.codec.http.HttpResponseStatus;
import io.netty.handler.codec.http.multipart.Attribute;
import io.netty.handler.codec.http.multipart.HttpPostRequestDecoder;
import io.netty.handler.codec.http.multipart.InterfaceHttpData;
import io.netty.handler.codec.http.multipart.InterfaceHttpData.HttpDataType;
import io.netty.util.CharsetUtil;

import java.io.UnsupportedEncodingException;
import java.util.Iterator;
import java.util.List;
import java.util.Map.Entry;

import javax.servlet.Servlet;
import javax.servlet.ServletContext;


import org.springframework.mock.web.MockHttpServletRequest;
import org.springframework.web.util.UriComponents;
import org.springframework.web.util.UriComponentsBuilder;
import org.springframework.web.util.UriUtils;

public class ServletNettyHandler extends SimpleChannelInboundHandler<FullHttpRequest> {
	

	private final Servlet servlet;

	private final ServletContext servletContext;

	public ServletNettyHandler(Servlet servlet) {
		this.servlet = servlet;
		this.servletContext = servlet.getServletConfig().getServletContext();
	}

	public static MockHttpServletRequest createServletRequest(FullHttpRequest fullHttpRequest,ServletContext servletContext) {
		UriComponents uriComponents = UriComponentsBuilder.fromUriString(fullHttpRequest.getUri()).build();

		MockHttpServletRequest servletRequest = new MockHttpServletRequest(servletContext);
		servletRequest.setRequestURI(uriComponents.getPath());
		servletRequest.setPathInfo(uriComponents.getPath());
		servletRequest.setMethod(fullHttpRequest.getMethod().name());

		if (uriComponents.getScheme() != null) {
			servletRequest.setScheme(uriComponents.getScheme());
		}
		if (uriComponents.getHost() != null) {
			servletRequest.setServerName(uriComponents.getHost());
		}
		if (uriComponents.getPort() != -1) {
			servletRequest.setServerPort(uriComponents.getPort());
		}

		for (String name : fullHttpRequest.headers().names()) {
			servletRequest.addHeader(name, fullHttpRequest.headers().get(name));
		}

		// 处理 http 请求参数
        try {
        	
            if (HttpMethod.POST == fullHttpRequest.getMethod()) {
                
                // 是POST请求
                HttpPostRequestDecoder decoder = new HttpPostRequestDecoder(fullHttpRequest);
                decoder.offer(fullHttpRequest.duplicate());
                
                List<InterfaceHttpData> parmList = decoder.getBodyHttpDatas();
                
                if(parmList.size() > 0){
	                for (InterfaceHttpData parm : parmList) {
	                    
	                    // 判度是不是post参数，还是文件
	                    if (parm.getHttpDataType() == HttpDataType.Attribute) {
	                        Attribute data = (Attribute)parm;
	                        servletRequest.addParameter(data.getName(), data.getValue() == null ? "" : data.getValue());
	                    }
	                }
                }
            	ByteBuf bbContent = fullHttpRequest.content();
            	bbContent.resetReaderIndex();
        		if(bbContent.hasArray()) {
        			byte[] baContent = bbContent.array();
        			servletRequest.setContent(baContent);
        		}else{
                    int readable=bbContent.readableBytes();
                    byte[] bytes=new byte[readable];
                    bbContent.readBytes(bytes);
                    servletRequest.setContent(bytes);
        		}
            }
        }
        catch (Exception e) {
        }
		

		try {
			if (uriComponents.getQuery() != null) {
				String query = UriUtils.decode(uriComponents.getQuery(), "UTF-8");
				servletRequest.setQueryString(query);
			}

			for (Entry<String, List<String>> entry : uriComponents.getQueryParams().entrySet()) {
				for (String value : entry.getValue()) {
					servletRequest.addParameter(
							UriUtils.decode(entry.getKey(), "UTF-8"),
							UriUtils.decode(value == null ? "" : value, "UTF-8"));
				}
			}
		}
		catch (UnsupportedEncodingException ex) {
			// shouldn't happen
		}
		return servletRequest;
	}

	@Override
	public void exceptionCaught(ChannelHandlerContext ctx, Throwable cause) throws Exception {
		if (ctx.channel().isActive()) {
			sendError(ctx, INTERNAL_SERVER_ERROR);
		}
	}

	public static void sendError(ChannelHandlerContext ctx, HttpResponseStatus status) {
		ByteBuf content = Unpooled.copiedBuffer(
				"Failure: " + status.toString() + "\r\n",
				CharsetUtil.UTF_8);

		FullHttpResponse fullHttpResponse = new DefaultFullHttpResponse(
				HTTP_1_1,
				status,
				content
		);
		fullHttpResponse.headers().add(CONTENT_TYPE, "text/plain; charset=UTF-8");

		// Close the connection as soon as the error message is sent.
		ctx.write(fullHttpResponse).addListener(ChannelFutureListener.CLOSE);
	}
	
/*
	//netty 4.0.0实现该方法
	@Override
	protected void channelRead0(ChannelHandlerContext channelHandlerContext, FullHttpRequest fullHttpRequest) throws Exception {

	}*/

	//netty 5.0.0 实现该方法
	protected void messageReceived(ChannelHandlerContext channelHandlerContext, FullHttpRequest fullHttpRequest) throws Exception {
		fullHttpRequest.retain();
		new HttpTaskSync(servlet,channelHandlerContext, fullHttpRequest,servletContext).run();
	}
}
