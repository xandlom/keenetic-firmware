<% htmlHead("Авторизация"); %>
<script type="text/javascript"><!--
<%
	setMibsVars(
		"OP_MODE", "WAN_DOT1X_ENABLED", "WAN_DOT1X_AUTH_TYPE", "WAN_DOT1X_USER_NAME", "WAN_DOT1X_PASSWORD",

		"WAN_IP_ADDR", "WAN_SUBNET_MASK", "WAN_DEFAULT_GATEWAY", "WAN_IP_ADDRESS_MODE", 
		"LAN_IP_ADDR", "LAN_SUBNET_MASK",

		"PPP_TYPE", "PPP_ON_DEMAND_ENABLED", "PPP_SERVER",
		"PPP_SERVICE_NAME", "PPP_AC_NAME",
		"PPP_IP_AUTO", "PPP_IP_ADDR", "PPP_SUBNET_MASK",
		"PPP_REMOTE_IP_ADDR", "PPP_REMOTE_SUBNET_MASK", 
		"PPP_AUTH_TYPE", "PPP_USER_NAME", "PPP_PASSWORD", 
		"PPP_MPPE_LEVEL", "PPP_MTU_SIZE", "PPP_IDLE_TIME",
		"PPP_REINIT_ENABLED", "PPP_REINIT_SERVER" );

	writeMibProps(
		"OP_MODE", "PPP_TYPE", "LAN_IP_ADDR", "LAN_SUBNET_MASK",
		"WAN_IP_ADDR", "WAN_SUBNET_MASK", "WAN_IP_ADDRESS_MODE");
	noip = autoip = "1";
%>
mib.lan_ip = IP.parse(mib.LAN_IP_ADDR);
mib.lan_mask = IP.parse(mib.LAN_SUBNET_MASK);

function update(event, form, type) {
	var init = (type === 'init'),
	    dotxExist = mib.OP_MODE != 1,
	    pppType = form.PPP_TYPE.value,
	    pppoe = pppType == 1,
	    enabled = pppType > 0 && pppType <= <%
		if (WAN_IP_ADDRESS_MODE == 2)
			write("1");
		else
			write("3"); %>,
	    mppe = enabled && form.PPP_AUTH_TYPE.value > 1;

	_(form, "#DOTX_EN")         .show(dotxExist);
	_(form, "#DOTX")            .show(dotxExist &= form.WAN_DOT1X_ENABLED.checked);

	_("#PPP_SU,#PPP_AUTH,#PPP_CONNECT,#_PPP_STATUS,#PPP_IPa")
		.show(enabled);

	_("#_PPP_SERVER,#PPP_REINIT") .show(enabled && (pppType == 2 || pppType == 3));
	_("#_PPP_SERVICE") .show(enabled && pppType == 1);

	_("#PPP_IPs")
		.show(enabled && !form.PPP_IP_AUTO.checked);

	_("#PPP_MPPE")            .show(mppe);

	_(form, "/^WAN_DOT1X_[^E]") .enable(dotxExist);
	_(form, "PPP_USER_NAME,PPP_PASSWORD")
		.enable(enabled);
	_(form, "PPP_IP_ADDR,PPP_SUBNET_MASK,PPP_REMOTE_IP_ADDR,PPP_REMOTE_SUBNET_MASK")
		.enable(enabled && !form.PPP_IP_AUTO.checked);
	_(form, "PPP_MPPE_LEVEL") .enable(mppe);

	//var idle = enabled && form.PPP_ON_DEMAND_ENABLED.value > 0; /* connect-on-demand or manual */
	//_("#PPP_IDLE")           .show(idle);
	//_(form, "PPP_IDLE_TIME") .enable(idle);

	if (init) {
		_(form, "WAN_DOT1X_USER_NAME") .setParser("ascii");
		_(form, "WAN_DOT1X_PASSWORD")  .setParser("password");
		_(form, "PPP_IP_ADDR,PPP_REMOTE_IP_ADDR")
			.setParser("ip");
		_(form, "PPP_SUBNET_MASK,PPP_REMOTE_SUBNET_MASK")
			.setParser("mask");

		_(form, "PPP_USER_NAME") .setParser("ascii");
		_(form, "PPP_PASSWORD")  .setParser("password");
		_(form, "PPP_MTU_SIZE")  .setParser("mtu");
		_(form, "PPP_IDLE_TIME") .setParser("num:1,1000");

		_(form, "PPP_SERVER") .setParser("host");
		_(form, "PPP_SERVICE_NAME,PPP_AC_NAME") .setParser("?ascii"); /* UTF-8 string */

		autoStatus.done = function (text, changed) {
				if (!changed)
					return true;

				var form = document.wanAuth;
				_(form, "save_connect").enable(form.validation.ok && text != "Connected");
				_(form, "disconnect").enable(text != "Disconnected");
				return true;
			};

		autoStatus.init("ppp", "cmd=status", "ppp_status");
	}

	if (enabled)
		autoStatus.start();
	else
		autoStatus.stop();

	if (init || this.name == "PPP_TYPE") {
		if (<%=WAN_IP_ADDRESS_MODE; %> == 2) {
			var env = hint.box(form.save),
			    hnt = hint.left(env.box);
			if (pppType >= 2) {
				hnt.className = "fullist error";
				hnt.innerHTML = "Протоколы PPTP и L2TP не могу работать без IP-адреса на WAN-интерфейсе. Выберите ручную или автоматическую настройку <a href=\"/internet/eth.asp\">параметров IP</a>.";
				form.validation.enable(false);
			} else {
				hnt.className = "fullist message";
				hnt.innerHTML = (pppType != 0) ? "" : "Обратите внимание: WAN-интерфейс не имеет IP-адреса. Выберите ручную или автоматическую настройку <a href=\"/internet/eth.asp\">параметров IP</a>.";
				form.validation.enable(true);
			}
		}
		var pppoe_warn = mib.WAN_IP_ADDRESS_MODE != 2 && mib.PPP_TYPE != 1 && pppType == 1,
		    noip_warn  = mib.WAN_IP_ADDRESS_MODE == 2 && pppType != 1;
		_("#_PPPOE_WARNING").show(pppoe_warn); _("#noip").enable(pppoe_warn);
//		_("#_NOIP_WARNING").show(noip_warn);   _("#autoip").enable(noip_warn);
	}
}

