<% htmlHead("Управление"); %>
<script type="text/javascript"><!--
<%
	setMibsVars("OP_MODE",
		"WEB_WAN_ACCESS_ENABLED", "WEB_WAN_ACCESS_PORT",
		"TELNET_WAN_ACCESS_ENABLED", "TELNET_ACCESS_PORT",
		"WEB_TIMEOUT");

	if (opts_isDef("tr069"))
		setMibsVars(
			"TR069_ENABLED", "TR069_ACS_URL", "TR069_USERNAME", "TR069_PASSWORD" );
%>

function update(event, form, type) {
	var init = (type === 'init');
	switch (form.name) {
	case "remoteManagement":
		if (init) {
			_(form, "WEB_WAN_ACCESS_PORT,TELNET_ACCESS_PORT")
				.setParser("port");
		}
		break;

	case "systemTimeout":
		if (init) {
			_(form, "WEB_TIMEOUT")
				.setParser("timeout");
		}
<%
if (opts_isDef("tr069")) write("
		break;

	case \"TR069\":
		if (init) {
			_(form, \"TR069_ACS_URL\")    .setParser(\"url\");
			_(form, \"TR069_USERNAME\")   .setParser(\"ascii\");
			_(form, \"TR069_PASSWORD\")   .setParser(\"password\");
		}

		_(form, \"TR069_ACS_URL,TR069_USERNAME,TR069_PASSWORD\")
			.enable(form.TR069_ENABLED.checked);
	}
");
%>}
//--></script>
</head>
<body class="body">
<%
	info_inet = "";
	info_os = "";
	AP_MODE = (OP_MODE == 2) || (OP_MODE == 3);
	if (!AP_MODE) {
		info_inet = " А так же разрешить к нему доступ из Интернета.<br>";
		info_os = ", если они заняты в <a href=\"/homenet/servers.asp\">правилах перенаправления портов</a> или заблокированы провайдером";
	}

	writeLeafOpen("Управление интернет-центром", 
		"Вы можете изменить стандартные номера портов управления интернет-центром для протоколов HTTP и TELNET" +
		info_os + "." + info_inet); %>

<% writeFormOpen("remoteManagement", "target='_top'"); %>
<table class="sublayout">
<tr>
	<td class='label'>TCP-порт веб-конфигуратора:</td>
	<td class='field'><%=inputText("WEB_WAN_ACCESS_PORT", 5, 5); %></td>
</tr><%
	if (!AP_MODE) {
		write("
<tr>
	<td class='label'></td>
	<td class='field'>
		" + checkBox("WEB_WAN_ACCESS_ENABLED") + "<label for='WEB_WAN_ACCESS_ENABLED'>Разрешить удаленный доступ</label>
	</td>
</tr>
<tr>
	<td class='label' colspan='2'></td>
</tr>");
	} %>
<tr>
	<td class='label'>TCP-порт командной строки:</td>
	<td class='field'><%=inputText("TELNET_ACCESS_PORT", 5, 5); %></td>
</tr><%
	if (!AP_MODE) {
		write("
<tr>
	<td class='label'></td>
	<td class='field'>
		" + checkBox("TELNET_WAN_ACCESS_ENABLED") + "<label for='TELNET_WAN_ACCESS_ENABLED'>Разрешить удаленный доступ</label>
	</td>
</tr>");
	} %>
<tr>
	<td class='label'></td>
	<td class='submit'>
		<%=submit("Применить");%>
	</td>
</tr>
</table>
</form>
<% writeLeafClose(); write("\n");

writeLeafOpen("Таймаут сессии управления", 
	"Определяет время простоя в минутах, после которого сессия администратора "+
	"будет автоматически завершена. Чтобы отключить тайм-аут установите 0.");
write("\n");
writeFormOpen("systemTimeout"); %>
<table class="sublayout">
<tr>
	<td class='label'>Таймаут:</td>
	<td class='field'><%=inputText("WEB_TIMEOUT", 14, 4); %></td>
</tr>
<tr>
	<td class='label'></td>
	<td class='submit'>
		<%=submit("#systemTimeout", "Применить");%>
	</td>
</tr>
</table>
</form>
<% writeLeafClose();
if (opts_isDef("tr069")) {
	write("\n");
	writeLeafOpen("#TR069", "TR069 setup", 
		"TR069 allows your provider to manage the device, update settings and track device status.");
	write("\n");
	writeFormOpen("TR069");
	write("
<table class='sublayout'>
<tr>
	<td class='label'></td>
	<td class='field'>
		", checkBox("TR069_ENABLED"), "<label for='TR069_ENABLED'>Enable TR069</label>
	</td>
</tr>
<tr>
	<td class='label'>Management server URL:</td>
	<td class='field'>", inputText("TR069_ACS_URL", 50, 120), "</td>
</tr>

<tr>
	<td class='label'>Connection username</td>
	<td class='field'>", inputText("TR069_USERNAME", 40, 63), "</td>
</tr>
<tr>
	<td class='label'>Connection password</td>
	<td class='field'>", inputPassword("TR069_PASSWORD", 40, 63), "</td>
</tr>
<tr>
	<td class='label'></td>
	<td class='submit'>
		", submit("#TR069", "Save"), "
	</td>
</tr>
</table>
</form>
");
	writeLeafClose();
}
%>

<script type="text/javascript">updateAllForms();</script>
</body>
</html>
