<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Insert title here</title>
</head>
<style>
html, body {
	width: 100%; /*provides the correct work of a full-screen layout*/
	height: 100%; /*provides the correct work of a full-screen layout*/
	overflow: hidden; /*hides the default body's space*/
	margin: 0px; /*hides the body's scrolls*/
}
div.controls {
	margin: 0px 10px;
	font-size: 14px;
	font-family: Tahoma;
	color: #404040;
	height: 80px;
}
.my_ftr {
	background-color: white;
	padding-top: 9px;
}
.my_ftr .text {
	font-family: Roboto, Arial, Helvetica;
	font-size: 14px;
	color: #404040;
	padding: 5px 10px;
	height: 70px;
	border: 1px solid #dfdfdf;
	overFlow: auto;
}
</style>
<script> 
var bodyLayout, dbTree,winF,popW; 
var aLay, bLay, cLay;
var bTabs, bTab1, bTab2, bTab3;
var cTabs;
var tableInfoGrid;
var log="";
function columnListCB(res){
	if(res.list){
		tableInfoGrid = bTabs.tabs("tableInfo").attachGrid();
		var columns = res.list[0];
		var headerStr = "";
		var colTypeStr = "";
		for(var key in columns){
			if(key=="id") continue;
			headerStr += key + ",";
			colTypeStr += "ro,";
		}
		headerStr = headerStr.substr(0, headerStr.length-1);
		colTypeStr = colTypeStr.substr(0, colTypeStr.length-1);
        tableInfoGrid.setColumnIds(headerStr);
		tableInfoGrid.setHeader(headerStr);
		tableInfoGrid.setColTypes(colTypeStr);
        tableInfoGrid.init();
		tableInfoGrid.parse({data:res.list},"js");
	}
}

function tableDataListCB(res){
	if(res.list){
		tableInfoGrid = bTabs.tabs("tableData").attachGrid();
		var columns = res.list[0];
		var headerStr = "";
		var colTypeStr = "";
		for(var key in columns){
			if(key=="id") continue;
			headerStr += key + ",";
			colTypeStr += "ro,";
		}
		headerStr = headerStr.substr(0, headerStr.length-1);
		colTypeStr = colTypeStr.substr(0, colTypeStr.length-1);
        tableInfoGrid.setColumnIds(headerStr);
		tableInfoGrid.setHeader(headerStr);
		tableInfoGrid.setColTypes(colTypeStr);
        tableInfoGrid.init();
		tableInfoGrid.parse({data:res.list},"js");
		
	}
}
function connectionListCB(res){
	dbTree = aLay.attachTreeView({
	    items: res.list
	});
	dbTree.attachEvent("onDblClick",function(id){
		var level = dbTree.getLevel(id);
		if(level==2){
			var text = dbTree.getItemText(id);
			var au = new AjaxUtil("${root}/connection/tables/" + text + "/" + id,null,"get");
			au.send(tableListCB); 
		}else if(level==3){
			var pId= dbTree.getParentId(id);
			var dbName = dbTree.getItemText(pId);
			var tableName = dbTree.getUserData(id,"orgText");
			var au = new AjaxUtil("${root}/connection/columns/" + dbName + "/" + tableName,null,"get");
			au.send(columnListCB);
			var au = new AjaxUtil("${root}/connection/tabledata/"+dbName+"/"+ tableName,null,"get");
			au.send(tableDataListCB);
		} 
	});
}
function tableListCB(res){
	var parentId = res.parentId;
	var i=1;
	for(var table of res.list){
		var id = parentId + "_" + i++;
		var text = table.tableName;
		if(table.tableComment!=""){
			text += "[" + table.tableComment + "]";
		}
		text += ":"+ table.tableSize + "KB"; 
		dbTree.addItem(id, text, parentId);
		dbTree.setUserData(id,"orgText",table.tableName);
	}
	dbTree.openItem(parentId);
}
function addConnectionCB(res){
	console.log(res);
}

