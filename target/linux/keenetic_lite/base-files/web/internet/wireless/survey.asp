<% htmlHead("Обзор доступных сетей Wi-Fi"); %>
<style type='text/css'>
img.lock {
}
</style>
<!--[if lte IE 6]>
	<style type="text/css">
		img { behavior: url(/js/iepngfix.htc); }
	</style>
<![endif]-->
<script type="text/javascript"><!--
<%
	setMibsVarsAndWriteMibProps("WLAN_ENABLED");
	ssid = auth = encrypt = '';
%>

var survey = {
    auth_types: {
				"OPEN": "WEP", 
				"SHARED": "WEP",
				"AUTOWEP": "WEP",
				"WPA": "",
				"WPAPSK": "WPA",
				"WPANONE": "WPA",
				"WPA2": "",
				"WPA2PSK": "WPA2",
				"WPA1-2": "",
				"WPAPSK1-2": "WPA1/2"
			},

	simple_auth: function (auth) {
			return this.auth_types[auth];
		},

	template: {
		table: { className: 'log', id: 'survey_table' },
		th:    { className: "list"},
		td:    {
				className: "list",
				style: {
						whiteSpace:"nowrap"
					},
				innerHTML: "@" 
			},
		empty: { className: "empty", innerHTML: "Поиск..." },
		tr: { className: function(row) {
				return [
						row.className, 
						(!this.row_data.mode) ? "" : "point",
						(this.row_data.con) ? "highlighted" : ""
					].join(' '); }
			},

		cols: {
				select:  {
						th: { innerHTML: "&nbsp;" },
						td: { innerHTML: function (cell) {
								return (!this.row_data.mode) ?
									'' :
									[	"<input type='radio' class='radio' name='ap' value='",
										this.row_index, 
										"'",
										this.row_data.con ? " checked='checked'":"",
										"/>"
									].join(''); }
							}
					},
				privacy: {
							th: { innerHTML: "<img src='/i/ic_lock.png' class='lock'/>" },
							td: { innerHTML: function (cell) {
									  return this.value ? ["<img src='/i/ic_lock.png' class='lock'/> ",_l(survey.simple_auth(this.row_data.auth))].join('') : ""; } 
								 }
					},
	/*			mode:    {
						th: { innerHTML: "Режим" },
						td: { innerHTML: function (cell)
								{ return this.value ? "Infra" : "Ad-hoc"; }
							}
					},
					*/
					
				ssid:    { th: { innerHTML: "Имя сети (SSID)" } },
				type:    {
						th: { innerHTML: "Wi-Fi" },
						td: { innerHTML: function (cell) { return this.value.split('').join('/'); } }
					},
				qual:    {
						th: { innerHTML: "Качество" },
						td: { innerHTML: "", className: "list_border gauge",
								g: function(cell) {
										cell.appendChild(Funs.gauge(this.value, 100, 7, .9, '_warm'));
										return null;
									}
						    }
					},
									chan:    {
						th: { innerHTML: "Канал" },
						td: { className: "empty" }
					},
				/*rssi:    {
						th: { innerHTML: "Level" },
						td: { innerHTML: "@ dBm" }
					},*/
				mac:     { th: { innerHTML: "MAC-адрес" } }
			}
		},

	ajax: null,
	ontimer: function () {
			var it = this;
			if (!it.lock) {
				++it.lock;
				it.req();
			}
		},

	onstate: function (event) {
			var it = survey,
			    aj = it.ajax;

			if (aj.readyState == 4) {
				if(aj.status == 200) {
					it.data = eval("(" + aj.responseText + ")"),
					it.renderAll();
				}

				it.ajax = null;
				it.lock = 0;
			}
		},

	req: function () {
			if (this.ajax !== null)
				this.ajax.abort();

			var aj = this.ajax = new ajaxObject();
			aj.onreadystatechange = this.onstate;
			aj.open("GET", this.url, true);
			aj.setRequestHeader("If-Modified-Since", "Sat, 1 Jan 1996 00:00:00 GMT");
			aj.send(null);
		},

	autoRefresh: function (interval) {
			if (this.timer)
				clearInterval(this.timer);
			this.timer = interval != 0 ? setInterval("survey.ontimer();", interval*100) : 0;
		},

	renderAll: function () {
			this.data.sort(function (l, r) {
					return r.rssi - l.rssi;
				});

			$('content').html(Table.toDOM(this.data, this.template));

			$('survey_table').byTag('tr')
				.shift()
				.setEvents({
						click:    this.onSelect,
						dblclick: this.onDblClick
					});
			postponeValidation(document.wlanSiteSelect);
		},

	onSelect: function (event) {
			var sel = this.firstChild.firstChild;
			return (sel) ? sel.checked = 1 : false;
		},

	onDblClick: function (event) {
			if (survey.onSelect.apply(this, arguments))
				document.wlanGo.save.click();
		}
};

function update(event, form, type) {
	switch (form.name) {
	case 'wlanGo':
		if (type === 'init') {
			_(form, "refresh")
				.enable(mib.WLAN_ENABLED);
			_(form, "connect")
				.enable(mib.WLAN_ENABLED && _(document.wlanSiteSelect, "ap").length != 0 );
		}
	}
}

function submit(event) {
	if (this.name != 'wlanGo')
		return false;

	var form = document.wlanSiteSelect,
	    index = $(form.ap).getRadioValue(),
	    elSsid = this.ssid,
	    elAuth = this.auth,
	    elEncrypt = this.encrypt;

	elSsid.value = survey.data[index].ssid;
	elAuth.value = survey.data[index].auth;
	elEncrypt.value = survey.data[index].encrypt;
	return true;
}

--></script>
</head>
<body class="body">
<% writeLeafOpen("Обзор доступных сетей Wi-Fi",
	"Можно просмотреть список доступных в настоящий момент точек доступа и выбрать "+
	"одну из них для подключения. Для каждой точки доступа приводится тип применяемой "+
	"защиты, имя сети (SSID), стандарт Wi-Fi, качество связи с ней, номер используемого "+
	"канала и ее MAC-адрес."); %>

<% writeFormOpen("wlanSiteSelect"); %>
<%=hidden("ssid");%>
<%=hidden("auth");%>
<%=hidden("encrypt");%>

<table class="sublayout">
<tr><td><div id='content' class='log_place'></div></td></tr>
</table>
</form>

<% writeFormOpen("wlanGo", "method='get' action='/internet/wireless/security.asp'"); %>
<table class="sublayout">
<tr><td class="submit">
		<%=hidden("ssid");%>
		<%=hidden("auth");%>
		<%=hidden("encrypt");%>
		<input type="button" name="refresh" value="Обновить" onclick="survey.renderAll('[]'); survey.req();"/>
		<%=submitButton("save:Подключиться");%>
</td></tr>
</table>
</form>
<% writeLeafClose(); %>

<script type="text/javascript"><!--
(function (obj,url,data) {
	updateAllForms();
	obj.url = url;
	obj.data = data;
	obj.renderAll();
	obj.req();
	//obj.autoRefresh(50);
})(survey, '/req/staSurvey', []);
--></script>
</body>
</html>
