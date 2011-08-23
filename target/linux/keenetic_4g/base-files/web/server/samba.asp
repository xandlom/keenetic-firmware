<% htmlHead("NetBios-доступ к USB-диску"); %>
<script type="text/javascript"><!--
<%
	setMibsVars(
		"HOST_NAME", "SMB_NAME", "SMB_WORKGROUP", 
		"SMB_ACCESS_ENABLED", "SMB_ANONYMOUS_ENABLED", "SMB_ANONYMOUS_FULLACCESS",
		"SMB_USERS_ENABLED");
%>

function update(event, form, type) {
	if (type === 'init')
		_(form, "SMB_NAME,SMB_WORKGROUP") .setParser("domain");

	_(form, "SMB_ANONYMOUS_ENABLED,SMB_USERS_ENABLED,SMB_NAME,SMB_WORKGROUP").enable(form.SMB_ACCESS_ENABLED.checked);
	_(form, "SMB_ANONYMOUS_FULLACCESS").enable(form.SMB_ACCESS_ENABLED.checked && form.SMB_ANONYMOUS_ENABLED.checked);
}

--></script>
</head>

<body class="body">

<% writeLeafOpen("Общий доступ к USB-диску в сети Microsoft Windows",
	"Можно открыть общий доступ к USB-диску для пользователей домашней сети. Введите "+
	"используемое в вашей сети имя рабочей группы Windows и NetBIOS-имя, по которому "+
	"будет доступен подключенный диск. NetBIOS-имя не должно совпадать с именем рабочей "+
	"группы или компьютера в домашней сети."); %>

<% writeFormOpen("smb"); %>
<table class="sublayout">
<tr>
	<td class='label'></td>
	<td class='field'>
		<%=checkBox("SMB_ACCESS_ENABLED"); %><label for='SMB_ACCESS_ENABLED'>Разрешить общий доступ к диску в сети Windows</label>
	</td>
</tr>
<tr>
	<td class='label'>NetBIOS-имя:</td>
	<td class='field'>
		<%=inputText("SMB_NAME", 30, 30); %>
	</td>
</tr>
<tr>
	<td class='label'>Рабочая группа Windows:</td>
	<td class='field'>
		<%=inputText("SMB_WORKGROUP", 30, 30); %>
	</td>
</tr>
<tr>
	<td class='label'></td>
	<td class='field'>
		<%=checkBox("SMB_ANONYMOUS_ENABLED"); %><label for='SMB_ANONYMOUS_ENABLED'>Разрешить доступ на чтение любым пользователям домашней сети</label>
	</td>
</tr>
<tr>
	<td class='label'></td>
	<td class='field' style='padding-left: 1.9em !important;'>
		<%=checkBox("SMB_ANONYMOUS_FULLACCESS"); %><label for='SMB_ANONYMOUS_FULLACCESS'>Разрешить изменять файлы любым пользователям домашней сети</label>
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
<% writeLeafClose(); %>
<script type="text/javascript">updateAllForms();</script>
</body>
</html>
