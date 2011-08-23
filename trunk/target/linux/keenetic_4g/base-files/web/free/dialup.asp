<%	setMibsVars("DEVICE_NAME");
	htmlHead("ZyXEL "+DEVICE_NAME); %>
<link rel='stylesheet' type='text/css' href='/css/leaf.css?=<%=rvsn();%>'/>
<script type="text/javascript"><!--
<%
setMibsVars("OP_MODE", "LAN_IP_ADDR", "WEB_WAN_ACCESS_PORT");
writeMibProps("LAN_IP_ADDR", "WEB_WAN_ACCESS_PORT");

if (!testVar('from')) {
	from = '';
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
autoStatus.data = eval("("+decodeURIComponent("<%=encodeURI(getDialupProps());%>")+")");

autoStatus.done = function (text, changed) {

		return true;
	};

autoStatus.oneval = function () {
		var st = (status = autoStatus.data).stage;
		if (st in ppp_states && ppp_states[st].charAt(0) != '-')
			lockedState = st;
		autoStatus.set(st);
	};

//--></script>
</head>
<body>
<div class='head'></div>
<div class='redline'></div>
<div class='container bg'>

<div id='SETUP' class='form_frame'>
<%
	writeLeafOpen("Установка соединения",
		"...");
%>

<table id="PPP_WAIT" class="sublayout part">
<tr>
	<td class='label' style='padding: 1em 1em;'>Состояние:</td>
	<td class='field' id='trap_state'></td>
</tr>
</table>

<% writeLeafClose(); %>
</div>
<script type="text/javascript">
autoStatus.init('/trap/dialup/status', '', 'trap_state');
</script>
</div>
</body>
</html>
