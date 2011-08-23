<% htmlHead("Режим работы"); %>
<style type='text/css'>
.mode_cur, .mode_out {
	color: #000;
}
.mode_cur {
	font-weight: bold !important;
}
.mode_out {
	font-weight: normal !important;
}
</style>
<script type="text/javascript"><!--
<%	setMibsVars("OP_MODE", "LAN_DHCP_MODE");

	nat_lans_count = opts_get("lans_count");
	ap_lans_count = nat_lans_count+1;

	turn_dhcp_off = 0;
	turn_dhcp_on = 0;

	nat_mode_warning = "";
	ap_mode_warning = "";
	br_mode_warning = "";
	usb_host = "";

	if (OP_MODE == 2 && LAN_DHCP_MODE == 0)
		nat_mode_warning = 
"	<p class='error'>Обратите внимание: Автоматическая выдача IP-адресов (DHCP сервер) останется выключенной. При необходимости её можно включить позднее на <a href='/homenet/lan.asp'> странице настроек домашней сети.</a></p>
	" + checkBox("turn_dhcp_on") + "<label for='turn_dhcp_on' class='error'>Включить DHCP сервер сейчас</label>
";

	if (LAN_DHCP_MODE != 0) {
		ap_mode_warning = 
"	<p class='error'>Обратите внимание: Автоматическая выдача IP-адресов (DHCP сервер) останется включенной. При необходимости её можно выключить позднее на <a href='/homenet/lan.asp'> странице настроек домашней сети.</a></p>
	" + checkBox("turn_dhcp_off#ap_chb") + "<label for='ap_chb' class='error'>Выключить DHCP сервер сейчас</label>
";
		br_mode_warning = 
"	<p class='error'>Обратите внимание: Автоматическая выдача IP-адресов (DHCP сервер) останется включенной. При необходимости её можно выключить позднее на <a href='/homenet/lan.asp'> странице настроек домашней сети.</a></p>
	" + checkBox("turn_dhcp_off#br_chb") + "<label for='br_chb' class='error'>Выключить DHCP сервер сейчас</label>
";
	}

	if (!opts_isDef("no_usb"))
		usb_host = ", хост-контроллер USB";
%>
var msg_notice = "Изменение режима работы интернет-центра приведет к сбросу всех текущих сетевых соединений.";
	
function submit(event) {
	return confirm(msg_notice);
}
	
function update(event, form, type)
{
	if (this.name == "OP_MODE" || type === 'init') {
		_(form, "turn_dhcp_off") .enable($(form.OP_MODE).getRadioValue() == 2);
		_(form, "OP_MODE").each(function(obj, idx, sel) {
			//           td         tr         "\n"      tr
			var el = obj.parentNode.parentNode.nextSibling;
			if (el.tagName != 'TR')
				el = el.nextSibling;
			$(el)
				.show(obj.checked)
				.byTag("input")
					.enable(obj.checked);
			$(obj.parentNode)
				.setSubClass("mode", obj.checked ? "cur" : "out");
		}, 0);
	}
}

--></script>
</head>
<body class="body">
<% writeLeafOpen("Режим работы интернет-центра"); %>

<% writeFormOpen("opMode", "target='_top'"); %>
<table class="sublayout">

<tr><td>
<fieldset><legend>Подключение к провайдеру:</legend>
<table>
<tr><td class='radio_header'><%=radio("OP_MODE", 0); %><label for='OP_MODE_0'>по выделенной линии Ethernet</label></td></tr>
<tr><td class='radio_info'>
	<p>Объединяет ваши компьютеры и беспроводные Wi-Fi-устройства в домашнюю сеть, обеспечивая их одновременно доступом в Интернет и в районную сеть. Для авторизации в сети провайдера можно использовать протоколы 802.1x, PPPoE, PPTP, L2TP.</p>
	<p>Основные функции: точка доступа Wi-Fi, <%=nat_lans_count;%>-портовый коммутатор, маршрутизатор, транслятор сетевых адресов (NAT), межсетевой экран, сервер DHCP, хост-контроллер USB.</p>
