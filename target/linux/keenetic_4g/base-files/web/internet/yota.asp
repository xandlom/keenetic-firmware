<% htmlHead("Yota Internet 4G"); %>
<script type='text/javascript' src='/js/status.js?=<%=rvsn();%>'></script>
<script type="text/javascript"><!--
<% setMibsVars("DEVICE_NAME"); %>
controller.query = '/req/yota';
controller.labels = {
	wimax_state: "WiMAX-подключение",
	wimax_model: "Модель модема",
	wimax_fwver: "Версия ПО модема",

	SSID: 'Имя сети (SSID)',

	ap_mac:  "MAC-адрес станции",
	if_mac:  "MAC-адрес модема",

	if_ip:      "IP-адрес",
	if_mask:    "Маска подсети",
	if_gw:      "Шлюз",

	qual:   "CINR",
	level:  "RSSI",

	linktime:   "Длительность",

	tx:      "Передано",
	rx:      "Принято",
};

formatter.cinr = function(i) {
	var cinr = Math.round(i/40);
	return [cinr, 'дБ'].join(' ');
};

controller.formatters = {
	wimax_state:formatter.lang,
	linktime: formatter.uptime,
	tx:       formatter.sizenspeed,
	rx:       formatter.sizenspeed,
	tx_:       formatter.shortsize,
	rx_:       formatter.shortsize,
	qual:     formatter.cinr,
	level:    formatter.dbm_level,
	noise:    formatter.dbm_level
};

controller.renderAll = function (text) {
	var data = eval("(" + text + ")");

	this.formatData(data, "", "");

	var infoRow = $("stat_row").el;

	this.td = infoRow.insertCell(1);

	this.renderNets(data);

	infoRow.deleteCell(2);
};

controller.renderNets = function (data) {
	var leaf = new statusLeaf(""),
	    wimax = data.WiMAX;

	if (1) {
/*
		leaf.addFields("", {
			'WiMAX': {
				'wireless': 'SSID', 'if_mac':'', 'wireless':'ap_mac',
				'net': {'if_ip':'', 'if_mask':'', 'if_gw':'' } },
			'DNS':'#',
			'WiMAX': {
				'wireless': {
					qual: '', level: '' },
				'stat': '*' }
			], data);
*/
		if ('wimax_state' in wimax)
			leaf.addField("", "wimax_state", wimax.wimax_state);

		if ('wireless' in wimax) {
			if ('wimax_model' in wimax.wireless)
				leaf.addField("", "wimax_model", wimax.wireless.wimax_model);

			if ('wimax_fwver' in wimax.wireless)
				leaf.addField("", "wimax_fwver", wimax.wireless.wimax_fwver);

			if ('wimax_status' in wimax.wireless)
				leaf.addField("", "wimax_status", wimax.wireless.wimax_status);

			if ('SSID' in wimax.wireless)
				leaf.addField("", "SSID", wimax.wireless.SSID);
		}

		if ('if_mac' in wimax)
			leaf.addField("", "if_mac", wimax.if_mac);

		if ('wireless' in wimax) {
			if ('ap_mac' in wimax.wireless)
				leaf.addField("", "ap_mac", wimax.wireless.ap_mac);
		}
	
		if ('net' in wimax) {
			if ('if_ip' in wimax.net)
				leaf.addField("", "if_ip", wimax.net.if_ip);
			if ('if_mask' in wimax.net)
				leaf.addField("", "if_mask", wimax.net.if_mask);
			if ('if_gw' in wimax.net)
				leaf.addField("", "if_gw", wimax.net.if_gw);
		}
	
		if ('DNS' in data) {
		    var dns = data.DNS;
			for (var idx = 0; idx < dns.length; ++idx)
				leaf.addField("", "DNS "+(idx+1), dns[idx]);
		}

		if ('wireless' in wimax) {
			if ('qual' in wimax.wireless)
				leaf.addField("", "qual",  wimax.wireless.qual);
			if ('level' in wimax.wireless)
				leaf.addField("", "level", wimax.wireless.level);
		}
	
		if ('linktime' in wimax)
			leaf.addField("", "linktime", wimax.linktime);

		if ('stat' in wimax) {
			if ('tx' in wimax.stat) {
				leaf.addField("", "tx", wimax.stat.tx);
				leaf.addField("", "rx", wimax.stat.rx);
			}
			if ('tx_' in wimax.stat) {
				leaf.addField("", "tx", wimax.stat.tx_);
				leaf.addField("", "rx", wimax.stat.rx_);
			}
		}
	} else {
		leaf.addBreak(_l("Device is not connected"));
	}

	leaf.finish();
	this.td.appendChild(leaf.tbl);
};

controller.renderDNS = function (data) {
	var leaf = new statusLeaf( this.getLabel("DNS") );
	for (var idx = 1; idx <= data.length; ++idx)
		leaf.addRow( _l("Server")+" "+idx+":", data[idx-1] );
	this.td.appendChild(leaf.tbl);
};

--></script>
</head>
<body class="body">
<% writeLeafOpen("Yota Internet 4G"); %>

<table class="sublayout">
	<tr id='stat_row'>
		<td style='width:30%; vertical-align: middle; text-align: center; padding: 10px 0px 0px 0px'>
			<div style=''>
				<p><a target='_blank' href='http://yota.ru/'><img src='/i/yota.png'/></a></p>
				<p><a target='_blank' href='http://yota.ru/'>www.yota.ru</a></p>
				<p><a target='_blank' href='mailto:support@yotateam.com'>support@yotateam.com</a></p>
				<p>8 800 700 55 00</p>
			</div>
		</td>
		<td></td>
		<td style='width:20%'></td>
	</tr>
	<tr>
		<td class='submit' colspan='3'>
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
	obj.query = '/req/yota';
	obj.renderAll(decodeURIComponent(text));
	obj.autoRefresh(obj.restoreRefresh());
})(controller, "<% write(encodeURI(getYotaProps())); %>");
--></script>
</body>
</html>
