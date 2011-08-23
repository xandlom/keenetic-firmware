<% htmlHead("Настройка подключения"); %>
<script type="text/javascript"><!--
<%
	setMibsVars("OP_MODE", "HOST_NAME", "WAN_IP_ADDRESS_MODE",
		"WAN_IP_ADDR", "WAN_SUBNET_MASK", "WAN_DEFAULT_GATEWAY",
		"LAN_IP_ADDR", "LAN_SUBNET_MASK",
		"WAN_DNS_MODE", "WAN_DNS1", "WAN_DNS2", "WAN_DNS3",
		"WAN_MACCLONE_IP_ENABLED", "WAN_MAC_ADDR", "WAN_PING_ENABLED",
		"WAN_AUTO_QOS_ENABLED", "WAN_TTL_INC_ENABLED", "UPNP_ENABLED");

	HW_MAC_ADDR = getDefaultWanMac();

	if (HW_MAC_ADDR == "unknown")
		HW_MAC_ADDR = "неизвестен";

	MAC_MODE = (WAN_MAC_ADDR != "00:00:00:00:00:00") && WAN_MAC_ADDR != HW_MAC_ADDR;

	wan_macAddr = WAN_MAC_ADDR;

	if (WAN_DNS1 == '0.0.0.0') WAN_DNS1 = '';
	if (WAN_DNS2 == '0.0.0.0') WAN_DNS2 = '';
	if (WAN_DNS3 == '0.0.0.0') WAN_DNS3 = '';

	writeMibProps("OP_MODE", "LAN_IP_ADDR", "LAN_SUBNET_MASK", "WAN_IP_ADDR", "WAN_SUBNET_MASK", "HW_MAC_ADDR", "MAC_MODE", "WAN_MAC_ADDR");

	if (opts_isDef("vdsl"))
		leaf_head = "Подключение по выделенной линии VDSL";
	else
		leaf_head = "Подключение по выделенной линии Ethernet";

	leaf_info = "Для работы в Интернете необходимо назначить интернет-центру IP-адрес. Обычно это происходит автоматически при каждом соединении, однако, если провайдер предоставил вам IP-адрес и другие параметры IP, укажите их здесь, выбрав ручную настройку.";
	clonemac_info = " Установите MAC-адрес, зарегистрированный у провайдера, если это требуется для подключения.";

	if (OP_MODE == 1) { // wireless isp
		leaf_head = "Подключение по беспроводной сети Wi-Fi";
		leaf_info = leaf_info + clonemac_info;
	} else
	if (OP_MODE == 5) { // yota
		leaf_head = "Подключение через внешний USB-модем WiMAX — Yota 4G";
	}
%>
mib.lan_ip = IP.parse(mib.LAN_IP_ADDR);
mib.lan_mask = IP.parse(mib.LAN_SUBNET_MASK);

function addOption(sel, value, str) {
	var op = document.createElement("option");
	op.value = value;
	op.innerHTML = str;
	sel.appendChild(op);
}

function macSel_update(aj, state) {
	var tbl = eval(['(', aj.responseText, ')'].join('')),
		mac_sel = this.wan_macAddr2;

	while (mac_sel.length > 0)
		mac_sel.remove(0);

	for (v in tbl) {
		addOption(mac_sel, tbl[v], [tbl[v], ' (', v, ')'].join(''));
		if (tbl[v] == mib.HW_MAC_ADDR)
			mac_sel.value = tbl[v];
	}

	if (mac_sel.length == 0) {
		mac_sel.value = 0;
		addOption(mac_sel, mib.HW_MAC_ADDR, [mib.HW_MAC_ADDR, ' (', _m("Current"), ')'].join(''));
	}
}

