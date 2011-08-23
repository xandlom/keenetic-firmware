<% htmlHead("Настройки безопасности Wi-Fi"); %>
<script type="text/javascript" src="/js/md5.js?=<%=rvsn();%>"></script>
<!--[if IE]>
	<style type="text/css">
		.openpass { display: none; }
	</style>
<![endif]-->
<script type="text/javascript"><!--
<%
	setMibsVars(
		"WLAN_AP_AUTH_TYPE", "WLAN_AP_ENCRYPT_TYPE",
		"WLAN_AP_WEP_KEY_INDEX",
		"WLAN_AP_WEP_KEY1", "WLAN_AP_WEP_KEY1_FORMAT", 
		"WLAN_AP_WEP_KEY2", "WLAN_AP_WEP_KEY2_FORMAT", 
		"WLAN_AP_WEP_KEY3", "WLAN_AP_WEP_KEY3_FORMAT", 
		"WLAN_AP_WEP_KEY4", "WLAN_AP_WEP_KEY4_FORMAT",
		"WLAN_AP_WPA_PSK",  "WLAN_AP_WPA_PSK_FORMAT" );

	var authClass = 0;
	var wepBits = 0;

	if (WLAN_AP_AUTH_TYPE > 0) 
		authClass = 1; 	
	if (WLAN_AP_AUTH_TYPE > 2)
		authClass = 2;

	if (authClass == 1)
		if (WLAN_AP_ENCRYPT_TYPE == 1)
			wepBits = 64;
		else
			wepBits = 128;

	var WLAN_AP_WEP_ENCRYPT_TYPE = WLAN_AP_ENCRYPT_TYPE;
	var WLAN_AP_WPA_ENCRYPT_TYPE = WLAN_AP_ENCRYPT_TYPE;

	if (WLAN_AP_ENCRYPT_TYPE >= 3)
		WLAN_AP_WEP_ENCRYPT_TYPE = 2;

	if (WLAN_AP_ENCRYPT_TYPE < 3 && WLAN_AP_ENCRYPT_TYPE >= 1)
		WLAN_AP_WPA_ENCRYPT_TYPE = 5;

	WLAN_AP_WEP64_KEY1 = 
	WLAN_AP_WEP64_KEY2 = 
	WLAN_AP_WEP64_KEY3 = 
	WLAN_AP_WEP64_KEY4 = 
	WLAN_AP_WEP128_KEY1 = 
	WLAN_AP_WEP128_KEY2 = 
	WLAN_AP_WEP128_KEY3 = 
	WLAN_AP_WEP128_KEY4 = "";
	WLAN_AP_WEP64_KEY_INDEX = 
	WLAN_AP_WEP128_KEY_INDEX = 1;

	if (!wepBits) {
		var keylen = strlen(WLAN_AP_WEP_KEY1);
		if (keylen < 11) {
			if (keylen == 5 || keylen == 10)
				wepBits = 64;
		} else {
			if (keylen == 13 || keylen == 26)
				wepBits = 128;
		}
	}

	if (wepBits == 64) {
		WLAN_AP_WEP64_KEY1 = WLAN_AP_WEP_KEY1;
		WLAN_AP_WEP64_KEY2 = WLAN_AP_WEP_KEY2;
		WLAN_AP_WEP64_KEY3 = WLAN_AP_WEP_KEY3;
		WLAN_AP_WEP64_KEY4 = WLAN_AP_WEP_KEY4;
		WLAN_AP_WEP64_KEY_INDEX = WLAN_AP_WEP_KEY_INDEX;
	}

	if (wepBits == 128) {
		WLAN_AP_WEP128_KEY1 = WLAN_AP_WEP_KEY1;
		WLAN_AP_WEP128_KEY2 = WLAN_AP_WEP_KEY2;
		WLAN_AP_WEP128_KEY3 = WLAN_AP_WEP_KEY3;
		WLAN_AP_WEP128_KEY4 = WLAN_AP_WEP_KEY4;
		WLAN_AP_WEP128_KEY_INDEX = WLAN_AP_WEP_KEY_INDEX;
	}

	if (WLAN_AP_WPA_PSK_FORMAT) {
		WLAN_AP_WPA_PSK_hex = "";
		WLAN_AP_WPA_PSK_passphrase = WLAN_AP_WPA_PSK;
	} else {
		WLAN_AP_WPA_PSK_hex = WLAN_AP_WPA_PSK;
		WLAN_AP_WPA_PSK_passphrase = "";
	}

	WLAN_AP_WEP64_KEY = 
	WLAN_AP_WEP128_KEY = 
	WLAN_AP_WPA_PSK_pp_show = 0;
