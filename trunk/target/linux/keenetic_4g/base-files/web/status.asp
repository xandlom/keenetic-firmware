<% htmlHead("Системный монитор"); %>
<script type='text/javascript' src='/js/status.js?=<%=rvsn();%>'></script>
<script type="text/javascript"><!--
<% setMibsVars("DEVICE_NAME", "OP_MODE");
	VDSL_MODE = opts_isDef("vdsl");
	if (VDSL_MODE)
		WAN = 'VDSL';
	else
		WAN = 'WAN';
	writeMibProps("OP_MODE", "VDSL_MODE"); %>
controller.head_links = {
	IWLAN:  '/internet/wireless/basic.asp',
	WWAN:   '/internet/wireless/basic.asp',
	WiMAX:  '/internet/yota.asp',
	WLBRI:  '/internet/wireless/basic.asp',
	WLAN:   '/homenet/wireless/basic.asp',
	LAN:    '/homenet/lan.asp',
	IPPP:   '/internet/ppp.asp',
	IWAN:   '/internet/eth.asp',
	WAN:    '/internet/eth.asp',
	DNS:    '/internet/eth.asp',
	MODEM:  '/internet/modem.asp',
	routing:'/internet/route.asp',
	printer:'/server/printer.asp',
	storage:'/server/samba.asp'
};

controller.rows_links = {
	wlradio: '',
	opmode:  '/system/mode.asp',
	wlmode:  '/system/mode.asp',
	domain:  '/internet/dyndns.asp',
	uptime:  '/system/log.asp',
	systime: '/system/time.asp',
	version: '/system/firmware.asp',
	wps:     '/wireless/wps.asp',
	wimax_state:'/internet/yota.asp',
	linktime: {
		'WiMAX':'/internet/yota.asp'},

	ip_mode: {
		'IWAN':  '/internet/eth.asp',
		'IWLAN': '/internet/eth.asp',
		'WWAN':  '/internet/eth.asp',
		'WAN':   '/internet/eth.asp',
		'VDSL':  '/internet/eth.asp',
		'IVDSL': '/internet/eth.asp' },
	security: {
		'wireless/IWLAN': '/internet/wireless/security.asp',
		'wireless/WWAN':  '/internet/wireless/security.asp',
		'wireless/WLBRI': '/internet/wireless/security.asp',
		'wireless/WLAN':  '/homenet/wireless/security.asp' },

	'wireless/IWLAN': '/internet/wireless/basic.asp',
	'wireless/WWAN':  '/internet/wireless/basic.asp',
	'wireless/WLBRI': '/internet/wireless/basic.asp',
	'wireless/WLAN':  '/homenet/wireless/basic.asp',
	'wireless/WiMAX': '/internet/yota.asp',

	'if_mac': {
			'net/LAN': '',
			'WiMAX': '',
			'IWAN': '/internet/eth.asp',
			'IWLAN': '/internet/eth.asp',
			'WAN':   '/internet/eth.asp',
			'WWAN':  '/internet/eth.asp',
			'VDSL':  '/internet/eth.asp',
			'IVDSL': '/internet/eth.asp'
		},

	'net/LAN':   '/homenet/lan.asp',
	'net/WLAN':  '/homenet/lan.asp',
	'net/IPPP':  '/internet/ppp.asp',
	'net/IWLAN': '/internet/eth.asp',
	'net/WiMAX': '/internet/eth.asp',
	'net/WAN':   '/internet/eth.asp',
	'net/IWAN':  '/internet/eth.asp',
	'net/VDSL':  '/internet/eth.asp',
	'net/WWAN':  '/internet/eth.asp',
	'WAN':       '/internet/eth.asp',
	'IWAN':      '/internet/eth.asp',
	'VDSL':      '/internet/eth.asp',
	'IVDSL':     '/internet/eth.asp',
	'WiMAX':     '/internet/eth.asp',
	'IPPP':      '/internet/ppp.asp',
	'VDSL/VDSL': '/internet/vdsl.asp',
	'VDSL/IVDSL':'/internet/vdsl.asp',
	'MODEM':     '/internet/modem.asp',
	'dhcpd/LAN': '/homenet/lan.asp',
	'LAN':       '/homenet/lan.asp'
};

