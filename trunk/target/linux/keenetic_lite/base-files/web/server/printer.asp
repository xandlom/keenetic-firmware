<% htmlHead("Принт-сервер"); %>
<script type="text/javascript"><!--
<%
	setMibsVars("OP_MODE", "PRINTSERVER_WAN_ACCESS_ENABLED", "PRINTSERVER_ENABLED");
%>

var printer = <% writePrinterFirmwareProps(); %>;

function update(event, form, type) {
	if (type === 'init') {
		switch(form.name) {
			case 'printerFirmware':
				_(form, "binary") .setParser("-ascii@bottom");
				break;

			case 'printerFirmwareDel':
				_("#file_size").attr("innerHTML", Size.full(printer.file_size));
				_("#tableFwDel").show(printer.file_size != 0);
				_("#tableFwAdd").show(printer.file_size == 0);
				break;
		}
	}

	if (form.name == 'printer')
		_("#WAN_ACCESS").show(form.PRINTSERVER_ENABLED.checked);
}
--></script>
</head>

<body class="body">
<% writeLeafOpen("Сетевая печать на USB-принтер",
	"Можно разрешить всем пользователям домашней сети доступ к совместимому принтеру, "+
	"подключенному к интернет-центру."); %>

<% writeFormOpen("printer"); %>
<table class="sublayout">
<tr>
	<td class='label'></td>
	<td class='field'>
		<%=checkBox("PRINTSERVER_ENABLED"); %><label for='PRINTSERVER_ENABLED'>Включить сервер печати</label>
	</td>
</tr><%
	AP_MODE = (OP_MODE == 2) || (OP_MODE == 3);
	if (!AP_MODE) write("
<tr id='WAN_ACCESS'>
	<td class='label'></td>
	<td class='field'>
		", checkBox("PRINTSERVER_WAN_ACCESS_ENABLED"), "<label for='PRINTSERVER_WAN_ACCESS_ENABLED'>Открыть доступ к принтеру из интернета</label>
	</td>
</tr>");
%>
<tr>
	<td class='label'></td>
	<td class='submit'>
		<%=submit("Применить");%>
	</td>
</tr>
</table>
</form>

</td></tr>
</table>

<% writeLeafOpen("#tableFwAdd", "Микропрограмма принтера",
	"Для работы некоторых принтеров с сервером печати, например серии принтеров HP "+
	"LaserJet P/10xx, необходимо подгружать микропрограмму (прошивку) принтера."); %>

<% writeFormOpen("printerFirmware", "enctype=\"multipart/form-data\""); %>
<table class="sublayout">
<tr>
	<td class='label'>Выберите файл:</td>
	<td class='field'><% writeInputFile("binary", 40); %></td>
</tr>
<tr>
	<td colspan='2' class='submit'>
		<%=submit("send:Установить");%>
	</td>
</tr>
</table>
</form>
</td></tr></table>

<% writeLeafOpen("#tableFwDel", "Текущая микропрограмма принтера",
	"Если вы хотите подключить другой принтер к серверу печати, удалите текущую микропрограмму."); %>

<% writeFormOpen("printerFirmwareDel"); %>
<table class="sublayout">
<tr>
	<td class='label'>Размер файла:</td>
	<td class='field' id="file_size"></td>
</tr>
<tr>
	<td colspan='2' class='submit'>
		<%=submit("del:Удалить");%>
	</td>
</tr>
</table>
</form>
<% writeLeafClose(); %>

<script type="text/javascript">updateAllForms();</script>
</body>
</html>