function postValidate(form, valid) {
	_(form, "save_connect").enable(valid && $("ppp_status").html() == "Disconnected");
	return valid;
}

function save_connect_onclick(event) {
	_(this.form, "save_connect").enable(false);
	var reply = _(this.form).ajaxSubmit();
	if (/ok$/.test(reply)) {
		autoStatus.request("cmd=connect", "Сохранение и подключение...");
	} else {
		autoStatus.message("Подключение не удалось");
		_(this.form, "save_connect").enable(false);
	}
	return true;
}

function disconnect_onclick(event) {
	autoStatus.request("cmd=disconnect", "Отключение...");
	return true;
}

//--></script>
</head>

<body class="body">
<%
	extra_info = '';
	if (OP_MODE != 1)
		extra_info = " Можно также активировать протокол 802.1x, если это требуется для "+
			"подключения к сети провайдера.";

	writeLeafOpen("Авторизация пользователя",
		"Если для подключения к Интернету необходима аутентификация, выберите протокол "+
		"доступа в Интернет и укажите регистрационные данные, предоставленные провайдером."+
		extra_info);

writeFormOpen("wanAuth"); %>
<table id="DOTX_EN" class="sublayout part">
<tr>
	<td class='label'></td>
	<td class='field'><%=checkBox("WAN_DOT1X_ENABLED"); %><label for='WAN_DOT1X_ENABLED'>Авторизация в сети провайдера по протоколу 802.1x</label></td>
</tr>
</table>


<table id="DOTX" class="sublayout part">
<tr>
	<td class='label'>Метод проверки подлинности:</td>
	<td class='field'><% writeSelectOpen("WAN_DOT1X_AUTH_TYPE"); %>
		<% writeOption("EAP-MD5", 0); %>
		<% writeOption("EAP-TTLS/CHAP", 1); %>
		<% writeOption("EAP-TTLS/MS-CHAP", 2); %>
		<% writeOption("EAP-TTLS/MS-CHAPv2", 3); %>
	</select></td>
</tr>
<tr>
	<td class='label'>Имя пользователя:</td>
	<td class='field'><%=inputText("WAN_DOT1X_USER_NAME", 40, 63); %></td>
</tr>
<tr>
	<td class='label'>Пароль:</td>
	<td class='field'><%=inputPassword("WAN_DOT1X_PASSWORD", 40, 63); %></td>
</tr>
<tr>
	<td colspan='2'><hr color="#C5C9CF"></td>
</tr>
</table>


<table class="sublayout">
<tr>
	<td class='label'>Протокол доступа в Интернет:</td>
	<td class='field'><% writeSelectOpen("PPP_TYPE"); %>
		<% writeOption("Не требуется", 0); %>
		<% writeOption("PPPoE", 1); %>
		<% writeOption("PPTP", 2); %>
		<% writeOption("L2TP", 3); %>
	</select></td>
</tr>
</table>


<table id="_PPPOE_WARNING" class="sublayout part">
<tr>
	<td class='label'></td>
	<td class='field_hint warning small'>
		Обратите внимание: При этом типе авторизации у многих провайдеров WAN-интерфейс не имеет IP адреса.
	</td>
