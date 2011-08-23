<% htmlHead("URL-фильтр"); %>
<script type="text/javascript"><!--
<%
	setMibsVarsAndWriteMibProps("URLFILTER_ENABLED");
	url = "";
%>
mib.tbl_name = "<%=mib_tbl_name="URLFILTER_TBL"; %>";
mib.tbl_info = <% writeTableInfo(mib_tbl_name); %>;

function submit(event)
{
	switch (this.name) {
	case "urlFilterDel":
		return submitStdDelForm(event);
	}

	return true;
}

function update(event, form, type)
{
	switch (form.name) {
	case "urlFilterAdd":
		if (type === 'init') {
			if (mib.tbl_info.height >= mib.tbl_info.limit) {
				_(form, "/!save") .enable(false);
				_(form, "save") .setParser("disable:В таблице фильтра не осталось свободных строк");
			}

			_(form, "url")
				.setParser("ascii");
		}
		break;

	case "urlFilterDel":
		updateStdDelForm(event, form, type);
	}
}
--></script>
</head>
<body class="body">
<% writeLeafOpen("Блокировка доступа к веб-страницам (URL-адресам)", 
	"Можно запретить устройствам домашней сети доступ к определенным веб-страницам, адреса "+
	"которых совпадают с одной из указанных масок URL.<br><br>Примеры масок:"+
	"<ul><li>something.com — блокировка доступа к сайту something.com</li>"+
	"<li>something.com/abc — блокировка доступа к ресурсу «abc» на сайте something.com</li>"+
	"<li>abc — блокировка доступа ко всем веб-страницам, в адресе которых есть сочетание «abc»</li></ul>"); %>

<% writeFormOpen("urlFilterSet"); %>
<table class="sublayout">
<tr>
	<td class='label'></td>
	<td class='field'>
		<%=checkBox("URLFILTER_ENABLED"); %><label for='URLFILTER_ENABLED'>Включить фильтр URL-адресов</label>
	</td>
</tr>
<tr>
	<td class='label'></td>
	<td class='submit'>
		<%=submit("Применить");%>
	</td>
</tr>
</table>
</form>

<% writeLeafSubheader("Таблица масок URL"); %>

<% writeFormOpen("urlFilterAdd"); %>
<table class="sublayout">
<tr>
	<td class='label'>Маска URL:</td>
	<td class='field'><%=inputText("url", 40, 120); %></td>
</tr>
<tr>
	<td class='label'></td>
	<td class='submit'>
		<%=submit("Добавить");%>
	</td>
</tr>
</table>
</form>

<% writeFormOpen("urlFilterDel"); %>
<table class="sublayout">
<tr><td>
	<table id="some_table" class="list">
		<tr>
			<th class='check'>&nbsp;</th>
			<th class='list'>Маска URL</th>
		</tr>
<%
writeTable(mib_tbl_name,
"		<tr class='#.class point'>
			<td class='check'><input type='checkbox' name='select#' value='ON'/></td>
			<td class='list'>$url</td>
		</tr>
", "		<tr class='odd first'><td colspan='2' class='empty'>Нет записей</td></tr>
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