%>
var NONE = 0, WEP = 1, WPA = 2;
var HEX = 0, ASCII = 1;

function getAuthClass(form) {
	return [ NONE, WEP, WEP, WPA, WPA, WPA ][form.WLAN_AP_AUTH_TYPE.value];
}

function wepkey64(val)
{
	var pseed  = [ 0, 0, 0, 0 ],
	    k64 = [ "", "", "", "" ],
	    randNumber, i, j;

	for (i = 0; i < val.length; ++i)
		pseed[i%4] ^= val.charCodeAt(i);

	randNumber = pseed[0] | (pseed[1] << 8) | (pseed[2] << 16) | (pseed[3] << 24);
	for (i = 0; i < 4; ++i)
		for (j = 0; j < 5; ++j) {
			randNumber = (randNumber * 0x343fd + 0x269ec3) & 0xffffffff;
			k64[i] += (((randNumber >> 16) & 0xff) + 256).toString(16).substr(1).toUpperCase();
		}
	return k64;
}

function genWep64Key(event)
{
	var form = this.form;
	var pass = this.previousSibling.value;

	_(form, "/^WLAN_AP_WEP64_KEY\\d$")
		.setValues(wepkey64(pass));

	_(form.WLAN_AP_WEP64_KEY_INDEX, "=1")
		.select(true);

	initForm(form);
}

function padPass(str) {
	var pad = str ? str : (str='*');
	while (pad.length < 64)
		pad += str;
	return pad.substr(0, 64);
}

function genWep128Key(event)
{
	var form = this.form;
	var pass = this.previousSibling.value;

	_(form, "/^WLAN_AP_WEP128_KEY\\d$")
		.setValue(
			hex_md5(padPass(pass)).substr(0, 26).toUpperCase());

	_(form.WLAN_AP_WEP128_KEY_INDEX, "=1")
		.select(true);

	initForm(form);
}

var reIs128 = /128/;
var CLASS = {
	KEY  : "key",
	DEF  : "default" };

function updateDefaultKey(event) {
	var form = this.form;
	_(form, "/^WLAN_AP_WEP\\d+_KEY_INDEX")
		.each(function (el, i, form) {
				form.elements[el.name.replace("_INDEX", el.value)]
					.className = el.checked ? CLASS.DEF : CLASS.KEY;
			}, form);
}

function validateKey() {
	var form = this.element.form;
	var format = form[this.element.name+"_FORMAT"];
	var keyLen  = reIs128.test(this.element.name) ? [ 26, 13 ] : [ 10, 5 ];

	var value = this.value;
	var length = this.value.length;
	var ishex = regexes.hex.test(value);

	

	
	if (0 < length && length < keyLen[ASCII])
		if (ishex)
			return this.error("требуется "+keyLen[ASCII]+" знаков ASCII или "+keyLen[HEX]+" знаков HEX");
		else
			return this.error("требуется "+keyLen[ASCII]+" знаков ASCII");

	if (keyLen[ASCII] < length && length < keyLen[HEX])
		return this.error( ishex ? "требуется " +keyLen[HEX]+" знаков HEX" : "слишком длинный ASCII-ключ" );

	if (keyLen[ASCII] == length) {
		format.value = ASCII;
		return this.ok("ASCII");
	}

	if (keyLen[HEX] == length) {
		format.value = HEX;
		if (ishex)
			return this.ok("HEX");

		return this.error( "слишком длинный ASCII-ключ");
	}

	return this.error("required");
}

function _isPassphraseOk(value) {
	var err = "";
	if (value.length == 0)
		err = " can't be empty";
	else
		if (!/^[\x20-\x7F]+$/i.test(value))
			err = "должен содержать только ASCII-символы";

	return err;
}

function ppUpdate(event) {
	this.nextSibling
		.disabled = _isPassphraseOk(this.value) != "";
	return true;
}

function ppPress(event) {
	event = event||window.event;
	if (event.keyCode && event.keyCode == 13) {
		if (!this.nextSibling.disabled)
			_(this.nextSibling)
				.trigEvent("click");
		event.returnValue = false;
		return false;
	}
	return true;
}

function ppFocus(event) {
	event = event||window.event;
	var focus = event.type == "focus";
	this.nextSibling.style.fontWeight = focus ? 'bold' : "";
	_(this)
		.trigEvent("keyup");
	return true;
}

