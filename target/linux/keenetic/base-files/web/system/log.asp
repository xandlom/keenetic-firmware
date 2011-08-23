<% htmlHead("Журнал"); %>
<script type="text/javascript"><!--
<% setMibsVars("LOG_MODE", "REMOTELOG_SERVER", "DEVICE_NAME", "HOST_NAME", "DEBUG", "WEBFACE_OPTIONS");
	writeMibProps("LOG_MODE");
	LOGS_LOAD = WEBFACE_OPTIONS & 2;
%>

// Jan 19 14:39:42 syslogd started: BusyBox v1.8.2 
var log = {
log: 'sys',
lastIdx: 0,
length: 0,
regexs: {
	sys: /^(\w+)\s+(\d+)\s+(\d+:\d+:\d+)\s+([^:]+):\s*(.*)$/i,
	usb: /^(.):(.)\s*(.*)$/i },
months: { Jan: 0, Feb: 1, Mar: 2, Apr: 3, May: 4, Jun: 5, Jul: 6, Aug: 7, Sep: 8, Oct: 9, Nov: 10, Dec: 11 },
onState: function(aj, state) {
		if (aj.readyState != 4)
			return 0;
		this.set(aj.responseText);
		this.aj = null;
		this.timer = setInterval("log.tick()", 500);
	},

onUpdate: function(aj, state) {
		if (aj.readyState != 4)
			return 0;
		if (aj.responseText.length) {
			if (aj.responseText == ' reload!') {
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
		var frame = this.frame;
		return frame.scrollTop == Math.max(0, frame.scrollHeight - frame.clientHeight);
	},

scroll: function () {
		var frame = this.frame;
		frame.scrollTop = Math.max(0, frame.scrollHeight - frame.clientHeight);
	},

add: function(text) {
		var lines = text.split('\n');

		for (var idx = 0; idx < lines.length; ++idx) {
			var line = lines[idx];
			if (line == '')
				continue;

			var row = this.tbody.insertRow(-1),
			    tds = this.regexs[this.log].exec(line);

			row.className = [this.lastIdx & 1 ? 'odd' : 'even', this.lastIdx ? '' : ' first'].join('');

			if (tds != null) {
				var cell_time = row.insertCell(-1),
				    cell_src = row.insertCell(-1),
				    cell_text = row.insertCell(-1);

				cell_time.className = 'log nowrap';
				cell_src.className = 'log nowrap';

				if (this.log == 'sys') {
					cell_time.innerHTML = [tds[2], lang.months[this.months[tds[1]]], tds[3]].join(' ');
					cell_src.innerHTML = tds[4];
					line = tds[5];
				} else {
					cell_time.innerHTML = tds[1];
					cell_src.innerHTML = tds[2];
					line = tds[3];
				}
			} else {
				var cell_text = row.insertCell(-1);
				cell_text.colSpan = 3;
			}

			cell_text.innerHTML = line.replace(/&/g, "&amp;").replace(/</g, "&lt;");
			cell_text.className = 'log';
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
		    th_time = document.createElement("th"),
		    th_src = document.createElement("th"),
		    th_text = document.createElement("th");

		tbl.className = 'log';
		tbody.id = 'log_body';
		tbl.appendChild(tbody);
		th_row.appendChild(th_time);
		th_row.appendChild(th_src);
		th_row.appendChild(th_text);

		th_time.className = th_src.className = th_text.className = 'empty';
		if (this.log == 'sys') {
			th_time.width = '90px';
			th_src.width = '90px';
			th_text.width = '570px';
			th_time.innerHTML = 'Время';
			th_src.innerHTML = 'Источник';
			th_text.innerHTML = 'Сообщение';
		} else {
			th_time.width = '5px';
			th_src.width = '5px';
			th_text.width = '740px';
			th_time.innerHTML = 'T';
			th_src.innerHTML = '*';
			th_text.innerHTML = 'Текст';
		}

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
			this.aj = ajaxGet(['/req/sysLog/', this.log, '?cat=all&raw=1&skip=', this.length].join(''), log.onUpdate, log);
	},

start: function() {
		this.frame = $("msg").el;
		this.stop();
		this.set(_l("Waiting for answer..."));
		if (this.aj)
			this.aj.abort();

		this.aj = ajaxGet(['/req/sysLog/', this.log, '?cat=all&raw=1'].join(''), log.onState, log);
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

		this.aj = ajaxGet('/req/sysLog?cat=all&raw=1&clear=yes', log.onState, log);
	},

select: function(log) {
		this.log = log ? 'usb' : 'sys';
		this.start();
	}
}

function update(event, form, type) {
	_('#remote_server').show(form.LOG_MODE.value == 2);
	_('#REMOTELOG_SERVER').enable(form.LOG_MODE.value == 2);

	if (type === 'init') {
		_('#REMOTELOG_SERVER').setParser("ip_port");
		_("#LOG_VIEW,#LOG_VIEW2") .show(mib.LOG_MODE != 0);

		if (mib.LOG_MODE != 0)
			refresh_onclick(event);

		var lf = document.cookie.match('(?:^|;)\\s*file=([^;]*)');
		if (lf)
			form.log_file.value = decodeURIComponent(lf[1]);
	}

	if (this.name == 'log_file') {
		document.cookie = 'file='+encodeURIComponent(this.value);
	}
	if (type === 'init' || this.name == 'log_file') {
		_(form, 'clear').show(form.log_file.value == 0);
		log.select(form.log_file.value != 0);
	}
}

function refresh_onclick(event) {
	log.start();
}

function clear_onclick(event) {
	log.clean();
}

function store_onclick() {
	window.location.href = ["/req/log/", log.log == 'sys' ? '<%=HOST_NAME;%>' : 'usb_devs', ".log"].join('');
}<%
	if (LOGS_LOAD)
		write("

function logs_onclick() {
	fileBrowser.show('logs/', this);
	return true;
}

treeView.leafClick = function () {
	if (this.type == TREE.FILE) {
		fileBrowser.close();
		window.location.href = '/req/'+this.getPath();
	}
};");
%>
--></script>
</head>

<body class="body">
<% writeLeafOpen("Журнал системных событий", 
	"Ведение журнала позволит просматривать сообщения об ошибках системы при диагностике "+
	"неполадок. Журнал можно сохранить в текстовый документ."); %>

<% writeFormOpen("sysLog"); %>

<table class="sublayout">
<tr>
	<td class='label'>Ведение журнала:</td>
	<td class='field'>
		<% writeSelectOpen("LOG_MODE"); %>
			<% writeOption("Выключено", 0); %>
			<% writeOption("Включено", 1); %>
			<% writeOption("Направить на удалённый syslog сервер", 2); %>
		</select>
	</td>
</tr>
<tr id='remote_server'>
	<td class='label'>Удалённый сервер:</td>
	<td class='field'><%=inputText("REMOTELOG_SERVER", 40, 127); %></td>
</tr>
<tr>
	<td class='label'></td>
	<td class='submit'><%
		if (LOGS_LOAD)
			write("
		", button("logs: ---- [ Открыть папку журналов ] ---- ")); %>
		<%=submit("Применить");%>
	</td>
</tr>
</table>

<table id="LOG_VIEW" class="sublayout">
<tr>
	<td><div id='msg' class='log_place'></div></td>
</tr>
</table>
<table id="LOG_VIEW2" class="sublayout">
<tr>
	<td class='label'><label for='log_file'>Журнал:</label></td>
	<td class='field'><% writeSelectOpen("log_file"); %>
			<% writeOption("syslog", 0); %>
			<% writeOption("usb devices", 1); %>
		</select></td>
	<td class='submit'>
		<%=button("store:Сохранить журнал"); %> &nbsp; 
		<%=button("refresh:Обновить"); %>
		<%=button("clear:Удалить"); %>
	</td>
</tr>
</table>
</form>

<% writeLeafClose(); %>
<script type="text/javascript">updateAllForms();</script>
</body>
</html>
