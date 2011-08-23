<%	setMibsVars("DEVICE_NAME", "LAN_IP_ADDR", "LAN_SUBNET_MASK", "HOST_NAME", "WEB_WAN_ACCESS_PORT");
	remote_ip = ip_to_num(REMOTE_ADDR);

	if (testVar("SAVED_LAN_IP_ADDR")) {
		lan_ip = ip_to_num(SAVED_LAN_IP_ADDR);
		lan_mask = ip_to_num(SAVED_LAN_SUBNET_MASK);
	} else {
		lan_ip = ip_to_num(LAN_IP_ADDR);
		lan_mask = ip_to_num(LAN_SUBNET_MASK);
	}

	if ((lan_mask & lan_ip) == (lan_mask & remote_ip)) {
		url = "http://" + LAN_IP_ADDR;
		if (WEB_WAN_ACCESS_PORT != 80)
			url = url + ':'+WEB_WAN_ACCESS_PORT;
	} else
		if (testVar("HTTP_HOSTNAME")) {
			url = "http://" + HTTP_HOST;
	
			if (HTTP_HOSTPORT != WEB_WAN_ACCESS_PORT) {
				url = "http://" + HTTP_HOSTNAME;
				if (WEB_WAN_ACCESS_PORT != 80)
					url = url + ":" + WEB_WAN_ACCESS_PORT;
			}
		} else
			url = "/";

	host_url = url;

	if (testVar("submit_url"))
		url = url + "?page=" + submit_url;

	htmlHead("Refresh all", "nolinks"); %>
</head>
<style type="text/css">
table, div { font-size: 14px; }
body, div {
	padding: 0px;
	margin: 0px 0px 0px 0px;
	font-family: arial, verdana, tahoma, helvetica, sans-serif;
}
body {
	background: #C5C9CF url('/i/config_bg.gif') repeat-x;
	-webkit-text-size-adjust: none;
}
div.back {
	width: 100%;
	text-align: center;
}
div.outer {
	margin: 48px 8px 8px 8px;
	display: inline-block;
	width: 400px;
	border: 1px solid;
	border-color: #555;
}
div.header {
	background: #e7e7e7 url('/i/leaf_page_bg.gif') repeat-x;
	padding: 8px 8px 20px 8px;
	border: 1px solid;
	border-color: #800 #e7e7e7 #FFF #e7e7e7;
}
#logo_line {
	display: block;
	background: #0C2F83 url('/i/logo.gif') no-repeat;
	text-align: left;
	height: 25px;
	vertical-align: bottom;
	font-size: 24px;
	color: #eef;
	font-weight: bold;
	font-family: Arial, Tahoma, sans-serif;
	text-align: right;
	font-style: italic;
	padding: 12px 20px 13px 105px;
	white-space: nowrap;
}
#logo_underline {
	background: #B00;
	height: 4px;
	margin: 0px;
	font: 0pt;
}
input[type=button] {
	background: #e7e7e7 url('/i/button_bg.gif') repeat-x;
	color: #333;
	border: 1px solid;
	border-color: #aba5a1;
	font-size: 14px;
}
input[type=button]:focus {
	border: dotted 1px #aba5a1;
}
input[type=button]:hover {
	color: #384e83;
}
</style>
<body>
<div class='back'><div class='outer'>
	<div id='logo_line'><%=DEVICE_NAME;%></div>
	<div id='logo_underline'></div><div class="header">
		<h2>IP-адрес устройства был изменен</h2>
		<p>Обновите IP-адрес вашего компьютера и щелкните кнопку ниже</p>
		<input type='button' id='rehome' value='<%=host_url;%>' onclick='javascript:window.top.location.replace("<%=url;%>")'/>
	</div>
</div></div>
</body>
</html>
<script type="text/javascript"><!--
var obj = {
	interval: 1000,
	timer: 0,
	timeout: 7,

	start: function () {
				this.timer = setInterval('obj.tick();', this.interval);
				this.tick();
				if ('applying' in top)
					top.applying.stop();
		},

	tick: function () {
			--this.timeout;
			var butt = document.getElementById('rehome');

			if (this.timeout == 0) {
				clearInterval(this.timer);
				this.timer = 0;
				butt.value = '<%=host_url;%>';
				butt.disabled = false;
			} else {
				butt.value = "(" + this.timeout+")";
				butt.disabled = true;
			}
		}
};
	obj.start();
--></script>
