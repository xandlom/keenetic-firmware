<% htmlHead("WLAN Secutiry Settings"); %>
<!--[if IE]>
	<style type="text/css">
		.openpass { display: none; }
	</style>
<![endif]-->
<script type="text/javascript"><!--
<%
	setMibsVars(
		"WLAN_STA_AUTH_TYPE", "WLAN_STA_ENCRYPT_TYPE",
		"WLAN_STA_WEP_KEY_INDEX",
		"WLAN_STA_WEP_KEY1", "WLAN_STA_WEP_KEY1_FORMAT", 
		"WLAN_STA_WEP_KEY2", "WLAN_STA_WEP_KEY2_FORMAT", 
		"WLAN_STA_WEP_KEY3", "WLAN_STA_WEP_KEY3_FORMAT", 
		"WLAN_STA_WEP_KEY4", "WLAN_STA_WEP_KEY4_FORMAT",
		"WLAN_STA_WPA_PSK",  "WLAN_STA_WPA_PSK_FORMAT" );

	WLAN_STA_WEP64_KEY1 = 
	WLAN_STA_WEP64_KEY2 = 
	WLAN_STA_WEP64_KEY3 = 
	WLAN_STA_WEP64_KEY4 = 
	WLAN_STA_WEP128_KEY1 = 
	WLAN_STA_WEP128_KEY2 = 
	WLAN_STA_WEP128_KEY3 = 
	WLAN_STA_WEP128_KEY4 = "";
	WLAN_STA_WEP64_KEY_INDEX = 
	WLAN_STA_WEP128_KEY_INDEX = 1;
	WLAN_STA_WEP64_show_keys = 
	WLAN_STA_WEP128_show_keys = 
	WLAN_STA_WPA_PSK_pp_show = 0;

	var _has_ssid = testVar('ssid');

	if (_has_ssid) {
		WLAN_STA_SSID = ssid;
		WLAN_STA_BAND = 7;     // 802.11nbg
		WLAN_STA_FIX_RATE = 0; // Auto
		WLAN_STA_CHANNEL = 0;  // Auto

		WLAN_STA_AUTH_TYPE = 0;
		WLAN_STA_ENCRYPT_TYPE = 5;
		WLAN_STA_WEP_ENCRYPT_TYPE = 2;
		WLAN_STA_WPA_ENCRYPT_TYPE = 5;
		WLAN_STA_WPA_PSK = WLAN_STA_WPA_PSK_passphrase = WLAN_STA_WPA_PSK_hex = '';
		WLAN_STA_WPA_PSK_FORMAT = 1;

		if (auth == "OPEN")      WLAN_STA_AUTH_TYPE = 1;
		if (auth == "SHARED")    WLAN_STA_AUTH_TYPE = 2;
		if (auth == "WPAPSK")    WLAN_STA_AUTH_TYPE = 3;
		if (auth == "WPA2PSK")   WLAN_STA_AUTH_TYPE = 4;
		if (auth == "WPAPSK1-2") WLAN_STA_AUTH_TYPE = 4;

		if (encrypt == "TKIP")    WLAN_STA_WPA_ENCRYPT_TYPE = 3;
		if (encrypt == "AES")     WLAN_STA_WPA_ENCRYPT_TYPE = 4;
		if (encrypt == "TKIPAES") WLAN_STA_WPA_ENCRYPT_TYPE = 5;
	} else {
		var authClass = 0;
		var wepBits = 0;

		if (WLAN_STA_AUTH_TYPE > 0)
			authClass = 1;
		if (WLAN_STA_AUTH_TYPE > 2)
			authClass = 2;

		if (authClass == 1)
			if (WLAN_STA_ENCRYPT_TYPE == 1)
				wepBits = 64;
			else
				wepBits = 128;

		var WLAN_STA_WEP_ENCRYPT_TYPE = WLAN_STA_ENCRYPT_TYPE;
		var WLAN_STA_WPA_ENCRYPT_TYPE = WLAN_STA_ENCRYPT_TYPE;

		if (WLAN_STA_ENCRYPT_TYPE >= 3)
			WLAN_STA_WEP_ENCRYPT_TYPE = 2;

		if (WLAN_STA_ENCRYPT_TYPE < 3 && WLAN_STA_ENCRYPT_TYPE >= 1)
			WLAN_STA_WPA_ENCRYPT_TYPE = 5;

		if (!wepBits) {
			var keylen = strlen(WLAN_STA_WEP_KEY1);
			if (keylen < 11) {
				if (keylen == 5 || keylen == 10)
					wepBits = 64;
			} else {
				if (keylen == 13 || keylen == 26)
					wepBits = 128;
			}
		}

		if (wepBits == 64) {
			WLAN_STA_WEP64_KEY1 = WLAN_STA_WEP_KEY1;
			WLAN_STA_WEP64_KEY2 = WLAN_STA_WEP_KEY2;
			WLAN_STA_WEP64_KEY3 = WLAN_STA_WEP_KEY3;
			WLAN_STA_WEP64_KEY4 = WLAN_STA_WEP_KEY4;
			WLAN_STA_WEP64_KEY_INDEX = WLAN_STA_WEP_KEY_INDEX;
		}

		if (wepBits == 128) {
			WLAN_STA_WEP128_KEY1 = WLAN_STA_WEP_KEY1;
			WLAN_STA_WEP128_KEY2 = WLAN_STA_WEP_KEY2;
			WLAN_STA_WEP128_KEY3 = WLAN_STA_WEP_KEY3;
			WLAN_STA_WEP128_KEY4 = WLAN_STA_WEP_KEY4;
			WLAN_STA_WEP128_KEY_INDEX = WLAN_STA_WEP_KEY_INDEX;
		}

		if (WLAN_STA_WPA_PSK_FORMAT) {
			WLAN_STA_WPA_PSK_hex = "";
			WLAN_STA_WPA_PSK_passphrase = WLAN_STA_WPA_PSK;
		} else {
			WLAN_STA_WPA_PSK_hex = WLAN_STA_WPA_PSK;
			WLAN_STA_WPA_PSK_passphrase = "";
		}
	}
