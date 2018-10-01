package com.lolaage.netty;

import io.netty.util.AttributeKey;

/**
 * @Description : 
 * @Autor : xiongjinpeng  jpx_011@163.com
 * @Date  : 2016年10月10日 下午6:10:40 
 * @version : 
 */
public class Keys {
	public static AttributeKey<Long> startTimeKey=AttributeKey.valueOf("startTime");
	
	public static AttributeKey<Long> busiStartKey=AttributeKey.valueOf("busiStartTime");
	public static AttributeKey<Long> busiEndKey=AttributeKey.valueOf("busiEndTime");
	
	public static AttributeKey<String> uriKey=AttributeKey.valueOf("uri");
}
