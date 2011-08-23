<% htmlHead("DynamicDNS"); %>
<script type="text/javascript"><!--
<%
	setMibsVars(
		"DDNS_ENABLED", "DDNS_NAME_TYPE", "DDNS_TYPE", 
		"DDNS_DOMAIN_NAME", "DDNS_USER", "DDNS_PASSWORD");
%>
var ddnsElements = "DDNS_TYPE,DDNS_NAME_TYPE,DDNS_DOMAIN_NAME,DDNS_USER,DDNS_PASSWORD";

_ru['updating'] = 'обновление';
_ru['inactive'] = 'служба остановлена';

function update(event, form, type) {
	if (type === 'init') {
		_(form, "DDNS_DOMAIN_NAME")   .setParser("domain");
		_(form, "DDNS_USER")          .setParser("ascii");
		_(form, "DDNS_PASSWORD")      .setParser("password");
		autoStatus.data = <% ddnsStatus(); %>;
		autoStatus.init('ddns', 'cmd=status', 'dyndns_status');
	}

	_(form, ddnsElements)
		.enable(form.DDNS_ENABLED.checked);

	_("#_NAME_TYPE") .show(form.DDNS_TYPE.value == "2");

	if (!form.DDNS_ENABLED.checked)
		return;

	_(form.DDNS_NAME_TYPE)
		.enable(form.DDNS_TYPE.value == "2");

	var NameType = form.DDNS_NAME_TYPE[0].checked || form.DDNS_TYPE.value != "2";
	$("ddnsNameLabel").html(NameType ?
		"Доменное имя:" : 
		"Имя группы:");
}

--></script>
</head>

<body class="body">
<% writeLeafOpen("Постоянное доменное имя",
	"Если вы установили домашний <a href='/homenet/servers.asp'>интернет-сервер</a> или "+
	"пользуетесь <a href='/system/management.asp'>удаленным управлением</a>, то для "+
	"удобства можно зарегистрировать доменное имя в службах "+
	"<a href='http://www.dyndns.com/' target='_blank'>DynDNS</a>, "+
	"<a href='http://www.no-ip.com/' target='_blank'>NO-IP</a> или "+
	"<a href='http://www.tzo.com/' target='_blank'>TZO</a>.<br>Интернет-пользователи "+
	"всегда смогут найти ваш сервер, обращаясь к нему по доменному имени, даже если в "+
	"вашем распоряжении постоянно меняющийся динамический IP-адрес."); %>

<% writeFormOpen("ddns"); %>
<table class="sublayout">
<tr>
	<td class='label'></td>
	<td class='field'>
		<%=checkBox("DDNS_ENABLED"); %><label for='DDNS_ENABLED'>Использовать динамическую DNS</label>
	</td>
</tr>
<tr>
	<td class='label'>Служба динамической DNS:</td>
	<td class='field'><% writeSelectOpen("DDNS_TYPE"); %>
		<% writeOption("DynDNS", 0); %>
		<% writeOption("TZO",    1); %>
		<% writeOption("NO-IP",  2); %>
	</select></td>
</tr>
</table>
<table id="_NAME_TYPE" class="sublayout">
<tr>
	<td class='label'>Тип:</td>
	<td class='field'>
		<%=radio("DDNS_NAME_TYPE", "0"); %><label for='DDNS_NAME_TYPE_0'>Доменное имя</label>
		<%=radio("DDNS_NAME_TYPE", "1"); %><label for='DDNS_NAME_TYPE_1'>Имя группы</label>
	</td>
</tr>
</table>
<table class="sublayout">

<tr>
	<td class='label' id="ddnsNameLabel">Доменное имя:</td>
	<td class='field'><%=inputText("DDNS_DOMAIN_NAME", 50, 63); %></td>
</tr>
<tr>
	<td class='label'>Имя пользователя/e-mail:</td>
	<td class='field'><%=inputText("DDNS_USER", 50, 63); %></td>
</tr>

<tr>
	<td class='label'>Пароль/Ключ:</td>
	<td class='field'><%=inputPassword("DDNS_PASSWORD", 50, 63); %></td>
</tr>
<tr>
	<td class='label'>Состояние:</td>
	<td class='field' id='dyndns_status'></td>
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