%>
var NONE = 0, WEP = 1, WPA = 2;
var HEX = 0, ASCII = 1;

function getAuthClass(form) {
	return [ NONE, WEP, WEP, WPA, WPA ][form.WLAN_STA_AUTH_TYPE.value];
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

var reIs128 = /128/;
var CLASS = {
	KEY  : "key",
	DEF  : "default" };

function updateDefaultKey(event) {
	var form = this.form;
	_(form, "/^WLAN_STA_WEP\\d+_KEY_INDEX")
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

		return this.error( "слишком длинный ASCII-ключ" );
	}

	return this.error("required");
}

function update(event, form, type) {
	var ac = getAuthClass(form);
	var toWEP = (ac == WEP);
	var toWPA = (ac == WPA);
	var wepBits = !toWEP ? 0 : [ 64, 128 ][form.WLAN_STA_WEP_ENCRYPT_TYPE.selectedIndex];
	var wpa_ascii = form.WLAN_STA_WPA_PSK_FORMAT.value;

	_(form, "/^WLAN_STA_WEP_")  .enable(toWEP);
	_(form, "/^WLAN_STA_WEP64") .enable(wepBits == 64);
	_(form, "/^WLAN_STA_WEP128").enable(wepBits == 128);
	_(form, "/^WLAN_STA_WPA_")  .enable(toWPA);

	_("#WPA")    .show(toWPA);
	_("#WEP")    .show(toWEP);
	_("#WEP64")  .show(wepBits == 64);
	_("#WEP128") .show(wepBits == 128);

	_("#WPA_PASSPHRASE") .show(toWPA && wpa_ascii == 1);
	_("#WPA_HEX")        .show(toWPA && wpa_ascii == 0);

	_(form, "WLAN_STA_WPA_PSK_hex")        .enable(toWPA && wpa_ascii == 0);
	_(form, "WLAN_STA_WPA_PSK_passphrase") .enable(toWPA && wpa_ascii == 1);

	if (type === 'init') {
		_(form, "/^WLAN_STA_WEP\\d+_KEY\\d$")
			.setParser("ascii", validateKey);

		_(form, "/^WLAN_STA_WEP\\d+_KEY_INDEX")
			.setAttrs( { title: "default key selection" } )
			.setEvents( { click: updateDefaultKey } )
			.trigEvent("click");

		_(form, "WLAN_STA_WPA_PSK_passphrase")
			.setParser("psk_passphrase");

		_(form, "WLAN_STA_WPA_PSK_hex")
			.setParser("psk_hex");
	}

	if (!browser.isIE) {
		_(form, "/^WLAN_STA_WEP64_KEY\\d$")
			.setAttrs({
				type: ((form.WLAN_STA_WEP64_show_keys.checked) ? 'text' : 'password')
			});

		_(form, "/^WLAN_STA_WEP128_KEY\\d$")
			.setAttrs({
				type: ((form.WLAN_STA_WEP128_show_keys.checked) ? 'text' : 'password')
			});

		_(form, "WLAN_STA_WPA_PSK_passphrase")
			.setAttrs({
				type: ((form.WLAN_STA_WPA_PSK_pp_show.checked) ? 'text' : 'password')
			});
	}

}