function update(event, form, type) {
	var ac = getAuthClass(form);
	var toWEP = (ac == WEP);
	var toWPA = (ac == WPA);
	var wepBits = !toWEP ? 0 : [ 64, 128 ][form.WLAN_AP_WEP_ENCRYPT_TYPE.selectedIndex];
	var wpa_ascii = form.WLAN_AP_WPA_PSK_FORMAT.value;

	_(form, "/^WLAN_AP_WEP_")  .enable(toWEP);
	_(form, "/^WLAN_AP_WEP64") .enable(wepBits == 64);
	_(form, "/^WLAN_AP_WEP128").enable(wepBits == 128);
	_(form, "/^WLAN_AP_WPA_")  .enable(toWPA);

	_("#WPA")    .show(toWPA);
	_("#WEP")    .show(toWEP);
	_("#WEP")    .show(toWEP);
	_("#WEP64")  .show(wepBits == 64);
	_("#WEP128") .show(wepBits == 128);
	//_("#WPS_WAP") .show(toWEP);

	_("#WPA_HEX")        .show(toWPA && wpa_ascii == 0);
	_("#WPA_PASSPHRASE") .show(toWPA && wpa_ascii == 1);

	_(form, "WLAN_AP_WPA_PSK_hex")        .enable(toWPA && wpa_ascii == 0);
	_(form, "WLAN_AP_WPA_PSK_passphrase") .enable(toWPA && wpa_ascii == 1);
	

		
	if (type === 'init') {
		_(form, "/^WLAN_AP_WEP\\d+_KEY\\d$")
			.setParser("ascii", validateKey);

		_(form, "/^WLAN_AP_WEP\\d+_KEY_INDEX")
			.setAttrs( { title: "default key selection" } )
			.setEvents( { click: updateDefaultKey } )
			.trigEvent("click");

		_(form, "/^WEP\\d+_pass")
			.setEvents( {
				keyup: ppUpdate,
				keydown: ppPress,
				focus: ppFocus,
				blur:  ppFocus } )
			.each(function (el, i, form) {
					el.submit = el.nextSibling.id;
				}, form)
			.trigEvent("keyup");

		_(form, "WLAN_AP_WPA_PSK_passphrase")
			.setParser("psk_passphrase");

		_(form, "WLAN_AP_WPA_PSK_hex")
			.setParser("psk_hex");
	}

	if (!browser.isIE) {
		_(form, "/^WLAN_AP_WEP64_KEY\\d$")
			.setAttrs({
				type: ((form.WLAN_AP_WEP64_show_keys.checked) ? 'text' : 'password')
			});

		_(form, "/^WLAN_AP_WEP128_KEY\\d$")
			.setAttrs({
				type: ((form.WLAN_AP_WEP128_show_keys.checked) ? 'text' : 'password')
			});

		_(form, "WLAN_AP_WPA_PSK_passphrase")
			.setAttrs({
				type: ((form.WLAN_AP_WPA_PSK_pp_show.checked) ? 'text' : 'password')
			});
	}
}

function submit(event) {

	var form = this;
	var ac = getAuthClass(form);
	var toWEP = (ac == WEP);
	var toWPA = (ac == WPA);
	var wepBits = !toWEP ? 0 : [ -1, 0, 1 ][form.WLAN_AP_WEP_ENCRYPT_TYPE.value];

	WLAN_AP_ENCRYPT_TYPE = 0;

	if (toWEP)
		WLAN_AP_ENCRYPT_TYPE = form.WLAN_AP_WEP_ENCRYPT_TYPE.options[form.WLAN_AP_WEP_ENCRYPT_TYPE.selectedIndex].value;

	if (toWPA)
		WLAN_AP_ENCRYPT_TYPE = form.WLAN_AP_WPA_ENCRYPT_TYPE.options[form.WLAN_AP_WPA_ENCRYPT_TYPE.selectedIndex].value;

	form.WLAN_AP_ENCRYPT_TYPE.value = WLAN_AP_ENCRYPT_TYPE;

	if (wepBits >= 0) {

		form.WLAN_AP_WEP_KEY_INDEX.value =
			$(!wepBits ? form.WLAN_AP_WEP64_KEY_INDEX : form.WLAN_AP_WEP128_KEY_INDEX).getRadioValue();

		_(form, "/^WLAN_AP_WEP_KEY\\d")
			.setValues(
				_(form, !wepBits ? "/^WLAN_AP_WEP64_KEY\\d" : "/^WLAN_AP_WEP128_KEY\\d")
					.getValues());
	}

	form.WLAN_AP_WPA_PSK.value = 
		( form.WLAN_AP_WPA_PSK_FORMAT.value == 0 ?
			form.WLAN_AP_WPA_PSK_hex :
			form.WLAN_AP_WPA_PSK_passphrase
		).value;

	return true;
}

