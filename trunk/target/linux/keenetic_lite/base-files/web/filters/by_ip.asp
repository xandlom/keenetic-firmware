<%	htmlHead("Фильтр IP-адресов"); %>
<script type="text/javascript"><!--
<%	setMibsVarsAndWriteMibProps("IPFILTER_MODE", "LAN_IP_ADDR", "LAN_SUBNET_MASK");
	protocol = 3;
	ip = comment = "";
	selfdel = selfadd = 1;
	selfip = REMOTE_ADDR;
%>
mib.its_ip = '<%=selfip;%>';
mib.tbl_name = "<%=mib_tbl_name="IPFILTER_TBL"; %>";
mib.tbl_info = <% writeTableInfo(mib_tbl_name); %>;
mib.lan_ip = IP.parse(mib.LAN_IP_ADDR);
mib.lan_mask = IP.parse(mib.LAN_SUBNET_MASK);
mib.tbl_data = [
<% writeTable(mib_tbl_name,
"	{ ip: '$ip', proto: '$proto[\"\",\"TCP\",\"UDP\",\"TCP и UDP\"]', comment: '$comment' },
", "");
%>	{}
];
mib.tbl_idx = {
<% writeTable(mib_tbl_name,
"	'$ip':#,
", "");
%>	'fake':-1
};

function submit(event) {
	switch (this.name) {
	case "ipFilterDel":
		return submitStdDelForm(event);
	}
	return true;
}

function update(event, form, type) {
	switch (form.name) {
	case "ipFilterSet":
		var mode = form.IPFILTER_MODE.value,
		    enabled = (mib.its_ip !== '') && (mode != 0),
		    inlist_black = enabled && (mode == 1) && mib.its_ip in mib.tbl_idx,
		    inlist_white = enabled && (mode == 2) && !(mib.its_ip in mib.tbl_idx);

		_("#_selfwhite").show(inlist_white);
		_("#selfadd").enable(inlist_white);
		_("#_selfblack").show(inlist_black);
		_("#selfdel").enable(inlist_black);
		break;

	case "ipFilterAdd":
		if (type === 'init')
			if (mib.tbl_info.height >= mib.tbl_info.limit) {
				_(form, "/!save") .enable(false);
				_(form, "save") .setParser("disable:В таблице фильтра не осталось свободных строк");
			}

		_(form, "ip").setParser("ip")
			.groupValidation("localIp");
		break;

	case "ipFilterDel":
		updateStdDelForm(event, form, type);
	}
}
--></script>
</head>
<body class="body">
<% writeLeafOpen("Блокировка локальных IP-адресов", 
	"Можно запретить доступ в Интернет определенным устройствам домашней сети. Для этого включите этот фильтр и укажите IP-адреса,  которые нужно блокировать. Для блокировки устройства с динамически назначаемым IP-адресом, можно выполнить <a href=\"/homenet/lan.asp\">привязку IP-адрес</a> к MAC-адресу этого устройства или использовать <a href=\"/filters/by_mac.asp\">фильтр MAC-адресов</a>."); %>

<% writeFormOpen("ipFilterSet"); %>
<%=hidden("selfip");%>
<table class="sublayout">
<tr>
	<td class='label'><label for='IPFILTER_MODE'>Режим фильтра IP-адресов:</label></td>
	<td class='field'><% writeSelectOpen("IPFILTER_MODE"); %>
			<% writeOption("Отключен", 0); %>
			<% writeOption("Черный список", 1); %>
			<% writeOption("Белый список", 2); %>
		</select>
	</td>
</tr>
</table>

<table id='_selfwhite' class="sublayout">
<tr>
	<td class='label'></td>
	<td class='field_hint warning small'>
		Внимание! Вашего компьютера в белом списке нет. Это значит, что после включения фильтра вы потеряете доступ к интернет-центру.
	</td>
</tr>
<tr>
	<td class='label'></td>
	<td class='field error'>
		<%=checkBox("selfadd");%><label for='selfadd'>Добавить мой IP-адрес в белый список</label>
	</td>
</tr>
</table>

<table id='_selfblack' class="sublayout">
<tr>
	<td class='label'></td>
	<td class='field_hint warning small'>
		Внимание! Адрес вашего компьютера есть в чёрном списке. Это значит, что после включения фильтра вы потеряете доступ к интернет-центру.
	</td>
</tr>
<tr>
	<td class='label'></td>
	<td class='field error'>
		<%=checkBox("selfdel");%><label for='selfdel'>Удалить мой IP-адрес из чёрного списка</label>
	</td>
</tr>
</table>

<table class="sublayout">
<tr>
	<td class='label'></td>
	<td class='submit'>
		<%=submit("Применить");%>
	</td>
</tr>
</table>
</form>

<% writeLeafSubheader("Таблица блокируемых IP-адресов"); %>

<% writeFormOpen("ipFilterAdd"); %>
<table class="sublayout">
<tr>
	<td class='label'>IP-адрес:</td>
	<td class='field'><%=inputText("ip", 18, 15); %></td>
</tr>
<tr>
	<td class='label'>Протокол:</td>
	<td class='field'>
		<% writeSelectOpen("protocol"); %>
			<% writeOption("Только TCP", 1); %>
			<% writeOption("Только UDP", 2); %>
			<% writeOption("TCP и UDP", 3); %>
		</select>
	</td>
</tr>
<tr>

	<td class='label'>Описание:</td>
	<td class='field'><%=inputText("comment", 30, 31); %></td>
</tr>
<tr>
	<td class='label'></td>
	<td class='submit'>
		<%=submit("Добавить");%>
	</td>
</tr>
</table>
</form>

<% writeFormOpen("ipFilterDel"); %>
<table class="sublayout">
<tr><td>
	<table id="some_table" class="list">
		<tr>
			<th class='check'>&nbsp;</th>
			<th class='list'>IP-адрес</th>
			<th class='list'>Протокол</th>
			<th class='list' width="57%">Описание</th>
		</tr>
<%
writeTable(mib_tbl_name,
"		<tr class='#.class point'>
			<td class='check'><input type='checkbox' name='select#' value='ON'/></td>
			<td class='list'>$ip</td>
			<td class='list'>$proto[\"\",\"TCP\",\"UDP\",\"TCP и UDP\"]</td>
			<td class='list'>$comment</td>
		</tr>
", "		<tr class='odd first'><td colspan='4' class='empty'>Нет записей</td></tr>
");
%>	</table>
</td></tr>
<tr><td class='submit'>
		<%=submit("del:Удалить", "delAll:Удалить все");%>
</td></tr>
</table>
</form>

<% writeLeafClose(); %>
<script type="text/javascript">updateAllForms();</script>
</body>
</html>
