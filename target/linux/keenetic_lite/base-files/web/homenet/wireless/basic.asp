<% htmlHead("Настройка WLAN"); %>
<script type="text/javascript"><!--
<%
	setMibsVars(
		"OP_MODE", "WLAN_AP_SSID", "WLAN_AP_CHANNEL", "WLAN_AP_BAND", "WLAN_AP_FIX_RATE",
		"WLAN_RATE_ADAPTIVE_ENABLED", "WLAN_ENABLED", "WLAN_AP_TXPOWER",
		"WLAN_AP_PREAMBLE_TYPE", "WLAN_AP_HIDDEN_SSID", "WLAN_WMM_ENABLED");

	WLAN_AP_SSID = cp1251toUtf8(WLAN_AP_SSID);
	writeMibProps("OP_MODE", "WLAN_ENABLED");

	if (WLAN_AP_TXPOWER > 90)	WLAN_AP_TXPOWER = 100;
	else if (WLAN_AP_TXPOWER > 60)	WLAN_AP_TXPOWER = 75;
	else if (WLAN_AP_TXPOWER > 30)	WLAN_AP_TXPOWER = 50;
	else if (WLAN_AP_TXPOWER > 15)	WLAN_AP_TXPOWER = 25;
	else if (WLAN_AP_TXPOWER > 9)	WLAN_AP_TXPOWER = 12;
	else WLAN_AP_TXPOWER = 3;
%>
var msg_notice = "Для применения настроек текущие соединения будут прерваны";

function submit(event)
{
	return confirm(msg_notice);
}

var basicFields = "WLAN_AP_BAND,WLAN_AP_SSID,WLAN_AP_HIDDEN_SSID,WLAN_AP_CHANNEL,WLAN_AP_TXPOWER,WLAN_AP_FIX_RATE,WLAN_AP_PREAMBLE_TYPE,WLAN_WMM_ENABLED";

function sel_add(sel, list) {
	for (v in list) {
		var op = document.createElement("option");
		op.value = v;
		op.innerHTML = list[v] + "M";
		sel.appendChild(op);
	}
}

function update(event, form, type)
{
	var wlan_enabled = form.WLAN_ENABLED.checked,
	    init = (type === 'init');

	_(form, basicFields)
		.enable(wlan_enabled);

	_("#NO_WPS").show(form.WLAN_AP_HIDDEN_SSID.checked);

	//_("#_PARAMS")
		//.show(wlan_enabled);

	var rate = form.WLAN_AP_FIX_RATE;
	if (rate.targetValue == undefined)
		rate.targetValue = rate.value;

	if (this.name == "WLAN_AP_BAND" || init) {
		var bandIndex = 1 * form.WLAN_AP_BAND.value,
		    b_en = " b b    ".charAt(bandIndex) == "b",
		    g_en = "  gg    ".charAt(bandIndex) == "g";

		while (rate.length > 1)
			rate.remove(1);

		if (b_en)
			sel_add(rate, { 1:"1", 2:"2", 3:"5.5", 4:"11" });

		if (g_en)
			sel_add(rate, { 5:"6", 6:"9", 7:"12", 8:"18", 9:"24", 10:"36", 11:"48", 12:"54" });

		var idx;
		for (idx = 1; idx < rate.length; ++idx) {
			var op = rate.options[idx];
			if (op.value == rate.targetValue) {
				op.setAttribute("selected", "1");
				break;
			}
		}

		_('#_rate').show(0);//b_en || g_en);
	}

	if (this.name == "WLAN_AP_FIX_RATE" || init)
		rate.targetValue = rate.value;

	if (init)
		_(form, "WLAN_AP_SSID")
			.setParser("ascii");
}
--></script>
</head>

<body class="body">
<% writeLeafOpen("Основные настройки беспроводной сети", 
	"Можно изменить имя сети и режимы работы точки доступа."); %>

