<%	setMibsVars("OP_MODE", "DEVICE_NAME", "DEBUG");
	htmlHead(DEVICE_NAME + " Main Menu", "nolinks"); %>
<link rel="stylesheet" type="text/css" href="/css/default.css?=<%=rvsn();%>"/>
<style type="text/css">
body {
	background: #0C2F83 url('i/panel_bg0.gif');
	margin-left: 0px;
	margin-top: 0px;
}
table {
	border-collapse: collapse;
	border: 0px;
	padding: 0px;
}
table.sidebar {
	width:185px;
	margin-top: 11px;
}
table.menu {
	background: url('i/panel_menu_bg2.gif');
}
td {
	border: 0px;
	padding: 0px;
	margin: 0px;
}
td.top {
	vertical-align: top;
	height: 50px;
}
td.middle {
	background: url(i/panel_menu_bg2.gif);
}
td.bottom {
	background: url('i/panel_menu_bg3.gif');
	width: 185px;
	height: 68px;
}
img.status_icon {
	width: 185px;
	height: 50px;
	border: 0px;
	color: white;
}
.panel, .sub1, .sub2 {
	font-family: Arial,Verdana,Helvetica,sans-serif;
	font-size: small;
	text-decoration: none;
}
.panel {
	color: #00FFFF;
	font-weight: bold;
	padding: 0px;
	margin: 0px;
}
a.panel:link, a.panel:visited, a.panel:hover, a.panel:active {
	text-transform: uppercase;
}
a.panel:hover, a.panel:active {
	color: #0244E4;
}
.sub1 {
	color: #FFFFFF;
	font-weight: bold;
}
a.sub1:link, a.sub1:visited {
}
.sub2 {
	color: #FFFFFF;
	font-weight: normal;
}
a.sub2:link, a.sub2:visited, a.sub2:hover {
}
a.sub2:hover {
	color: #C2EEE6;
	background-color: #4A5798;
}
</style>
<script type="text/javascript" src="/js/tree.js?=<%=rvsn();%>"></script>
<script type="text/javascript"><!--
<%
	VDSL_MODE = opts_isDef("vdsl");
	writeMibProps("OP_MODE", "DEVICE_NAME"); %>
var Funs = {
	preloadImages: function (path) {
			var id, im;
			this.imgs = {};
			for (id in path) {
				im = new Image(202, 52);
				//im.className = 'status_icon';
				im.src = path[id];
				this.imgs[id] = im;
			}
		}
}
//--></script>
</head>

<body>
<table class='sidebar'>
<tr><td class='top'><a target='view' href='/status.asp'><img
	class='status_icon'
	src='/i/panel_menu_bg1.gif'
	alt='status'
	onmouseout="this.src='/i/panel_menu_bg1.gif'"
	onmouseover="this.src='/i/panel_menu_bg1_on.gif'"/></a></td></tr>
<tr>
	<td class='middle'>
		<table class='menu'>
		<tr><td width="20px">&nbsp;</td><td width="165px">
