<% htmlHead("3G Modem"); %>
<script type="text/javascript"><!--
<%
	setMibsVarsAndWriteMibProps("MODEM_ENABLED", "MODEM_PROVIDER_COUNTRY", "MODEM_PROVIDER",
		"MODEM_PIN", "MODEM_PHONE_NUMBER", "MODEM_APN", "MODEM_AUTH_TYPE", "MODEM_USERNAME", "MODEM_PASSWORD",
		"MODEM_ON_DEMAND_ENABLED", "MODEM_MTU_SIZE", "MODEM_IDLE_TIME", "WAN_PING_ENABLED", "UPNP_ENABLED",
		"MODEM_INIT_ATCMDS_ENABLED", "MODEM_INIT_ATCMDS1", "MODEM_INIT_ATCMDS2", "MODEM_INIT_ATCMDS3");
%>

var Rus_presets_tpl = {
	cols: [ 'MODEM_APN', 'MODEM_USERNAME', 'MODEM_PASSWORD', 'MODEM_AUTH_TYPE', 'MODEM_PHONE_NUMBER' ],
	list: { 'Другой':0, 'Билайн':1, 'МегаФон':2, 'МТС':3, 'Скай Линк':4 },
	rows: {
		0: [ '',                    '',        '',         4,   '' ],
		1: [ 'home.beeline.ru',     'beeline', 'beeline',  4, '*99#' ],
		2: [ 'internet',            'gdata',   'gdata',    4, '*99#' ],
		3: [ 'internet.mts.ru',     'mts',     'mts',      4, '*99#' ],
		4: [ null,                  'mobile',  'internet', 4, '#777' ]
	}
},
    Ukr_presets_tpl = {
	cols: [ 'MODEM_APN', 'MODEM_USERNAME', 'MODEM_PASSWORD', 'MODEM_AUTH_TYPE', 'MODEM_PHONE_NUMBER' ],
	list: { 'Другой':0,
		'Киевстар':5, 'Киевстар Контракт':6, 'Киевстар XL':7, 'Киевстар 3G':8,
		'Djuice':9, 'МТС Украина':10 },
	rows: {
		0: [ '',                    '',        '',         4,   '' ],
		5: [ 'www.ab.kyivstar.net', '',        '',         4, '*99#' ],
		6: [ 'www.kyivstar.net',    '',        '',         4, '*99#' ],
		7: [ 'xl.kyivstar.net',     '',        '',         4, '*99#' ],
		8: [ '3g.kyivstar.net',     '',        '',         4, '*99#' ],
		9: [ 'www.djuice.com.ua',   '',        '',         4, '*99#' ],
		10:[ null,                  'mobile',  'internet', 4, '#777' ]
	}
},
    presets_tpls = [ Rus_presets_tpl, Ukr_presets_tpl ],
    providers = [ 0, 0 ];

providers[mib.MODEM_PROVIDER_COUNTRY] = mib.MODEM_PROVIDER;

function update(event, form, type) {
	_(form, "MODEM_PROVIDER_COUNTRY,MODEM_PROVIDER,MODEM_PIN,MODEM_PHONE_NUMBER,MODEM_APN,MODEM_AUTH_TYPE,MODEM_USERNAME,MODEM_PASSWORD,MODEM_ON_DEMAND_ENABLED,MODEM_IDLE_TIME,WAN_PING_ENABLED,UPNP_ENABLED")
		.enable(form.MODEM_ENABLED.checked);
	_("#MODEM").show(form.MODEM_ENABLED.checked);
	_("#IDLE").show(form.MODEM_ON_DEMAND_ENABLED.checked);
	_("#ATCMDS1,#ATCMDS2,#ATCMDS3").show(form.MODEM_INIT_ATCMDS_ENABLED.checked);
	_(form, "MODEM_IDLE_TIME").enable(form.MODEM_ON_DEMAND_ENABLED.checked);

	var init = type === 'init';
	if (init || this.name == 'MODEM_PROVIDER_COUNTRY') {
		var country = form.MODEM_PROVIDER_COUNTRY.value;
		presets.init(form.MODEM_PROVIDER, presets_tpls[country], 
			(init) ? mib.MODEM_PROVIDER :
			providers[country]);
		if (!init)
			presets.select(form, 
				form.MODEM_PROVIDER.value = providers[country], 
				presets_tpls[country]);
	}

	if (init) {
		_("#row_PIN").show(false);

		_(form, "MODEM_PIN")          .setParser("?pin");
		_(form, "MODEM_USERNAME")     .setParser("?ascii");
		_(form, "MODEM_APN")          .setParser("?domain");
		_(form, "MODEM_PHONE_NUMBER") .setParser("phone");
		_(form, "MODEM_PASSWORD")     .setParser("?password");
		_(form, "MODEM_MTU_SIZE")     .setParser("modemmtu");
		_(form, "MODEM_IDLE_TIME")    .setParser("num:1,1000");
		_(form, "MODEM_INIT_ATCMDS1,MODEM_INIT_ATCMDS2,MODEM_INIT_ATCMDS3")
		                              .setParser("?atcmd");

		autoStatus.done = function (text, changed) {
				if (!changed)
					return true;

				var form = document.modem;
				_(form, "save_connect").enable(mib.MODEM_ENABLED != 0 && text != "Connected");
				_(form, "disconnect").enable(text != "Disconnected");
				return true;
			};

		if (mib.MODEM_ENABLED != 0)
			autoStatus.init("modem", "cmd=status", "ppp_status");
		else
			_(form, "save_connect,disconnect").enable(false);
	}

	if (this.name == 'MODEM_PROVIDER') {
		var country = form.MODEM_PROVIDER_COUNTRY.value;
		providers[country] = this.value;
		presets.select(form, this.value, presets_tpls[country]);
	}
}

