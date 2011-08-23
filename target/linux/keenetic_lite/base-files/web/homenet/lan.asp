<%htmlHead("Организация домашней сети");
	setMibsVars("OP_MODE", "HOST_NAME", 
		"LAN_DHCP_MODE", "LAN_DHCP_POOL_START", "LAN_DHCP_POOL_END", 
		"LAN_IP_ADDR", "LAN_SUBNET_MASK", "LAN_DEFAULT_GATEWAY",
		"LAN_DHCP_SNOOPING_ENABLED", "STATICLEASE_TBL_NUM",
		"WAN_DNS1", "WAN_DNS2", "WAN_DNS3",
		"WAN_IP_ADDR", "WAN_SUBNET_MASK" );

	dhcpPoolAutoGen = 0;
	dhcpPoolStart = LAN_DHCP_POOL_START;
	dhcpPoolEnd   = LAN_DHCP_POOL_END;
%>
<script type="text/javascript"><!--
<%
	writeMibProps("OP_MODE", 
		"LAN_IP_ADDR", "LAN_SUBNET_MASK", "WAN_IP_ADDR", "WAN_SUBNET_MASK");

	mac = leaseIp = hostName = "";

	if (LAN_DEFAULT_GATEWAY == '0.0.0.0') LAN_DEFAULT_GATEWAY = '';
	if (WAN_DNS1 == '0.0.0.0') WAN_DNS1 = '';
	if (WAN_DNS2 == '0.0.0.0') WAN_DNS2 = '';
	if (WAN_DNS3 == '0.0.0.0') WAN_DNS3 = '';
%>
mib.tbl_name = "<%=mib_tbl_name="STATICLEASE_TBL"; %>";
mib.tbl_info = <% writeTableInfo(mib_tbl_name); %>;
var msg_notice = "В процессе изменения конфигурации вы будете отключены от устройства.";

mib.lan_ip = IP.parse(mib.LAN_IP_ADDR);
mib.lan_mask = IP.parse(mib.LAN_SUBNET_MASK);

mib.ifs = <% writeIfsProps(); %>;

mib.wan_ip = IP.parse(mib.WAN_IP_ADDR);
mib.wan_mask = IP.parse(mib.WAN_SUBNET_MASK);

var autopool = {
	init: function (form) {
		var lan = {
			ip:   IP.parse(form.LAN_IP_ADDR.value),
			mask: IP.parse(form.LAN_SUBNET_MASK.value),
			from: IP.parse(form.LAN_DHCP_POOL_START.value),
			to:   IP.parse(form.LAN_DHCP_POOL_END.value),
			ok:   1
		};

		lan.net = lan.ip & lan.mask;

		var pool = this.calc(lan);

		form.dhcpPoolAutoGen.checked = 
			(lan.from == pool.from && lan.to == pool.to)
			? 'checked' : false;
	},

	calc: function (lan) {
		lan.addr = ~lan.mask & lan.ip,
		lan.band = (~lan.mask + 1) / 2;

		if (lan.band > 32)
			lan.band = 32;

		var pool_from = lan.band + 1,
		    pool_to   = Math.max(pool_from, lan.band * 2 - 2);

		if (pool_from <= lan.addr && lan.addr <= pool_to) {
			pool_from += lan.band;
			pool_to   += lan.band;
		}

		return {
				from: (pool_from & ~lan.mask) | lan.net,
				to:   (pool_to   & ~lan.mask) | lan.net
			};
	}
};

