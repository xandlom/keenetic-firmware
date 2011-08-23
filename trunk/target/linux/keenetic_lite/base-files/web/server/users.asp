<% htmlHead("Пользователи USB-диска"); %>
<script type="text/javascript"><!--
<%
	setMibsVarsAndWriteMibProps("SMB_ACCESS_ENABLED");
	user_name = "";
	password = "";
	fullAccess = 0;
%>
mib.tbl_name = "<%=mib_tbl_name="USERS_TBL"; %>";
mib.tbl_info = <% writeTableInfo(mib_tbl_name); %>;

function submit(event)
{
	switch (this.name) {
	case "usersDel":
		return submitStdDelForm(event);
	}

	return true;
}

function update(event, form, type)
{
	switch (form.name) {
	case "usersAdd":
		if (type === 'init') {
			if (mib.tbl_info.height >= mib.tbl_info.limit) {
				_(form, "/!save") .enable(false);
				_(form, "save") .setParser("disable:В таблице пользователей не осталось свободных строк");
			}

			_(form, "user_name") .setParser("login");
			_(form, "password")  .setParser("password");
		}
		break;

	case "usersDel":
		updateStdDelForm(event, form, type);
	}
}
--></script>
</head>

<body class="body">
<% writeLeafOpen("Учетные записи пользователей USB-диска",
	"Можно разрешить доступ по FTP и сети Windows к USB-диску только определенным "+
	"пользователям."); %>

<% writeFormOpen("usersAdd"); %>
<table class="sublayout">

<tr>
	<td class='label'>Имя пользователя:</td>
	<td class='field'><%=inputText("user_name", 40, 63); %></td>
</tr>
<tr>
	<td class='label'>Пароль:</td>
	<td class='field'><%=inputPassword("password", 40, 63); %></td>
</tr>
</table>

<table class="sublayout">
<tr>
	<td class='label'>Доступ:</td>
	<td class='field'>
		<% writeSelectOpen("fullAccess"); %>
			<% writeOption("Только чтение", 0); %>
			<% writeOption("Чтение и запись", 1); %>
		</select>
	</td>
</tr>
<tr>
	<td class='label'></td>
	<td class='submit'>
		<%=submit("Добавить");%>
	</td>
</tr>
</table>
</form>

<% writeFormOpen("usersDel"); %>
<table class="sublayout">
<tr>
    <td colspan='2'><table id="some_table" class="list">
<tr>
	<th class='list' width="1%">&nbsp;</th>
	<th class='list' width="66%">Имя</th>
	<th class='list' width="31%">Допуск</th>
</tr>
<%
writeTable(mib_tbl_name,
"<tr class='#.class point'>
	<td class='check'><input type='checkbox' name='select#' value='ON'/></td>
	<td class='list'>$name</td>
	<td class='list'>$fullAccess[\"Чтение\",\"Полный\"]</td>
</tr>
", "<tr class='odd first'><td colspan='3' class='empty'>Нет записей</td></tr>
");
%></table></td>
</tr>
<tr>
	<td colspan='2' class='submit'>
		<%=submit("del:Удалить", "delAll:Удалить все");%>
	</td>
</tr>
</table>
</form>
<% writeLeafClose(); %>

<script type="text/javascript">updateAllForms();</script>
</body>
</html>