//--></script>
</head>

<body class="body">
<% writeLeafOpen("Настройки безопасности Wi-Fi",
	"К незащищенной точке доступа может подключиться любой желающий, находясь в "+
	"радиусе ее действия. Если вы не планируете создавать открытую беспроводную сеть, "+
	"используйте максимальную защиту WPA2. Проверку подлинности Open, Shared или WPA-PSK "+
	"используйте только при необходимости подключения устаревших устройств, не "+
	"поддерживающих WPA2."); %>
	
<% writeFormOpen("wlanApSecurity"); %>
<div class="none"><% write(hidden("WLAN_AP_ENCRYPT_TYPE")); 
	write(hidden("WLAN_AP_WEP_KEY_INDEX"));
	/* order of the fields should be same as in form!!! */
	write(hidden("WLAN_AP_WEP_KEY1_FORMAT"));
	write(hidden("WLAN_AP_WEP_KEY1"));
	write(hidden("WLAN_AP_WEP_KEY2_FORMAT"));
	write(hidden("WLAN_AP_WEP_KEY2"));
	write(hidden("WLAN_AP_WEP_KEY3_FORMAT"));
	write(hidden("WLAN_AP_WEP_KEY3"));
	write(hidden("WLAN_AP_WEP_KEY4_FORMAT"));
	write(hidden("WLAN_AP_WEP_KEY4"));
	write(hidden("WLAN_AP_WPA_PSK")); %></div>
<table class="sublayout">
<tr>
	<td class='label'>Проверка подлинности:</td>
	<td class='field'>
		<% writeSelectOpen("WLAN_AP_AUTH_TYPE"); %>
			<% writeOption("Не использовать", 0); %>
			<% writeOption("Open", 1); %>
			<% writeOption("Shared", 2); %>
			<% writeOption("WPA-PSK", 3); %>
			<% writeOption("WPA2-PSK", 4); %>
			<% writeOption("WPA-PSK/WPA2-PSK", 5); %>
		</select>
		<!--span class="warning" id="WPS_WAP"> (технология WPS не работает с защитой WEP)</span-->
	</td>
</tr>
</table>

<table id="WEP" class="sublayout part">
<tr>
	<td class='label'>Тип защиты:</td>
	<td class='field'>
		<% writeSelectOpen("WLAN_AP_WEP_ENCRYPT_TYPE"); %>
			<% writeOption("WEP 64", 1); %>
			<% writeOption("WEP 128", 2); %>
		</select>
	</td>
</tr>
</table>

<table id="WEP128" class="sublayout part">
<tr><% keyLength = 26; keySize = 33; %>
	<td class='label'>Ключ 1:</td>
	<td class='field'><%
		write(radio("WLAN_AP_WEP128_KEY_INDEX", 1),
			hidden("WLAN_AP_WEP128_KEY1_FORMAT"),
			inputText("WLAN_AP_WEP128_KEY1", keySize, keyLength));
	%></td>
</tr>
<tr>
	<td class='label'>Ключ 2:</td>
	<td class='field'><%
		write(radio("WLAN_AP_WEP128_KEY_INDEX", 2),
			hidden("WLAN_AP_WEP128_KEY2_FORMAT"),
			inputText("WLAN_AP_WEP128_KEY2", keySize, keyLength));
	%></td>
</tr>
<tr>
	<td class='label'>Ключ 3:</td>
	<td class='field'><%
		write(radio("WLAN_AP_WEP128_KEY_INDEX", 3),
			hidden("WLAN_AP_WEP128_KEY3_FORMAT"),
			inputText("WLAN_AP_WEP128_KEY3", keySize, keyLength));
	%></td>
</tr>
<tr>
	<td class='label'>Ключ 4:</td>
	<td class='field'><%
		write(radio("WLAN_AP_WEP128_KEY_INDEX", 4),
			hidden("WLAN_AP_WEP128_KEY4_FORMAT"),
			inputText("WLAN_AP_WEP128_KEY4", keySize, keyLength));
	%></td>
