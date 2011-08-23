<%	setMibsVars("DEVICE_NAME");
	htmlHead("ZyXEL "+DEVICE_NAME, "nolinks"); %>
<link rel='stylesheet' type='text/css' href='/css/msg.css?=<%=rvsn();%>'/>
<style type="text/css">
div.outer {
	margin: 160px 8px 8px 8px !important;
}
</style>
</head>
<body>
<div class='back'>
<div class='outer'>
<div id='logo_line'> </div>
<div id='logo_underline'></div><div class="header">
<p>Работа с веб-конфигуратором <span class='nowrap'>интернет-центра <%=DEVICE_NAME;%></span> завершена.</p>
</div>
</div>
</div>
</body>
</html>
