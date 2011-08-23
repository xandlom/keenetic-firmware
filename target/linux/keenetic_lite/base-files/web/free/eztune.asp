<%	setMibsVars("DEVICE_NAME");
	htmlHead("ZyXEL "+DEVICE_NAME); %>
<link rel='stylesheet' type='text/css' href='/css/leaf.css?=<%=rvsn();%>'/>
<script type="text/javascript"><!--
<%
setMibsVars(
		"OP_MODE", "EZTUNE_REDIRECT_URL", "LAN_IP_ADDR", "WEB_WAN_ACCESS_PORT", 
		"PPP_TYPE", "PPP_SERVICE_NAME",
		"PPP_AUTH_TYPE", "PPP_USER_NAME", "PPP_PASSWORD");

EZTUNE_ENABLED = 0;

dest_url = 'to_url';
PPP_TYPE="PPPoE";
PPP_SERVICE_NAME="";
WAN_IP_ADDRESS_MODE="No IP";

writeMibProps("LAN_IP_ADDR", "WEB_WAN_ACCESS_PORT");

if (!testVar('from')) {
	from = '';
	dest_url = 'to_isp';
	if (EZTUNE_REDIRECT_URL == '')
		dest_url = 'to_setup';
}
%>
var lockedState = null,
    ppp_states = {
	'Pause': '-',
	'Initializing...': '-',
	"Disconnected": '-',
	"Connection": '-',
	"Connected": 'ok',
	"No responce": 'err',
	"Protocol error": 'err',
	"Auth error": 'noauth'
};

autoStatus.timeout = 500;
autoStatus.data = eval("("+decodeURIComponent("<%=encodeURI(getEzTuneProps());%>")+")");

autoStatus.done = function (text, changed) {
		var form = document.forms.tune;
		tickForm(form);
		return true;
	};

autoStatus.oneval = function () {
		var st = (status = autoStatus.data).stage;
		if (st in ppp_states && ppp_states[st].charAt(0) != '-')
			lockedState = st;
		autoStatus.set(st);
	};

function update(event, form, type) {
	var init = (type === 'init'),
	    status = autoStatus.data;

	switch(form.name) {
	case 'tune':
		if (init) {
			_(form, "PPP_USER_NAME") .setParser("ascii");
			_(form, "PPP_PASSWORD")  .setParser("password");
			autoStatus.init('/trap/eztune/status', '', 'ezstate');
		}
		var NO_WAN = status.wan == 0,
		    NO_USER = status.mib.ppp_name == "",
		    TUNED = !NO_WAN && !NO_USER,
		    st = lockedState || status.stage;

		st = st in ppp_states && ppp_states[st];

		var WAIT    = TUNED && (st == '-'),
		    PPP_ERR = TUNED && (st == "err"),
		    NO_AUTH = TUNED && (st == "noauth"),
		    OK      = TUNED && (st == "ok");

		_("#PPP_OK"   ).show(OK);
		_("#PPP_SETUP").show((NO_WAN || NO_USER || NO_AUTH || PPP_ERR));
		_("#PPP_ERR"  ).show(PPP_ERR);
		_("#PPP_AUTH" ).show(NO_AUTH);
		_("#PPP_WAIT" ).show(WAIT);
		_("#warning"  ).show(PPP_ERR || NO_AUTH);

		var info = document.getElementById('info'),
		    warn = document.getElementById('warning');

		if (OK)
			info.innerHTML = "Интернет соединение настроено и работает.";
		else
			if (WAIT)
				info.innerHTML = "Сейчас идёт проверка соединения.";
			else
				info.innerHTML = "Для подключения к Интернету необходима аутентификация, укажите свои регистрационные данные, предоставленные провайдером.";

		if (NO_AUTH)
			warn.innerHTML = "К сожалению не удалось авторизоваться. Скорее всего имя или пароль не верны. Поправьте и повторите попытку.";
		if (PPP_ERR)
			warn.innerHTML = "Подключиться не удалось. Ещё раз проверьте подключение кабеля и правильность имени/пароля и повторите попытку. Если связь не установилась -- обратитесь в службу технической поддержки провайдера.";
		break;

	case 'finish':
		if (this.name == "dest_url" || type === 'init') {
				
			_(form, "dest_url").each(function(obj, idx, sel) {
				obj.nextSibling.setAttribute("class",
					[(obj.checked ? "selected" : ""),
					 (obj.disabled ? "disabled" : "")].join(' '));
			}, 0);
		}
	}
}

function postValidate(form, valid) {
	if (form.name != 'tune')
		return valid;

	var env = hint.box(form.save),
	    hnt = hint.left(env.box),
	    NO_WAN = autoStatus.data.wan == 0;

	if (NO_WAN) {
		hnt.className = "fullist error important";
		hnt.innerHTML = "<%
		if (opts_isDef("vdsl"))
			write("VDSL соединение не установлено.");
		else
			write("Поключите кабель провайдера к WAN порту устройства.");%>";
		return false;
	}

	hnt.className = "fullist message";
	hnt.innerHTML = ""
	return valid;
}
//--></script>
</head>
<body>
<div class='head'></div>
<div class='redline'></div>
<div class='container bg'>

<div id='SETUP' class='form_frame'>
<%
	writeLeafOpen("!info", "?warning", "Подключение к интернет",
		"Для подключения к Интернету необходима аутентификация, укажите свои регистрационные данные, предоставленные провайдером.",
		"Подключиться не удалось. Ещё раз проверьте подключение кабеля и правильность имени/пароля и повторите попытку. Если связь не установилась -- обратитесь в службу технической поддержки провайдера.");
%>

<% writeFormOpen("tune", "action='/trap/eztune/set'"); %>

<table id='PPP_SETUP' class="sublayout part">
<tr>
	<td class='label'>Имя пользователя:</td>
	<td class='field'><%=inputText("PPP_USER_NAME", 30, 30); %></td>
</tr>
<tr>
	<td class='label'>Пароль:</td>
	<td class='field'><%=inputPassword("PPP_PASSWORD", 30, 30); %></td>
</tr>
<tr>
	<td class='label'>
	<td class='submit' colspan="2">
		<%=submit("Подключить");%>
	</td>
</tr>
</table>

<%=hidden("PPP_TYPE");%>
<%=hidden("PPP_SERVICE_NAME");%>
<%=hidden("WAN_IP_ADDRESS_MODE");%>
<%=hidden("from");%>
</form>

<table id="PPP_WAIT" class="sublayout part">
<tr>
	<td class='label' style='padding: 1em 1em;'>Состояние:</td>
	<td class='field' id='ezstate'></td>
</tr>
</table>

<% writeFormOpen("finish", "action='/trap/eztune/finish'"); %>
<table id="PPP_OK" class="sublayout part">
<tr>
	</td>
	<td class='label'></td>
	<td class='field'>
		<div><%=radio("dest_url", 'to_isp', EZTUNE_REDIRECT_URL == ''); %><label for='dest_url_to_isp'>перейти на страницу провайдера</label></div>
		<div><%=radio("dest_url", 'to_url', from == ''); %><label for='dest_url_to_url'>вернуться по вашей ссылке</label></div>
		<div><%=radio("dest_url", 'to_setup'); %><label for='dest_url_to_setup'>перейти на страницу настроек интернет центра</label></div>
	</td>
</tr>
<tr>
	<td class='label'>
	<td class='submit' colspan="2">
		<%=submit("Готово");%>
	</td>
</tr>
</table>
<%=hidden("from");%>
</form>

<% writeLeafClose(); %>
</div>
<script type="text/javascript">updateAllForms();</script>
</div>
</body>
</html>