controller.labels = {
	sockets:  "Разъемы Ethernet",
	system:   "Система",
	opmode:   "Режим работы",
	uptime:   "Время работы",
	cpusage:  "Загрузка ЦП",
	memtotal: "Память",
	memusage: "&nbsp;&nbsp; Занято",
	swaptotal:"Подкачка",
	swapusage:"&nbsp;&nbsp; Занято",
	memfree:  "Свободно памяти",
	systime:  "Текущее время",
	version:  "Версия ПО",
	created:  "Дата ПО",
	DNS:      "DNS-серверы",
	IWAN:     "Подключение к Интернету",
	IPPP:     "Подключение к Интернету",
	MODEM:    "Подключение к Интернету 3G",
	IWLAN:    "Подключение к Интернету по Wi-Fi",
	WAN:      "Подключение к районной сети (Link Duo)",
	IVDSL:    "Подключение к Интернету по VDSL",
	VDSL:     "Подключение по VDSL",
	LAN:      "Домашняя сеть",
	WLAN:     "Беспроводная сеть Wi-Fi",
	WLBRI:    "Беспроводной мост Wi-Fi",
	WWAN:     "Подключение по Wi-Fi",
	WiMAX:    "Сеть Yota Internet 4G",
	USB:      "Сетевой интерфейс USB-модема",

	storage:  "USB-накопитель",
	printer:  "Принтер",
	routing:  "Таблица маршрутизации",
	domain:      "Доменное имя",
	type:        "Тип",
	state:       "Состояние",
	linktime:    "Длительность",
	profile:     "Профиль соединения",
	act_us_speed:"Скорость отдачи",
	act_ds_speed:"Скорость приёма",
	ip_mode:     "Настройка IP",
	if_mac:      "MAC-адрес",
	if_ip:       "IP-адрес",
	if_mask:     "Маска подсети",
	if_gw:       "Основной шлюз",
	dhcp_state:  "DHCP-сервер",
	dhcp_pool:   "&nbsp;&nbsp; Пул адресов",

	wlstatus:"Сеть Wi-Fi",
	wlradio: "Радиомодуль",
	wlmode:  "Режим сети",
	ap_mac:  "Точка доступа",
	wlstate: "Соединение", /* station status */
	SSID:    "Имя сети",
	bitrate: "Скорость",
	qual:    "Качество связи",
	level:   "Уровень сигнала",
	noise:   "Уровень шума",
	channel: "Канал",
	security:"Защита",
	wltype:  "Стандарт",
	wps:     "WPS",
	tx:      "Отправлено",
	rx:      "Принято",
	tx_:     "Отправлено",
	rx_:     "Принято",

	wimax_state: "WiMAX-подключение",
	wimax_model: "Модель",
	wimax_fwver: "Версия ПО",

	modem:      "Устройство",
	modem_type: "&nbsp;&nbsp; Модель",
	modem_pin:  "&nbsp;&nbsp; PIN-код",

	dir:     "Диск",
	mode:    "Режим доступа",
	filesys: "Формат",
	size:    "Ёмкость",
	avail:   "Свободно",
	free:    "Свободно",
	usage:   "&nbsp;&nbsp; Занято"
};

controller.route_tpl = {
	table: { className: 'status' },
	th:    { className: "sublist"},
	td:    { className: "list", innerHTML: "@" },

	cap:  { th: { className: "list", colSpan: '4', innerHTML: "<a href='/internet/route.asp'>Действующие маршруты</a>" } },

	cols: {
			rt_dest: { th: { innerHTML: "Сетевой адрес" } },
			rt_gw:   { th: { innerHTML: "Шлюз" } },
			rt_mask: { th: { innerHTML: "Маска" } },
			rt_dev:  { th: { innerHTML: "Интерфейс" } }
		}
};

