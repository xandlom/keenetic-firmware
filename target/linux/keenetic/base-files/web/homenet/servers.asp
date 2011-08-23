<% htmlHead("Серверы домашней сети "); %>
<script type="text/javascript"><!--
<%
	setMibsVars(
		"LAN_IP_ADDR", "LAN_SUBNET_MASK", 
		"LAN_DHCP_MODE", "LAN_DHCP_POOL_START", "LAN_DHCP_POOL_END", 
		"PORTFW_ENABLED", "DMZ_ENABLED", "DMZ_HOST");

	writeMibProps("PORTFW_ENABLED", "LAN_IP_ADDR", "LAN_SUBNET_MASK",
		"LAN_DHCP_MODE", "LAN_DHCP_POOL_START", "LAN_DHCP_POOL_END");

	DefSrv = 'Другой';
	ip = local_ip = bcast_ip = inPorts = destPorts = fromPort = toPort = destFromPort = destToPort = comment = "";
	isbcast = 0;
	protocol = 3;
%>
mib.tbl_name = "<%=mib_tbl_name="PORTFW_TBL"; %>";
mib.tbl_info = <% writeTableInfo(mib_tbl_name); %>;
mib.lan_ip   = IP.parse(mib.LAN_IP_ADDR);
mib.lan_mask = IP.parse(mib.LAN_SUBNET_MASK);
mib.dhcp_server = mib.LAN_DHCP_MODE == 2;
mib.dhcp_pool = [IP.parse(mib.LAN_DHCP_POOL_START), IP.parse(mib.LAN_DHCP_POOL_END)];
mib.protos = { 1: 'TCP', 2: 'UDP', 3: 'TCP+UDP' };
mib.tbl_data = [
<% writeTable(mib_tbl_name,
"	{ ip: '$ip', isbcast: '$isbcast', proto: '$proto.int', inPorts: [$fromport, $toport], destPorts: [$destfromport, $desttoport], comment: '$comment' },
", "");
%>	{}
];
mib.isbcast = 0;
mib.protocol = 3;
mib.inPorts = mib.destPorts = mib.comment = '';

mib.tbl_data.pop();

function submit(event)
{
	switch (this.name) {
	case "portFwAdd":
		this.ip.value = this.isbcast[0].checked ? this.local_ip.value : this.bcast_ip.value;
		break;

	case "portFwDel":
		return submitStdDelForm(event);
	}

	return true;
}

var presets_tpl = {
	cols: [ 'isbcast', 'protocol', 'inPorts', 'destPorts', 'comment' ],
	list: { 'Другой':0, 'Web':1, 'Web SSL':2, 'FTP':3, 'E-Mail (POP3)':4, 
		'E-Mail (SMTP)':5, 'DNS':6, 'TelNet':7, 'SSH':8, 'Wake on LAN':9, 
		'IRC':10 },
	rows: {
		0: [ 0, 3,         '',         '', '' ],
		1: [ 0, 1,         80,         80, 'HTTP' ],
		2: [ 0, 3,        443,        443, 'HTTPS' ],
		3: [ 0, 1,    "20-21",    "20-21", 'FTP' ],
		4: [ 0, 1,        110,        110, 'POP3' ],
		5: [ 0, 1,         25,         25, 'SMTP' ],
		6: [ 0, 2,         53,         53, 'DNS' ],
		7: [ 0, 1,         23,         23, 'TelNet' ],
		8: [ 0, 3,         22,         22, 'SSH' ],
		9: [ 1, 2,          9,          9, 'WoL' ],
		10:[ 0, 1,"6667-6672","6667-6672", 'IRC' ]
	}
};

function update(event, form, type)
{
	var init = (type === 'init');
	switch (form.name) {
	case "DMZ":
		_(form, "DMZ_HOST")
			.enable(form.DMZ_ENABLED.checked != 0);

		if (init) {
			_(form, "DMZ_HOST") .setParser("ip")
				.groupValidation("localIp");
		}
		break;

	case "portFwAdd":
		if (init) {
			if (mib.tbl_info.height >= mib.tbl_info.limit) {
				_(form, "/!save") .enable(false);
				_(form, "save") .setParser("disable:В таблице сервисов не осталось свободных строк");
			}

			presets.init(form.DefSrv, presets_tpl);

			_(form, "local_ip,bcast_ip") .setParser("ip");
			_(form, "inPorts") .setParser("ports");
			//_(form, "destPorts") .setParser("ports");
			_(form, "local_ip,bcast_ip") .groupValidation("localIp");
			_(form, "bcast_ip") .groupValidation("notBCastIP");
			//_(form, "inPorts,destPorts") .groupValidation("portsForward");
		}

		if (this.name == "DefSrv" && this.selectedIndex)
			presets.select(form, this.value, presets_tpl);

		_(form, "local_ip") .enable(form.isbcast[0].checked);
		_(form, "bcast_ip") .enable(form.isbcast[1].checked);

		//var ip_label_element = document.getElementById("ip_label");
		//ip_label_element.textContent = "Local " + (form.isbcast.checked ? "broadcast " : "") + "IP address:";
		break;

	case "portFwDel":
		updateStdDelForm(event, form, type);
	}
}

function postValidate(form, valid) {
	if (form.name != 'portFwAdd')
		return valid;

	var v = form.validation,
	    item = {
	    	proto: form.protocol.value,
	    	inPorts:   v.el("inPorts").parsedValue/*,
	    	destPorts: v.el("destPorts").parsedValue*/ };

	var env = hint.box(form.save),
	    hnt = hint.left(env.box);
	if (valid) {
		var idx, tbl = mib.tbl_data;
		for (idx = 0; idx < tbl.length; ++idx) {
			var it = tbl[idx];
			if (it.proto & item.proto) {
				if (!((it.inPorts[0] > item.inPorts[1]) || (it.inPorts[1] < item.inPorts[0]))) {
					hnt.className = "fullist error";
					hnt.innerHTML = [
							"Пересечение с правилом: ",
							it.ip, '/', mib.protos[it.proto], '/', it.inPorts[0], (it.inPorts[1]>it.inPorts[0]?'-'+it.inPorts[1]:''), '/', it.comment
						].join('');
					return false;
				}
			}
		}
	}

	hnt.className = "fullist message";
	hnt.innerHTML = "";

	if (valid && mib.PORTFW_ENABLED == 0)
		hnt.innerHTML = "Не забудьте включить перенаправление портов";

	if (valid) {
		form.fromPort.value = item.inPorts[0];
		form.toPort.value = item.inPorts[1];
		form.destFromPort.value = item.inPorts[0];
		form.destToPort.value = item.inPorts[1];
	}
	return valid;
}
//--></script>
</head>

<body class="body">
<% writeLeafOpen("Доступ к домашней сети из Интернета", 
	"Чтобы разрешить пользователям Интернета подключаться к домашней сети, " + 
	"включите функцию «Перенаправление портов». Затем выберите сетевой сервис, " + 
	"который вы хотите открыть для доступа, и укажите IP-адрес компьютера с ним."); %>

<% writeFormOpen("portFwSet"); %>
<table class="sublayout">
<tr>
	<td class='label'></td>
	<td class='field'>
		<%=checkBox("PORTFW_ENABLED"); %><label for='PORTFW_ENABLED'>Перенаправление портов</label>
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

<% writeLeafSubheader("Правила перенаправления портов"); %>

<%	writeFormOpen("portFwAdd");
	write(hidden("ip")); %>
<table class="sublayout">
<tr>
	<td class='label'>Сервис:</td>
	<td class='field'>
		<% writeSelectOpen("DefSrv"); %>
		</select>
	</td>
</tr>
<tr>
	<td class='label'>IP-адрес сервера:</td>
	<td class='field'><%=radio("isbcast", 0);%><%=inputText("local_ip", 16, 15); %></td>
</tr>
<tr>
	<td class='label'>Широковещательный IP-адрес:</td>
	<td class='field'><%=radio("isbcast", 1);%><%=inputText("bcast_ip", 16, 15); %></td>
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
	<td class='label'>Порты:</td>
	<td class='field'><%=inputText("inPorts", 17, 11); %></td>
</tr>
<!--tr>
	<td class='label'>Порты сервера:</td>
	<td class='field'><%=inputText("destPorts", 17, 11); %></td>
</tr-->
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
<%=hidden("fromPort");%>
<%=hidden("toPort");%>
<%=hidden("destFromPort");%>
<%=hidden("destToPort");%>
</form>

<% writeFormOpen("portFwDel"); %>
<table class="sublayout">
<tr>
	<td colspan="2"><table id="some_table" class="list">
<tr>
	<th class='check'>&nbsp;</th>
	<th class='list'>IP-адрес сервера</th>
	<th class='list'>Протокол</th>
	<th class='list'>Порты</th>
	<th class='list' width="50%">Описание</th>
</tr>

<% writeTable(mib_tbl_name,
"<tr class='#.class point'>
	<td class='check'><input type='checkbox' name='select#' value='ON'/></td>
	<td class='list'>$ip$isbcast?'<small>&nbsp;(широковещательный)</small>'</td>
	<td class='list'>$proto[\"\",\"TCP\",\"UDP\",\"TCP и UDP\"]</td>
	<td class='list nowrap'>$fromport.$toport</td>
	<td class='list'>$comment</td>
</tr>
", "<tr class='even first'><td colspan='5' class='empty'>Нет записей</td></tr>
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

<% writeLeafOpen("Открытый сервер", 
	"Компьютер в домашней сети со всеми сетевыми сервисами доступными из Интернета. " +
	"Исключение составляют сервисы уже занятые в правилах перенаправления портов."); %>

<% writeFormOpen("DMZ"); %>
<table id="DMZ" class="sublayout">
<tr>
	<td class='label'></td>
	<td class='field'>
		<%=checkBox("DMZ_ENABLED"); %><label for='DMZ_ENABLED'>Открыть домашний сервер</label>
	</td>
</tr>
<tr>
	<td class='label'>IP-адрес домашнего сервера:</td>
	<td class='field'><%=inputText("DMZ_HOST", 15, 16); %></td>
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