function save_connect_onclick(event) {
	_(this.form, "save_connect").enable(false);
	var reply = _(this.form).ajaxSubmit();
	if (/ok$/.test(reply)) {
		autoStatus.request("cmd=connect", "Применение настроек...");
	} else {
		autoStatus.message("Submit Failed");
		_(this.form, "save_connect").enable(false);
	}
	return true;
}

function disconnect_onclick(event) {
	autoStatus.request("cmd=disconnect", "Отключение...");
	return true;
}

//--></script>
</head>
<body class="body">
<% writeLeafOpen("Подключение через внешний USB-модем 3G",
	"Для подключения к Интернету укажите параметры, предоставленные"+
	" вашим оператором. Перед установкой USB-модема необходимо отключить на"+
	" установленной в нем SIM- или RUIM-карте запрос PIN-кода при каждом включении."+
	" Это можно сделать в меню любого сотового телефона, временно установив в него"+
	" карту из модема, или в утилите модема, подключив модем к компьютеру."); %>

<% writeFormOpen("modem"); %>
<table class="sublayout part">
<tr>
	<td class='label'></td>
	<td class='field'>
		<%=checkBox("MODEM_ENABLED"); %><label for='MODEM_ENABLED'>Включить модемное соединение</label>
	</td>
</tr>
</table>

<table id="MODEM" class="sublayout part">
<tr>
	<td class='label'>Страна:</td>
	<td class='field'>
		<% writeSelectOpen("MODEM_PROVIDER_COUNTRY"); %>
			<% writeOption("Россия", 0); %>
			<% writeOption("Украина", 1); %>
		</select>
	</td>
</tr>
<tr>
	<td class='label'>Оператор:</td>
	<td class='field'>
		<% writeSelectOpen("MODEM_PROVIDER"); %>
		</select>
	</td>
</tr>
<tr id='row_PIN'>
	<td class='label'>PIN-код:</td>
	<td class='field'>
		<%=inputText("MODEM_PIN", 8, 8); %>
	</td>
</tr>
<tr>
	<td class='label'>Телефонный номер:</td>
	<td class='field'>
		<%=inputText("MODEM_PHONE_NUMBER", 40, 20); %>
	</td>
</tr>
<tr id='cell_MODEM_APN'>
	<td class='label'>Название точки доступа (APN):</td>
	<td class='field'>
		<%=inputText("MODEM_APN", 40, 30); %>
	</td>
</tr>
<tr id='cell_MODEM_AUTH_TYPE'>
	<td class='label'>Метод авторизации:</td>
	<td class='field'><% writeSelectOpen("MODEM_AUTH_TYPE"); %>
		<% writeOption("PAP", 0); %>
		<% writeOption("CHAP", 1); %>
		<% writeOption("CHAP+PAP", 4); %>
	</select></td>
</tr>
<tr>
	<td class='label'>Имя пользователя:</td>
	<td class='field'>
		<%=inputText("MODEM_USERNAME", 40, 63); %>
	</td>
</tr>
<tr>
	<td class='label'>Пароль:</td>
	<td class='field'>
		<%=inputPassword("MODEM_PASSWORD", 40, 63); %>
	</td>
</tr>
<tr>
	<td class='label'></td>
	<td class='field'><%=checkBox("MODEM_ON_DEMAND_ENABLED"); %><label for='MODEM_ON_DEMAND_ENABLED'>Разрывать соединение при простое</label></td>
</tr>
<tr id='IDLE'>
	<td class='label'>Время простоя (мин):</td>
	<td class='field'><%=inputText("MODEM_IDLE_TIME", 10, 8); %></td>
</tr>
<tr>
	<td class='label'></td>
	<td class='field'><%=checkBox("MODEM_INIT_ATCMDS_ENABLED"); %><label for='MODEM_INIT_ATCMDS_ENABLED'>Дополнительные AT команды</label></td>
</tr>
<tr id='ATCMDS1'>
	<td class='label'>AT команды:</td>
	<td class='field'>
		<%=inputText("MODEM_INIT_ATCMDS1", 60, 127); %>
	</td>
</tr>
<tr id='ATCMDS2'>
	<td class='label'></td>
	<td class='field'>
		<%=inputText("MODEM_INIT_ATCMDS2", 60, 127); %>
	</td>
</tr>
<tr id='ATCMDS3'>
	<td class='label'></td>
	<td class='field'>
		<%=inputText("MODEM_INIT_ATCMDS3", 60, 127); %>
	</td>
</tr>
<tr>
	<td class="label">Размер MTU (300&ndash;1500 байт):</td>
	<td><%=inputText("MODEM_MTU_SIZE", 10, 5); %></td>
</tr>
<tr>
	<td class='label'></td>
	<td class='field'><%=button("save_connect:Подключить", "disconnect:Отключить"); %></td>
</tr>
<tr>
	<td class='label'>Состояние подключения:</td>
	<td class='field' id="ppp_status"></td>
</tr>
<tr>
	<td class='label'></td>
	<td class='field'><%=checkBox("WAN_PING_ENABLED"); %><label for='WAN_PING_ENABLED'>Отвечать на ping-запросы из Интернета</label></td>
</tr>
<tr>
	<td class='label'></td>
	<td class='field'><%=checkBox("UPNP_ENABLED"); %><label for='UPNP_ENABLED'>Разрешить UPnP</label></td>
</tr>
</table>

<table class="sublayout">
<tr>
	<td class='label'></td>
	<td class='submit'>
		<%=submit("Применить");%>
	</td>
</tr>
</table>
</form>
<% writeLeafClose(); %>
<script type="text/javascript">updateAllForms();</script>
</body>
</html>
