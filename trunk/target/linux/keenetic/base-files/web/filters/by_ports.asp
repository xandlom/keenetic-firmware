<% htmlHead("Фильтр портов"); %>
<script type="text/javascript"><!--
<%
	setMibsVarsAndWriteMibProps("PORTFILTER_ENABLED");
	service_name = 0;
	protocol = 3;
	ports = fromPort = toPort = comment = "";
%>
mib.protos = { 1: 'TCP', 2: 'UDP', 3: 'TCP+UDP' };
mib.tbl_name = "<%=mib_tbl_name="PORTFILTER_TBL"; %>";
mib.tbl_info = <% writeTableInfo(mib_tbl_name); %>;
mib.tbl_data = [
<% writeTable(mib_tbl_name,
"	{ ports: [$fromport, $toport], proto: '$proto.int', comment: '$comment' },
", "");
%>	{}
];

var presets_tpl = {
	cols: [ 'protocol', 'ports', 'comment' ],
	list: {
		"":0, "ALL( TCP/UDP:1..65535 )":1, "BGP( TCP:179 )":2, 
		"BOOTP_CLIENT( UDP:68 )":3, "BOOTP_SERVER( UDP:67..68 )":4,
		"CU-SEEME( TCP/UDP:7648 )":5, "DNS( TCP/UDP:53 )":6,
		"FINGER( TCP:79 )":7, "FTP( TCP:20..21 )":8,
		"HTTP( TCP:80 )":9, "HTTPS( TCP:443 )":10,
		"NETBIOS( TCP/UDP:137..139 )":11,
		"NEWS( TCP:144 )":12, "NFS( UDP:2049 )":13,
		"NNTP( TCP:119 )":14, "POP3( TCP:110 )":15,
		"PPTP( TCP:1723 )":16, "RCMD( TCP:512 )":17,
		"REAL-AUDIO( TCP:7070 )":18, "REXEC( TCP:514 )":19,
		"RLOGIN( TCP:513 )":20, "RTELNET( TCP:107 )":21,
		"RTSP( TCP/UDP:554 )":22, "SFTP( TCP:115 )":23,
		"SMTP( TCP:25 )":24, "SNMP( TCP/UDP:161 )":25,
		"SNMP-TRAPS( TCP/UDP:162 )":26, "SQL-NET( TCP:1521 )":27,
		"SSH( TCP/UDP:22 )":28, "STRMWORKS( UDP:1558 )":29,
		"TACACS( UDP:49 )":30, "TELNET( TCP:23 )":31,
		"TFTP( UDP:69 )":32, "VDOLIVE( TCP:7000 )":33 },
	rows: {
		0: [ 0, "",        "" ],
		1: [ 0, "1-65535", "all ports" ],
		2: [ 1,  179,      "BGB" ],
		3: [ 2,  68,       "BOOTP_CLIENT" ],
		4: [ 2, "67-68",   "BOOTP_SERVER" ],
		5: [ 0,  7648,     "CU-SEEME" ],
		6: [ 0,  53,       "DNS" ],
		7: [ 1,  79,       "FINGER" ],
		8: [ 1, "20-21",   "FTP" ],
		9: [ 1,  80,       "HTTP" ],
		10:[ 1, "443",     "HTTPS" ],
		11:[ 0, "137-139", "NETBIOS" ],
		12:[ 1,  144,      "NEWS" ],
		13:[ 2, 2049,      "NFS" ],
		14:[ 1,  119,      "NNTP" ],
		15:[ 1,  110,      "POP3" ],
		16:[ 1, 1723,      "PPTP" ],
		17:[ 1,  512,      "RCMD" ],
		18:[ 1, 7070,      "REAL-AUDIO" ],
		19:[ 1,  514,      "REXEC" ],
		20:[ 1,  513,      "RLOGIN" ],
		21:[ 1,  107,      "RTELNET" ],
		22:[ 0,  554,      "RTSP" ],
		23:[ 1,  115,      "SFTP" ],
		24:[ 1,   25,      "SMTP" ],
		25:[ 0,  161,      "SNMP" ],
		26:[ 0,  162,      "SNMP-TRAPS" ],
		27:[ 1, 1521,      "SQL-NET" ],
		28:[ 0,   22,      "SSH" ],
		29:[ 2, 1558,      "STRMWORKS" ],
		30:[ 2,   49,      "TACACS" ],
		31:[ 1,   23,      "TELNET" ],
		32:[ 2,   69,      "TFTP" ],
		33:[ 1, 7000,      "VDOLIVE" ]
	}
};

function submit(event) {
	switch (this.name) {
	case "portFilterDel":
		return submitStdDelForm(event);
	}
	return true;
}

function update(event, form, type) {
	switch (form.name) {
	case "portFilterAdd":
		if (type === 'init') {
			if (mib.tbl_info.height >= mib.tbl_info.limit) {
				_(form, "/!save") .enable(false);
				_(form, "save") .setParser("disable:В таблице фильтра не осталось свободных строк");
			}

			_(form, "ports") .setParser("ports");

			presets.init(form.service_name, presets_tpl, "0");
		}

		if (this.name == "service_name" && this.selectedIndex)
			presets.select(form, this.value, presets_tpl);
		break;

	case "portFilterDel":
		updateStdDelForm(event, form, type);
	}
}

function postValidate(form, valid) {
	if (form.name != 'portFilterAdd')
		return valid;

	var v = form.validation,
	    item = {
	    	proto: form.protocol.value,
	    	ports:   v.el("ports").parsedValue };

	var env = hint.box(form.save),
	    hnt = hint.left(env.box);
	if (valid) {
		var idx, tbl = mib.tbl_data;
		for (idx = 0; idx < tbl.length; ++idx) {
			var it = tbl[idx];
			if (it.proto & item.proto) {
				if (!((it.ports[0] > item.ports[1]) || (it.ports[1] < item.ports[0]))) {
					hnt.className = "fullist error";
					hnt.innerHTML = [
							"Пересечение с фильтром: ",
							mib.protos[it.proto], '/', it.ports[0], (it.ports[1]>it.ports[0]?'-'+it.ports[1]:''), '/', it.comment
						].join('');
					return false;
				}
			}
		}
	}

	hnt.className = "fullist message";
	hnt.innerHTML = "";

	if (valid) {
		form.fromPort.value = item.ports[0];
		form.toPort.value = item.ports[1];
	}
	return valid;
}
//--></script>
</head>
<body class="body">
<% writeLeafOpen("Блокировка портов TCP и UDP", 
	"Можно запретить устройствам домашней сети доступ к определенным сервисам в "+
	"Интернете. Для этого включите этот фильтр, выберите протокол и укажите диапазон "+
	"портов, которые нужно блокировать. Для популярных сервисов есть готовый набор "+
	"стандартных установок."); %>

<% writeFormOpen("portFilterSet"); %>
<table class="sublayout">
<tr>
	<td class='label'></td>
	<td class='field'><%=checkBox("PORTFILTER_ENABLED"); %><label for='PORTFILTER_ENABLED'>Включить фильтр сетевых портов</label></td>
</tr>
<tr>
	<td class='label'></td>
	<td class='submit'>
		<%=submit("Применить");%>
	</td>
</tr>
</table>
</form>

<% writeLeafSubheader("Таблица блокируемых сервисов"); %>

<% writeFormOpen("portFilterAdd"); %>
<table class="sublayout">
<tr>
	<td class='label'>Популярные сервисы:</td>
	<td class='field'>
		<% writeSelectOpen("service_name"); %>
		</select>
	</td>
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
	<td class='field'><%=inputText("ports", 17, 11); %></td>
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
<%=hidden("fromPort", 5, 5); %></td>
<%=hidden("toPort", 5, 5); %></td>
</form>

<% writeFormOpen("portFilterDel"); %>
<table class="sublayout">
<tr><td>
	<table id="some_table" class="list">
		<tr>
			<th class='list' width="1%">&nbsp;</th>
			<th class='list' width="10%">Протокол</th>
			<th class='list' width="20%">Порты</th>
			<th class='list' width="60%">Описание</th>
		</tr>
<% writeTable(mib_tbl_name,
"		<tr class='#.class point'>
			<td class='check'><input type='checkbox' name='select#' value='ON'/></td>
			<td class='list'>$proto[\"\",\"TCP\",\"UDP\",\"TCP и UDP\"]</td>
			<td class='list'>$fromport.$toport</td>
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
