<% htmlHead("Фильтр MAC-адресов"); %>
<script type="text/javascript"><!--
<%
	setMibsVarsAndWriteMibProps("MACFILTER_MODE");
	mac = "";
	comment = "";
	selfdel = selfadd = 1;
	selfmac = getClientMac();
%>
mib.its_mac = '<%=selfmac;%>';
mib.tbl_name = "<%=mib_tbl_name="MACFILTER_TBL"; %>";
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
	case "macFilterDel":
		return submitStdDelForm(event);
	}

	return true;
}

function update(event, form, type)
{
	switch (form.name) {
	case "macFilterSet":
		var mode = form.MACFILTER_MODE.value,
		    enabled = (mib.its_mac !== '') && (mode != 0),
		    inlist_black = enabled && (mode == 1) && mib.its_mac in mib.tbl_idx,
		    inlist_white = enabled && (mode == 2) && !(mib.its_mac in mib.tbl_idx);

		_("#_selfwhite").show(inlist_white);
		_("#selfadd").enable(inlist_white);
		_("#_selfblack").show(inlist_black);
		_("#selfdel").enable(inlist_black);
		break;

	case "macFilterAdd":
		if (type === 'init') {
			if (mib.tbl_info.height >= mib.tbl_info.limit) {
				_(form, "/!save") .enable(false);
				_(form, "save") .setParser("disable:В таблице фильтра не осталось свободных строк");
			}

			_(form, "mac")
				.setParser("mac");
		}
		break;

	case "macFilterDel":
		updateStdDelForm(event, form, type);
	}
}
--></script>
</head>

<body class="body">
<% writeLeafOpen("Блокировка локальных MAC-адресов", 
	"Можно запретить доступ в Интернет определенным устройствам домашней сети. "+
	"Для этого включите этот фильтр и укажите MAC-адреса, которые нужно блокировать."); %>

<% writeFormOpen("macFilterSet"); %>
<%=hidden("selfmac");%>
<table class="sublayout">
<tr>
	<td class='label'><label for='MACFILTER_MODE'>Режим фильтра MAC-адресов:</label></td>
	<td class='field'><% writeSelectOpen("MACFILTER_MODE"); %>
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
		<%=checkBox("selfadd");%><label for='selfadd'>Добавить мой MAC-адрес в белый список</label>
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

<% writeLeafSubheader("Таблица блокируемых MAC-адресов"); %>

<% writeFormOpen("macFilterAdd"); %>
<table class="sublayout">
<tr>
	<td class='label'>MAC-адрес:</td>
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

<% writeFormOpen("macFilterDel"); %>
<table class="sublayout">
<tr><td>
	<table id="some_table" class="list">
		<tr>
			<th class='list' width="1%">&nbsp;</th>
			<th class='list' width="27%">MAC-адрес</th>
			<th class='list' width="63%">Описание</th>
		</tr>
<%
writeTable(mib_tbl_name,
"		<tr class='#.class point'>
			<td class='check'><input type='checkbox' name='select#' value='ON'/></td>
			<td class='list'>$mac.mac</td>
			<td class='list'>$comment</td>
		</tr>
", "		<tr class='odd first'><td colspan='3' class='empty'>Нет записей</td></tr>
");
%>	</table>
</td></tr>
<tr><td class="submit">
		<%=submit("del:Удалить", "delAll:Удалить все");%>
</td></tr>
</table>
</form>
<% writeLeafClose(); %>
<script type="text/javascript">updateAllForms();</script>
</body>
</html>
