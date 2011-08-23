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

//	if (testVar("submit_url"))
//		url = url + "?page=" + submit_url;

	htmlHead("Refresh all", "nolinks"); %>
<style type='text/css'>
li.queued {
	color: #BBB;
}

li.in_progress {
	font-weight: bold;
	color: #666;
}

li.done {
	color: black;
}
body {
	font-size: small;
	margin: 0px;
	background: #C5C9CF;
	color: #333;
}

div.head, div.redline, div.container {
	position: fixed;
	left: 0px;
	right: 0px;
	padding: 0px;
	margin: 0px;
}
div.head {
	top: 0px;
	height: 50px;
	background: #0C2F83 url(/i/logo.gif) no-repeat;
}
div.redline {
	top: 50px;
	height: 4px;
	background: #B00;
	font-size: 0px;
}
div.container {
	top: 54px;
	bottom: 0px;
	text-align: center;
	padding-top: 160px;
	background: #C5C9CF url('/i/config_bg.gif');
}
div.form_frame {
	display: inline-block;
	text-align: left;
	padding: 0px;
	margin: 8px 8px 0px 8px;
	width: 800px;
	font-family: Verdana, Arial, Helvetica, sans-serif;
}

div.gauge, div.mercury {
	margin: 0px;
	padding: 0px;
}

div.gauge {
	display: inline-block;
	vertical-align: top;
	background: white;
	text-align: left;
	background: url('/i/gauge_bg.gif') repeat-x;
}

div.mercury {
	text-align: center;
	border: 0px;
}

div.gauge {
	border: solid 1px #888;
}

.mercury {
	height: 100%;
	background: #ccc;
}

a {
	color: #259;
}
.leaf {
	border: #002040 solid;
	border-width: 0 1px 1px 1px;
	font-family: Verdana, Arial, Helvetica, sans-serif;
	padding: 0;
	position: relative;
	width: 62em;
	margin: 8px;
}
.leaf_head, .leaf_page {
	left: 0;
	right: 0;
	border-top: 1px #002040 solid;
	position: relative;
}
.leaf_head {
	background: #314473  url('/i/leaf_header_bg.gif') repeat-x !important;
	color: white;
	padding: 6px 12px 6px 12px !important;
	font-size: 133%;
	font-weight: bold;
}
.leaf_page {
	border-top: 1px #002040 solid;
	background: #e7e7e7 url('/i/leaf_page_bg.gif') repeat-x;
}
.leaf_page {
	padding: 0;
}
.leaf_page_content {
	z-index: 2;
	position: relative;
	vertical-align: top;
}
.leaf_page_content {
	padding: 22px;
}
.leaf_page_shade {
	z-index: 1;
	position: absolute;
	left: 0; right: 0; bottom: 0;
	height: 30px;
	background: #e7e7e7 url('/i/leaf_page_bt.gif') repeat-x;
}
</style>
</head>
<body>
<div class='head'></div>
<div class='redline'></div>
<div class="container">
<div class="form_frame">
<%
	if (cmd == 'reboot')
		head = "Перезагрузка интернет-центра " + DEVICE_NAME;
	else if (cmd == 'factory')
		head = "Сброс настроек интернет-центра " + DEVICE_NAME;
	else
		head = "Обновление настроек интернет-центра " + DEVICE_NAME;

	writeLeafOpen(head); %>
<div class='gauge' id='_gauge' style='width: 752px; height: 1.5em;'><div class='mercury' id='_mercury' style='width: 0px;'/></div>
</td></tr></table>
<% writeLeafClose(); %>
</body>
<script type="text/javascript"><!--
var obj = {
	presets: {
		reboot:  40000,
		restore: 20000,
		factory: 20000,
		reload:  0
		},

	time_limit: 5000,

	interval: 33,
	time: <% if (testVar("start")) write(start); else write("0"); %>,

	start: function () {
			this.time_limit = this.presets.<%=cmd;%>;
			if (this.time_limit == 0)
				this.tick();
			else
				this.timer = setInterval('obj.tick();', this.interval);
		},

	tick: function () {
			this.time += this.interval;
			var merc_el = document.getElementById('_mercury'),
			    gauge_el = document.getElementById('_gauge'),
			    percent = Math.round(gauge_el.clientWidth * Math.min(1.0, this.time / this.time_limit));

			merc_el.style.width = [percent, 'px'].join('');

			if (this.time >= this.time_limit) {
				clearInterval(this.timer);
				var leaf = document.getElementById('_mercury');
				leaf.innerHTML = "<a href='<%=url;%>'><%=url;%></a>";
				window.top.location.replace('<%=url;%>');
			}
		}
};
	obj.start();
--></script>
</html>