function update(event, form, type) {
	var init = (type === 'init');
	switch (form.name) {
	case "lan":
		if (init) {
			_("#fix_pool_net")	.show(false);
			autopool.init(form);
			_(form, "LAN_IP_ADDR,dhcpPoolStart,dhcpPoolEnd")
				.setParser("ip");
			_(form, "LAN_SUBNET_MASK")
				.setParser("mask");
<%
	AP_MODE = (OP_MODE == 2) || (OP_MODE == 3);
	BR_MODE = (OP_MODE == 3);
	if (!AP_MODE) write("
			_(form, \"HOST_NAME\")
				.setParser(\"domain\");
			_(form, \"LAN_IP_ADDR\")
				.groupValidation(\"notWan\");");

	if (AP_MODE)
		write("
			_(form, \"LAN_DEFAULT_GATEWAY,WAN_DNS1,WAN_DNS2,WAN_DNS3\")
				.setParser(\"?ip\");
			_(form, \"LAN_IP_ADDR,LAN_SUBNET_MASK,LAN_DEFAULT_GATEWAY\")
				.groupValidation(\"inNet\");
");
%>
			_(form, "LAN_IP_ADDR,LAN_SUBNET_MASK")
				.groupValidation("ipNet");

			_(form, "LAN_IP_ADDR,LAN_SUBNET_MASK,dhcpPoolStart,dhcpPoolEnd")
				.groupValidation("inNet");

			_(form, "dhcpPoolStart,dhcpPoolEnd,LAN_IP_ADDR")
				.groupValidation("pool");

			_("#button_fix_pool_net")
				.setEvents( { click: _FixPoolNet } );
		}

		_(form, "dhcpPoolStart,dhcpPoolEnd")
			.enable(form.LAN_DHCP_MODE.value != 0 && !form.dhcpPoolAutoGen.checked);

		_("#_POOL") .show(form.LAN_DHCP_MODE.value != 0);
		_("#_staticlease").show(form.LAN_DHCP_MODE.value != 0);
		break;

	case "lanLeaseAdd":
		if (init) {
			if (mib.tbl_info.height >= mib.tbl_info.limit) {
				_(form, "/!add") .enable(false);
				_(form, "add") .setParser("disable:В таблице адресов не осталось свободных строк");
			}

			_(form, "mac")
				.setParser("mac");
			_(form, "leaseIp")
				.setParser("ip")
					.groupValidation("localIp");

			_(form, "mac,leaseIp")
				.groupValidation("optional");
			_(form, "hostName")
				.setParser("?domain");
		}
		break;

	case "lanLeaseDel":
		var selects = _(form, "/select\\d+"),
			checks = selects.checked().length;

		_(form, "release")
			.enable(checks != 0);

		_(form, "reserve")
			.enable((checks != 0) && !mib.tbl_is_full);

		if (init) {
			selects.setEvents( { click: updateForm } );
			_(form, "releaseAll")
				.enable(selects.length != 0);

			if (mib.tbl_info.height >= mib.tbl_info.limit) {
				_(form, "/!add") .enable(false);
				_(form, "add") .setParser("disable:В таблице адресов не осталось свободных строк");
			}

/*			_(form, "mac")
				.setParser("mac");
			_(form, "leaseIp")
				.setParser("ip")
					.groupValidation("localIp");
			_(form, "mac,leaseIp")
				.groupValidation("optional");*/
		}

		updateStdDelForm(event, form, type);
	}
}

function _getLan(form) {
	var v = form.validation,
	    parsers = {
	    	ip:   v.el("LAN_IP_ADDR"),
	    	mask: v.el("LAN_SUBNET_MASK"),
	    	from: v.el("dhcpPoolStart"),
	    	to:   v.el("dhcpPoolEnd") },
	    lan = {
	    	parsers: parsers,
	    	v: v };

	lan.ok = parsers.ip.isValid() && parsers.mask.isValid();
	if (lan.ok) {
		lan.ip   = parsers.ip.parsedValue,
		lan.mask = parsers.mask.parsedValue,
		lan.net  = lan.ip & lan.mask,
		lan.from = parsers.from.parsedValue,
		lan.to   = parsers.to.parsedValue;
	}

	return lan;
}

function postValidate(form, valid) {
	switch (form.name) {
	case "lan":
		var lan = _getLan(form),
		    autopooler = form.dhcpPoolAutoGen.checked,
		    fix_net = lan.ok && ((lan.from & lan.mask) == (lan.to & lan.mask) && (lan.from & lan.mask) != lan.net);

		_("#fix_pool_net")	.show(!autopooler && fix_net);

		if (autopooler && lan.ok) {
			var pool = autopool.calc(lan);
			lan.parsers.from.element.value = IP.toStr(pool.from);
			lan.parsers.to  .element.value = IP.toStr(pool.to);
		}
		return valid;
	}

	return valid;
}

function submit(event)
{
	switch (this.name) {
	case "lan":
		if (!confirm(msg_notice))
			return false;

		if (this.LAN_IP_ADDR.value != mib.LAN_IP_ADDR) {
			this.target = '_top';
		}

		this.LAN_DHCP_POOL_START.value = this.dhcpPoolStart.value;
		this.LAN_DHCP_POOL_END.value = this.dhcpPoolEnd.value;
		return true;

	case "lanLeaseAdd":
		break;

	case "lanLeaseDel":
		switch (document.activeElement.name) {
		case "add":
			return true;
		case "releaseAll":
			return confirm('Все арендованные адреса будут освобождены');
		case "reserve":
			return confirm('Выбранные адреса будут арендованы');
		}

		return confirm('Выбранные арендованные адреса будут освобождены');
	}

	return true;
}

function _FixPoolNet() {
	var lan = _getLan(this.form);
	if (lan.ok) {
		lan.parsers.from.element.value = IP.toStr((lan.from & ~lan.mask) | lan.net);
		lan.parsers.to  .element.value = IP.toStr((lan.to   & ~lan.mask) | lan.net);

		postponeValidation(this.form);
	}
}
--></script>
</head>

<body class="body">
<% writeLeafOpen("Организация домашней сети", 
	"Для работы в домашней сети устройства, подключенные к интернет-центру, должны "+
	"быть правильно настроены. Интернет-центр может выполнить их настройку автоматически "+
	"с помощью DHCP-сервера, который динамически назначит устройствам IP-адреса из "+
	"указанного пула."); %>

<% writeFormOpen("lan"); %>
<%=hidden("LAN_DHCP_POOL_START");%>
<%=hidden("LAN_DHCP_POOL_END");%>
<table class="sublayout"><%
	if (AP_MODE) write("
<tr>
	<td class='label'>Имя интернет-центра:</td>
	<td class='field'>", inputText("HOST_NAME", 20, 30), "</td>
</tr>");
%>
<tr>
	<td class='label'>IP-адрес интернет-центра:</td>
	<td class='field'><%=inputText("LAN_IP_ADDR", 16, 15); %></td>
</tr>
<tr>
	<td class='label'>Маска подсети:</td>
	<td class='field'><%
		writeSelectOpen("LAN_SUBNET_MASK");
			writeOptionsIpMasks("Основные", "Редкие"); %>
		</select>
	</td>
</tr><%
	if (AP_MODE) write("
<tr>
	<td class='label'>Основной шлюз:</td>
	<td class='field'>", inputText("LAN_DEFAULT_GATEWAY", 16, 15), "</td>
</tr>
<tr>
	<td class='label'>DNS 1:</td>
	<td class='field'>", inputText("WAN_DNS1", 16, 15), "</td>
</tr>
<tr>
	<td class='label'>DNS 2:</td>
	<td class='field'>", inputText("WAN_DNS2", 16, 15), "</td>
</tr>
<tr>
	<td class='label'>DNS 3:</td>
	<td class='field'>", inputText("WAN_DNS3", 16, 15), "</td>
</tr>");
%>
<tr>
	<td class='label'>DHCP:</td>
	<td class='field'>
		<% writeSelectOpen("LAN_DHCP_MODE"); %>
			<% writeOption("Отключен", 0); %>
			<% writeOption("Сервер", 2); %>
		</select>
	</td>
</tr>
</table>
<table id="_POOL" class="sublayout">
<tr>
	<td class='label'>Пул адресов:</td>
	<td class='field'><%=checkBox("dhcpPoolAutoGen"); %><label for='dhcpPoolAutoGen'>Образовать автоматически</label></td>
</tr>
<tr>
	<td class='label'>от:</td>
	<td class='field'><%=inputText("dhcpPoolStart", 16, 15); %></td>
</tr>
<tr>
	<td class='label'>до:</td>
	<td class='field'><%=inputText("dhcpPoolEnd", 16, 15); %></td>
</tr>
<tr id='fix_pool_net'>
	<td class='label'></td>
	<td class='field'><input type='button' id='button_fix_pool_net' value='Исправить'/></td>
</tr>
</table>
<table class="sublayout"><%
	if (BR_MODE) write("
<tr>
	<td class='label'></td>
	<td class='field'>", checkBox('LAN_DHCP_SNOOPING_ENABLED'), "<label for='LAN_DHCP_SNOOPING_ENABLED'>Включить DHCP Snooping</label></td>
</tr>");
%>
<tr>
	<td class='label'></td>
	<td class='submit'>
		<%=submit("Применить");%>
	</td>
</tr>
</table><%
	if (!BR_MODE)
		write("
", hidden('LAN_DHCP_SNOOPING_ENABLED'));
%>
</form>
<% writeLeafClose(); %>

<% writeLeafOpen("Арендованные адреса", 
	"Если важно, чтобы некое устройство в домашней сети получало определенный "+
	"IP-адрес, добавьте его в таблицу арендованных адресов или зафиксируйте уже "+
	"арендованный устройством IP-адрес."); %>

<% writeFormOpen("lanLeaseAdd"); %>
<table class="sublayout">
<tr>
	<td class='label'>MAC-адрес:</td>
	<td class='field'><%=inputText("mac", 18, 17); %></td>
</tr>
<tr>
	<td class='label'>Выдавать IP-адрес:</td>
	<td class='field'><%=inputText("leaseIp", 18, 15); %></td>
</tr>
<tr>
	<td class='label'>Имя:</td>
	<td class='field'><%=inputText("hostName", 18, 23); %></td>
</tr>
<tr>
	<td class='label'></td>
	<td class='submit'>
		<%=submit("add:Добавить");%>
	</td>
</tr>
</table>
</form>

<% writeFormOpen("lanLeaseDel"); %>
<table id="_DEL" class="sublayout">
<tr>
	<td colspan="2">
		<table id="some_table" class="list">
			<tr>
				<th class='list' width="1%">&nbsp;</th>
				<th class='list' width="20%">MAC-адрес</th>
				<th class='list' width="20%">IP-адрес</th>
				<th class='list' width="20%">Имя</th>
				<th class='list' width="10%">Тип</th>
			</tr>
<%
dhcpFillLeasedTable("DHCP_LEASED");
writeTable("DHCP_LEASED",
"			<tr class='#.class point'>
				<td class='check'><input type='checkbox' name='select#' value='ON'/></td>
				<td class='list'>$mac.mac</td>
				<td class='list'>$ip</td>
				<td class='list'>$host</td>
				<td class='list'>$static[\"Постоянный\",\"Арендованный\",\"Свободный\"]</td>
			</tr>
",
"			<tr class='odd first'>
				<td colspan='5' class='empty'>Нет записей</td>
			</tr>
");
%>			<!--tr class='odd point'>
				<td class='check'> </td>
				<td class='form'><%=inputText("mac", 16, 17); %></td>
				<td class='form'><%=inputText("leaseIp", 16, 15); %></td>
				<td class='form'><%=inputText("hostName", 16, 20); %> <%=submitButton("add:Добавить");%></td>
				<td class='check'>Постоянный</td>
			</tr-->
		</table>
	</td>
</tr>
<tr>
	<td class='label'></td>
	<td class='submit'>
		<%=submit("reserve:Фиксировать", "release:Освободить", "releaseAll:Освободить все");%>
	</td>
</tr>
</table>
</form>
<% writeLeafClose(); %>
<script type="text/javascript">updateAllForms();</script>
</body>
</html>
