<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%
	String path = request.getContextPath();
	String basePath = request.getScheme() + "://"
			+ request.getServerName() + ":" + request.getServerPort()
			+ path + "/";
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<base href="<%=basePath%>">

<title>Provinces and cities linkage</title>

<meta http-equiv="pragma" content="no-cache">
<meta http-equiv="cache-control" content="no-cache">
<meta http-equiv="expires" content="0">
<meta http-equiv="keywords" content="keyword1,keyword2,keyword3">
<meta http-equiv="description" content="This is my page">
<!--
	<link rel="stylesheet" type="text/css" href="styles.css">
	-->
<script type="text/javascript">
	function createXMLHttpRequest() {
		try {
			return new XMLHttpRequest(); //大多数浏览器
		} catch (e) {
			try {
				return ActvieXObject("Msxm12.XMLHTTP");//IE6.0
			} catch (e) {
				try {
					return ActvieXObject("Microsoft.XMLHTTP");//IE5.5及更早版本	
				} catch (e) {
					alert("检测不到你用的浏览器类型!!!");
					throw e;
				}
			}
		}
	}
	/*
	 * 1. 在文档加载完毕时发送请求，得到所有省份名称，显示在<select name="province"/>中
	 * 2. 在选择了新的省份时，发送请求（参数为省名称），得到xml文档，即<province>元素
	 *   解析xml文档，得到其中所有的<city>，再得到每个<city>元素的内容，即市名，使用市名生成	*	<option>，插入到<select name="city">元素中
	 */
	window.onload = function() {
		/*
		 *	ajax四步，请求ProvinceServlet，得到所有省份名称
		 *	使用每个省份名称创建一个<option>元素，添加到<select name="province">中
		 */
		var xmlHttp = createXMLHttpRequest();
		xmlHttp.open("GET", "<c:url value='/ProvinceServlet'/>", true);
		xmlHttp.send(null);

		xmlHttp.onreadystatechange = function() {
			if (xmlHttp.readyState == 4 && xmlHttp.status == 200) {
				// 获取服务器的响应
				var text = xmlHttp.responseText;
				// 使用逗号分隔它，得到数组
				var arr = text.split(",");
				// 循环遍历每个省份名称，每个名称生成一个option对象，添加到<select>中
				for (var i = 0; i < arr.length; i++) {
					var op = document.createElement("option");//创建一个指名名称元素
					op.value = arr[i];//设置op的实际值为当前的省份名称
					var textNode = document.createTextNode(arr[i]);//创建文本节点
					op.appendChild(textNode);//把文本子节点添加到op元素中，指定其显示值
					document.getElementById("p1").appendChild(op);
				}
			}
		};

		/*
		 *	第二件事情：给<select name="province">添加改变监听
		 *	使用选择的省份名称请求CityServlet，得到<province>元素(xml元素)！！！
		 *	获取<province>元素中所有的<city>元素，遍历之！获取每个<city>的文本内容，即市名称
		 *	使用每个市名称创建<option>元素添加到<select name="city">
		 */
		var proSelect = document.getElementById("p1");
		proSelect.onchange = function() {

			xmlHttp.open("POST", "<c:url value='/CityServlet'/>", true);
			xmlHttp.setRequestHeader("Content-Type",
					"application/x-www-form-urlencoded");
			xmlHttp.send("pname=" + proSelect.value);//把下拉列表中选择的值发送给服务器！
			xmlHttp.onreadystatechange = function() {

				if (xmlHttp.readyState == 4 && xmlHttp.status == 200) {
					/*
					 *	把select中的所有option移除（除了请选择）
					 */
					var citySelect = document.getElementById("p2");
					// 获取其所有子元素
					var optionEleList = citySelect
							.getElementsByTagName("option");
					// 循环遍历每个option元素，然后在citySelect中移除
					while (optionEleList.length > 1) {//子元素的个数如果大于1就循环，等于1就不循环了！
						citySelect.removeChild(optionEleList[1]);//总是删除1下标，因为1删除了，2就变成1了！
					}

					var doc = xmlHttp.responseXML;
					// 得到所有名为city的元素
					var cityEleList = doc.getElementsByTagName("city");
					// 循环遍历每个city元素
					for (var i = 0; i < cityEleList.length; i++) {
						var cityEle = cityEleList[i];//得到每个city元素
						var cityName;// 获取市名称
						if (window.addEventListener) {//处理浏览器的差异
							cityName = cityEle.textContent;//支持FireFox等浏览器
						} else {
							cityName = cityEle.text;//支持IE
						}
						// 使用市名称创建option元素，添加到<select name="city">中
						var op = document.createElement("option");
						op.value = cityName;
						// 创建文本节点
						var textNode = document.createTextNode(cityName);
						op.appendChild(textNode);//把文本节点追加到op元素中
						document.getElementById("p2").appendChild(op);//把op添加到<select>元素中
					}
				}
			};

		};
	};
</script>

</head>

<body>
	<h1 align="center">省市联动</h1>
	<select name="province" id="p1">
		<option>==请选择省份==</option>
	</select>
	<br />

	<select name="city" id="p2">
		<option>==请选择请城市==</option>
	</select>
</body>
</html>