controller.formatters = {
	uptime:   formatter.uptime,
	cpusage:  formatter.usage,
	memusage: formatter.usage,
	swapusage:formatter.usage,
	memtotal: formatter.memsize,
	memfree:  formatter.memsize,
	swaptotal:formatter.memsize,
	systime:  formatter.date,
	linktime: formatter.uptime,
	act_us_speed: formatter.kbitrate,
	act_ds_speed: formatter.kbitrate,
	created:  function(data, path, it) { return formatter.fwdate(data); },
	tx:       formatter.sizenspeed,
	rx:       formatter.sizenspeed,
	tx_:      formatter.shortsize,
	rx_:      formatter.shortsize,
	mode:     formatter.accessMode,
	size:     formatter.memsize,
	avail:    formatter.memsize,
	free:     formatter.percent,
	usage:    formatter.usage,
	filesys:  formatter.filesys,
	rt_dest:  formatter.numToIp,
	rt_mask:  formatter.numToIp,
	rt_gw:    formatter.numToIp,
	node:     formatter.diskNode,
	bitrate:  formatter.bitrate,
	qual:     formatter.usage,
	level:    formatter.dbm_level,
	noise:    formatter.dbm_level,
	wlmode:   formatter.lang,
	wlstate:  formatter.wlanState,
	wlradio:  formatter.onoff,
	wlstatus: _f,
	wimax_state:formatter.lang,
	modem:    formatter.presenti,
	pr_status:formatter.present,
	modem_pin:formatter.modem_pin,
	wps:      _m,
	opmode:   formatter.lang,
	security: formatter.lang,
	channel:  formatter.lang,
	state:    formatter.lang,
	ip_mode:  formatter.lang,
	dhcp_state:formatter.ONOFF
};

