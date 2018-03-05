package com.iot.spring.common.aspect;

import java.io.IOException;

import org.aspectj.lang.JoinPoint;
import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.After;
import org.aspectj.lang.annotation.Around;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.Before;
import org.codehaus.jackson.map.ObjectMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.servlet.ModelAndView;

import com.iot.spring.dao.impl.NaverTransDAOImpl;
import com.iot.spring.vo.NaverMsg;

@Service
@Aspect
public class LogPrintAspect {
	
	@Autowired
	NaverTransDAOImpl ntdao;
	
   private static final Logger log = LoggerFactory.getLogger(LogPrintAspect.class);
  
   @Before("execution(* com.iot.spring.controller.*Controller.*(..))")
   public void beforeLog(JoinPoint jp) {
      log.info("@Before => {}", jp);
   }
   
   @Around("execution(* com.iot.spring.controller.*Controller.*(..))")
   public Object aroundLog(ProceedingJoinPoint pjp) throws IOException {
	   log.info("@Around begin");
	   Object obj = null;
	   long startTime = System.currentTimeMillis();
	   try {
		   obj= pjp.proceed();//실행 시점입니다. 
	   }catch (Throwable e) {
		   ObjectMapper om = new ObjectMapper();
		   log.error("@Around error=>{}",e);
		   ModelAndView mav= new ModelAndView("error/error");
		   String emsg = ntdao.getText(e.getMessage());
		   NaverMsg nm= om.readValue(emsg, NaverMsg.class);
		   mav.addObject("errorMsg", nm.getMessage().getResult().getTranslatedText());
		   return mav;
	   }
	   log.info("@Around end, RunTime : {}", (System.currentTimeMillis()-startTime));
	   return obj; 
   }
   
   @After("execution(* com.iot.spring.controller.*Controller.*(..))")
   public void afterLog(JoinPoint jp) {
	   log.info("@After => {}", jp); 
   }
}
