<% htmlHead("IP-телевидение и IP-телефония"); %>
<script type="text/javascript"><!--
<%
	setMibsVars(
		"IPTV_MODE", "IPTV_PORT", "IPTV_VLAN_WAN_TAG", "IPTV_VLAN_TV_TAG",
		"IPTV_VLAN_TV2_ENABLED", "IPTV_VLAN_TV2_TAG",
		"VOIP_PORT_ENABLED", "VOIP_PORT", "VOIP_VLAN_TAG");
	var lans_count = opts_get("lans_count");
%>

function submit(event) {
	if (this.IPTV_MODE.value == 0)
		return true;

	var mode = this.IPTV_MODE.selectedIndex,
	    ports = [];

	if (mode >= 1) {
		var iptvPort = this.IPTV_PORT.value * 1 + 1;
		if (iptvPort < 5)
			ports.push('LAN'+iptvPort);
		else {
			ports.push('LAN3');
			ports.push('LAN4');
		}
	}
<%
	if (lans_count >= 4)
		write("\n\tif (mode >= 2 && this.VOIP_PORT_ENABLED.checked)
		ports.push('LAN' + (this.VOIP_PORT.value * 1 + 1));\n");
%>
	ports.sort();

	if (ports.length > 1) {
		if (ports.length > 2)
			ports[0] = ports[0] + ',';
		ports.splice(ports.length - 1, 0, 'и');
	}

	var multi = ports.length > 1,
	    msg_notice = [
		"Разъем", multi?'ы ':' ', ports.join(' '), " интернет-центра буд", multi?'у':'е',"т отключен", multi?'ы':'', " от домашней сети.\n",
		"Если этот компьютер подключен к ", multi?"ним":"нему", ", связь с интернет-центром будет потеряна."].join('');

	return confirm(msg_notice);
}

function update(event, form, type)
{
	if (type === 'init') {
		_(form, "IPTV_VLAN_TV_TAG,IPTV_VLAN_TV2_TAG,IPTV_VLAN_WAN_TAG,VOIP_VLAN_TAG")
			.setParser("tag");<%
	if (lans_count >= 4)
		write("\n\t\t_(form, 'VOIP_PORT,IPTV_PORT')
			.groupValidation('voipPort');");
%>
	}

	var mode = form.IPTV_MODE.selectedIndex;
	_(form, "IPTV_VLAN_TV_TAG,IPTV_VLAN_TV2_ENABLED,IPTV_VLAN_WAN_TAG").enable(mode >= 2);
	_(form, "IPTV_VLAN_TV2_TAG").enable(mode >= 2 && form.IPTV_VLAN_TV2_ENABLED.checked);
	_(form.IPTV_PORT).enable(mode >= 1);
<%
	if (lans_count >= 4)
		write("\n\t_(form, 'VOIP_PORT,VOIP_VLAN_TAG').enable(form.VOIP_PORT_ENABLED.checked);\n");
%>
	_("#IPTV_PORT_PART").show(mode >= 1);
	_("#IPTV_VLAN").show(mode >= 2);
}
--></script>
</head>
<body class="body">
<% writeLeafOpen("IP-телевидение", 
	"Технология TVport обеспечивает прием IP-телевидения на ресивере IPTV или компьютере. "+
	"В зависимости от особенностей предоставления услуги IP-телевидения вашим провайдером, "+
	"используйте автоматический режим или назначьте разъем для подключения ресивера IPTV вручную. "+
	"Если услуга IP-телевидения и IP-телефонии предоставляются на базе VLAN по стандарту 802.1Q, "+
	"выберите соответствующий режим и укажите VLAN ID, выданные провайдером. Разъемы интернет-центра, "+
	"назначенные для IP-телевидения и IP-телефонии, будут отключены от домашней сети."); %>

<% writeFormOpen("iptv"); %>
<table class="sublayout">
<tr>
	<td class='label'><label for='IPTV_MODE'>Режим TVport:</label></td>
	<td class='field'>
		<% writeSelectOpen("IPTV_MODE"); %>
			<% writeOption("Автоматический", 0); %>
			<% writeOption("Назначить разъем LAN", 1); %>
			<% writeOption("На базе 802.1Q VLAN", 2); %>
		</select>
	</td>
</tr>
</table>
<table id='IPTV_PORT_PART' class='sublayout part'>
<tr>
	<td class='label'><label for='IPTV_PORT'>Разъем для ресивера IPTV:</label></td>
	<td class='field'>
		<% writeSelectOpen("IPTV_PORT"); %>
			<% writeOption("LAN1",   0); %>
			<% if (lans_count >= 2 ) writeOption("LAN2",   1); %>
			<% if (lans_count >= 3 ) writeOption("LAN3",   2); %>
			<% if (lans_count >= 4 ) writeOption("LAN4",   3); %>
			<% if (lans_count >= 4 ) writeOption("LAN3+LAN4", 4); %>
		</select>
	</td>
</tr>
</table>
<table id='IPTV_VLAN' class='sublayout part'>
<tr>
	<td class='label'><label for='IPTV_VLAN_WAN_TAG'>VLAN ID для Интернета:</label></td>
	<td class='field'><%=inputText("IPTV_VLAN_WAN_TAG", 4, 4); %></td>
</tr>
<tr>
	<td class='label'><label for='IPTV_VLAN_TV_TAG'>VLAN ID для IP-телевидения:</label></td>
	<td class='field'><%=inputText("IPTV_VLAN_TV_TAG", 4, 4); %></td>
</tr>
<tr>
	<td class='label'></td>
	<td class='field'><%=checkBox("IPTV_VLAN_TV2_ENABLED"); %><label for='IPTV_VLAN_TV2_ENABLED'>Отдельный Multicast VLAN для IP-телевидения</label></td>
</tr>
<tr>
	<td class='label'><label for='IPTV_VLAN_TV2_TAG'>Multicast VLAN ID:</label></td>
	<td class='field'><%=inputText("IPTV_VLAN_TV2_TAG", 4, 4); %></td>
</tr><%
	if (lans_count >= 4 ) {
		write("
<tr>
	<td class='label'></td>
	<td class='field'>" + checkBox("VOIP_PORT_ENABLED") + "<label for='VOIP_PORT_ENABLED'>VLAN для IP-телефонии</label></td>
</tr>
<tr>
	<td class='label'><label for='VOIP_PORT'>Разъем для IP-телефона:</label></td>
	<td class='field'>
		");
		writeSelectOpen("VOIP_PORT");
			writeOption("LAN1",   0);
			writeOption("LAN2",   1);
			writeOption("LAN3",   2);
			writeOption("LAN4",   3);
		write("
		</select>
	</td>
</tr>
<tr>
	<td class='label'><label for='VOIP_VLAN_TAG'>VLAN ID для IP-телефонии:</label></td>
	<td class='field'>
		", inputText("VOIP_VLAN_TAG", 4, 4), "
	</td>
</tr>");
	}
%>
</table>
<table class='sublayout part'>
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