controller.renderAll = function (text) {
	var data = eval("(" + text + ")");

	if ('mib' in data) {
		mib = data.mib;
		if ('menu' in window.top && 'sidebar' in window.top.menu) {
			var sidebar = window.top.menu;
			if ('mib' in sidebar)
				if (mib.OP_MODE != sidebar.mib.OP_MODE)
					sidebar.location.reload();
		}
	}

	this.formatData(data, "", "");

	var infoRow = document.getElementById("stat_row");

	this.left = infoRow.insertCell(0);
	this.right = infoRow.insertCell(1);

	this.left.setAttribute('style', 'width: 59%');

	this.renderSystem(data.system);
	this.renderNets(data.ifs);
<% if (opts_isDef("usb_storage")) write(
"	if ('storage' in data)
		this.renderStorage(data.storage);"); %>
<% if (opts_isDef("usb_printer")) write(
"	if ('printer' in data)
		this.renderPrinter(data.printer);"); %>
	this.renderRoutes(data.route);
	if ('ports' in data)
		this.renderSwitch(data.ports);

	infoRow.deleteCell(3);
	infoRow.deleteCell(2);
};

controller.renderSystem = function (data) {
	this.appendLeaf(this.right, 'system', data );
};

controller.renderPrinter = function (data) {
	this.appendLeaf(this.right, 'printer', {}, controller.link(_m(('pr_status' in data) ? "Connected" : "Not connected"), '/server/printer.asp') );
};

controller.renderStorage = function (data) {
	for (lab in data) {
		var item = data[lab],
		    mode = item.mode;
		if (mode.substr(0, 1) == 'R') {
			item.filesys += ' (' + mode + ')';
			delete item.free;
			delete item.avail;
		}
		delete item.mode;
		var node_name = item.node;
		item.node = 
			["<div class='disk_eject'>",
				"<button class='flat' onclick='this.disabled=true; sendAjaxRequest(\"eject?disk="+node_name+"\"); controller.req();'>Отключить</button>",
			"</div>",
			"<div class='disk_name'>",
				node_name,
			"</div>"].join('');
	}
	this.appendLeaf(this.right, 'storage', data, controller.link(_m('Not connected'), '/server/samba.asp'));
};

controller.renderRoutes = function (data) {
	this.left.appendChild(Table.toDOM( data, this.route_tpl ));
};

controller.renderSwitch = function (data) {
	var tbl = Table.create({ className:'status' }),
	    header_row = Table.appendRow(tbl, {}),
	    labels_row = Table.appendRow(tbl, {}),
	    speed_row = Table.appendRow(tbl, { className:'odd first' }),
	    idx;

	Table.appendTH(header_row, { className:'list', colSpan:data.length.toString(), innerHTML:this.getLabel("sockets") });

	for (idx = 0; idx < data.length; ++idx) {
		var if_name = data[idx].id;
		if (if_name == 0 && mib.OP_MODE == 0)
			if_name = 'WAN';
		else
			if_name = ['LAN', if_name].join('');

		var speed = (data[idx].speed > 0)
			? [data[idx].speed, 'M/', data[idx].duplex ? 'Full' : 'Half'].join('')
			: '-';

		Table.appendTH(labels_row, { className:'sublist', innerHTML:if_name });
		Table.appendTD(speed_row,  { className:'empty', innerHTML:speed });
	}
	this.left.appendChild(tbl);
};

controller.renderDNS = function (data) {
	var leaf = new statusLeaf("DNS");
	for (var idx = 1; idx <= data.length; ++idx)
		leaf.addRow( _l("Server")+" "+idx+":", data[idx-1] );
	if (mib.OP_MODE == 1) /* wisp */
		this.right.appendChild(leaf.tbl);
	else
		this.left.appendChild(leaf.tbl);
};

controller.renderNets = function (data) {
	/* show Internet connection */
	if (mib.OP_MODE < 2) /* gw | wisp */ {
		if ('PPP' in data && data.PPP.type != 'None') {
			this.appendLeaf(this.left, 'IPPP', data.PPP );

			if (mib.OP_MODE == 0) {
				if (data.WAN.ip_mode != 'No IP')
					this.appendLeaf(this.left, '<%=WAN;%>', data.WAN);
			} else {
				this.appendLeaf(this.left, 'WWAN', data.WLAN, controller.link(_l("Off"), '/internet/wireless/basic.asp'));
			}
		} else {
			if (mib.OP_MODE == 0) {
				if (data.WAN.ip_mode != 'No IP')
					this.appendLeaf(this.left, 'I<%=WAN;%>', data.WAN);
			} else {
				this.appendLeaf(this.left, 'IWLAN', data.WLAN, controller.link(_l("Off"), '/internet/wireless/basic.asp'));
			}
		}
	}

	switch (mib.OP_MODE) {
	case '4': /* modem */
		if ('PPP' in data && data.PPP.type != 'None')
			this.appendLeaf(this.left, 'MODEM', data.PPP);
		break;

	case '5': /* WiMAX */
		if ('WiMAX' in data)
			this.appendLeaf(this.left, 'WiMAX', data.WiMAX);
		if ('USB' in data)
			this.appendLeaf(this.left, 'USB', data.USB);
	}

	if (/^[0145]$/.test(mib.OP_MODE) && 'DNS' in data) /* gw | wisp | modem | yota_wimax */
		this.renderDNS(data.DNS);

	var wloff = controller.link(_f("Off"), '/homenet/wireless/basic.asp');
	if ('wlradio' in data.WLAN.wireless) {
		wloff = "Выключена тумблером на корпусе";
		data.WLAN = {};
	}

	if (mib.OP_MODE == 2 || mib.OP_MODE == 3) /* ap || br */ {
		this.appendLeaf(this.left, (mib.OP_MODE == 3) ? 'WLBRI':'WLAN', data.WLAN, wloff);
		if ('DNS' in data && data.DNS.length)
			this.renderDNS(data.DNS);
		this.appendLeaf(this.right, 'LAN', data.LAN);
	} else {
		this.appendLeaf((mib.OP_MODE != 1 && mib.OP_MODE != 5) ? this.left : this.right, 'LAN', data.LAN);

		if (/^[045]$/.test(mib.OP_MODE)) /* gw, modem */
			this.appendLeaf(this.right, 'WLAN', data.WLAN, wloff);
	}
};
--></script>
</head>
<body class="body">
<% writeLeafOpen("_status", "Системный монитор интернет-центра " + DEVICE_NAME); %>

<table class="sublayout">
	<tr id='stat_row'><td style='width:59%'></td><td></td></tr>
	<tr><td id="stat_footer">
		<table class='status' style='display: none'>
			<tr><th class='list'> blinker </th></tr>
		</table>
	</td></tr>
	<tr>
		<td class='submit' colspan='2'>
			Период обновления: <select id='interval' onchange='controller.autoRefresh(this.value);' onkeyup='controller.autoRefresh(this.value);'>
				<option value='5'>0,5 с</option>
				<option value='10'>1 с</option>
				<option value='20'>2 с</option>
				<option value='50' selected='selected'>5 с</option>
				<option value='100'>10 с</option>
				<option value='300'>30 с</option>
				<option value='0'>Никогда</option>
			</select>
			<input type="button" name="refresh_status" value="Обновить" onclick="controller.req();"/>
		</td>
	</tr>
</table>

<% writeLeafClose(); %>
<script type="text/javascript"><!--
(function(obj,text) {
	Funs.preloadImages({ bg: '/i/tabtitle_bg.gif'});
	if ('applying' in top)
		top.applying.stop();
	obj.query = '/req/status';
	obj.renderAll(decodeURIComponent(text));
	obj.autoRefresh(obj.restoreRefresh());
})(controller, "<% write(encodeURI(getStatusProps())); %>");
--></script>
</body>
</html>
