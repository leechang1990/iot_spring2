package com.iot.spring.service;

import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpSession;

import com.iot.spring.vo.ColumnVO;
import com.iot.spring.vo.ConnectionInfoVO;
import com.iot.spring.vo.TableVO;

public interface ConnectionInfoService {
	List<ConnectionInfoVO> getConnectionInfoList(String uiId);
	ConnectionInfoVO getConnectionInfo(ConnectionInfoVO ci);
	List<ConnectionInfoVO> getConnectionInfoList(ConnectionInfoVO ci);
	void insertConnectionInfo(Map<String,Object> rMap,ConnectionInfoVO ci);
	List<Map<String,Object>> getDatabaseList(HttpSession hs, int ciNo)throws Exception ;
	List<TableVO> getTableList(HttpSession hs,String dbName);
	List<ColumnVO> getColumnList(HttpSession hs, Map<String,String> map);
	List<Map<String,Object>> sqlSelectExecute(HttpSession hs,String sqlTa)throws Exception;
	String sqlUpdateExecute(HttpSession hs,String sqlTa);
	List<ColumnVO> getTableData(HttpSession hs, Map<String,String> map);
}
