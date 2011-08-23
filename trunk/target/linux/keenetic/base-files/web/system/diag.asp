<% htmlHead("Network Diagnostics");
op="ping"; args = ""; %>
<script type="text/javascript"><!--
var log = {
lastIdx: 0,
length: 0,
onRun: function(aj, state) {
		if (aj.readyState != 4)
			return 0;
		this.start();
		this.aj = null;
	},

onState: function(aj, state) {
		if (aj.readyState != 4)
			return 0;
		this.timer = setInterval("log.tick()", 500);
		this.set(aj.responseText);
		this.aj = null;
	},

onUpdate: function(aj, state) {
		if (aj.readyState != 4)
			return 0;
		if (aj.responseText.length) {
			if (aj.responseText == ' reload!') {
				this.aj.abort();
				this.aj = null;
				this.start();
				return;
			}
			var doautoscroll = this.onbottom();
			this.add(aj.responseText);
			if (doautoscroll)
				this.scroll();
		}
		this.aj = null;
	},

onbottom: function () {
		var fr = this.frame;
		return fr.scrollTop == Math.max(0, fr.scrollHeight - fr.clientHeight);
	},

scroll: function () {
		var fr = this.frame;
		fr.scrollTop = Math.max(0, fr.scrollHeight - fr.clientHeight);
	},

add: function(text) {
		var lines = text.split('\n');
		lines.pop(); // last line is empty always

		for (var idx = 0; idx < lines.length; ++idx) {
			var line = lines[idx];
			if (line == "---finished---") {
				this.stop();
				continue;
			}

			var row = this.tbody.insertRow(-1);

			row.className = [this.lastIdx & 1 ? 'odd' : 'even', this.lastIdx ? '' : 'first'].join(' ');

			var cell_text = row.insertCell(-1);

			cell_text.innerHTML = line.length ? line.replace(/&/g, "&amp;").replace(/</g, "&lt;") : '&nbsp;';
			cell_text.className = 'log dump';
			++this.lastIdx;
		}
		this.length += text.length;
	},

set: function(text) {
		this.length = text.length;

		var frame = this.frame,
		    tbl = document.createElement("table"),
		    th_row = tbl.createTHead().insertRow(-1),
		    tbody = document.createElement("tbody"),
		    th_head = document.createElement("th");

		tbl.className = 'log';
		tbody.id = 'log_body';
		tbl.appendChild(tbody);
		th_row.appendChild(th_head);

		th_head.className = 'empty';
		th_head.width = '750px';
		th_head.innerHTML = 'Результат';

		this.lastIdx = 0;
		this.length = 0;
		this.tbody = tbody;
		this.add(text);

		frame.innerHTML = "";
		frame.appendChild(tbl);
		this.scroll();
	},

tick: function() {
		if (!this.aj)
			this.aj = ajaxGet(['/req/execLog?raw=1&skip=', this.length].join(''), log.onUpdate, log);
	},

start: function() {
		this.frame = $("msg").el;
		this.stop();
		if (this.aj)
			this.aj.abort();

		this.set(_l("Waiting for answer..."));
		this.aj = ajaxGet('/req/execLog?raw=1', log.onState, log);
	},

stop: function() {
		if (this.timer) {
			clearInterval(this.timer);
			this.timer = 0;
		}
	},

clean: function() {
		this.stop();
		this.set("удаление...");
		if (this.aj)
			this.aj.abort();

		this.aj = ajaxGet('/req/execLog?raw=1&clear=yes', log.onState, log);
	}
}

function update(event, form, type) {
	if (type === 'init') {
		var v = form.validation;
		v.submits = "#ping,#nslookup";
		_(form, "args") .setParser("-ascii");
		refresh_onclick(event);
	}
}

var lastOp = 'ping';

function submit(event) {
	ajaxGet(
		['/req/diag?op=', lastOp, '&args=', encodeURIComponent(this.args.value)].join(''),
		log.onRun, log)
	return false;
}

function ping_onclick(event) {
	lastOp = 'ping';
	ajaxGet(
		['/req/diag?op=ping&args=', encodeURIComponent(this.form.args.value)].join(''),
		log.onRun, log)
}

function nslookup_onclick(event) {
	lastOp = 'nslookup';
	ajaxGet(
		['/req/diag?op=nslookup&args=', encodeURIComponent(this.form.args.value)].join(''),
		log.onRun, log)
}

function pppoediscovery_onclick(event) {
	lastOp = 'pppoe-discovery';
	ajaxGet(
		['/req/diag?op=pppoe-discovery&args=', encodeURIComponent(this.form.args.value)].join(''),
		log.onRun, log)
}

function dump_onclick(event) {
	ajaxGet(
		'/req/diag?op=dump',
		log.onRun, log)
}

function refresh_onclick(event) {
	log.start();
}

function clear_onclick(event) {
	log.clean();
}

function store_onclick() {
	window.location.href = "/req/diag.log";
}
--></script>
</head>

<body class="body">
<% writeLeafOpen("Диагностика интернет-соединения", 
	"Можно проверить подключение интернет-центра к сети провайдера и к Интернету, "+
	"используя две встроенные утилиты: <b>ping</b> и <b>nslookup</b>. Первая утилита "+
	"проверяет доступность указанного сервера (можно использовать IP-адрес или доменное "+
	"имя сервера), а вторая — возможность обращения к интернет-ресурсам по доменным "+
	"именам (необходимо указать доменное имя, например zyxel.ru)."); %>

<% writeFormOpen("diag"); %>
<table class="sublayout">
<tr>
	<td class='label'>Доменное имя/IP-адрес/параметры:</td>
	<td class='field'><%=inputText("args", 39, 64); %></td>
</tr>
<tr>
	<td class='label'>Действие:</td>
	<td class='field'>
		<%=button("ping:ping", "nslookup:nslookup", "pppoediscovery:pppoe-discovery"); %>
	</td>
</tr>
</table>

<table id="LOG_VIEW" class="sublayout">
<tr>
	<td><div id='msg' class='log_place'></div></td>
</tr>
<tr>
	<td class='submit'>
		<%=button("dump:Полная диагностика"); %> &nbsp; 
		<%=button("store:Сохранить в файл"); %> &nbsp; 
		<%=button("refresh:Обновить"); %>
		<%=button("clear:Очистить"); %>
	</td>
</tr>
</table>
</form>

<% writeLeafClose(); %>
<script type="text/javascript">updateAllForms();</script>
</body>
</html>
