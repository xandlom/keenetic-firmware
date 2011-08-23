<% htmlHead("Wireless Access List"); %>
<script type="text/javascript"><!--
<%
	setMibsVarsAndWriteMibProps("WLAN_MAC_ACL_MODE");
	mac = "";
	comment = "";
	selfdel = selfadd = 1;
	selfmac = getWLANclientMac();
%>
mib.its_mac = '<%=selfmac;%>';
mib.tbl_name = "<%=mib_tbl_name="WLAN_MAC_ACL_TBL"; %>";
mib.tbl_info = <% writeTableInfo(mib_tbl_name); %>;
mib.tbl_data = [
<% writeTable(mib_tbl_name,
"	{ mac: '$mac', comment: '$comment', smac: '$mac.mac' },
", "");
%>	{}
];
mib.tbl_idx = {
<% writeTable(mib_tbl_name,
"	'$mac':#,
", "");
%>	'fake':-1
};

function submit(event)
{
	switch (this.name) {
	case "wlanACLadd":
		return confirm(["Устройство с указанным MAC-адресом будет ", mib.WLAN_MAC_ACL_MODE == 1 ? "заблокировано":"разблокировано", "!"].join(""));

	case "wlanACLdel":
		return submitStdDelForm(event);
	}

	return true;
}

function update(event, form, type)
{
	switch (form.name) {
	case "wlanACLset":
		var onwifi = (mib.its_mac !== '') && form.WLAN_MAC_ACL_MODE.value,
		    onwifi_black = onwifi && (form.WLAN_MAC_ACL_MODE.value == 1) && mib.its_mac in mib.tbl_idx,
		    onwifi_white = onwifi && (form.WLAN_MAC_ACL_MODE.value == 2) && !(mib.its_mac in mib.tbl_idx);

		_("#_selfwhite").show(onwifi_white);
		_("#selfadd").enable(onwifi_white);
		_("#_selfblack").show(onwifi_black);
		_("#selfdel").enable(onwifi_black);
		break;

	case "wlanACLadd":
		if (type === 'init') {
			if (mib.tbl_info.height >= mib.tbl_info.limit) {
				_(form, "/!save") .enable(false);
				_(form, "save") .setParser("disable:В списке клиентов не осталось свободных строк");
			}

			_(form, "mac")     .setParser("mac");
			_(form, "comment") .setParser("?printable");
		}
		break;

	case "wlanACLdel":
		updateStdDelForm(event, form, type);
	}
}

function postValidate(form, valid) {
	if (form.name != 'wlanACLadd')
		return valid;

	var v = form.validation,
	    item = {
	    	mac: v.el("mac").parsedValue };

	var env = hint.box(form.save),
	    hnt = hint.left(env.box);
	if (valid && item.mac in mib.tbl_idx) {
		var it = mib.tbl_data[ mib.tbl_idx[ v.el("mac").parsedValue ] ];

		hnt.className = "fullist error";
		hnt.innerHTML = [
				"Совпадает с: ",
				it.smac, ', "', it.comment, '"'
			].join('');
		return false;
	}

	hnt.className = "fullist message";
	hnt.innerHTML = "";
	return valid;
}
--></script>
</head>
<body class="body">
<% writeLeafOpen("Блокировка доступа по MAC-адресам", 
	"Можно выбрать режим блокировки доступа к беспроводной сети и составить список "+
	"клиентов. В&nbsp;режиме «Белый список» доступ к беспроводной сети запрещен "+
	"клиентам, не входящим в список. В&nbsp;режиме «Черный список» доступ к "+
	"беспроводной сети запрещен всем клиентам из списка."); %>

<% writeFormOpen("wlanACLset"); %>
<%=hidden("selfmac");%>
<table class="sublayout">
<tr>
	<td class='label'><label for='WLAN_MAC_ACL_MODE'>Режим блокировки:</label></td>
	<td class='field'><% writeSelectOpen("WLAN_MAC_ACL_MODE"); %>
			<% writeOption("Отключено", 0); %>
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
		Внимание! Вашего компьютера в белом списке нет. Это значит, что после включения блокировки вы потеряете доступ к интернет-центру через Wi-Fi.
	</td>
</tr>
<tr>
	<td class='label'></td>
	<td class='field error'>
		<%=checkBox("selfadd");%><label for='selfadd'>Добавить мой MAC-адрес в белый список</label>
	</td>
</tr>
</table>

<table id='_selfblack' class="sublayout">
<tr>
	<td class='label'></td>
	<td class='field_hint warning small'>
		Внимание! Адрес вашего компьютера есть в чёрном списке. Это значит, что после включения блокировки вы потеряете доступ к интернет-центру через Wi-Fi.
	</td>
</tr>
<tr>
	<td class='label'></td>
	<td class='field error'>
		<%=checkBox("selfdel");%><label for='selfdel'>Удалить мой MAC-адрес из чёрного списка</label>
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

<%
	type = "заблокированных";
	if (WLAN_MAC_ACL_MODE == 2)
		type = "допущенных";
	writeLeafSubheader("Список " + type + " устройств"); %>

<% writeFormOpen("wlanACLadd"); %>
<table class="sublayout">
<tr>
	<td class='label'>MAC-адрес клиента:</td>
	<td class='field'><%=inputText("mac", 16, 17); %></td>
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

<% writeFormOpen("wlanACLdel"); %>
<table class="sublayout">
<tr><td colspan="2">
<table id="some_table" class="list">
<tr>
	<th class="list" width="10%"></th>
	<th class="list" width="27%">MAC-адрес</th>
	<th class="list" width="63%">Описание</th>
</tr>
<%
writeTable(mib_tbl_name,
"<tr class='#.class point'>
	<td class='check'><input type='checkbox' name='select#' value='ON'/></td>
	<td class='list'>$mac.mac</td>
	<td class='list'>$comment</td>
</tr>
", "<tr class='odd first'><td colspan='3' class='empty'>Нет записей</td></tr>
");
%></table></td>
</tr>
<tr>
	<td class='label'></td>
	<td class='submit'>
		<%=submit("del:Удалить", "delAll:Удалить все");%>
	</td>
</tr>
</table>
</form>
<% writeLeafClose(); %>
<script type="text/javascript">updateAllForms();</script>
</body>
</html>
