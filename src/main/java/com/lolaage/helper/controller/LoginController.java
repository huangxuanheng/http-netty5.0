package com.lolaage.helper.controller;

import io.swagger.annotations.*;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;

@Controller
@RequestMapping(value = "/auth")
@Api(description = "安全认证",value = "LoginController")
public class LoginController {

    @RequestMapping(value = "/login",method = RequestMethod.GET)
    @ResponseBody
    @ApiOperation(value = "登录")
    @ApiImplicitParams({@ApiImplicitParam(name = "userName",value = "用户名",dataType = "String",paramType = "query"),
            @ApiImplicitParam(name = "passwd",value = "用户密码",dataType = "String",paramType = "query")
    })
    public Result<UserVo> login(String userName,String passwd){
        if("huangxuanheng".equalsIgnoreCase(userName)&&"123456".equalsIgnoreCase(passwd)){
            return new Result<UserVo>(200,null,new UserVo(userName,passwd));
        }else {
            return new Result<UserVo>(5000,"用户名或者密码错误",null);
        }
    }

    @RequestMapping(value = "/register",method = RequestMethod.GET)
    @ResponseBody
    @ApiOperation(value = "注册")
    @ApiImplicitParams({@ApiImplicitParam(name = "userName",value = "用户名",dataType = "String",paramType = "query"),
            @ApiImplicitParam(name = "passwd",value = "用户密码",dataType = "String",paramType = "query")
    })
    public Result<UserVo> register(String userName,String passwd){
        if("huangxuanheng".equalsIgnoreCase(userName)&&"123456".equalsIgnoreCase(passwd)){
            return new Result<UserVo>(200,null,new UserVo(userName,passwd));
        }else {
            return new Result<UserVo>(5000,"用户名或者密码错误",null);
        }
    }
}