</tr>
<tr>
	<td class='label'></td>
	<td class='field error'>
		<%=checkBox("noip");%><label for='noip'>Отключить IP адрес WAN-интерфейса</label>
	</td>
</tr>
</table>


<table id="_PPP_SERVER" class="sublayout part">
<tr>
	<td class='label'>Адрес сервера:</td>
	<td class='field'><%=inputText("PPP_SERVER", 40, 127); %></td>
</tr>
</table>


<table id="_PPP_SERVICE" class="sublayout part">
<tr>
	<td class='label'>Имя сервиса:</td>
	<td class='field'><%=inputText("PPP_SERVICE_NAME", 40, 127); %></td>
</tr>
<tr>
	<td class='label'>Имя концентратора:</td>
	<td class='field'><%=inputText("PPP_AC_NAME", 40, 127); %></td>
</tr>
</table>


<table id="PPP_SU" class="sublayout part">
<tr>
	<td class='label'>Имя пользователя:</td>
	<td class='field'><%=inputText("PPP_USER_NAME", 40, 63); %></td>
</tr>
<tr>
	<td class='label'>Пароль:</td>
	<td class='field'><%=inputPassword("PPP_PASSWORD", 40, 63); %></td>
</tr>
</table>

<table id="PPP_AUTH" class="sublayout part">
<tr>
	<td class='label'>Метод проверки подлинности:</td>
	<td class='field'><% writeSelectOpen("PPP_AUTH_TYPE"); %>
		<% writeOption("PAP", 0); %>
		<% writeOption("CHAP", 1); %>
		<% writeOption("MSCHAP-v1", 2); %>
		<% writeOption("MSCHAP-v2", 3); %>
		<% writeOption("Автоопределение", 4); %>
	</select></td>
</tr>
</table>

<table id="PPP_MPPE" class="sublayout part">
<tr>
	<td class='label'>Безопасность данных (MPPE):</td>
	<td class='field'><% writeSelectOpen("PPP_MPPE_LEVEL"); %>
		<% writeOption("Не используется", 0); %>
		<% writeOption("40-разрядный ключ", 1); %>
		<% writeOption("56-разрядный ключ", 2); %>
		<% writeOption("128-разрядный ключ", 3); %>
		<% writeOption("Автоопределение", 4); %>
	</select></td>
</tr>
</table>

<table id="PPP_IPa" class="sublayout part">
<tr>
	<td class='label'></td>
	<td class='field'><%=checkBox("PPP_IP_AUTO"); %><label for='PPP_IP_AUTO'>Получать IP-адрес автоматически</label></td>
</tr>
</table>
<table id="PPP_IPs" class="sublayout part">
<tr>
	<td class='label'>IP-адрес:</td>
	<td class='field'><%=inputText("PPP_IP_ADDR", 16, 15); %></td>
</tr>
<tr>
	<td class='label'>Маска сети:</td>
	<td class='field'><%
		writeSelectOpen("PPP_SUBNET_MASK");
			writeOptionsIpMasks("Основные", "Редкие"); %>
		</select>
	</td>
</tr>
<tr>
	<td class='label'>Удаленный IP-адрес:</td>
	<td class='field'><%=inputText("PPP_REMOTE_IP_ADDR", 16, 15); %></td>
</tr>
<tr>
	<td class='label'>Маска удаленной сети:</td>
	<td class='field'><%
		writeSelectOpen("PPP_REMOTE_SUBNET_MASK");
			writeOptionsIpMasks("Основные", "Редкие"); %>
		</select>
	</td>
</tr>
</table>

<table id="PPP_CONNECT" class="sublayout part">
<tr>
	<td class="label">Размер MTU (1000&ndash;1492 байт):</td>
	<td><%=inputText("PPP_MTU_SIZE", 10, 5); %></td>
</tr>
<tr>
	<td class="label"></td>
	<td><%=button("save_connect:Подключить", "disconnect:Отключить"); %></td>
</tr>
</table>

<table id="_PPP_STATUS" class="sublayout">
<tr>
	<td class='label'>Состояние подключения:</td>
	<td class='field' id="ppp_status"></td>
</tr>
</table>

<table id="PPP_REINIT" class="sublayout part">
<tr>
	<td class='label'></td>
	<td class='field'><%=checkBox("PPP_REINIT_ENABLED"); %><label for='PPP_REINIT_ENABLED'> Принудительный сброс WAN-интерфейса при ошибке подключения</label></td>
</tr>
</table>


<table class="sublayout">
<tr>
	<td class='label'>
	<td class='submit' colspan="2">
		<%=submit("Применить");%>
	</td>
</tr>
</table>
</form>
<script type="text/javascript">updateAllForms();</script>
<% writeLeafClose(); %>
</body>
</html>
