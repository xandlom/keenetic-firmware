<%	setMibsVars("DEVICE_NAME", "WEBFACE_OPTIONS");
	if (!testVar("page"))
		page = "/status.asp";
	if (WEBFACE_OPTIONS & 1)
		sidebar_url = "/sidebar_.asp?page="+page;
	else
		sidebar_url = "/sidebar.asp";
	htmlHead(DEVICE_NAME, "nolinks"); %>
<style type='text/css'>
body {
	-webkit-text-size-adjust: none;
	margin: 0;
	padding: 0;
}
div {
	position: absolute;
	overflow: hidden;
	margin: 0;
}
#head {
	left: 0; right: 0;
	top: 0; height: 50px;
	background: no-repeat left top #0C2F83 url(/i/logo.gif);
}
#redline {
	left: 0; right: 0;
	top: 50px; height: 4px;
	background: #B00;
}
#sidebar {
	left: 0; width: 185px;
	top: 54px; bottom: 0;
	background: #0C2F83 left top url(/i/panel_bg0.gif);
}
#page {
	left: 185px; right: 0;
	top: 54px; bottom: 0;
	background: #C5C9CF left top url(/i/config_bg.gif);
	border-left: 1px solid #000f5f;
}
iframe {
	position: absolute;
	width: 100%;
	height: 100%;
	border: 0;
}
#frame_sidebar {
	overflow: hidden;
}
div.all {
	position: fixed;
	top: 0px;
	bottom: 0px;
	left: 0px;
	right: 0px;
	z-index: 9999;
	background: #111;
	opacity: 0.6;
	-khtml-opacity: 0.6;
}
div.applying {
	display: block;

	position: fixed;

	background: white;
	border: 1px solid black;
	-moz-border-radius: 5px;

	text-align: center;
	font-family: verdana;
	font-size: large;
	padding: 9px 0px;
	z-index: 10000;

	margin: -26px 0px 0px -140px;
	left: 50%;
	top: 50%;
	width: 280px;
	height: 52px;
}

img.icon {
	margin: 4px 0px 0px 0px;
}
</style>
<!--[if gte IE 6]><style type='text/css'>
div.all { filter: alpha(opacity=60); }
</style><![endif]-->
<!--[if lte IE 7]><style type='text/css'>
div.all { filter: progid:DXImageTransform.Microsoft.Alpha(opacity=60); }
</style><![endif]-->
<script type="text/javascript"><!--
applying = {
	lang: {
			"Applying":              "Применение настроек",
			"Preparing for update":  "Подготовка к обновлению"
		},

	_l: function(str) {
			return (str in this.lang) ? this.lang[str] : str;
		},
	
	loadingImageName: "/i/loading.gif",

	onLoad: function () {
			this.preloadImages({ lim: this.loadingImageName });
		},

	imgs: {},
	preloadImages: function (pathes) {
			var root = document.URL;
			root = root.slice(0, root.indexOf('/', 8));
			for (var id in pathes) {
				var im = document.createElement('img');
				im.src = root+pathes[id];
				this.imgs[id] = im;
			}
		},

	show: function (text) {
			this.busyTimeoutId = 0;
			if (this.div) return;

			var div = document.createElement('div');
			div.id = 'busy';
			div.innerHTML = [
				"<div class='all' onclick='applying.hide();'></div>",
				"<div class='applying'>",
					this._l(text),
					"<img class='icon' src='", this.loadingImageName, "'/>",
				"</div>"].join('');

			document.body.appendChild(div);
			this.div = div;
		},

	hide: function() {
			if (this.div) {
				this.div.parentNode.removeChild(this.div);
				delete this.div;
				this.div = null;
			}
		},

	busyTimeoutId: 0,
	div: null,

	start: function (text, timeout) {
			this.stop();
			this.busyTimeoutId = 
				setTimeout(["applying.show('", text || "Applying", "');"].join(''), timeout || 300);
		},

	stop: function() {
			if (this.busyTimeoutId) {
				clearTimeout(this.busyTimeoutId);
				this.busyTimeoutId = 0;
			}
			this.hide();
		}
};

//--></script>
</head>
<body onload='applying.onLoad()'>
<div id='head'></div>
<div id='redline'></div>
<div id='sidebar'><iframe name='menu' id='frame_sidebar' src='<%=sidebar_url;%>' frameBorder='0' scrolling='no'></iframe></div>
<div id='page'><iframe name='view' id='frame_page' src='<%=page;%>' frameBorder='0'></iframe></div>
</body>
</html>