<script type="text/javascript"><!--
var foldersTree = null;
(function () {
	var modes = {
			gw: /^[06]$/, wisp: /^[13]$/, ap: /^[2]$/, br: /^[3]$/, modem: /^[4]$/, yota: /^[5]$/,
			wan: /^[0156]$/, ppp: /^[016]$/, nat: /^[01456]$/, wl: /^[02456]$/, ip: /^\d$/,
			vdsl: /^[6]$/, mode: /^[^6]$/ },
	    exmode = /^(.*):([a-z]+)$/,
	    tree = {
			'Yota Internet 4G:yota':'/internet/yota.asp',
			'Модем 3G:modem':       '/internet/modem.asp',
			'VDSL-модем:vdsl':      '/internet/vdsl.asp',

			'Клиент Wi-Fi:wisp': {
				'Обзор сетей':   '/internet/wireless/survey.asp',
				'Соединение':    '/internet/wireless/basic.asp',
				'Безопасность':  '/internet/wireless/security.asp'},

			'Интернет:nat': {
				'Подключение:wan':   '/internet/eth.asp',
				'Авторизация:ppp':   '/internet/ppp.asp',
				'Доменное имя':      '/internet/dyndns.asp',
				'Маршруты':          '/internet/route.asp' },

			'Домашняя сеть': {
				'Организация сети':  '/homenet/lan.asp',
				'IP-телевидение:gw': '/homenet/vlan.asp',
				'Серверы:nat':       '/homenet/servers.asp' },
			'Сеть Wi-Fi:wl': {
				'WPS':               '/wireless/wps.asp',
				'Соединение':        '/homenet/wireless/basic.asp',
				'Безопасность':      '/homenet/wireless/security.asp',
				'Блокировка':        '/homenet/wireless/access.asp',
				'Клиенты':           '/homenet/wireless/clients.asp' },
			'Фильтры:nat': {
				'MAC-адреса':        '/filters/by_mac.asp',
				'IP-адреса':         '/filters/by_ip.asp',
				'TCP/UDP-порты':     '/filters/by_ports.asp',
				'URL-адреса':        '/filters/by_url.asp' }, <%
	have_storage = opts_isDef("usb_storage");
	have_printer = opts_isDef("usb_printer");
	show_wps_button = !opts_isDef("hide_wps_btn_umount");

	if (have_storage || have_printer)
		write("
			'USB-приложения:ip': {");

	delim = '';
	if (have_storage) {
		write("
				'Сетевой диск':      '/server/samba.asp',
				'Сервер FTP':        '/server/ftp.asp',
				'Учетные записи':    '/server/users.asp'");
		delim = ',';
	}

	if (have_printer) {
		write(delim, "
				'Сервер печати':     '/server/printer.asp'");
		delim = ',';
	}

	if (have_storage && opts_isDef("torrents_client")) write(delim, "
				'Торренты':          '/server/torrents.asp'");

	if (have_storage || have_printer)
		write(" },");
%>
			'Система': {
				'Режим работы:mode': '/system/mode.asp',
				'Конфигурация':      '/system/config.asp',
				'Микропрограмма':    '/system/firmware.asp',
				'Управление':        '/system/management.asp',
				'Пароль':            '/system/admin.asp',
				'Дата и время':      '/system/time.asp',<%
	if (have_storage && show_wps_button)
		write("
				'Кнопка WPS':        '/system/wps_button.asp',");
%>
				'Журнал':            '/system/log.asp',
				'Диагностика':       '/system/diag.asp'},
			'Выход':                 '/system/logout.asp'
		};

	mib.menu_mode = <%
	if (opts_isDef("vdsl"))
		write(6); else write(OP_MODE); %>;

	function addTree(folder, tree) {
		for (key in tree) {
			var ex = exmode.exec(key),
			    visible = true,
			    label = key;
			if (ex) {
				label = ex[1];
				visible = modes[ex[2]].test(mib.menu_mode);
			}

			if (!visible)
				continue;

			if (typeof tree[key] == 'object') {
				addTree(
					insFld(folder, gFld("<span class=\"panel\">"+label+"</span>", "")),
					tree[key]);
			} else {
				insDoc(folder, gLnk(0, "<span class=\"sub1\">"+label+"</span>", tree[key]));
			}
		}
	}

	addTree(
		foldersTree = gFld("<span class=\"panel\">"+mib.DEVICE_NAME+"</span>", ""),
		tree);
})();

	initializeDocument();
--></script>
			</td></tr>
		</table>
	</td>
</tr>
<tr><td class='bottom'>&nbsp;</td></tr>
</table>
</body>
<script type="text/javascript"><!--
Funs.preloadImages({
	off: '/i/panel_menu_bg1.gif',
	on:  '/i/panel_menu_bg1_on.gif'});
--></script>
</html>
