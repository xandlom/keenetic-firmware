<% htmlHead("Config File"); setMibsVars("HOST_NAME"); %>
<script type="text/javascript"><!--
function update(event, form, type) {
	if (type === 'init' && form.name == "loadConfig")
		_(form, "binary") .setParser("-none@bottom");
}

function submit(event) {
	switch (this.name) {
	case "loadConfig":
		return confirm("В процессе изменения конфигурации вы будете отключены от устройства.");

	case "resetConfig":
		return confirm('Будут отменены все изменения конфигурации и восстановлены настройки по умолчанию.');

	case "reboot":
		return confirm('Устройство будет перезапущено.\nУверены?');
	}
	return true;
}

function Store_onclick() {
	window.location.href = "/req/config/<%=HOST_NAME;%>.cfg";
}

function StorePublic_onclick() {
	alert("Конфигурация без учётных записей и паролей(заменятся на 1234).");
	window.location.href = "/req/config/<%=HOST_NAME;%>_pub.cfg?pub=1";
}
--></script>
</head>
<body class="body">
<% writeLeafOpen("Конфигурация интернет-центра", 
	"Можно сделать резервную копию текущей конфигурации интернет-центра, восстановить "+
	"ранее сохраненную конфигурацию из файла или сбросить пользовательские настройки."); %>

<table class="sublayout">
<tr>
	<td class='label'>Резервная копия настроек:</td>
	<td class='field'><%=button("Store:Сохранить"); %><%=button("StorePublic:Без паролей"); %></td>
</tr>
</table>

<% writeFormOpen("loadConfig", "enctype='multipart/form-data' target='_top'"); %>
<table class="sublayout">
<tr>
	<td class='label'>Восстановить конфигурацию:</td>
	<td class='field'>
		<% writeInputFile("binary", 30);
		   write(submit("send:Восстановить")); %>
	</td>
</tr>
</table>
</form>

<% writeFormOpen("resetConfig", "target='_top'"); %>
<table class="sublayout">
<tr>
	<td class='label'>Сбросить настройки:</td>
	<td class='field'><%=submit("reset:Сброс");%></td>
</tr>
</table>
</form>

<% writeFormOpen("syncConfig", "target='_top'"); %>
<table class="sublayout">
<tr>
	<td class='label'>Настройки в telnet-сессии:</td>
	<td class='field'><%=submit("sync:Получить изменения");%></td>
</tr>
</table>
</form>

<% writeFormOpen("reboot", "target='_top'"); %>
<table class="sublayout">
<tr>
	<td class='label'></td>
	<td class='field'><%=submit("save:Перезапустить устройство");%></td>
</tr>
</table>
</form>

<% writeLeafClose(); %>
<script type="text/javascript">updateAllForms();</script>
</body>
</html>