<%=nat_mode_warning; %></td></tr>
<%
	if (opts_isDef("usb_modem")) { write("
<tr><td class='radio_header'>", radio("OP_MODE", 4), "<label for='OP_MODE_4'>через внешний USB-модем 3G</label></td></tr>
<tr><td class='radio_info'>
	<p>Объединяет ваши компьютеры и беспроводные Wi-Fi-устройства в домашнюю сеть, обеспечивая их высокоскоростным доступом в Интернет в любой точке сети 3G.</p>
	<p>Основные функции: точка доступа Wi-Fi, "+ap_lans_count+"-портовый коммутатор, маршрутизатор, транслятор сетевых адресов (NAT), межсетевой экран, сервер DHCP, хост-контроллер USB.</p>
" + nat_mode_warning + "</td></tr>

<tr><td class='radio_header'>", radio("OP_MODE", 5), "<label for='OP_MODE_5'>через внешний USB-модем 4G — Yota</label></td></tr>
<tr><td class='radio_info'>
	<p>Объединяет ваши компьютеры и беспроводные Wi-Fi-устройства в домашнюю сеть, обеспечивая их высокоскоростным доступом в Интернет в любой точке сети WiMAX.</p>
	<p>Основные функции: точка доступа Wi-Fi, "+ap_lans_count+"-портовый коммутатор, маршрутизатор, транслятор сетевых адресов (NAT), межсетевой экран, сервер DHCP, хост-контроллер USB.</p>
" + nat_mode_warning + "</td></tr>
"); } %>
<tr><td class='radio_header'><%=radio("OP_MODE", 1); %><label for='OP_MODE_1'>по беспроводной сети Wi-Fi</label></td></tr>
<tr><td class='radio_info'>
	<p>Объединяет ваши компьютеры в домашнюю сеть, обеспечивая их доступом в Интернет и в районную сеть. Для авторизации в сети провайдера вы можете использовать протоколы PPPoE, PPTP или L2TP.</p>
	<p>Основные функции: беспроводной клиент Wi-Fi, <%=ap_lans_count;%>-портовый коммутатор, маршрутизатор, транслятор сетевых адресов (NAT), межсетевой экран, сервер DHCP, хост-контроллер USB.</p>
<%=nat_mode_warning; %></td></tr>
</table></fieldset></td></tr>
<tr><td>
<fieldset><legend>Подключение к домашней сети:</legend>
<table>
<tr><td class='radio_header'><%=radio("OP_MODE", 2); %><label for='OP_MODE_2'>точка беспроводного доступа Wi-Fi</label></td></tr>
<tr><td class='radio_info'>
	<p>Объединяет ваши компьютеры и беспроводные Wi-Fi-устройства в домашнюю сеть. Может использоваться для создания беспроводной сети Wi-Fi или для увеличения покрытия существующей. Один из портов интернет-центра можно соединить с маршрутизатором, подключенным к Интернету.</p>
	<p>Основные функции: точка доступа Wi-Fi, <%=ap_lans_count;%>-портовый коммутатор, сервер DHCP<%=usb_host;%>.</p>
<%=ap_mode_warning;%>
</td></tr>
<tr><td class='radio_header'><%=radio("OP_MODE", 3); %><label for='OP_MODE_3'>беспроводной мост Wi-Fi</label></td></tr>
<tr><td class='radio_info'>
	<p>Объединяет ваши компьютеры и беспроводные Wi-Fi-устройства в домашнюю сеть. Может использоваться для создания беспроводной сети Wi-Fi или для увеличения покрытия существующей.</p>
	<p>Основные функции: клиент точки доступа Wi-Fi, <%=ap_lans_count;%>-портовый коммутатор, сервер DHCP<%=usb_host;%>.</p>
<%=br_mode_warning;%>
</td></tr>
</table></fieldset></td></tr>

<tr>
	<td class="submit">
		<%=submit("/", "Применить");%>
	</td>
</tr>
</table>

</form>
<% writeLeafClose(); %>

<script type="text/javascript">updateAllForms();</script>
</body>
</html>