function sqlResult(res){
	res=JSON.parse(res.xmlDoc.response);
	cTabs = cLay.attachTabbar();
	for(var i=1; i<res.lists.length+1; i++){
		cTabs.addTab("result"+i,"result"+i);	
	}
	for(var i=0; i<res.lists.length; i++){
		resultGridTab = cTabs.tabs("result"+(i+1)).attachGrid();
		var columns = res.lists[i][0];
		var headerStr = "";
		var colTypeStr = "";
		for(var key in columns){
			headerStr += key + ",";
			if(key=="id") {
				colTypeStr += "ro,";	
				continue;
			}
			colTypeStr += "ed,";
		}
		headerStr = headerStr.substr(0, headerStr.length-1);
		colTypeStr = colTypeStr.substr(0, colTypeStr.length-1);
		resultGridTab.setColumnIds(headerStr);
		resultGridTab.setHeader(headerStr);
		resultGridTab.setColTypes(colTypeStr);
		resultGridTab.init();
		resultGridTab.parse({data:res.lists[i]},"js");
	}
	
	var cnt=0;
	for(var i=0; i<res.lists.length; i++){
		for(var j=0; j<res.lists[i].length; j++){
			cnt++;
		}
	}

	var falseCnt= 0;
	for(var i=0; i<res.msg.length; i++){
		log += res.msg[i] + "<br>";
		if(res.msg[i].indexOf("실패")!=-1){
			falseCnt++;
		}
	}
	
	log+= "/* Affected rows:  찾은 행: "+cnt+"  실패: "+falseCnt+"  지속 시간 3 queries: 0.000 sec. */ <br>";
	document.getElementById("resultDiv").innerHTML=log;
	if(cTabs.tabs("result1")){
		cTabs.tabs("result1").setActive(true);
	}
}

function dbListCB(res){
	if(res.error){
		alert(res.error);
		return;
	}
	var parentId = res.parentId;
	for(var db of res.list){
		var id = db.id;
		var text = db.text;
		dbTree.addItem(id, text, parentId);
	}
	dbTree.openItem(parentId);
}
dhtmlxEvent(window,"load",function(){
	bodyLayout = new dhtmlXLayoutObject(document.body,"3L");
	bodyLayout.attachFooter("footDiv");
	aLay = bodyLayout.cells("a");
	aLay.setWidth(300);
	aLay.setText("Connection Info List");
	var aToolbar = aLay.attachToolbar();
	aToolbar.addButton("addcon",1,"add Connector");
	aToolbar.addButton("condb",2,"Connection");
	aToolbar.attachEvent("onClick",function(id){
		if(id=="condb"){
			var rowId =dbTree.getSelectedId();
			if(!rowId){
				alert("접속할 커넥션을 선택해주세요.");
				return;
			}
			var au = new AjaxUtil("${root}/connection/db_list/" + rowId,null,"get");
			au.send(dbListCB); 
		}else if(id=="addcon"){
			popW.show();
		}
	})
	var au = new AjaxUtil("${root}/connection/list",null,"get");
	au.send(connectionListCB); 
	
	bLay = bodyLayout.cells("b");
	bTabs = bLay.attachTabbar({
		align:"left",
		tabs:[
			{id:"tableInfo", text:"Table Info"},
			{id:"tableData", text:"Table Datas"},
			{id:"sql", text:"Run Sql", active:true}
		]
	});
	var sqlFormObj = [
		{type: "block", blockOffset: 10, list: [
			{type: "button", name:"runBtn",value: "Run"},
			{type: "newcolumn"},
			{type: "button", name:"cancelBtn",value: "Clear"} 
		]},
		{type:"input",name:"sqlTa",label:"sql",required:true,rows:10,style:"background-color:#ecf3f9;border:1px solid #39c;width:800"},
	];
	var sqlForm = bTabs.tabs("sql").attachForm(sqlFormObj);
	sqlForm.attachEvent("onButtonClick",function(id){
		if(id=="runBtn"){
			sqlForm.send("${root}/connection/sql","get",sqlResult);
		}else if(id=="cancelBtn"){
			sqlForm.clear();
		}
	})
	cLay = bodyLayout.cells("c");
	winF = new dhtmlXWindows();
	popW = winF.createWindow("win1",20,30,320,300);
	//popW.hide(); 
	popW.setText("Add Connection Info"); 
	var formObj = [
				{type:"settings", offsetTop:12,name:"connectionInfo",labelAlign:"left"},
				{type:"input",name:"ciName", label:"커넥션이름",required:true},
				{type:"input",name:"ciUrl", label:"접속URL",required:true},
				{type:"input",name:"ciPort", label:"PORT번호",validate:"ValidInteger",required:true},
				{type:"input",name:"ciDatabase", label:"데이터베이스",required:true},
				{type:"input",name:"ciUser", label:"유저ID",required:true},
				{type:"password",name:"ciPwd", label:"비밀번호",required:true},
				{type:"input",name:"ciEtc", label:"설명"},
				{type: "block", blockOffset: 0, list: [
					{type: "button", name:"saveBtn",value: "저장"},
					{type: "newcolumn"},
					{type: "button", name:"cancelBtn",value: "취소"}
				]}
		];
	var form = popW.attachForm(formObj,true);
	popW.hide();
	
	form.attachEvent("onButtonClick",function(id){
		if(id=="saveBtn"){
			if(form.validate()){
				form.send("${root}/connection/insert", "post",addConnectionCB);
			}
		}else if(id=="cancelBtn"){
			form.clear();
		}
	});
})

</script>
<body>
	<div id="footDiv" class="my_ftr">
		<div id="resultDiv" class="text">log</div>
	</div>
</body>
</html>