</tr>
<tr class='openpass'>
	<td class='label'></td>
	<td class='field'>
		<%=checkBox("WLAN_AP_WEP128_show_keys"); %><label for='WLAN_AP_WEP128_show_keys'>Показать ключи</label>
	</td>
</tr>
<tr>
	<td class='label'>Ключевая фраза:</td>
	<td class='field'>
		<input type='text' name="WEP128_passphrase" size='32' maxlength='64'
		/><input type='button' name="WEP128_genkeys" value="Создать WEP-ключи" id="g128" onclick="genWep128Key.call(this,event)" disabled="disabled"/>
	</td>
</tr>
</table>

<table id="WEP64" class="sublayout part">
<tr><% keyLength = 10; keySize = 33; %>
	<td class='label'>Ключ 1:</td>
	<td class='field'><%
		write(radio("WLAN_AP_WEP64_KEY_INDEX", 1),
			hidden("WLAN_AP_WEP64_KEY1_FORMAT"),
			inputText("WLAN_AP_WEP64_KEY1", keySize, keyLength));
	%></td>
</tr>
<tr>
	<td class='label'>Ключ 2:</td>
	<td class='field'><%
		write(radio("WLAN_AP_WEP64_KEY_INDEX", 2),
			hidden("WLAN_AP_WEP64_KEY2_FORMAT"),
			inputText("WLAN_AP_WEP64_KEY2", keySize, keyLength));
	%></td>
</tr>
<tr>
	<td class='label'>Ключ 3:</td>
	<td class='field'><%
		write(radio("WLAN_AP_WEP64_KEY_INDEX", 3),
			hidden("WLAN_AP_WEP64_KEY3_FORMAT"),
			inputText("WLAN_AP_WEP64_KEY3", keySize, keyLength));
	%></td>
</tr>
<tr>
	<td class='label'>Ключ 4:</td>
	<td class='field'><%
		write(radio("WLAN_AP_WEP64_KEY_INDEX", 4),
			hidden("WLAN_AP_WEP64_KEY4_FORMAT"),
			inputText("WLAN_AP_WEP64_KEY4", keySize, keyLength));
	%></td>
</tr>
<tr class='openpass'>
	<td class='label'></td>
	<td class='field'>
		<%=checkBox("WLAN_AP_WEP64_show_keys"); %><label for='WLAN_AP_WEP64_show_keys'>Показать ключи</label>
	</td>
</tr>
<tr>
	<td class='label'>Ключевая фраза:</td>
	<td class='field'>
		<input type='text' name="WEP64_passphrase" size='32' maxlength='64'
		/><input type='button' name="WEP64_genkeys" value="Создать WEP-ключи" id="g64" onclick="genWep64Key.call(this,event)" disabled="disabled"/>
	</td>
</tr>
</table>

<table id="WPA" class="sublayout part">
<tr>
	<td class='label'>Тип защиты:</td>
	<td class='field'>
		<% writeSelectOpen("WLAN_AP_WPA_ENCRYPT_TYPE"); %>
			<% writeOption("TKIP", 3); %>
			<% writeOption("AES", 4); %>
			<% writeOption("TKIP/AES", 5); %>
		</select>
	</td>
</tr>
<tr>
	<td class='label'>Формат сетевого ключа:</td>
	<td class='field'>
		<% writeSelectOpen("WLAN_AP_WPA_PSK_FORMAT"); %>
			<% writeOption("HEX", 0); %>
			<% writeOption("ASCII", 1); %>
		</select>
	</td>
</tr>
</table>

<table id="WPA_HEX" class="sublayout part">
<tr>
	<td class='label'>Сетевой ключ (HEX):</td>
	<td class='field'><%=inputText("WLAN_AP_WPA_PSK_hex", 36, 64); %></td>
</tr>
</table>

<table id="WPA_PASSPHRASE" class="sublayout part">
<tr>
	<td class='label'>Сетевой ключ (ASCII):</td>
	<td class='field'><%=inputText("WLAN_AP_WPA_PSK_passphrase", 36, 63); %></td>
</tr>
<tr class='openpass' id='spsk'>
	<td class='label'></td>
	<td class='field'>
		<%=checkBox("WLAN_AP_WPA_PSK_pp_show"); %><label for='WLAN_AP_WPA_PSK_pp_show'>Показывать сетевой ключ</label>
	</td>
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
<script type="text/javascript">updateAllForms();</script>
<% writeLeafClose(); %>
</body>
</html>
