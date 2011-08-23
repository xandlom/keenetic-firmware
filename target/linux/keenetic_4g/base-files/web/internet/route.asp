<% htmlHead("Статические маршруты"); %>
<script type="text/javascript"><!--
<%
	setMibsVars( "STATICROUTE_ENABLED",
		"WAN_IP_ADDR", "WAN_SUBNET_MASK" );

	writeMibProps("STATICROUTE_ENABLED");

	ip = gateway = ""
	mask = "255.255.0.0";
%>

mib.ifs = <% writeIfsProps(); %>;
mib.tbl_name = "<%=mib_tbl_name="STATICROUTE_TBL"; %>";
mib.tbl_info = <% writeTableInfo(mib_tbl_name); %>;

function submit(event)
{
	switch (this.name) {
	case "routeDel":
		return submitStdDelForm(event);
	}

	return true;
}

function update(event, form, type)
{
	switch (form.name) {
	case "routeAdd":
		if (type === 'init') {
			if (mib.tbl_info.height >= mib.tbl_info.limit) {
				_(form, "/!save") .enable(false);
				_(form, "save") .setParser("disable:В таблице статических маршрутов не осталось свободных строк");
			}

			_(form, "ip")      .setParser("ip");
			_(form, "gateway") .setParser("gateway");
			_(form, "mask")    .setParser("mask");
			_(form, "ip,mask") .groupValidation("net");

			var name, net, nets = [];
			for (name in mib.ifs) {
				net = mib.ifs[name];
				nets.push([IP.toStr(net.ip & net.mask), IP.maskWidth(net.mask)].join('/'));
			}
			$('gw_comment').html(nets.join(', '));
		}
		break;

	case "routeDel":
		updateStdDelForm(event, form, type);
	}
}
--></script>
</head>

<body class="body">
<% writeLeafOpen("Статические маршруты",
	"Можно добавить статические маршруты для доступа к локальным ресурсам провайдера. "+
	"Таблицу действующих маршрутов можно просмотреть в <a href='/status.asp'>системном "+
	"мониторе</a>."); %>

<% writeFormOpen("routeSet"); %>
<table class="sublayout">
<tr>
	<td class='label'></td>
	<td class='field'>
		<%=checkBox("STATICROUTE_ENABLED"); %><label for='STATICROUTE_ENABLED'>Использовать статические маршруты</label>
	</td>
</tr>
<tr>
	<td colspan='2' class='submit'>
		<%=submit("Применить");%>
	</td>
</tr>
</table>
</form>

<% writeLeafSubheader("Таблица статических маршрутов"); %>

<% writeFormOpen("routeAdd"); %>
<table class="sublayout">
<tr>
	<td class='label'>IP-адрес:</td>
	<td class='field'><%=inputText("ip", 16, 15); %></td>
</tr>
<tr>
	<td class='label'>Маска сети:</td>
	<td class='field'><%
		writeSelectOpen("mask");
			writeOptionsIpMasks("Основные", "Редкие"); %>
		</select>
	</td>
</tr>
<tr>
	<td class='label'>Шлюз:</td>
	<td class='field'><%=inputText("gateway", 16, 15); %></td>
</tr>
<tr>
	<td class='label'>Доступные сети:</td>
	<td class='field' id='gw_comment'></td>
</tr>
<tr>
	<td class='label'></td>
	<td class='submit'>
		<%=submit("Добавить");%>
	</td>
</tr>
</table>
</form>

<% writeFormOpen("routeDel"); %>
<table class="sublayout">
<tr><td colspan='2'></td></tr>
<tr>
	<td colspan='2'><table id="some_table" class="list">
<tr>
	<th class='check'>&nbsp;</th>
	<th class='list'>Сетевой адрес</th>
	<th class='list'>Маска</th>
	<th class='list'>Шлюз</th>
</tr>
<%
writeTable(mib_tbl_name,
"<tr class='#.class point'>
	<td class='check'><input type='checkbox' name='select#' value='ON'/></td>
	<td class='list'>$destaddr</td>
	<td class='list'>$netmask</td>
	<td class='list'>$gateway</td>
</tr>
", "<tr class='odd first'><td colspan='4' class='empty'>Нет записей</td></tr>
");
%></table></td>
</tr>
<tr>
	<td colspan='2' class="submit">
		<%=submit("del:Удалить", "delAll:Удалить все");%>
	</td>
</tr>
</table>
</form>
<% writeLeafClose(); %>
<script type="text/javascript">updateAllForms();</script>
</body>
</html>