<% writeFormOpen("wlanApBasic"); %>
<table class="sublayout">
<tr>
	<td class='label'></td>
	<td class='field'>
		<%=checkBox("WLAN_ENABLED"); %><label for='WLAN_ENABLED'>Включить точку беспроводного доступа</label>
	</td>
</tr>
</table>

<table id="_PARAMS" class="sublayout part">
<tr>
	<td class='label'>Имя сети (SSID):</td>
	<td class='field'><%=inputText("WLAN_AP_SSID", 44, 32); %></td>
</tr>
<tr>
	<td class='label'></td>
	<td class='field'>
		<%=checkBox("WLAN_AP_HIDDEN_SSID"); %><label for='WLAN_AP_HIDDEN_SSID'>Скрывать SSID <span id='NO_WPS' class='warning'>(отключает WPS)</span></label>
	</td>
</tr>
<tr>
	<td class='label'>Стандарт:</td>
	<td class='field'>
		<% writeSelectOpen("WLAN_AP_BAND"); %>
			<% writeOption("802.11b",     1); %>
			<% writeOption("802.11g",     2); %>
			<% writeOption("802.11b/g",   3); %>
			<% /* writeOption("802.11a",     4); skipped! */ %>
			<% writeOption("802.11n",     5); %>
			<% writeOption("802.11g/n",   6); %>
			<% writeOption("802.11b/g/n", 7); %>
		</select>
	</td>
</tr>
</table>
<table id='_rate' class="sublayout">
<tr>
	<td class='label'>Скорость:</td>
	<td class='field'>
		<% writeSelectOpen("WLAN_AP_FIX_RATE");
			writeOption("Автовыбор", 0); 
			writeNumOptions(1, 12);
		%></select>
	</td>
</tr>
</table>
<table class="sublayout">
<tr>
	<td class='label'>Канал:</td>
	<td class='field'>
		<% writeSelectOpen("WLAN_AP_CHANNEL"); %>
			<% writeOption("Автовыбор",  0);
			writeNumOptions(1, 13); %>
		</select>
	</td>
</tr>
<tr>
	<td class='label'>Преамбула:</td>
	<td class='field'>
		<%=radio("WLAN_AP_PREAMBLE_TYPE", 0); %><label for='WLAN_AP_PREAMBLE_TYPE_0'>Длинная</label>
		<%=radio("WLAN_AP_PREAMBLE_TYPE", 1); %><label for='WLAN_AP_PREAMBLE_TYPE_1'>Короткая</label>
	</td>
</tr>
<tr>
	<td class='label'>Мощность сигнала:</td>
	<td class='field'>
		<%=radio("WLAN_AP_TXPOWER", 100); %><label for='WLAN_AP_TXPOWER_100'>100%</label>
		<%=radio("WLAN_AP_TXPOWER", 75); %><label for='WLAN_AP_TXPOWER_75'>75%</label>
		<%=radio("WLAN_AP_TXPOWER", 50); %><label for='WLAN_AP_TXPOWER_50'>50%</label>
		<%=radio("WLAN_AP_TXPOWER", 25); %><label for='WLAN_AP_TXPOWER_25'>25%</label>
		<%=radio("WLAN_AP_TXPOWER", 12); %><label for='WLAN_AP_TXPOWER_12'>12%</label>
		<%=radio("WLAN_AP_TXPOWER", 3); %><label for='WLAN_AP_TXPOWER_3'>3%</label>
	</td>
</tr>
<tr>
	<td class='label'></td>
	<td class='field'>
		<%=checkBox("WLAN_WMM_ENABLED"); %><label for='WLAN_WMM_ENABLED'>Включить режим Wi-Fi Multimedia (WMM)</label>
	</td>
</tr>
</table>

<table id="_SUBMIT" class="sublayout part">
<tr>
	<td class='submit' colspan='2'>
		<%=submit("Применить");%>
	</td>
</tr>
</table>
</form>
<% writeLeafClose(); %>
<script type="text/javascript">updateAllForms();</script>
</body>
</html>
