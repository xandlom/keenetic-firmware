<%	setMibsVars("DEVICE_NAME");

	if (opts_isDef("torrents_client"))
		extra_time = "+20000";
	else
		extra_time = "";

	htmlHead("Firmware Updating Process", "nolinks"); %>
<style type='text/css'>
ul {
	padding-left: 20px;
	margin: 0px;
}
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
	height: 3px;
	background: #a00;
	border-bottom: 1px solid #B00;
}
div.container {
	top: 54px;
	bottom: 0px;
	text-align: center;
	padding-top: 100px;
	background: #C5C9CF url('/i/config_bg.gif');
}
div.form_frame {
	display: inline-block;
	text-align: left;
	padding: 0px;
	margin: 8px 8px 0px 8px;
	width: 62em;
	font-family: Verdana, Arial, Helvetica, sans-serif;
}
#_box {
	padding: 2em;
}
#_stages {
	padding: 0px 7em 2em 7em !important;
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
	border: 0px;
}
div.gauge {
	border: solid 1px #888;
}
.mercury {
	height: 100%;
	background: #ccc;
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
.leaf_head, .leaf_info, .leaf_page, .leaf_note {
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
.leaf_info {
	background: #657cb2;
	color: white;
	padding: 6px 3em 6px 3em !important;
}
.leaf_note {
	background: #657cb2;
	color: #f0ff91;
	font-weight: bold;
	padding: 6px 3em 6px 3em !important;
}
.leaf_page {
	border-top: 1px #002040 solid;
	background: #e7e7e7 url('/i/leaf_page_bg.gif') repeat-x;
	padding: 0;
}
.leaf_page_content {
	z-index: 2;
	position: relative;
	vertical-align: top;
	padding: 0 !important;
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
<div class="container bg">
<div class="form_frame">
<%
	notes = "";
	if (testVar("COMPRESS_ERROR"))
		notes = notes + "Произошла ошибка сжатия настроек ("+COMPRESS_ERROR+").";
	if (testVar("SAVE_ERROR"))
		notes = notes + " И не удалось сохранить аварийно.";
	writeLeafOpen("Обновление микропрограммы интернет-центра " + DEVICE_NAME,
	"Пожалуйста, не выключайте питание и не перезагружайте устройство во время обновления!<br/>Это может привести к серьезным повреждениям интернет-центра.", notes); %>

<div id='_box'>
<div class='gauge' id='_gauge' style='width: 58em; height: 1.5em;'><div class='mercury' id='_mercury' style='width: 0px;'/></div>
</div></div>
<div id='_stages'>
<ul>
	<li id='upgrade_stage' class='queued'>Обновление
		<ul>
			<li id='kernel_stage' class='queued'>Ядро</li>
			<li id='rootfs_stage' class='queued'>Корневая файловая система</li>
		</ul>
	</li>
	<li id='reboot_stage' class='queued'>Перезагрузка</li>
	<li id='finish_stage' class='queued'>Готово!</li>
</ul>
</div>
<% writeLeafClose(); %>
</div>
</body>
</html>
<script type="text/javascript"><!--
var obj = {
	interval: 125,

	redirect_url: '<% if (testVar("submit_url")) write(submit_url); else write("/");%>',
	stages: [
			{ id: 'upgrade', start: 0 },
			{ id: 'kernel', start: 0 },
			{ id: 'rootfs', start: 30000<%=extra_time;%> },
			{ id: 'reboot', start: 75000<%=extra_time;%> },
			{ id: 'finish', start: 115000<%=extra_time;%> },
			{ id: '---',    start: 115500<%=extra_time;%> }
		],

	current_stage: 0,
	time: <% if (testVar("start")) write(start); else write("0"); %>,

	start: function () {
			this.timer = setInterval('obj.tick();', this.interval);
		},

	tick: function () {
			this.time += this.interval;
			var merc_el = document.getElementById('_mercury'),
			    gauge_el = document.getElementById('_gauge'),
			    stages = this.stages,
			    last = stages[stages.length - 1],
			    percent = Math.round(gauge_el.clientWidth * Math.min(1.0, this.time / last.start)),
			    idx;

			merc_el.style.width = [percent, 'px'].join('');

			for (idx = 0; idx < stages.length; ++idx) {
				var cur = stages[idx],
				    el = document.getElementById([cur.id, 'stage'].join('_'));

				if (!el)
					continue;

				var nxt = stages[idx+1];

				el.className =
					(cur.start <= this.time) ? 
						(nxt.start > this.time) ?
							'in_progress':
							'done' :
						'queued';
			}

			if (this.time >= last.start) {
				clearInterval(this.timer);
				window.top.location.replace('/');
			}
		}
};
	obj.start();
//--></script>
