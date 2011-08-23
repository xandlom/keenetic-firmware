<% htmlHead("Администрирование"); %>
<script type="text/javascript"><!--
<%
	setMibsVars("ADMIN_PASSWORD", "ADMIN_NAME" );

	username = "admin";
	PASSWORD_CONFIRM = ADMIN_PASSWORD;
%>

function update(event, form, type) {
	var init = (type === 'init');
	if (init)
		_(form, "ADMIN_PASSWORD,PASSWORD_CONFIRM")
			.setParser("?password")
				.groupValidation("optional,match");
}
--></script>
</head>
<body class="body">
<% writeFormOpen("admin"); %>
<% writeLeafOpen("Пароль администратора", 
	"Пароль позволяет предотвратить доступ посторонних к управлению интернет-центром. "+
	"Рекомендуется изменить установленный по умолчанию пароль администратора, указав "+
	"свой пароль в полях «Новый пароль» и «Подтверждение пароля»."); %>

<table class="sublayout">
<tr>
	<td><%=hidden("ADMIN_NAME");%></td>
</tr>
<tr>
	<td class='label'>Новый пароль:</td>
	<td class='field'><%=inputPassword("ADMIN_PASSWORD", 40, 63); %></td>
</tr>
<tr>
	<td class='label'>Подтверждение пароля:</td>
	<td class='field'><%=inputPassword("PASSWORD_CONFIRM", 40, 63); %></td>
</tr>
<tr>
	<td colspan='2' class='submit'>
		<%=submit("/status.asp", "Применить");%>
	</td>
</tr>
</table>
<% writeLeafClose(); %>
</form>
<script type="text/javascript">updateAllForms();</script>
</body>
</html>