function update(event, form, type) {
	var init = (type === 'init');
	if (init) {
		_(form, "HOST_NAME")
			.setParser("domain");

		_(form, "WAN_IP_ADDR")
			.setParser("ip");

		_(form, "WAN_DEFAULT_GATEWAY,WAN_DNS1,WAN_DNS2,WAN_DNS3")
			.setParser("?ip");

		_(form, "WAN_SUBNET_MASK")
			.setParser("mask");

		_(form, "WAN_IP_ADDR,WAN_SUBNET_MASK")
			.groupValidation("ipNet");

		_(form, "WAN_IP_ADDR,WAN_SUBNET_MASK,WAN_DEFAULT_GATEWAY")
			.groupValidation("inNet");

		_(form, "wan_macAddr")
			.setParser("mac<%
				if (opts_isDef("no_clone_mac"))
					write(":Должен отличаться на всех устройствах!"); %>");

		_(form, "HW_MAC_ADDR") .setAttrs({ readOnly: 1 });
	}

	if (this.name == "MAC_MODE" || init) {

		if (mib.OP_MODE == 5)
			_("#MAC_TYPE,#MAC_SET,#MAC_CLONE").show(false);
		else {
			var mode = form.MAC_MODE.value;

			if (mode == 2)
				ajaxGet('/req/lanArpTbl', macSel_update, form);

			_("#MAC_SET") .show(mode == 1);
			_("#MAC_CLONE") .show(mode == 2);

			_(form, "WAN_MAC_ADDR") .enable(mode = 1);
			_(form, "wan_macAddr2") .enable(mode = 2);
		}
	}

	var wanIpAddrMode = form.WAN_IP_ADDRESS_MODE.value,
	    wanEnableDNSs = wanIpAddrMode != 1 || !form.WAN_DNS_MODE.checked;

	_(form, "WAN_IP_ADDR,WAN_SUBNET_MASK,WAN_DEFAULT_GATEWAY")
		.enable(wanIpAddrMode == 0);
	//_(form, "WAN_DNS_MODE")
		//.enable(wanIpAddrMode == 1);
	_(form, "WAN_DNS1,WAN_DNS2,WAN_DNS3")
		.enable(wanEnableDNSs);

	_(form, "#WAN_IP")       .show(wanIpAddrMode == 0);
	_(form, "#WAN_DNS_AUTO") .show(wanIpAddrMode == 1);
	_(form, "#WAN_DNSs")     .show(wanEnableDNSs);
}

function submit(event) {
	switch (this.MAC_MODE.value) {
		case '2':
			this.WAN_MAC_ADDR.value = this.wan_macAddr2.value;
			break;

		case '1':
			this.WAN_MAC_ADDR.value = this.wan_macAddr.value;<%
			if (opts_isDef("no_clone_mac")) write("
			if (this.wan_macAddr.value != mib.WAN_MAC_ADDR)
				return confirm(\"Вы установили свой MAC-адрес на WAN-интерфейсе. \"+
				\"Если вы скопировали этот адрес с компьютера подключенного через интернет-центр, \"+
				\"то установите на нём другой. Иначе, компьютер потеряет доступ к сети.\");"); %>
			break;

		case '0':
		default:
			this.WAN_MAC_ADDR.value = "000000000000";
	}

	return true;
}
//--></script>
</head>

<body class="body">
<% writeLeafOpen(leaf_head, leaf_info); %>

<%	writeFormOpen("wanEth"); %>
<table id="WAN_AUTO" class="sublayout part">
<tr>
	<td class='label'>Имя интернет-центра:</td>
	<td class='field'><%=inputText("HOST_NAME", 20, 30); %></td>
</tr>
<tr>
	<td class='label'>Настройка параметров IP:</td>
	<td class='field'><% writeSelectOpen("WAN_IP_ADDRESS_MODE"); %>
		<% writeOption("Ручная", 0); %>
		<% writeOption("Автоматическая", 1);
			if (OP_MODE == 0) {
				write("\n\t\t");
				writeOption("Без IP-адреса", 2);
			}
		%>
	</select></td>
</tr>
</table>


<table id="WAN_IP" class="sublayout part">
<tr>
	<td class='label'>IP-адрес:</td>
	<td class='field'><%=inputText("WAN_IP_ADDR", 16, 15); %></td>
</tr>
<tr>
	<td class='label'>Маска сети:</td>
	<td class='field'><%
		writeSelectOpen("WAN_SUBNET_MASK");
			writeOptionsIpMasks("Основные", "Редкие"); %>
		</select>
	</td>
</tr>
<tr>
	<td class='label'>Основной шлюз:</td>
	<td class='field'><%=inputText("WAN_DEFAULT_GATEWAY", 16, 15); %></td>
</tr>
</table>


<table id="WAN_DNS_AUTO" class="sublayout part">
<tr>
	<td class='label'></td>
	<td class='field'><%=checkBox("WAN_DNS_MODE"); %><label for='WAN_DNS_MODE'>Получать адреса серверов DNS автоматически</label></td>
</tr>
</table>


<table id="WAN_DNSs" class="sublayout part">
<tr>
	<td class='label'>DNS 1:</td>
	<td class='field'><%=inputText("WAN_DNS1", 16, 15); %></td>
</tr>
<tr>
	<td class='label'>DNS 2:</td>
	<td class='field'><%=inputText("WAN_DNS2", 16, 15); %></td>
</tr>
<tr>
	<td class='label'>DNS 3:</td>
	<td class='field'><%=inputText("WAN_DNS3", 16, 15); %></td>
</tr>
</table>


<table id="MAC_TYPE" class="sublayout part">
<tr>
	<td class='label'>Использовать MAC-адрес:</td>
	<td class='field'><% writeSelectOpen("MAC_MODE", 0);
			writeOption("По умолчанию ("+HW_MAC_ADDR+")", 0);
			writeOption("Введенный", 1);
		if (!opts_isDef("no_clone_mac"))
			writeOption("С компьютера", 2); %>
		</select>
	</td>
</tr>
</table>
<table id="MAC_SET" class="sublayout part">
<tr>
	<td class='label'></td>
	<td class='field'><%=inputText("wan_macAddr", 20, 17); %></td>
</tr>
</table>

<table id="MAC_CLONE" class="sublayout part">
<tr>
	<td class='label'>MAC-адрес компьютера:</td>
	<td class='field'><% writeSelectOpen("wan_macAddr2"); %>
		</select>
	</td>
</tr>
</table>

<table class="sublayout part">
<tr>
	<td class='label'></td>
	<td class='field'><%=checkBox("WAN_PING_ENABLED"); %><label for='WAN_PING_ENABLED'>Отвечать на ping-запросы из Интернета</label></td>
</tr>
<tr>
	<td class='label'></td>
	<td class='field'><%=checkBox("WAN_AUTO_QOS_ENABLED"); %><label for='WAN_AUTO_QOS_ENABLED'>Авто-QoS</label></td>
</tr>
<tr>
	<td class='label'></td>
	<td class='field'><%=checkBox("WAN_TTL_INC_ENABLED"); %><label for='WAN_TTL_INC_ENABLED'>Не уменьшать TTL</label></td>
</tr>
<tr>
	<td class='label'></td>
	<td class='field'><%=checkBox("UPNP_ENABLED"); %><label for='UPNP_ENABLED'>Разрешить UPnP</label></td>
</tr>
</table>


<table class="sublayout">
<tr>
	<td class='label'></td>
	<td class='submit'>
		<%=hidden("WAN_MAC_ADDR"); %>
		<%=submit("Применить");%>
	</td>
</tr>
</table>
</form>
<script type="text/javascript">updateAllForms();</script>
<% writeLeafClose(); %>
</body>
</html>
