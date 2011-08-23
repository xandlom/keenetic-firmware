<% htmlHead("Таблица активных соединений"); %>
<script type="text/javascript"><!--
var clients = {
	template: {
		table: { className: 'list', style: { width: '98%', marginLeft: '1%' } },
		th:    { className: "list" },
		td:    {
				className: "list",
				innerHTML: "@" 
			},
		empty: { className: "empty", innerHTML: _l("no clients yet") },

		cols: {
				id: { th: { innerHTML: "&nbsp;", style: { width: "0.5em" } } },
				mac: { th: { innerHTML: "MAC-адрес", style: { width: "9em" } } },
				ip: {
						th: { innerHTML: "IP-адрес", style: { width: "7em" } },
						td: { innerHTML: function(cell) {
								return this.value.length == 0 ?
									_m('inactive') : 
									this.value.join(', '); }
							}
					},
				host: { th: { innerHTML: "Имя", style: { width: "7em" }} },
				rssi: {
						th: { innerHTML: "Сигнал", className: "numeric", style: { width: "3em" } },
						td: { innerHTML: ["@<small>&nbsp;", _l("dBm"), "</small>"].join(''),
							className: "numeric nowrap" }
					},
				mode: {
						th: { innerHTML: "Ст-рт", style: { width: "3em" } },
						td: { innerHTML: "11@", className: "empty nowrap" }
					},
				bw: {
						th: { innerHTML: "Диап.", style: { width: "3em" } },
						td: { innerHTML: function(cell) {
									return this.row_data.mode == 'n' ? [this.value, "<small>&nbsp;", _l("mHz"), "</small>"].join('') : "-"; },
							className: "empty nowrap" }
					},
				rate: {
						th: { innerHTML: _l("Mbit/sec"), className: "numeric", style: { width: "3em" } },
						td: { innerHTML: function (cell) {
								return [this.value / 10].join(' '); },
							className: "numeric" }
					},
				time: {
						th: { innerHTML: "Соединен" },
						td: { innerHTML: function (cell)
											{ return Fmt.uptime(this.value); },
									className: "list nowrap"
							}
					}/*,
				sel: {
						th: { innerHTML: "&nbsp;" },
						td: { innerHTML: function (cell) {
								return [
									"<input class='flat' type='button' name='",
									this.row_idx,
									"' value='+' style='padding: 0 !important;'/>"].join(''); }
							}
					}*/
			}
		},

	ajax: null,
	ontimer: function() {
			var it = this;
			if (!it.lock) {
				++it.lock;
				it.req();
			}
		},

	onstate: function(event) {
			var it = clients,
			    aj = it.ajax;

			if (aj.readyState == 4) {
				if(aj.status == 200)
					it.renderAll(aj.responseText);

				it.ajax = null;
				it.lock = 0;
			}
		},

	req: function() {
			if (this.ajax !== null)
				this.ajax.abort();

			var aj = this.ajax = new ajaxObject();
			aj.onreadystatechange = this.onstate;
			aj.open("GET", this.url, true);
			aj.setRequestHeader("If-Modified-Since", "Sat, 1 Jan 1996 00:00:00 GMT");
			aj.send(null);
		},

	restoreRefresh: function() {
			var el = $('interval').el,
			    interval = el.value,
			    cookie_interval = document.cookie.match('(?:^|;)\\s*interval=([^;]*)');

			if (cookie_interval) {
				var interval = decodeURIComponent(cookie_interval[1]);
				el.value = interval;
			}
			return interval;
		},

	autoRefresh: function(interval) {
			if (this.timer)
				clearInterval(this.timer);
			document.cookie = 'interval='+encodeURIComponent(interval);
			this.timer = interval != 0 ? setInterval("clients.ontimer();", interval*100) : 0;
		},

	renderAll: function(text) {
			var tbl = eval("(" + text + ")");
			//tbl.sort(function(l,r) {
				//return (l.ip.length ? IP.parse(l.ip[0]) : 0) > (r.ip.length ? IP.parse(r.ip[0]) : 0); });
			$("content").html(
				Table.toDOM(tbl, this.template));
		}
};

//--></script>
</head>

<body class="body">
<% writeLeafOpen("Таблица активных соединений", 
	"Можно просмотреть список клиентов, соединенных с точкой доступа в настоящий момент."); %>

<table class="sublayout">
<tr><td id="content"></td></tr>
<tr>
	<td class="submit">
			Период обновления: <select id='interval' onchange='clients.autoRefresh(this.value);' onkeyup='clients.autoRefresh(this.value);'>
				<option value='5'>0,5 с</option>
				<option value='10'>1 с</option>
				<option value='20'>2 с</option>
				<option value='50' selected='selected'>5 с</option>
				<option value='100'>10 с</option>
				<option value='300'>30 с</option>
				<option value='0'>Никогда</option>
			</select>
		<input type="button" name="refresh_status" value="Обновить" onclick="clients.req();"/>
	</td>
</tr>
</table>
<% writeLeafClose(); %>
<script type="text/javascript"><!--
(function(obj,url,text) {
	obj.url = url;
	obj.renderAll(text);
	obj.autoRefresh(obj.restoreRefresh());
})(clients, '/req/apClients', "<% writeApClientsList(); %>");
--></script>
</body>
</html>
