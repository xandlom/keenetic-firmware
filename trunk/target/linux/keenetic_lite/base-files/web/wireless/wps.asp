<% htmlHead("Wi-Fi Protected Setup"); %>
<style type="text/css">
td.hint_num {
	text-align: right;
	vertical-align: top;
	width: 50px;
}
td.hint_text {
	padding-right: 60px !important;
}
td.control {
	width: 33%;
}
</style>
<script type="text/javascript"><!--
<%
	setMibsVars("WLAN_WPS_CONFIGURED", "WLAN_HIDDEN_SSID", "WLAN_ENABLED", "WLAN_AP_AUTH_TYPE");
	WPS_TYPE = 0;
	WPS_APPIN = wpsGetAPPIN();
	WPS_CLIENT_PIN = "";

	leaf_message = "";
	if (!WLAN_ENABLED)
		leaf_message = "Технология WPS недоступна, так как <a href=\"/homenet/wireless/basic.asp\">точка беспроводного доступа</a> выключена.";

	if (WLAN_HIDDEN_SSID)
		leaf_message = "Технология WPS отключена, так как выбран режим <a href=\"/homenet/wireless/basic.asp\">скрытого SSID</a>.";
%>

function submit(event) {
	_("#_CONSOLE") .show(true);

	zyStatus.init("response");
	zyStatus.clear("Ожидание ответа...");
	zyStatus.request("WPS", _(this).getQuery());
	return false;
}

function update(event, form, type) {
	if (type === 'init') {
		_(form, "WPS_APPIN") .setAttrs({ readOnly: 1 });
		_(form, "WPS_CLIENT_PIN") .setParser("-wpspin@bottom");
	}

//	var type = form.WPS_TYPE.value;
//	_("#PIN_ENR,#PIN_REG,#PBC_ENR,#PBC_REG") .showTab(type);
//	_(form, "WPS_CLIENT_PIN") .enable(type == 1);
<%
	if (WLAN_HIDDEN_SSID || !WLAN_ENABLED)
		write("
	_(\"#WPS_TBL\").show(false);");
%>
}
--></script>
</head>

<body class="body">
<% writeLeafOpen("Быстрая настройка безопасного соединения — WPS", 
	"Если вы хотите подключить к беспроводной сети адаптер, который совместим с "+
	"технологией быстрой настройки WPS (Wi-Fi Protected Setup), можно воспользоваться "+
	"одним из предложенных вариантов. Безопасное соединение адаптера с точкой доступа "+
	"будет настроено автоматически.", leaf_message); %>

<table id="WPS_TBL">
	<tr>
<td>
<% WPS_TYPE = 2; writeFormOpen("wps_pbc_enr"); %>
<%=hidden("WPS_TYPE"); %>
<table  class="sublayout">
<tr><td class="hint_num">1.</td>
<td  class="hint_text">
	Если у беспроводного адаптера есть кнопка WPS, нажмите ее. Затем нажмите кнопку WPS на <%
	if (opts_get("wps_button") == 'top')
		write("верхней крышке");
	else
		write("задней панели");
	%> интернет-центра или щелкните "Начать WPS" здесь.
</td></tr>
<tr>
</table>
<table class="sublayout">
<tr><td class='label'></td>
	<td class='control'></td>
	<td>
		<%=submitButton("save:Начать WPS");%>
	</td>
</tr>
</table>
</form>

<hr color="#C5C9CF"/>

<% WPS_TYPE = 1; writeFormOpen("wps_pin_reg"); %>
<%=hidden("WPS_TYPE"); %>
<table class="sublayout">
<tr><td class="hint_num">2.</td>
<td class="hint_text">
	Если вам известен PIN-код вашего беспроводного клиента, введите его в поле "PIN-код адаптера" и щелкните "Настроить адаптер".
</td></tr>
</table>

<table class="sublayout">
<tr>
	<td class="label"><label for="WPS_CLIENT_PIN">PIN-код адаптера:<br></label></td>
	<td class='control'><%=inputText("WPS_CLIENT_PIN", 10, 8); %></td>
	<td>
		<%=submitButton("save:Настроить адаптер");%>
	</td>
</tr>
</table>
</form>

<hr color="#C5C9CF"/>

<%
	if (WLAN_WPS_CONFIGURED)
		button_text = "Настроить адаптер";
	else
		button_text = "Настроить точку доступа";

	WPS_TYPE = 0;
	writeFormOpen("wps_pin_enr");
%>
<%=hidden("WPS_TYPE"); %>
<%=hidden("WPS_APPIN"); %>
<table class="sublayout">
<tr><td class="hint_num">3.</td>
<td class="hint_text">
	Если при подключении к беспроводной сети адаптер предлагает ввести PIN-код точки доступа, укажите ему PIN-код <strong><%=WPS_APPIN;%></strong> и затем щелкните здесь "<%=button_text;%>"
</td></tr>
</table>
<table class="sublayout">
<tr>
<!--	<td class="label"><label for='WPS_APPIN'>PIN-код точки доступа:</label></td>
	<td class='control'><%=inputText("WPS_APPIN", 10, 8); %></td>
-->
<td class='label'></td>
	<td class='control'></td>
	<td>
		<%=submitButton("save:"+button_text);%>
	</td>
</tr>
</table>
</form>


<!--% WPS_TYPE = 3; writeFormOpen("wps_pbc_reg"); %>
<.%=hidden("WPS_TYPE"); %>
<table class="sublayout">
<tr><td class="label"></td><td>
	Push-Button-Configuration Registator.<br/>A device with the authority to issue and revoke credentials to a network.
</td></tr>
<tr><td class="label"></td>
	<td class="submit">
		<.%=submitButton("save:Начать WPS!"); %>
	</td>
</tr>
</table>
</form-->

<!--table class="sublayout">
<tr>
	<td class="submit">
		<%=submitButton("save:Let's start!");%>
	</td>
</tr>
</table-->
	</td>
</tr>
</table>
<script type="text/javascript">updateAllForms();</script>

<table id="_CONSOLE" class="sublayout" style="display:none">
<tr>
	<td style="text-align: center; " colspan='2'>
		<table class='list'>
			<colgroup><col style='width: 160px;'/><col/></colgroup>
			<thead><tr><th colspan='2' class='list'>Настройка</th></tr></thead>
			<tbody id='response'>
				<tr><td colspan='2'>Ожидание ответа...</td></tr>
			</tbody>
		</table>
	</td>
</tr>
</table>
<% writeLeafClose(); %>
</body>
</html>
