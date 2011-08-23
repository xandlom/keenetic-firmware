<% htmlHead("Сервер FTP"); %>
<script type="text/javascript"><!--
<%
	setMibsVars("OP_MODE", 
		"FTP_ACCESS_ENABLED", "FTP_WAN_ACCESS_ENABLED", "FTP_ANONYMOUS_ENABLED", "FTP_ANONYMOUS_FULLACCESS", "FTP_PORT");
%>

function update(event, form, type) {
	if (type === 'init')
		_(form, "FTP_PORT") .setParser("port");

	_(form, "FTP_WAN_ACCESS_ENABLED,FTP_ANONYMOUS_ENABLED,FTP_PORT").enable(form.FTP_ACCESS_ENABLED.checked);
	_(form, "FTP_ANONYMOUS_FULLACCESS").enable(form.FTP_ACCESS_ENABLED.checked && form.FTP_ANONYMOUS_ENABLED.checked);
}

--></script>
</head>

<body class="body">
<%
	AP_MODE = (OP_MODE == 2) || (OP_MODE == 3);
	from_inet = "";
	if (!AP_MODE)
		from_inet = " и из Интернета";

	writeLeafOpen("Сервер FTP",
		"Можно разрешить доступ к подключенному USB-диску по протоколу FTP из домашней "+
		"сети"+from_inet+". Вы можете разрешить анонимный доступ к серверу или настроить "+
		"<a href='/server/users.asp'>учетные записи пользователей</a>."); %>

<% writeFormOpen("ftp"); %>
<table class="sublayout">
<tr>
	<td class='label'></td>
	<td class='field'>
		<%=checkBox("FTP_ACCESS_ENABLED"); %><label for='FTP_ACCESS_ENABLED'>Включить FTP-сервер</label>
	</td>
</tr><%
	if (!AP_MODE) {
		write("
<tr>
	<td class='label'></td>
	<td class='field'>
		" + checkBox("FTP_WAN_ACCESS_ENABLED") + "<label for='FTP_WAN_ACCESS_ENABLED'>Разрешить доступ из Интернета</label>
	</td>
</tr>");
	}

%>
<tr>
	<td class='label'>Номер порта FTP-сервера:</td>
	<td class='field'>
		<%=inputText("FTP_PORT", 5, 5); %>
	</td>
</tr>
<tr>
	<td class='label'></td>
	<td class='field'>
		<%=checkBox("FTP_ANONYMOUS_ENABLED"); %><label for='FTP_ANONYMOUS_ENABLED'>Разрешить анонимный доступ для загрузки файлов с сервера</label>
	</td>
</tr>
<tr>
	<td class='label'></td>
	<td class='field' style='padding-left: 1.9em !important;'>
		<%=checkBox("FTP_ANONYMOUS_FULLACCESS"); %><label for='FTP_ANONYMOUS_FULLACCESS'>Разрешить полный доступ анонимным пользователям 
</tr>
<tr>
	<td class='label'></td>
	<td class='submit'>
		<%=submit("Применить");%>
	</td>
</tr>
</table>
</form>
<% writeLeafClose(); %>
<script type="text/javascript">updateAllForms();</script>
</body>
</html>
