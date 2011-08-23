<%	setMibsVars("OP_MODE", "DEVICE_NAME");
	htmlHead(DEVICE_NAME + " Main Menu", "nolinks"); %>
<style type="text/css">
body {
	background: #0C2F83 url('i/panel_bg0.gif');
	margin: 0;
}
div {
	margin: 0;
	padding: 0;
}
#sidebar {
	position: absolute;
	top: 11px; bottom: 0;
	left: 0; right: 0;
	overflow: hidden;
}
#icon {
	height: 50px;
}
img.status_icon {
	border: 0px;
	color: white;
	height: 50px;
	width: 185px;
}
#footer {
	background: no-repeat top left url('i/panel_menu_bg3.gif');
	height: 68px;
	width: 100%;
}
#menu {
	background: url(i/panel_menu_bg2.gif);
	color: #93f0ff;
	font-family: Arial,Verdana,Helvetica,Sans-Serif;
	font-size: small;
	font-weight: bold;
	padding: .3em 0 .2em 20px !important;
}
#menu > ul {
	margin: 0px;
	padding: 0 0 0 1.2em;
}
li {
	margin: .2em .2em .2em .2em;
}
#menu > ul > li {
	font-weight: bold;
}
#menu > ul > li > ul {
	padding: .2em 0 .4em 1.4em;
}
#menu > ul > li > ul > li {
	color: #F2F9FF;
}
.node_opened {
	list-style-type: disc;
}
.node_closed {
	list-style-type: circle;
}
.node_link {
	list-style-type: square;
}
a.menu_node, a.menu_link {
	font-weight: bold;
	text-decoration: none;
}
a.menu_node:hover, a.menu_link:hover {
	color: #FFFFB2;
}
a.menu_node {
	color: inherit;
}
a.menu_link {
	color: #F2F9FF;
}
a.link_free {
}
a.link_current {
	color: #FFFF7E !important;
}
</style>
</head>

<body>
<div id='sidebar'>
	<div id='icon'><a onclick='$(this).selectPic()' target='view' href='/status.asp'><img
		class='status_icon'
		src='/i/panel_menu_bg1.gif'
		alt='status'
		onmouseout="this.src='/i/panel_menu_bg1.gif'"
		onmouseover="this.src='/i/panel_menu_bg1_on.gif'"/></a></div>
	<div id='menu'><%=DEVICE_NAME;%><ul id='root'></ul></div>
	<div id='footer'></div>
</div>
</body>
<script type="text/javascript"><!--
<%
	if (opts_isDef("vdsl"))
		OP_MODE = 6;
	writeMibProps("OP_MODE", "DEVICE_NAME"); %>

var $;

(function () {
	function domHelper(el) {
		this.el = el;
		return this;
	}

	domHelper.prototype = {
		setStyle: function (name, value) {
				var el = this.el;
				if (el.style)
					el.style[name] = value;
				else
					el.setAttribute("style", name+":"+value);
				return this;
			},

		setSubClass: function (prefix, name) {
				var el = this.el,
				    list = el.className.split(' ');

				if (el.className.indexOf(prefix+'_') >= 0) {
					var pl = prefix.length;

					for (var i = 0; i < list.length; ++i)
						if (list[i].slice(0, pl) == prefix) {
							list[i] = [prefix, name].join('_');
							el.className = list.join(' ');
							return this;
						}
				}

				list.push([prefix, name].join('_'));
				el.className = list.join(' ');
				return this;
			},

		show: function (yes) {
				if (this.el)
					this.setStyle("display", (yes < 0 ? !this.isVisible(): yes) ? "" : "none");
				return this;
			},

		isVisible: function () {
				return !(this.el && this.el.style && this.el.style.display == 'none');
			},

		toggleMenu: function (yes) {
				var node = this.el.parentNode.parentNode.firstChild,
				    sub = $(this.el.nextSibling),
				    opened = !!sub.isVisible() && yes == 1,
				    show = yes > 0 ? !!yes : !opened;

				if (show && !opened) {
					while (node) {
						if (node.tagName.toUpperCase() == 'LI') {
							$(node.firstChild.nextSibling).show(false);
							$(node).setSubClass('node', 'closed');
						}
						node = node.nextSibling;
					}
				}

				if (show != opened) {
					sub.show(yes);
					$(this.el.parentNode).setSubClass('node', show ? 'opened' : 'closed');
				}
			},

		freeAll: function(root) {
				var links = root.getElementsByTagName('a');
				for (var idx = 0; idx < links.length; ++idx) {
					var l = links[idx];
					if (l.className.indexOf('menu_link') >= 0) {
						$(l).setSubClass('link', 'free');
						$(l.parentNode).setSubClass('node', 'closed');
					}
				}
			},

		selectLink: function () {
				var root = this.el;
				do {
					root = root.parentNode.parentNode;
				} while (root.parentNode.parentNode.tagName == 'UL');

				this.freeAll(root);
				$(this.el).setSubClass('link', 'current');
				$(this.el.parentNode).setSubClass('node', 'opened');
			},

		selectPic: function () {
				this.freeAll(document.getElementById('root'));
			},

		_preloadImages: function (path) {
				for (var id in path)
					(this[['$', id].join('')] = new Image(202, 52)).src = path[id];
			}
		};

	$ = function (el) {
			return new domHelper(el);
		};

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
	if (have_storage)
		write("
				'Кнопка WPS':        '/system/wps_button.asp',");
%>
				'Журнал':            '/system/log.asp',
				'Диагностика':       '/system/diag.asp'},
			'Выход':                 '/system/logout.asp'
		};

	var currentLink = 0, className = 'link_free';

	function addList(folder, tree) {
		for (key in tree) {
			var ex = exmode.exec(key),
			    visible = true,
			    label = key;

			if (ex) {
				label = ex[1];
				visible = modes[ex[2]].test(mib.OP_MODE);
			}

			if (!visible)
				continue;

			var li = document.createElement("li");
			if (typeof tree[key] == 'object') {
				li.innerHTML = ["<a onmouseover='$(this).toggleMenu(1)' href='#' onclick='javascript:$(this).toggleMenu(1)' class='menu_node'>", label, '</a><ul></ul>'].join('');
				folder.appendChild(li);
				addList(li.lastChild, tree[key]);
			} else {
				li.innerHTML = ["<a onclick='$(this).selectLink()' target='view' href='", tree[key], "' class='menu_link'>", label, "</a>"].join('');<%
				if (testVar("page")) write("
				if (tree[key] == \"", page, "\")
					currentLink = li.firstChild;"); %>
				folder.appendChild(li);
			}
		}
	}

	var root = document.getElementById("root");
	addList(root, tree);
	if (currentLink) {
		$(currentLink).selectLink();
		$(currentLink.parentNode.parentNode.parentNode.firstChild).toggleMenu(2);
	}
	else
		$(root.firstChild.firstChild).toggleMenu(0);

	setTimeout('(function() { \
		var links = document.getElementById("root").getElementsByTagName("a"), \
		    page = window.top.view.location.pathname; \
		for (var idx = 0; idx < links.length; ++idx) { \
			var l = links[idx]; \
			if (l.className.indexOf("menu_link") >= 0) { \
				if (l.pathname == page) {\
					$(l).selectLink(); \
					$(l.parentNode.parentNode.parentNode.firstChild).toggleMenu(2); \
				} \
			} \
		} \
	})()', 300);
})();

var _imgs = $(0)._preloadImages({
	off: '/i/panel_menu_bg1.gif',
	on:  '/i/panel_menu_bg1_on.gif'});
--></script>
</html>