function submit(event) {

	var form = this;
	var ac = getAuthClass(form);
	var toWEP = (ac == WEP);
	var toWPA = (ac == WPA);
	var wepBits = !toWEP ? 0 : [ -1, 0, 1 ][form.WLAN_STA_WEP_ENCRYPT_TYPE.value];

	WLAN_STA_ENCRYPT_TYPE = 0;

	if (toWEP)
		WLAN_STA_ENCRYPT_TYPE = form.WLAN_STA_WEP_ENCRYPT_TYPE.options[form.WLAN_STA_WEP_ENCRYPT_TYPE.selectedIndex].value;

	if (toWPA)
		WLAN_STA_ENCRYPT_TYPE = form.WLAN_STA_WPA_ENCRYPT_TYPE.options[form.WLAN_STA_WPA_ENCRYPT_TYPE.selectedIndex].value;

	form.WLAN_STA_ENCRYPT_TYPE.value = WLAN_STA_ENCRYPT_TYPE;

	if (wepBits >= 0) {

		form.WLAN_STA_WEP_KEY_INDEX.value =
			$(!wepBits ? form.WLAN_STA_WEP64_KEY_INDEX : form.WLAN_STA_WEP128_KEY_INDEX).getRadioValue();

		_(form, "/^WLAN_STA_WEP_KEY\\d")
			.setValues(
				_(form, !wepBits ? "/^WLAN_STA_WEP64_KEY\\d" : "/^WLAN_STA_WEP128_KEY\\d")
					.getValues());
	}

	form.WLAN_STA_WPA_PSK.value = 
		( form.WLAN_STA_WPA_PSK_FORMAT.value == 0 ?
			form.WLAN_STA_WPA_PSK_hex :
			form.WLAN_STA_WPA_PSK_passphrase
		).value;

	return true;
}

//--></script>
</head>

<body class="body">
<% writeLeafOpen("Настройки безопасности Wi-Fi",
	"Для подключения к защищенной сети Wi-Fi необходимо указать ее сетевой ключ. "+
	"Следует помнить, что при подключение к незащищенной сети передаваемые вами "+
	"данные могут быть легко перехвачены."); %>

<% writeFormOpen("wlanStaSecurity"); %>
<div class="none"><%

	if (_has_ssid) {
		write(hidden("WLAN_STA_BAND")); 
		write(hidden("WLAN_STA_FIX_RATE")); 
		write(hidden("WLAN_STA_CHANNEL")); 
	}

	write(hidden("WLAN_STA_ENCRYPT_TYPE"));
	write(hidden("WLAN_STA_WEP_KEY_INDEX"));
	/* order of the fields should be same as in form!!! */
	write(hidden("WLAN_STA_WEP_KEY1_FORMAT"));
	write(hidden("WLAN_STA_WEP_KEY1"));
	write(hidden("WLAN_STA_WEP_KEY2_FORMAT"));
	write(hidden("WLAN_STA_WEP_KEY2"));
	write(hidden("WLAN_STA_WEP_KEY3_FORMAT"));
	write(hidden("WLAN_STA_WEP_KEY3"));
	write(hidden("WLAN_STA_WEP_KEY4_FORMAT"));
	write(hidden("WLAN_STA_WEP_KEY4"));
	write(hidden("WLAN_STA_WPA_PSK")); %></div>
<table class="sublayout"><%
if (_has_ssid) write("
	<tr>
		<td class='label'>SSID:</td>
		<td class='field'>
			", inputText("WLAN_STA_SSID", 33, 32), '
		</td>
	</tr>');
%>
<tr>
	<td class='label'>Проверка подлинности:</td>
	<td class='field'>
		<% writeSelectOpen("WLAN_STA_AUTH_TYPE"); %>
			<% writeOption("Не используется", 0); %>
			<% writeOption("Open", 1); %>
			<% writeOption("Shared", 2); %>
			<% writeOption("WPA-PSK", 3); %>
			<% writeOption("WPA2-PSK", 4); %>
		</select>
	</td>
</tr>
</table>

<table id="WEP" class="sublayout part">
<tr>
	<td class='label'>Тип защиты:</td>
	<td class='field'>
		<% writeSelectOpen("WLAN_STA_WEP_ENCRYPT_TYPE"); %>
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
		write(radio("WLAN_STA_WEP128_KEY_INDEX", 1),
			hidden("WLAN_STA_WEP128_KEY1_FORMAT"),
			inputText("WLAN_STA_WEP128_KEY1", keySize, keyLength));
	%></td>
</tr>
<tr>
	<td class='label'>Ключ 2:</td>
	<td class='field'><%
		write(radio("WLAN_STA_WEP128_KEY_INDEX", 2),
			hidden("WLAN_STA_WEP128_KEY2_FORMAT"),
			inputText("WLAN_STA_WEP128_KEY2", keySize, keyLength));
	%></td>
</tr>
<tr>
	<td class='label'>Ключ 3:</td>
	<td class='field'><%
		write(radio("WLAN_STA_WEP128_KEY_INDEX", 3),
			hidden("WLAN_STA_WEP128_KEY3_FORMAT"),
			inputText("WLAN_STA_WEP128_KEY3", keySize, keyLength));
	%></td>
</tr>
<tr>
	<td class='label'>Ключ 4:</td>
	<td class='field'><%
		write(radio("WLAN_STA_WEP128_KEY_INDEX", 4),
			hidden("WLAN_STA_WEP128_KEY4_FORMAT"),
			inputText("WLAN_STA_WEP128_KEY4", keySize, keyLength));
	%></td>
</tr>
<tr class='openpass'>
	<td class='label'></td>
	<td class='field'>
		<%=checkBox("WLAN_STA_WEP128_show_keys"); %><label for='WLAN_STA_WEP128_show_keys'>Показать ключи</label>
	</td>
</tr>
</table>

<table id="WEP64" class="sublayout part">
<tr><% keyLength = 10; keySize = 14; %>
	<td class='label'>Ключ 1:</td>
	<td class='field'><%
		write(radio("WLAN_STA_WEP64_KEY_INDEX", 1),
			hidden("WLAN_STA_WEP64_KEY1_FORMAT"),
			inputText("WLAN_STA_WEP64_KEY1", keySize, keyLength));
	%></td>
</tr>
<tr>
	<td class='label'>Ключ 2:</td>
	<td class='field'><%
		write(radio("WLAN_STA_WEP64_KEY_INDEX", 2),
			hidden("WLAN_STA_WEP64_KEY2_FORMAT"),
			inputText("WLAN_STA_WEP64_KEY2", keySize, keyLength));
	%></td>
</tr>
<tr>
	<td class='label'>Ключ 3:</td>
	<td class='field'><%
		write(radio("WLAN_STA_WEP64_KEY_INDEX", 3),
			hidden("WLAN_STA_WEP64_KEY3_FORMAT"),
			inputText("WLAN_STA_WEP64_KEY3", keySize, keyLength));
	%></td>
</tr>
<tr>
	<td class='label'>Ключ 4:</td>
	<td class='field'><%
		write(radio("WLAN_STA_WEP64_KEY_INDEX", 4),
			hidden("WLAN_STA_WEP64_KEY4_FORMAT"),
			inputText("WLAN_STA_WEP64_KEY4", keySize, keyLength));
	%></td>
</tr>
<tr class='openpass'>
	<td class='label'></td>
	<td class='field'>
		<%=checkBox("WLAN_STA_WEP64_show_keys"); %><label for='WLAN_STA_WEP64_show_keys'>Показать ключи</label>
	</td>
</tr>
</table>

<table id="WPA" class="sublayout part">
<tr>
	<td class='label'>Тип защиты:</td>
	<td class='field'>
		<% writeSelectOpen("WLAN_STA_WPA_ENCRYPT_TYPE"); %>
			<% writeOption("TKIP", 3); %>
			<% writeOption("AES", 4); %>
			<% writeOption("TKIP/AES", 5); %>
		</select>
	</td>
</tr>
<tr>
	<td class='label'>Формат сетевого ключа:</td>
	<td class='field'>
		<% writeSelectOpen("WLAN_STA_WPA_PSK_FORMAT"); %>
			<% writeOption("HEX", 0); %>
			<% writeOption("ASCII", 1); %>
		</select>
	</td>
</tr>
</table>

<table id="WPA_HEX" class="sublayout part">
<tr>
	<td class='label'>Сетевой ключ (HEX):</td>
	<td class='field'><%=inputText("WLAN_STA_WPA_PSK_hex", 36, 64); %></td>
</tr>
</table>

<table id="WPA_PASSPHRASE" class="sublayout part">
<tr>
	<td class='label'>Сетевой ключ (ASCII):</td>
	<td class='field'><%=inputText("WLAN_STA_WPA_PSK_passphrase", 36, 63); %></td>
</tr>
<tr class='openpass'>
	<td class='label'></td>
	<td class='field'>
		<%=checkBox("WLAN_STA_WPA_PSK_pp_show"); %><label for='WLAN_STA_WPA_PSK_pp_show'>Показать сетевой ключ</label>
	</td>
</tr>
</table>

<table class="sublayout">
<tr>
	<td class='label'></td>
	<td class='submit'>
		<%
if (_has_ssid)
	write(submit("/status.asp", "save:Подключиться"));
else
	write(submit("Применить"));
%>
	</td>
</tr>
</table>
</form>
<script type="text/javascript">updateAllForms();</script>
<% writeLeafClose(); %>
</body>
</html>
