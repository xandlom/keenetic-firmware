/* ------------------------------------------------------------------------ */
var regexes = {
	num:      /^\d+$/,
	ports:    /^\d+(-\d+)?$/,
	phone:    /^[\d\*#\(),\-+wpdt]+$/,
	'int':    /^$0(x[\da-f]+|[0-7]+)|[1-9]\d+/i,
	WPSPin:   /^\d{8}$/,
	pin:      /^\d{4,8}$/,
	hex:      /^[\da-f]+$/i,
	bound:    /^\[(\d+)-(\d+)\]$/,
	id:       /^[a-z_]\w+$/i,
	MAC:      /^[\da-f]{2}([:\-]?[\da-f]{2}){5}$/i,
	ascii:    /^[\x20-\x7E]+$/,
	login:    /^[\w+\()\-_=]*$/,
	password: /^[\x21-\x7E]*$/,
	prinable: /^[\x20-\x7E]+$/,
	time:     /^([01]\d|2[0-3])(:[0-5]\d){2}$/,
	date:     /^([0-2]\d|3[01])\/(0[1-9]|1[0-2])\/(19[7-9]\d|20\d\d)$/,
	IP:       /^((0x?)?[\da-f]{1,3}\.){1,3}(0x?)?[\da-f]{1,8}$/i,
	domain:   /^[\w\-]*(\.[\w\-]+)*$/i,
	URL:      /^https?:\/\/([\w\.\-]+(:[\w\.\-]+)?@)?([a-z][\w\-]+(\.[\w\-]+)*|(\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5])(\.(\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5])){3})(:[\d]{1,5})?(\/([\w\-_@\.+!,]|(\%[\da-f]{2}))+)*\/?(\?([\w$\-_@\.&+!*\(\),=]|\%[\da-z]{2})*)?$/i,
	folder:   /^(\/[\s\w\-\.\_\+\(\)\`\'\"]+)*\/?$/i,
	atcmd:    /^AT[\x20-\x7F]*$/i
};
/* ------------------------------------------------------------------------ */
var _ru = {
	male: {
			On: "Включен",
			Off: "Выключен",
			"Connected": "Подключен",
			"Disconnected": "Отключен",
			"Not connected": "Не подключен",
			"Configured": "Настроен",
			"Not Configured":"Не настроен",
			"Not found": "Не обнаружен",
			"inactive": "не активен",
			"Current": "Текущий"
		},

	female: {
			On: "Включена",
			Off: "Выключена",
			"Connected": "Подключена",
			"Disconnected": "Отключена",
			"Not connected": "Не подключена",
			"Configured": "Настроена",
			"Not Configured": "Не настроена",
			"Not found": "Не обнаружена",
			"inactive": "не активна",
			"Current": "Текущая"
		},

	FLOATSDOT: ",", 
	/*        1       2-4      5-0 & 10-19  */
	days:  [ "день", "дня",   "дней" ],
	hours: [ "час",  "часа",  "часов" ],
	minutes:["минута","минуты","минут" ],
	seconds:["секунда","секунды","секунд" ],
	bytes: [ "байт", "байта", "байт" ],
	Bytes: [ "Байт", "Байта", "Байт" ],

	'bytes/sec': 'байт/с',
	"Bit/sec":   "Бит/с",
	"mbit/sec":   "мбит/с",
	"Mbit/sec":   "Мбит/с",

	"dBm": "дБм",
	"mHz": "МГц",

	'byte':"байт",
	Byte:  "Байт",

	months: [ 'Янв', 'Фев', 'Мар', 'Апр', 'Май', 'Июн', 'Июл', 'Авг', 'Сен', 'Окт', 'Ноя', 'Дек' ],
	kilo:  " КМГТПЕЗЁ",
	On:    "Включено",
	Off:   "Выключено",
	auto:  "Автовыбор",

	'Connected':    'Подключен к Yota',
	'Connecting':   'Подключение к Yota',
	'Searching':    'Поиск сети',
	'Absent':       'Модем не обнаружен',
	'Modem initializing': 'Инициализация модема',
	'ConnectError': 'Ошибка подключения',
	'Check Modem':  'Пожалуйста, проверьте модем',
	'NoNetwork':    'Вне сети Yota',

	"Idle":       "Ожидание",
	"Handshake":  "Проверка",
	"Training":   "Подключение",
	"Showtime":   "Подключено",

	'You must update the device': 'Необходимо обновить устройство',
	'Device is not available':    'Модем не подключен',
	'Network found':              'Сеть найдена',
	'Search Network':             'Поиск сети',
	'Scanning':                   'Поиск сети',
	'Not connected to Network':   'Нет подключения к сети',
	"Connection":                 'Подключение',
	'Authentication Start':       'Авторизация',
	'Authentication Successful':  'Успешная авторизация',
	'Authentication Failed':      'Ошибка авторизации',
	'Reboot device':              'Перезагрузка модема',

	"None":  "Нет",
	"Bad":   "Ошибочный",
	"Error": "Неправильный",
	"Ok":    "Принят",
	"Not supported":
	          "Не поддерживается",

	"Not found": "Не обнаружено",

	"Absent":        "Отсутствует",
	"Connected":     "Подключено",
	"Not connected": "Не установлено",
	"Disconnected":  "Нет соединения",
	"No response":   "Не отвечает",
	"Protocol error":"Ошибка протокола",
	"Auth error":    "Ошибка авторизации",
	"No modem":      "Модем не подключен",
	"Address requesting":"Получение адреса",

	"Full":      'Полный',
	"Read only": 'Только чтение',

	"Dynamic":    "Динамический",
	"Static":     "Статический",
	"Auto":       "Автоматическая",
	"Manual":     "Ручная",
	"No IP":      "Без адреса",

	"Configured":      "Настроено",
	"Not Configured":  "Не настроено",
	"inactive":        "не активно",
	"Current":         "Текущее",

	"No Security":     "Нет",

	"Server":          "Сервер",
	"Station":         "Станция",
	"Access Point":    "Точка доступа",

	"Ethernet Router":  "Ethernet-роутер",
	"WiFi Router":      "WiFi-роутер",
	"WiFi Access Point":"Точка доступа Wi-Fi",
	"Wireless Bridge":  "Wi-Fi-мост",
	"3G Router":        "3G-роутер",
	"WiMAX Router":     "WiMAX-роутер",

	"Applying":              "Применение настроек",
	"Preparing for update":  "Подготовка к обновлению",
	"Running":               "Выполняется",
	"No responce":           "Удаленный сервер не отвечает",
	"Connecting...":         "Соединение...",
	"Initializing...":       "Инициализация...",
	"Disconnecting...":      "Отключение...",
	"Pause":                 "Ожидание...",
	"Waiting for answer...": "Ожидание ответа...",
	"Device is not connected": "Модем не подключен",

	"OPEN":     "Open",
	"SHARED":   "Shared",
	"AUTOWEP":  "AutoWep",
	"WPA":      "WPA",
	"WPAPSK":   "WPA-PSK",
	"WPANONE":  "WPA-None",
	"WPA2":     "WPA-2",
	"WPA2PSK":  "WPA-2-PSK",
	"WPA1-2":   "WPA-1&2",
	"WPAPSK1-2":"WPA-1&2-PSK",

	"NONE":    "None",
	"WEP":     "WEP",
	"TKIP":    "TKIP",
	"AES":     "AES",
	"TKIPAES": "TKIP+AES",

	"no clients yet": "соединений пока нет",

	"WPS supports AP mode ONLY! Exiting.": "WPS поддерживается только в режиме точки доступа. Настройка не возможна.",
	"WiFi disable! Exiting.": "Беспроводная сеть выключена. Настройка не возможна.",

	"Permission denied": "Нет доступа",
	"Nothing here": "Ничего нет",
	"No such file or directory": "Такой папки нет",

	"INCORRECT_IP": "недопустимый IP-адрес",
	"INCORRECT_IP_PART": "недопустимая часть (#1) IP-адреса",
	"TOO_BIG_IP_PART": "#1 — недопустимое значение в IP-адресе.",
	"INVAL_MASK": "неправильная маска",
	"SHOULD_BE_IN_RANGE": "адрес должен быть из диапазона: #1 — #2",
	"REQUIRED": "обязательное поле",
	"UNREACHABLE": "не доступен (возможно, временно)",
	"WRONG_MASK_VALUE": "недопустимое значение маски",
	"REQ_12_HEXDIGITS": "должно быть 12 шестнадцатеричных цифр",
	"INVAL_MAC": "недопустимый MAC-адрес. (00:00:00:00:00:00)",
	"INCORRECT": "недопустимое значение",
	"INVAL_HOST": "недопустимый хост",
	"INVAL_PORT": "недопустимый номер порта",
	"INVAL_SERV": "недопустимый адрес сервера",
	"REQ_NUMBER": "должно быть числовое значение",
	"SHOULD_BE_BETWEEN": "значение должно быть в пределах от #1 до #2",
	"PHONE_DIGITS_ONLY": "допустимы только цифры и символы '*#-+,w()'",
	"ID_FORMAT": "допустимы только цифры, латинские буквы и знак '_'",
	"ALDIGITS_ONLY": "допустимы только цифры и латинские буквы",
	"INVAL_DATE": "используйте формат даты: (дд/мм/гггг)",
	"INVAL_TIME": "используйте формат времени (чч:мм:сс)",
	"INCORR_PIN4": "должен содержать от 4-х до 8-ми цифр",
	"WRONG_PIN": "неправильный PIN-код",
	"INCORR_PIN8": "должен состоять из 8 цифр",
	"ASCII_ONLY": "допустимы только ASCII-символы",
	"PRINTABLE_ONLY": "допустимы только печатные ASCII-символы",
	"AT_ONLY": "AT...",
	"NEED_64_DIGITS": "[#1] требуется 64 знака",
	"HEX_ONLY": "допустимы только знаки от 0 до 9 и от A до F",
	"ATLEAST_8ASCIIs": "требуется минимум 8 символов ASCII",
	"PASSW_NOT_MATCH": "пароли не совпадают",
	"SHOULD_BE_GE_THAN_1ST": "конечный адрес должен быть больше начального или равен ему",
	"SHOULDNT_BE_IN_POOL": "пул не должен содержать IP-адрес: #1",
	"SHOULDNT_BE_ONEOF": "не должен быть #1 или #2",
	"SHOULDNT_BE": "должен отличаться от #1",
	"NOT_WAN": "подсеть должна отличаться от WAN-подсети",
	"NEED_IP_LIKE": "используйте адрес сети \"#1\", а не хоста",
	"CONFIRM_DELALL": "Все записи будут удалены...",
	"CONFIRM_DEL": "Выделенные записи будут удалены...",
	"NEED_XMLHTTPREQUEST": "Ваш браузер не поддерживает XMLHTTP или его поддержка отключена.",
	"VOIP_PORT_EQ_IPTV": "Уже занят для IPTV",
	"MUST_BE_HOST_IP": "Должен быть адрес хоста, а не сети",
	"SHOULD_BE_NOT_BROADCAST": "Широковещательный адрес недопустим",
	"INCORR_PORTS": "Неверное значение диапазона портов",
	"REVERSED_POOL": "Первый порт больше последнего",
	"INVALID_DEST_PORTS": "Либо один порт, либо равный диапазон",
	"SHOULDNOTBEBROADCAST": "Любой другой свободный IP",
	"SHOULDNOTBEFROMDHCPPOOL": "Не должен быть из диапазона #1-#2"
};
/* ------------------------------------------------------------------------ */
var _en = {
	male: {},
	female: {},
	FLOATSDOT: ".", 
	/*        1       2-4      5-0 & 10-19  */
	days:  [ "day",  "days",  "days" ],
	bytes: [ "byte", "bytes", "bytes" ],
	hours: [ "hour",  "hours",  "hours" ],
	minutes:["minute","minutes","minutes" ],
	seconds:["second","seconds","seconds" ],
	Bytes: [ "Byte", "Bytes", "Bytes" ],

	months: [ 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec' ],
	kilo:  " KMGTPEZY",

	"OPEN":     "Open",
	"SHARED":   "Shared",
	"AUTOWEP":  "AutoWep",
	"WPA":      "WPA",
	"WPAPSK":   "WPA-PSK",
	"WPANONE":  "WPA-None",
	"WPA2":     "WPA-2",
	"WPA2PSK":  "WPA-2-PSK",
	"WPA1-2":   "WPA-1&2",
	"WPAPSK1-2":"WPA-1&2-PSK",

	"NONE":    "None",
	"WEP":     "WEP",
	"TKIP":    "TKIP",
	"AES":     "AES",
	"TKIPAES": "TKIP+AES",

	"INCORRECT_IP": "incorrect IP address",
	"INCORRECT_IP_PART": "incorrect part(#1) of IP address",
	"TOO_BIG_IP_PART": "Too big(#1) value of ip address element.",
	"INVAL_MASK": "invalid mask",
	"SHOULD_BE_IN_RANGE": "should be in range: #1 - #2",
	"REQUIRED": "Required",
	"UNREACHABLE": "is unreachable (may be yet)",
	"WRONG_MASK_VALUE": "wrong mask value",
	"REQ_12_HEXDIGITS": "should be 12 digits in hex.",
	"INVAL_MAC": "invalid MAC address. (00:00:00:00:00:00)",
	"INCORRECT": "incorrect",
	"INVAL_HOST": "invalid host",
	"INVAL_PORT": "invalid port",
	"INVAL_SERV": "invalid server address",
	"REQ_NUMBER": "should be a numeric value",
	"SHOULD_BE_BETWEEN": "should be between #1 and #2",
	"PHONE_DIGITS_ONLY": "digits or '*#-+,w()' characters only",
	"ID_FORMAT": "'a'..'z', '0'..'9' or '_' symbols only",
	"ALDIGITS_ONLY": "alphabetical characters and digits only",
	"INVAL_DATE": "incorrect date (dd/mm/yyyy)",
	"INVAL_TIME": "incorrect time (hh:mm:ss)",
	"INCORR_PIN4": "incorrect PIN code (four digits only)",
	"WRONG_PIN": "wrong PIN code",
	"INCORR_PIN8": "incorrect PIN code (eight digits only)",
	"ASCII_ONLY": "must contains ASCII characters only",
	"PRINTABLE_ONLY": "must contains printable ASCII characters only",
	"AT_ONLY": "AT...",
	"NEED_64_DIGITS": "[#1] 64 digits are required.",
	"HEX_ONLY": "should contain only hex digits!",
	"ATLEAST_8ASCIIs": "must be at least 8 ASCII characters",
	"PASSW_NOT_MATCH": "confirm does not match",
	"SHOULD_BE_GE_THAN_1ST": "sould be greater or equal than 1st value",
	"SHOULDNT_BE_IN_POOL": "IP address(#1) should not be in pool",
	"SHOULDNT_BE_ONEOF": "should not be #1 or #2",
	"SHOULDNT_BE": "should not be #1",
	"NOT_WAN": "should be different subnet from WAN IP subnet",
	"NEED_IP_LIKE": "should be address of network like #1",
	"CONFIRM_DELALL": 'Do you really want to delete the all entries?',
	"CONFIRM_DEL": 'Do you really want to delete the selected entry?',
	"NEED_XMLHTTPREQUEST": "This browser does not support XMLHttpRequest.",
	"VOIP_PORT_EQ_IPTV": "Used for IPTV already",
	"MUST_BE_HOST_IP": "should be a host address",
	"SHOULD_BE_NOT_BROADCAST": "broadcast addres is unacceptable",
	"INCORR_PORTS": "invalide ports bound",
	"REVERSED_POOL": "last port grower than first",
	"INVALID_DEST_PORTS": "should be one port or equal bound",
	"SHOULDNOTBEBROADCAST": "should be another unused IP",
	"SHOULDNOTBEFROMDHCPPOOL": "should be not from DHCP pool #1-#2"
};

var lang = _ru, _l, _m, _f;

/* ------------------------------------------------------------------------ */
(function (){
	var _a = function (out, args) {
		if (args.length > 1) {
			switch (args.length) {
				case 6: out = out.replace("#5", args[5]);
				case 5: out = out.replace("#4", args[4]);
				case 4: out = out.replace("#3", args[3]);
				case 3: out = out.replace("#2", args[2]);
				case 2: out = out.replace("#1", args[1]);
			}
		}
		return out;
	};

	_l = function(str) { return _a((str in lang) ? lang[str] : str, arguments); };
	_m = function(str) { return _a((str in lang.male) ? lang.male[str] : (str in lang) ? lang[str] : str, arguments); };
	_f = function(str) { return _a((str in lang.female) ? lang.female[str] : (str in lang) ? lang[str] : str, arguments); };
})();

/* ------------------------------------------------------------------------ */
function _n(num, id) {
	if (num > 19 || num < 5)
		switch (num % 10) {
			case 1:	return lang[id][0];
			case 2:
			case 3:
			case 4: return lang[id][1];
		}
	return lang[id][2];
}

/* ------------------------------------------------------------------------ */
var Fmt = {
	dd: function (num) {
			return ("00" + num).slice(-2);
		},

	things: function (num, word) {
			return [ num, _n(num, word) ].join('&nbsp;')
		},

	uptime: function (value) {
			var a = [],
			    _time = {
				days: Math.floor(value / 86400),
				hours: Math.floor(value % 86400 / 3600),
				minutes: Math.floor(value % 3600 / 60),
				seconds: value % 60 };

			for (var name in _time) {
				var val = _time[name];
				if (val != 0)
					a.push(Fmt.things(val, name));
				if (a.length >= 2)
					break;
			}
			return a.join('&nbsp;');
		},

	date: function (value) {
			var d = new Date(value * 1000);
			return [
					[ d.getDate(), lang.months[d.getMonth()], d.getFullYear() ].join(' '),
					[ d.getHours(), Fmt.dd(d.getMinutes()), Fmt.dd(d.getSeconds()) ].join(':')
				].join(' ');
		},

	fwdate: function (date, delim) {
			var parts = /(\d{4})-(\d\d)-(\d\d)\s(\d\d):(\d\d)/.exec(date),
			    d = new Date(parts[1], parts[2]-1, parts[3], parts[4], parts[5]);

			return [
				[d.getDate(), lang.months[d.getMonth()], d.getFullYear()].join(delim || " "),
				[Fmt.dd(d.getHours()), Fmt.dd(d.getMinutes())].join(':')].join(' ');
		},

	px: function (value) {
			return [ Math.round(value), 'px' ].join('');
		}
};
/* ------------------------------------------------------------------------ */
var Size = {
	beauty2: function (s) {
			var t=s.toString(),l=t.length%3;
			return (t.substr(0,l)+t.substr(l).replace(/\d{3}/g,' $&')).substr(l===0);
		},

	beauty: function (s) {
			var t = s.toString(),
			    b = "";
			while (t.length > 3) {
				b =  ' '.concat(t.slice(-3), b);
				t = t.slice(0, -3);
			}
			return t.concat(b);
		},

	bin_scaled: function (i) {
			var ext = (i > 1023) ? Math.floor(Math.log(i)/Math.log(1024)) : 0,
			    ord = Math.pow(1024, ext),
			    int_part = Math.floor(i / ord).toString(),
			    frac_part = Math.floor(10.0*i / ord) % 10,
			    k = ' ' + lang.kilo.charAt(ext);

			frac_part = frac_part ? lang.FLOATSDOT + frac_part : "";
			return int_part + frac_part + (k == '  '? ' ' : k);
		},

	dec_scaled: function (i) {
			var ext = (i > 999) ? Math.floor(Math.log(i)/Math.log(1000)) : 0,
			    ord = Math.pow(1000, ext),
			    int_part = Math.floor(i / ord).toString(),
			    frac_part = Math.floor(10.0*i / ord) % 10,
			    k = ' ' + lang.kilo.charAt(ext);

			frac_part = frac_part ? lang.FLOATSDOT + frac_part : "";
			return int_part + frac_part + (k == '  '? ' ' : k);
		},

	full: function (i) {
			if (i < 1024)
				return [i.toString(), _n(i, "bytes")].join(' ');
			return [this.bin_scaled(i) + " (" + this.beauty(i)+" ", _n(i, "bytes"), ")"].join('');
		}
};
/* ------------------------------------------------------------------------ */
var IP = {
	parse: function (str) {
			if (!regexes.IP.test(str))
				return _l("INCORRECT_IP");

			var parts = str.split(".");

			for (var index = 0; index < parts.length; ++index)
				if (isNaN(parts[index]))
					return _l("INCORRECT_IP_PART", parts[index]);
				else
					parts[index] = parseInt(parts[index]);

			var ip_shift = 24,
				ip = 0, num;

			do {
				num = parts.shift();
				if (num >= 256)
					return _l("TOO_BIG_IP_PART", num);
				ip += num << ip_shift;
				ip_shift -= 8;
			} while (parts.length > 1);

			num = parts.shift();
			if (num >= (256 << ip_shift))
				return _l("TOO_BIG_IP_PART", num);

			return ip + num;
		},

	isMask: function (ip) {
			if (ip) {
				var x = ~ip + 1;
				if ((1 << Math.round(Math.log(x)/Math.LN2)) != x)
					return _l("INVAL_MASK");
			}

			return "";
		},

	maskWidth: function (mask) {
			return Math.round(32 - Math.log(~mask + 1) / Math.LN2);
		},

	inNet: function (ip, net_ip, mask) {
			var net = net_ip & mask,
			    left = net + 1,
			    right = net + ~mask;

			if ((ip & mask) != net)
				return _l("SHOULD_BE_IN_RANGE", IP.toStr(left), IP.toStr(right));

			if (ip == net_ip)
				return _l("SHOULDNT_BE", IP.toStr(ip));

			return "";
		},

	toStr: function (ip) {
			return [ ip >>> 24 & 255, ip >>> 16 & 255, ip >>> 8 & 255, ip & 255 ]
				.join(".");
		},

	reverseNum: function (rip) {
			return (rip >>> 24 & 255) + (rip << 24 & 0xFF000000) + (rip >> 8 && 0xFF00) + (rip << 8 & 0xFF0000);
		},

	reversedToStr: function (ip) {
			return [ ip & 255, ip >>> 8 & 255, ip >>> 16 & 255, ip >>> 24 & 255 ]
				.join(".");
		}
};
var browser = {
	isIE: !!("attachEvent" in window && !("opera" in window))
};

/* ------------------------------------------------------------------------ */
function formElements(objects, select) {
	if (!arguments.length)
		return this;

	var i, it, b, source = objects;

	switch (typeof objects) {
	case "string":
		select = objects;
		source = document.forms[0];
		break;

	case "object":
		if (typeof objects.length == 'undefined')
			source = [objects];
		break;

	case "undefined":
		source = document.forms[0];
	}

	if (select === undefined || select === "*") {
		this.selector = "";
		return this.add(source);
	} 

	this.selector = select;

	var list = select.split(",");
	while (list.length) {
		var sub = list.shift();

		switch (sub.charAt(0)) {
		case "=": /* value */
			sub = sub.substr(1);

			b = regexes.bound.exec(sub);
			if (b !== null) {
				var le = parseInt(b[1]);
				var ri = parseInt(b[2]);
				for (i = 0; i < source.length; ++i) {
					it = source[i], val = it.value;
					if ((le <= val) && (val <= ri))
						this.push(it);
				}
			} else {
				for (i = 0; i < source.length; ++i) {
					it = source[i];
					if (it.value == sub)
						this.push(it);
				}
			}
			break;

		case "#": /* id */
			this.add(document.getElementById(sub.substr(1)));
			break;

		case "/": /* RegExp */
			var inv = 0;
			sub = sub.substr(1);
			if (sub.charAt(0) == "!") {
				sub = sub.substr(1);
				inv = 1;
			}
			var re = new RegExp(sub.substr(1));
			for (i = 0; i < source.length; ++i) {
				it = source[i];
				if (re.test(it.name) ^ inv)
					this.push(it);
			}
			break;

		default:
			if (regexes.bound.test(sub)) {
				/* index */
				b = regexes.bound.exec(sub);
				var end = parseInt(b[2]) || 0;
				for (var j = parseInt(b[1]) || 0; j<=end; ++j)
					this.push(source[j]);
				break;
			}

			if (sub in source)
				this.add(source[sub]);
		}
	}

	return this;
}
/* ------------------------------------------------------------------------ */
function _(elements, select) {
	if (!arguments.length)
		return new formElements();

	return new formElements(elements, select);
}
/* ------------------------------------------------------------------------ */
function uniEvent(ev) {
	var event = { type: ev.type };
	event.target = ev['target'] || ev.srcElement;
	return event;
}
/* ------------------------------------------------------------------------ */
function _el(val) {
	this.el = typeof(val) == 'object'
		? val
		: document.getElementById(val);
	return this;
}
function $(el) {
	return new _el(el);
}
function $_(tag) {
	return document.createElement(tag);
}
/* ------------------------------------------------------------------------ */
_el.prototype = {
	setStyle: function (name, value) {
			if (this.el) {
				var el = this.el;
				if (el.style)
					el.style[name] = value;
				else
					el.setAttribute("style", name+":"+value);
			}
			return this;
		},

	setSubClass: function (prefix, name) {
			var el = this.el,
			    list = el.className.split(' '),
			    pl = prefix.length;

			for (var i = 0; i < list.length; ++i) {
				if (list[i].slice(0, pl) == prefix) {
					list[i] = [prefix, name].join('_');
					el.className = list.join(' ');
					return this;
				}
			}

			list.push([prefix, name].join('_'));
			el.className = list.join(' ');
			return this;
		},

	show: function (yes) {
			this.setStyle("display", yes ? "" : "none");
			return this;
		},

	setOpacity: function (value) {
			if (browser.isIE)
				this.setStyle("filter", "alpha(opacity="+value*100+")");
			else
				this.setStyle("opacity", value);
			return this;
		},

	placeUnder: function (field, height) {
			var it = field, left, top, width;

			if (it.getBoundingClientRect) {
				var rect = it.getBoundingClientRect();
				left = rect.left;
				top = rect.bottom;
				width = rect.right - rect.left;
			} else {
				width = it.offsetWidth;
				left = it.offsetLeft+1;
				top = it.offsetTop;
				while (it.offsetParent) {
					it = it.offsetParent;
					left += it.offsetLeft;
					top += it.offsetTop;
				}
				top += field.offsetHeight;
			}

			var scrLeft = document.pageXOffset || document.documentElement.scrollLeft || document.body.scrollLeft,
			    scrTop  = document.pageYOffset || document.documentElement.scrollTop  || document.body.scrollTop;

			this.el.setAttribute("style", "");

			var s = this.el.style;
			s.left = Fmt.px(left + scrLeft);
			s.top = Fmt.px(top + scrTop);
			s.width = Fmt.px(width-2);
			s.height = height ? Fmt.px(height) : "20em";
			return this;
		},

	getRadioValue: function () {
			var radio = this.el;
			if (radio)
				if ('length' in radio) {
					for (var i = 0; i < radio.length; ++i)
						if (radio[i].checked)
							return radio[i].value;
				} else
					if (radio.checked)
						return radio.value;
		
			return undefined;
		},

	del: function () {
			if (this.el)
				this.el.parentNode.removeChild(this.el);
			delete this.el;
		},

	html: function (text) {
			if (!arguments.length)
				return this.el.innerHTML;
			if (typeof(text) == 'string')
				this.el.innerHTML = text;
			else {
				this.el.innerHTML = '';
				this.el.appendChild(text);
			}
			return this;
		},

	append: function (chld) {
			if (this.el)
				this.el.appendChild(chld);
			return this;
		},

	byTag: function (tag) {
			return _(this.el.getElementsByTagName(tag));
		}
};


/* ------------------------------------------------------------------------ */
formElements.prototype = {
	attr: function (name, value) {
			for (var i = 0; i < this.length; ++i)
				this[i][name] = value;
			return this;
		},

	style: function (name, value) {
			for (var i = 0; i < this.length; ++i) {
				var el = this[i];
				if (!el.style)
					el.setAttribute("style", "");
				el.style[name] = value;
			}
			return this;
		},

	each: function (callback, obj) {
			for (var i = 0; i < this.length; ++i)
				callback.call(this, this[i], i, obj);
			return this;
		},

	filter: function (callback, obj) {
			var to = _();
			for (var i = 0; i < this.length; ++i)
				if (callback.call(this, this[i], i, obj))
					to.push(this[i]);
			return to;
		},

	enable: function (en) {
			return this.attr("disabled", !en);
		},

	check: function (yes) {
			return this.attr("checked", yes);
		},

	checked: function () {
			return this.filter(function (el, i) {
					return el.checked;
				});
		},

	_show: function (index, yes) {
			var el = this[index], value = yes ? "" : "none";
			if (el.style)
				el.style['display'] = value;
			else
				el.setAttribute("style", "display:"+value);
		},

	show: function (yes) {
			for (var i = 0; i < this.length; ++i)
				this._show(i, yes);
			return this;
		},

	showTab: function (num) {
			for (var i = 0; i < this.length; ++i)
				this._show(i, num == i);
		},

	setAttrs: function (props) {
			for (var i = 0; i < this.length; ++i) {
				var el = this[i];
				for (var attr in props)
					el[attr] = props[attr];
			}
			return this;
		},

	setParser: function (fmt, fn) {
			this.setEvents( {
					change: validateField,
					keyup: validateField,
					paste: validateField } );

			if (0 in this) {
				var v = this[0].form.validation;
				for (var i = 0; i < this.length; ++i)
					this[i].form.validation.addElement(this[i], fmt, fn);
			}

			return this;
		},

	groupValidation: function (fmt, fn) {
			this.setEvents( {
					change: validateField,
					keyup: validateField,
					paste: validateField } );

			this[0].form.validation.addGroup(this, fmt, fn);
			return this;
		},

	getValues: function () {
			var values = [];
			for (var i = 0; i < this.length; ++i)
				values.push(this[i].value);
			return values;
		},

	setValues: function (arr) {
			for (var i = 0; i < this.length; ++i) {
				var it = this[i];
				if (it.type == 'checkbox' || it.type == 'radio')
					it.checked = arr[i] ? true : false;
				else
					it.value = arr[i];
			}
			return this;
		},

	getValue: function (val) {
			return this.length ? this[0].value : undefined;
		},

	setValue: function (val) {
			return this.attr("value", val);
		},

	select: function (yes) {
			if (this.length)
				this[0].selected = yes;
			return this;
		},

	proxy: function (fn) {
		return function () { return fn.apply(this, arguments); };
	},

	setEvents: function (props) {
			for (var i = 0; i < this.length; ++i) {
				var el = this[i];
				for (var attr in props)
					el["on"+attr] = this.proxy(props[attr]);
			}
			return this;
		},

	trigEvent: function (event) {
			var ev = (typeof event == "string") ?
					{ type: event } : event;
			var ontype = "on" + ev.type;
			for (var i = 0; i < this.length; ++i)
				(ev.target = this[i]) [ontype]
					.call(ev.target, ev);
			return this;
		},

	length: [].length,
	push:   [].push,
	pop:    [].pop,
	_shift: [].shift,

	shift:  function () {
			this._shift(); return this;
		},

	add: function (gr) {
			if (!gr || typeof gr == 'undefined')
				return this;

			if (!(('tagName' in gr) && gr.tagName == "SELECT") && ('length' in gr))
				for (var i = 0; i < gr.length; ++i)
					this.push(gr[i]);
			else
				this.push(gr);
			return this;
		},

	getQuery: function (opts) {
			var query = opts || [];
			this.each(function (el,i,query) {
				if (el.disabled)
					return true;
	
				var value = el.value;
				switch (el.type) {
				case "checkbox":
					value = el.checked ? 1 : 0;
					break;

				case "radio":
					if (!el.checked)
						return true;
					break;
	
				case "button":
				case "reset":
					return true;
				}
	
				query.push(el.name + '=' + encodeURIComponent(value));
				return true;
			}, query);
			return query.join("&");
		},

	ajaxSubmit: function (opts) {
			var aj = new ajaxObject();
		//	aj.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
			aj.open("POST", '/req/MIB', false);
			aj.setRequestHeader("If-Modified-Since", "Sat, 1 Jan 1996 00:00:00 GMT");
			aj.send(this.getQuery(opts));
			return (aj.status != 200) ? null : aj.responseText;
		}
};
/* ------------------------------------------------------------------------ */
var hint = {
	box: function (field) {
			return (field.className.indexOf('inside') >= 0) ?
				{ box:field.parentNode, frame:field.parentNode } :
				(field.className.indexOf('fake') >= 0) ?
					{ box:field.parentNode, frame:field } :
					{ box:field, frame:field };
		},

	center: function (box) {
			var comment = box.nextSibling;
			if (!box.nextSibling || comment.tagName != "BR") {
				var tbl = $_("table");
				tbl.className = 'comment';
				box.parentNode.insertBefore(tbl, box);
				var cell = tbl.insertRow(0).insertCell(0);
				cell.appendChild(box);
				cell.appendChild($_("br"));
				cell.appendChild(comment = $_("div"));
			} else {
				comment = comment.nextSibling;
			}
			return comment;
		},

	bottom: function (box) {
			var comment,
			    br = box.nextSibling;
			if (!box.nextSibling || br.tagName != "BR") {
				var div = $_("div");
				div.setAttribute("style", "float: left");
				div.style.styleFloat = 'left';
				div.style.display = 'inline';
				div.style.whiteSpace = 'nowrap';
				box.parentNode.insertBefore(div, box);
				div.appendChild(box);
				div.appendChild($_("br"));
				div.appendChild(comment = $_("div"));
			} else
				comment = br.nextSibling;

			return comment;
		},

	right: function (box) {
			var comment = box.nextSibling;
			if (!box.nextSibling || comment.tagName != "DIV") {
				var parent = box.parentNode;
				parent.insertBefore(comment = $_("div"), box.nextSibling);
				if (parent.style)
					parent.style.whiteSpace = 'normal';
				else
					parent.setAttribute("style", "white-space: normal");
			}
			return comment;
		},

	left: function (box) {
			var comment = box.previousSibling;
			if (!box.previousSibling || comment.tagName != "DIV")
				box.parentNode.insertBefore(comment = $_("div"), box);
			return comment;
		}
};
/* ------------------------------------------------------------------------ */
function elementParser(formVr, el, format, callback_s) {
	this.formValidator = formVr;
	this.element = el;
	this.parsedValue = this.value = el.value;

	this.status = this.OK;
	this.comment = "";
	this.commentMethod = 'right';
	this.fresh = true;

	this.format = format;
	this.callback_s = callback_s;

	this.required = this.formatReqs[this.format.charAt(0)];
	if (this.required === undefined)
		this.required = 1;

	if (this.required < 1)
		this.format =  this.format.substr(1);

	var subst = this.formatsSubst[this.format];
	if (typeof subst != "undefined")
		this.format = subst;

	var pair = this.format.split(":");
	if (1 in pair) {
		this.params = pair[1].split(",");
		this.format = pair[0];
	} else
		this.params = [];

	pair = this.format.split("@");
	if (1 in pair) {
		this.commentMethod = pair[1];
		this.format = pair[0];
	}
	return this;
}
/* ------------------------------------------------------------------------ */
elementParser.prototype = {
	V_REQUIRED: 1,
	V_OPTIONAL: 0,
	V_QUIET: -1,
	V_EMPTY: -2,

	OK: 0,
	MESSAGE: 0,
	WARNING: 1,
	ERROR: 2,

	formatReqs: { '?': 0, '-': -1, '.': -2 },

	formatsSubst: {
			port:    "num:1,65535",
			mtu:     "num:1000,1492",
			modemmtu:"num:300,1500",
			tag:     "num:2,4094",
			timeout: "num:0,9999"
		},

	commentClass: [ "message", "warning", "error" ],

	parse: function () {
			this.parsedValue = 
				this.value = this.element.value;
			this.skip = this.element.disabled;
			if (this.skip)
				return this.ok("");
			this.ok("");

			if (this.value.length == 0 && this.required != this.V_EMPTY)
				return this.isError(
					this.required > 0 ? _l("REQUIRED") : 
						(this.required < 0 ? " " : "" ));

			if (!(this.format in this))
				return this.error("unknown field validator '"+this.format+"'");

			if (this[this.format].apply(this, this.params)) {
				var el = this.element;
				var a = this['callback_s'];
				if (a)
					if (typeof a == "function")
						return a.call(this);
					else
						for(var i = 0; i < a.length; ++i)
							if (!a[i].call(this))
								return false;

				return true;
			}
			return false;
		},

	isValid: function () {
			return this.status != this.ERROR;
		},

/* ------------ validators --------------- */
	none: function () {
			return true;
		},

	ip: function() {
			var parsed = IP.parse(this.value);
			if (typeof parsed == "string")
				return this.error(parsed);
			this.parsedValue = parsed;
			return true;
		},

	gateway: function() {
			if (!this.ip())
				return false;

			if (typeof mib != 'undefined' && 'ifs' in mib) {
				for (var name in mib.ifs) {
					var net = mib.ifs[name];
					if (IP.inNet(this.parsedValue, net.ip, net.mask) === "") {
						if (this.parsedValue & ~net.mask) {
							return ((this.parsedValue & ~net.mask) != ~net.mask) ||
								this.error(_l("SHOULD_BE_NOT_BROADCAST"));
						} else
							return this.error(_l("MUST_BE_HOST_IP"));
					}
				}
				return this.warning(_l("UNREACHABLE"));
			}
			return this.warning('undefined mib.ifs object');
		},

	mask: function() {
			if (this.value.charAt(0) == "/") {
				var num = this.value.substr(1);
				if (isNaN(num))
					return this.error(_l("WRONG_MASK_VALUE"));
				this.parsedValue = -1 << 32 - num;
				return true;
			}

			if (this.ip())
				return this.isError(IP.isMask(this.parsedValue));
			return false;
		},

	mac: function() {
			if (this.value.length < 12)
				return this.error(_l("REQ_12_HEXDIGITS"));

			if (!regexes.MAC.test(this.value))
				return this.error(_l("INVAL_MAC"));

			this.parsedValue = this.value.split(":").join("");
			if (this.params.length && this.parsedValue != '000000000000')
				return this.ok(this.params.join(", "));
			return true;
		},

	url: function() {
			return regexes.URL.test(this.value) || this.error(_l("INCORRECT"));
		},

	domain: function() {
			return regexes.domain.test(this.value) || this.error(_l("INCORRECT"));
		},

	folder: function() {
			return regexes.folder.test(this.value) || this.error(_l("INCORRECT"));
		},

	host: function() {
			if (!regexes.domain.test(this.value)) {
				var ip = IP.parse(this.value);
				if (typeof ip == "string")
					return this.error(_l("INVAL_HOST"));
			}
			return true;
		},

	host_port: function() {
			var parts = this.value.split(':');
			if (!regexes.domain.test(parts[0])) {
				var ip = IP.parse(parts[0]);
				if (typeof ip == "string")
					return this.error(_l("INVAL_HOST"));
			}
			if (parts.length == 2)
				if (!regexes.num.test(parts[1]) || parts[1] < 1 || parts[1] > 65535)
					return this.error(_l("INVAL_PORT"));
			if (parts.length > 2)
				return this.error(_l("INVAL_HOST"));
			return true;
		},

	ip_port: function() {
			var parts = this.value.split(':'),
			    ip = IP.parse(parts[0]);
			if (typeof ip == "string")
				return this.error(ip);
			if (parts.length == 2)
				if (!regexes.num.test(parts[1]) || parts[1] < 1 || parts[1] > 65535)
					return this.error(_l("INVAL_PORT"));
			if (parts.length > 2)
				return this.error(_l("INVAL_IP"));
			return true;
		},

	num: function(min, max) {
			if (isNaN(this.value))
				return this.error(_l("REQ_NUMBER"));

			if (parseFloat(this.value) != parseInt(this.value))
				return this.error(_l("REQ_NUMBER"));

			this.parsedValue = parseInt(this.value);
			if (min)
				return this.isError(
					(min <= this.parsedValue && this.parsedValue <= max) ?
					"" : _l("SHOULD_BE_BETWEEN", min, max));
			return true;
		},

	phone: function() {
			return regexes.phone.test(this.value) || this.error(_l("PHONE_DIGITS_ONLY"));
		},

	login: function(confirm) {
			return regexes.login.test(this.value) || this.error(_l("ID_FORMAT"));
		},

	password: function(confirm) {
			var err = regexes.password.test(this.value);
			if (!err)
				return this.error(_l("ALDIGITS_ONLY"));

			var caps = 0, pass = this.value, reUpCase = /^[A-Z]+$/;
			for (var i = 0; i < pass.length; ++i)
				caps += reUpCase.test(pass.charAt(i));

			if (caps >= pass.length * .8)
				return this.ok("[CapsLock]");

			return true;
		},

	custom: function() {
			return true;
		},

	date: function() {
			return regexes.date.test(this.value) || this.error(_l("INVAL_DATE"));
		},

	time: function() {
			return regexes.time.test(this.value) || this.error(_l("INVAL_TIME"));
		},

	pin: function() {
			return regexes.pin.test(this.value) || this.error(_l("INCORR_PIN4"));
		},

	ports: function() {
			var err = regexes.ports.test(this.value);
			if (!err)
				return this.error(_l("INCORR_PORTS"));

			var pool = this.value.split('-'),
			    left = pool[0] * 1,
			    right = ((pool.length > 1) ? pool[1] : pool[0]) * 1;

			if (left < 1 || left > 65535 || right < 1 || right > 65535)
				return this.error(_l("SHOULD_BE_BETWEEN", 1, 65535));

			if (right < left)
				return this.error(_l("REVERSED_POOL"));

			this.parsedValue = [left, right];
			return true;
		},

	wpspin: function() {
			if (regexes.WPSPin.test(this.value)) {
				var acc = 0, pin = this.value;
				for (var i = 0; i < 8; i += 2)
					acc += 3 * parseInt(pin.charAt(i))
						+ parseInt(pin.charAt(i+1));
				acc %= 10;
				return this.isError(acc == 0 ? "" : _l("WRONG_PIN"));
			}
			return this.error(_l("INCORR_PIN8"));
		},

	ascii: function() {
			return regexes.ascii.test(this.value) || this.error(_l("ASCII_ONLY"));
		},

	printable: function() {
			return regexes.prinable.test(this.value) || this.error(_l("PRINTABLE_ONLY"));
		},

	psk_hex: function() {
			var length = this.value.length;
			if (regexes.hex.test(this.value))
				return length == 64 || this.error(_l("NEED_64_DIGITS", length));

			return this.error(_l("HEX_ONLY"));
		},

	psk_passphrase: function() {
			if (!regexes.prinable.test(this.value))
				return this.error( _l("ASCII_ONLY"));

			return (this.value.length >= 8) || this.error(_l("ATLEAST_8ASCIIs"));
		},

	atcmd: function() {
			return regexes.atcmd.test(this.value) || this.error(_l("AT_ONLY"));
		},

	disable: function() {
			return this.error(this.params.join(","));
		},

	attention: function() {
			return this.warning(this.params.join(","));
		},

/* ------------ status --------------- */
	error: function (com) {
			this.status = this.ERROR;
			this.comment = com;
			return false;
		},

	warning: function (com) {
			this.status = this.WARNING;
			this.comment = com;
			return true;
		},

	ok: function (com) {
			this.status = this.OK;
			this.comment = com;
			return true;
		},

	isError: function (com) {
			if (com != "") {
				this.status = this.ERROR;
				this.comment = com;
				return false;
			}
			return true;
		},

	updateComment: function () {
		if (this.fresh && (!this.comment || this.comment == " ")) {
			switch (this.element.type) {
			case "button":
			case "submit":
			case "file":
				break;

			default:
				$(this.element).setSubClass('blend', this.commentClass[this.status]);
			}
			return;
		}

		this.fresh = false;

		var env = hint.box(this.element);
		switch (this.element.type) {
		case "button":
		case "submit":
			var c = hint.left(env.box);
			c.innerHTML = this.comment;
			c.className = "fullist " + this.commentClass[this.status];
			break;

		case "file":
			var c = hint[this.commentMethod](env.box);
			c.innerHTML = this.comment;
			c.className = "comment " + this.commentClass[this.status];
			break;

		default:
			var subclass = this.commentClass[this.status],
			    c = hint[this.commentMethod](env.box);
			c.innerHTML = this.comment;
			c.className = "comment " + subclass;
			$(env.frame).setSubClass('blend', subclass);
		}
	}
};

/* ------------------------------------------------------------------------ */
function groupValidator(formVr, format_s, callback_s) {
	this.formValidator = formVr;
	this.format = format_s;
	if (format_s == 'default')
		this.format = ['isAllValid'];
	else
		this.format = format_s.split(",");
	if (typeof callback_s != 'undefined')
		this.callback_s = callback_s;
}
/* ------------------------------------------------------------------------ */
groupValidator.prototype = {
	add: function (parser) {
			if (parser)
				this.push(parser);
		},

	_execFormat: function (name) {
			if (!(name in this)) {
				for (var i = 0; i < this.length; ++i)
					this[i].error("unknown group validator '"+name+"'");
				return false;
			}
			return this[name].call(this);
		},

	validate: function () {
			var ok = true,
			    a = this.format;

			if (a != 'optional' && !this.isAllValid())
				return false;

			for (var i = 0; i < a.length; ++i)
				if ((ok = this._execFormat(a[i])) < 0)
					break;

			if (ok != 0)
				return ok;

			if ('callback_s' in this) {
				a = this['callback_s'];
				if (typeof a == "function")
					return a.call(this);
				else
					for(var i = 0; i < a.length; ++i)
						if ((ok = a[i].call(this)) < 0)
							break;
				return true;
			}
			return false;
		},

	isAllValid: function () {
			var valid = true;
			for (var i = 0; i < this.length; ++i)
				valid &= this[i].isValid();
			return valid;
		},

	isSkip: function () {
			for (var i = 0; i < this.length; ++i)
				if (this[i].skip)
					return true;
			return false;
		},

	updateComments: function () {
			for (var i = 0; i < this.length; ++i)
				this[i].updateComment();
		},

	optional: function () { /* ok if all group elements are empty */
			for (var i = 0; i < this.length; ++i)
				if (this[i].value.length != 0)
					return true;

			return this.ok(""), -1; // ok and stop
		},

	match: function () { /* ok if all group emements are equal */
			var value = this[0].value;

			for (var i = 1; i < this.length; ++i)
				if (!this[i].skip)
					if (this[i].value != value)
						return this[i].error(_l("PASSW_NOT_MATCH"));

			return true;
		},

	pool: function () {
			if (this.isSkip())
				return true;

			var ok = (this[0].parsedValue <= this[1].parsedValue) ||
				this[1].error(_l("SHOULD_BE_GE_THAN_1ST"));

			if (ok && this.length >= 3) {
				var from = this[0].parsedValue,
				    to   = this[1].parsedValue,
				    lan  = this[2].parsedValue;

				if (from <= lan && lan <= to)
					ok = this[0].error(_l("SHOULDNT_BE_IN_POOL", IP.toStr(lan)));
			}

			return ok;
		},

	portsForward: function () {
			if (this.isSkip())
				return true;

			var inPorts = this[0].parsedValue,
			    destPorts = this[1].parsedValue,
			    inBound = inPorts[1] - inPorts[0],
			    destBound = destPorts[1] - destPorts[0];

//			alert([inPorts.join('-'), destPorts.join('-')].join('#'));
			if (inBound != destBound) {
				if (destBound)
					return this[1].error(_l("INVALID_DEST_PORTS"));
			}
			return true;
		},

	ipNet: function () { /* first two group elements should be net_ip & net_mask */
			if (this[0].skip || this[1].skip)
				return true;

			var net_ip = this[0].parsedValue,
				net_mask = this[1].parsedValue,
				ip = ~net_mask & net_ip;

			return ip && (ip != ~net_mask) ||
				this[0].error(_l("SHOULDNT_BE_ONEOF", IP.toStr(net_ip & net_mask), IP.toStr(net_ip | ~net_mask)));
		},

	inNet: function () { /* first two group elements should be net_ip & net_mask */
			var net_ip = this[0].parsedValue;
			var net_mask = this[1].parsedValue;
			var ok = true;
			for (var i = 2; i < this.length; ++i)
				if (!this[i].skip && this[i].parsedValue != '')
					ok &= this[i].isError(IP.inNet(this[i].parsedValue, net_ip, net_mask));
			return ok;
		},

	localIp: function() {
			var ok = true;
			for (var i = 0; i < this.length; ++i)
				if (!this[i].skip)
					ok &= this[i].isError(IP.inNet(this[i].parsedValue, mib.lan_ip, mib.lan_mask));
			return ok;
		},

	notBCastIP: function() {
			var ok = true, err, ip;
			for (var i = 0; i < this.length; ++i)
				if (!this[i].skip) {
					err = "";
					ip = this[i].parsedValue;
					if ((ip & ~mib.lan_mask) == ~mib.lan_mask)
						err = _l("SHOULDNOTBEBROADCAST");
					else
						if (mib.dhcp_server && mib.dhcp_pool[0] <= ip && ip <= mib.dhcp_pool[1])
							err = _l("SHOULDNOTBEFROMDHCPPOOL", IP.toStr(mib.dhcp_pool[0]), IP.toStr(mib.dhcp_pool[1]));
					ok &= this[i].isError(err);
				}
			return ok;
		},

	wanIp: function() {
			var ok = true;
			for (var i = 0; i < this.length; ++i)
				if (!this[i].skip)
					ok &= this[i].isError(IP.inNet(this[i].parsedValue, mib.wan_ip, mib.wan_mask));
			return ok;
		},

	notWan: function() {
			var ok = true;
			for (var i = 0; i < this.length; ++i)
				if (!this[i].skip)
					ok &= this[i].isError(
						IP.inNet(this[i].parsedValue, mib.wan_ip, mib.wan_mask) == "" ?
							_l("NOT_WAN") : "");
			return ok;
		},

	net: function() {
			var net_ip = this[0].parsedValue;
			var net_mask = this[1].parsedValue;
			if ((net_ip & ~net_mask) != 0)
				return this[0].error(_l("NEED_IP_LIKE", IP.toStr(net_ip & net_mask)));

			return true;
		},

	voipPort: function() {
			if (this.isSkip())
				return true;

			var voipPort = this[0].element.value,
			    iptvPort = this[1].element.value;

			if ((iptvPort == 4) ? (voipPort >= 2) : (iptvPort == voipPort))
				return this[0].error(_l("VOIP_PORT_EQ_IPTV"));

			return true;
		},

	ok: function (comment) {
			for (var i = 0; i < this.length; ++i)
				this[i].ok(comment);
			return true;
		},

	length: [].length,
	push:   [].push,
	pop:    [].pop
};
/* ------------------------------------------------------------------------ */
function formValidator(form) {
	this.form = form;
	this.parsers = [];
	this.parsers.length = 0;
	this.ok = 1;
	this.enabled = true;
	this.submits = "save,send,add";
	this.push(
		new groupValidator(this, "default"));
}
/* ------------------------------------------------------------------------ */
formValidator.prototype = {
	enable: function(yes) {
			this.enabled = yes;
		},

	addElement: function (el, format, callback_s) {
			if (!(el.name in this.parsers))
				++this.parsers.length;
			return this[0].add(
				this.parsers[el.name] = new elementParser(this, el, format, callback_s)
			);
		},

	addGroup: function (sel, format, callback_s) {
			var group = new groupValidator(this, format, callback_s);
			for (var i = 0; i < sel.length; ++i) {
				var name = sel[i].name;
				if (!(name in this.parsers))
					this.addElement(this.form[name], "printable");
				group.add(this.parsers[name]);
			}

			this.push(group);
		},

	parse: function () {
			var valid = true;
			var ps = this.parsers;
			for (var name in ps)
				valid &= ps[name].parse();
			return valid;
		},

	validate: function () {
			var valid = true;
			for (var i = 0; i < this.length; ++i)
				valid &= this[i].validate();
			return valid;
		},

	updateComments: function () {
			var ps = this.parsers;
			for (var name in ps)
				ps[name].updateComment();
		},

	isEmpty: function () {
			return this.parsers.length == 0;
		},

	el: function (name) { return this.parsers[name]; },

	length: [].length,
	push:   [].push,
	pop:    [].pop
};
/* ------------------------------------------------------------------------ */
function initForm(form) {
	form.validation = new formValidator(form);
	updateForm.call(form[0], { target: form[0], type: "init" } );
}
function tickForm(form) {
	updateForm.call(form[0], { type: "tick", target: form[0] });
}
/* ------------------------------------------------------------------------ */
function updateAllForms() {
	var forms = document.forms;
	for (var i = 0; i < forms.length; ++i)
		initForm(forms[i]);

	if ('applying' in top)
		top.applying.stop();
}
/* ------------------------------------------------------------------------ */
function postponeValidation(form) {
	if (form.validationTimeoutId)
		clearTimeout(form.validationTimeoutId);

	form.validationTimeoutId = setTimeout("validateFormOnFly(document."+form.name+")", 50);
}
/* ------------------------------------------------------------------------ */
function validateField(event) {
	postponeValidation(this.form);
}
/* ------------------------------------------------------------------------ */
function validateFormOnFly(form) {
	if (!('validation' in form))
		return false;

	var v = form.validation;
	var valid = v.enabled;

	if (valid && !v.isEmpty()) {
		v.parse();
		valid = v.validate();

		v.updateComments();
	}

	if (typeof postValidate == "function")
		valid = postValidate(form, valid);

	v.ok = valid;

	_(form, v.submits).enable(valid);
	return valid;
}
/* ------------------------------------------------------------------------ */
function submitForm(event)
{
	event = event || window.event;
	if (!validateFormOnFly(this))
		return false;

	var ok = true;
	if (typeof submit == "function")
		ok = submit.call(this, event);


	if (ok) {
//		ajaxSubmit(this);
//		return false; // to cancel normal submit
		if ('applying' in top)
			top.applying.start('busyMessage' in this ? this['busyMessage'] : null);
		setTimeout("_(document."+this.name+", \"save,send,add\").enable(false);", 1);
		postponeValidation(this);
	}

	return ok;
}
/* ------------------------------------------------------------------------ */
function updateForm(event)
{
	event = event || window.event;
	var form = this.form;

	if (typeof update == "function")
		update.call(this, event, form, event.type);

	postponeValidation(form);
}
/* ------------------------------------------------------------------------ */
function submitClick(event) {
	this.focus();
}
/* ------------------------------------------------------------------------ */
function row_onSelect(event) {
		var sel = this.getElementsByTagName("input");
		if (0 in sel) {
			sel = sel[0];
			sel.checked = !sel.checked;
			updateForm.call(sel, { target: sel, type: "click" } );
		}
		return true;
}
function checkClick(event) {
		this.checked = !this.checked;
		return true;
}
/* ------------------------------------------------------------------------ */
function updateStdDelForm(event, form, type) {
	var selects = _(form, "/select\\d+");
	_(form, "del")
		.enable(selects.checked().length != 0);

	if (type === 'init') {
		selects.setEvents( { click: updateForm } );

		$('some_table').byTag('tr')
			.shift().setEvents({ click: row_onSelect });

		$('some_table').byTag('input')
			.setEvents({ click: checkClick });

		_(form, "del,delAll")
			.setEvents( { click: submitClick } );

		_(form, "delAll")
			.enable(selects.length != 0);
	}
}

/* ------------------------------------------------------------------------ */
function submitStdDelForm(event) {
	return document.activeElement.name == "delAll" ? 
		confirm(_l("CONFIRM_DELALL")) :
		confirm(_l("CONFIRM_DEL"));
}
/* ------------------------------------------------------------------------ */
var ajaxObject = function() {
	return "ActiveXObject" in window ? new ActiveXObject("Microsoft.XMLHTTP") : new XMLHttpRequest();
}
/* ------------------------------------------------------------------------ */
var ajax;
/* ------------------------------------------------------------------------ */
function sendSyncAjaxRequest(reqName, data, callback) {
	ajax = new ajaxObject();
	if (callback)
		ajax.onreadystatechange = callback;
	else
		ajax.onreadystatechange = function (event) {};

	ajax.open("GET", '/req/'+reqName, false);
	ajax.setRequestHeader("If-Modified-Since", "Sat, 1 Jan 1996 00:00:00 GMT");
	ajax.send(data);
	return ajax.responseText;
}

/* ------------------------------------------------------------------------ */
function sendAjaxRequest(reqName, data, callback) {
	ajax = new ajaxObject();
	if (callback)
		ajax.onreadystatechange = callback;
	else
		ajax.onreadystatechange = function (event) {};

	ajax.open("GET", '/req/'+reqName, true);
	ajax.send(data);

	return ajax;
}

/* ------------------------------------------------------------------------ */
function ajaxGet(req, func, obj) {
	var aj = ajaxObject();
	aj.onreadystatechange = function (state) {
			func.call(obj, aj, state);
			if (aj.readyState == 4 && aj.status == 200) {
				delete aj.onreadystatechange;
				delete aj;
			}
		};
	aj.open("GET", req, true);
	aj.setRequestHeader("If-Modified-Since", "Sat, 1 Jan 1996 00:00:00 GMT");
	aj.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
	aj.send(null);
	return aj;
}

/* ------------------------------------------------------------------------ */
var zyStatus = {
	timer: 0,
	height: 0,
	speed: 10,
	ajax: null,
	pos: 0,
	q: {},

	init: function (id, msg) {
			this.element = $(id).el;
			this.clear(msg);
			this.element.zyStatus = this;
		},

	onstate: function (event) {
			var aj = zyStatus.ajax;
			if (aj.readyState >= 3) {
				if(aj.status == 200)
					zyStatus.queueResponse(aj.responseText);

				if (aj.readyState == 4)
					zyStatus.ajax = null;
			}
		},

	request: function (reqName, data) {
			if (this.ajax !== null)
				this.ajax.abort();

			this.pos = 0;
			this.ajax = new ajaxObject();
			this.ajax.onreadystatechange = this.onstate;
			this.ajax.open("POST", '/req/'+reqName, true);
			this.ajax.setRequestHeader("If-Modified-Since", "Sat, 1 Jan 1996 00:00:00 GMT");
			this.ajax.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
			this.ajax.send(data);
		},

//	reLine: /[^ ]\n/,
	reSplit: /^(.+):\s+(.*)$/,

	queueResponse: function (responseText) {
			var eoln,
			    tail = responseText.substr(this.pos);
/*			while (eoln = this.reLine.exec(tail)) {
				eoln = eoln.index;
				this.queueLine(tail.substr(0, eoln));
				this.pos += eoln + 2;
				tail = tail.substr(eoln + 2);
			}*/

			while ((eoln = tail.indexOf("\n")) >= 0) {
				this.queueLine(tail.substr(0, eoln++));
				this.pos += eoln;
				tail = tail.substr(eoln);
			}
		},

	queueLine: function(line) {
			var m = this.reSplit.exec(line);
			if (m != null) {
				if (!(m[1] in this.q))
					++this.height;
				this.q[m[1]] = m[2];
			} else {
				if (!(line in this.q))
					++this.height;
				this.q[line] = '`';
			}

			if (this.timer == 0)
				this.step();
		},

	updateTimer: function () {
			this.timer = setTimeout(function () {
					zyStatus.timer = 0;
					zyStatus.step();
				}, this.speed);
		},

	step: function () {
			if (!this.height)
				return;

			var q = this.q,
			    el = this.element;

			while (el.rows.length)
				el.deleteRow(0);

			for (var label in q) {
				var row = el.insertRow(el.rows.length);
				if (q[label] == '`') {
					var cell = row.insertCell(0);
					cell.colSpan = 2;
					cell.innerHTML = _l(label);
				} else {
					row.insertCell(0).innerHTML = _l(label);
					row.insertCell(1).innerHTML = _l(q[label]);
				}
			}
		},

	clear: function (msg) {
			if (this.timer != 0) {
				clearTimeout(this.timer);
				this.timer = 0;
			}
			this.q = {};
			this.height = 0;
			if (typeof msg == 'string') {
				var el = this.element;

				while (el.rows.length)
					el.deleteRow(0);

				var cell = el.insertRow(0).insertCell(0);
				cell.innerHTML = msg;
				cell.colSpan = 2;
			}
			this.step();
		}
};

/* ------------------------------------------------------------------------ */
var autoStatus = {
	ajax: null,
	element: null,
	timer: 0,
	timeout: 2000,
	data: { state: '' },
	tickData: null,

	oneval: function () {
			this.set(this.data.state);
		},

	onstate: function (event) {
			var aj = autoStatus.ajax;
			if (aj.readyState == 4) {
				if(aj.status == 200) {
					autoStatus.data = eval(['(', aj.responseText, ')'].join(''));
					autoStatus.oneval();
				}

				autoStatus.ajax = null;
			}
		},

	set: function(text) {
			var localed = _l(text),
			    changed = (this.element.innerHTML != localed);

			if (changed)
				this.element.innerHTML = localed;

			if (this.done(text, changed))
				this.start();
		},

	stop: function() {
			if (this.timer != 0) {
				clearInterval(this.timer);
				this.timer = 0;
			}
		},

	start: function () {
			if (this.timer == 0)
				this.timer = setInterval("autoStatus.tick()", this.timeout);
		},

	send: function (data, waitMsg) {
			if (waitMsg !== "-")
				this.set(waitMsg || ["<small>[", _l("Waiting for answer..."), "]</small>"].join(''));

			if (this.ajax)
				this.ajax.abort();

			this.ajax = ajaxObject();
			this.ajax.onreadystatechange = this.onstate;
			this.ajax.open("POST", this.reqUrl, true);
			this.ajax.setRequestHeader("If-Modified-Since", "Sat, 1 Jan 1996 00:00:00 GMT");
			this.ajax.send(data);
		},

	tick: function () {
			this.send(this.tickData, "-");
		},

	request: function (data, waitMsg) {
			this.stop();
			this.send(data, waitMsg);
		},

	message: function (text) {
			this.stop();
			this.set(text);
		},

	init: function (reqName, data, id) {
			this.reqName = reqName;
			this.reqUrl = /^(\w{3,8}:\/)?\/.*/.test(reqName) ? reqName : '/req/'+reqName;
			this.tickData = data;
			this.element = $(id).el;
			setTimeout("autoStatus.start();autoStatus.tick();", 200);
		},

	done: function (text, changed) {
			return true;
		}
};

/* ------------------------------------------------------------------------ */
function tblPlace() {
}

tblPlace.prototype = {
	value: '',
	row_index: 0,
	row_data: [],

	copyAttrs: function (el, attrs) {
			for (aid in attrs) {
				var val = attrs[aid];
				switch (typeof val) {
				case 'object':
					if (!el[aid])
						el.setAttribute(aid, "");

					var subel = el[aid];
					for (var subid in val)
						subel[subid] = val[subid].replace('@', this.value);
					break;

				case 'string':
					el[aid] = val.replace('@', this.value);
					break;

				case 'function':
					val = val.call(this, el);
					if (val != null)
						el[aid] = val;
				}
			}
		}
};

/* ------------------------------------------------------------------------ */
var Table = {
	empty: { className: "empty", innerHTML: _l("no entries") },
	tr: { className: function(row) {
				return (!this.row_index ? "first ":"")+((this.row_index & 1) ? "odd" : "even"); }
		},

	copyAttrs: function (el, attrs) {
			for (var aid in attrs) {
				var val = attrs[aid];
				switch (typeof val) {
				case 'object':
					if (!el[aid])
						el.setAttribute(aid, "");

					var subel = el[aid];
					for (subid in val)
						subel[subid] = val[subid];
					break;

				case 'string':
					el[aid] = val;
				}
			}
		},

	create: function (attrs) {
			var tbl = $_("table");
			if (attrs)
				this.copyAttrs(tbl, attrs);
			return tbl;
		},

	appendRow: function (tbl, attrs) {
			var row = tbl.insertRow(-1);
			if (attrs)
				this.copyAttrs(row, attrs);
			return row;
		},

	appendTH: function (row, attrs) {
			var th = $_("th");
			if (attrs)
				this.copyAttrs(th, attrs);
			row.appendChild(th);
			return th;
		},

	appendTD: function (row, attrs) {
			var td = $_("td");
			if (attrs)
				this.copyAttrs(td, attrs);
			row.appendChild(td);
			return td;
		},

	toDOM: function (rows, tpl) {
			var tbl = this.create(tpl.table),
			    thead = tbl.createTHead(),
			    th_row = thead.insertRow(-1),
			    tbody = $_("tbody"),
			    rowFn = tpl.rowFn || this.rowFn,
			    cols = tpl.cols,
			    th = tpl.th,
			    td = tpl.td,
			    cols_count = 0,
			    place = new tblPlace();

			tbl.appendChild(tbody);

			if ('cap' in tpl) {
				var cell = $_("th");
				place.copyAttrs(cell, tpl.cap.th);
				th_row.appendChild(cell);
				th_row = thead.insertRow(-1);
			}

			for (var col in cols) {
				var cell = $_("th");

				place.copyAttrs(cell, th);

				if ('th' in cols[col])
					place.copyAttrs(cell, cols[col].th);

				th_row.appendChild(cell);
				++cols_count;
			}

			if (rows.length == 0) {
				var row = tbody.insertRow(-1),
				    cell = row.insertCell(-1);

				place.copyAttrs(row, this.tr);
				place.copyAttrs(cell, tpl.empty || this.empty);

				cell.colSpan = cols_count;
			}

			for (var idx = 0; idx < rows.length; ++idx) {
				var row = tbody.insertRow(-1);

				place.row_data  = rows[idx];
				place.row_index = idx;

				place.copyAttrs(row, this.tr);
				if ('tr' in tpl)
					place.copyAttrs(row, tpl.tr);

				if (typeof place.row_data == "object") {
					for (col in cols) {
						var cell = row.insertCell(-1);

						place.value = place.row_data[col];

						place.copyAttrs(cell, td);
						if ('td' in cols[col])
							place.copyAttrs(cell, cols[col].td);
					}
				} else {
					var cell = row.insertCell(-1);
					cell.colSpan = cols_count;
					place.value = place.row_data;
					place.copyAttrs(cell, td);
				}
			}
			return tbl;
		}
};

/* ------------------------------------------------------------------------ */
var presets = {
	init: function(selector, tpl, _sel) {
			var list = tpl.list,
			    cols = tpl.cols,
			    sel = (_sel !== undefined) ? _sel : '';
			while (selector.length > 0)
				selector.remove(0);

			if (typeof list != "object") {
				var i = 0,
				    col = list;
				tpl.list = list = {};
				for (var row in tpl.rows)
					list[tpl.rows[row][col]] = i++;
			}

			for (var name in list) {
				var op = $_("option"),
				    value = list[name];
				op.innerHTML = name;
				op.value = value;
				selector.appendChild(op);

				var preset = tpl.rows[value];
				for (var idx = 0; idx < cols.length; ++idx) {
					var def = preset[idx],
					    same = (typeof (def || '') != 'object') ?
					        mib[cols[idx]] == (def || ''):
					        def.join('~').indexOf(mib[cols[idx]].toString()) >= 0;
					if (!same)
						break;
				}

				if (same) {
					op.selected = true;
					sel = value;
				}
			}
			if (!same)
				selector.value = sel;
			this.select(selector.form, sel, tpl, 1);
		},

	select: function(form, name, tpl, notfill) {
			var rows = tpl.rows,
			    cols = tpl.cols,
			    preset = rows[name];
			for (var idx = 0; idx < cols.length; ++idx) {
				var el = cols[idx] in form ? form[cols[idx]] : null,
				    def = preset[idx],
				    val = (def !== null && typeof def == 'object') ? def[0] : (def||'');
				if (!notfill && el)
					if (!('tagName' in el)) // probably array of radio buttons
						el[def].checked = 1;
					else
						if (el.tagName == 'checkbox')
							el.checked = val;
						else
							el.value = val;
				$(["cell", cols[idx]].join('_'))
					.show((def !== null) && ((typeof def != 'object') || def.length > 1));
			}
		}
};

/* ------------------------------------------------------------------------ */
var Funs = {
	gauge: function (value, max_value, width, height, suffix) {
			var container = $_("div"),
			    indicator = $_("div");

			if (value > max_value)
				value = max_value;

			container.className = 'gauge'+suffix;
			container.setAttribute("style", ["width:",width,"em;height:",height,"em"].join(''));

			indicator.className = 'mercury'+suffix;
			indicator.setAttribute("style", ["width:", Math.round(width*value*100/max_value)/100, "em;height:",height,"em"].join(''));

			container.appendChild(indicator);
			return container;
		},

	imgs: {},
	preloadImages: function (pathes) {
			var root = document.URL;
			root = root.slice(0, root.indexOf('/', 8));
			for (var id in pathes) {
				var im = $_('img');
				im.src = root+pathes[id];
				this.imgs[id] = im;
			}
		}
};

/* ------------------------------ tree view part ---------------------------------*/
var TREE = {
	LEAF: 0,
	FILE: 1,
	LINK: 2,
	FAIL: 3,
	NODE: 10,
	FOLDER: 11,
	ROOT: 20
};

var treeView = {
	icons: { lines: "/i/ics_lines.gif", dir_o: "/i/ic_folder_o.png", dir_c: "/i/ic_folder_c.png", file: "/i/ic_file.png" },

	nodeClick: function () {
			this.trig();
		},

	leafClick: function () {
		},


	leaf: function (arg) {
			var event = arg || window.event;
			treeView.leafClick.call(this.parentNode.treeItem);
			return treeView.stop(event);
		},

	node: function (arg) {
			var event = arg || window.event;
			treeView.nodeClick.call(this.parentNode.treeItem);
			return treeView.stop(event);
		},

	ctrl: function (arg) {
			var event = arg || window.event;
			this.parentNode.treeItem.trig();
			return treeView.stop(event);
		},

	out: function (arg) {
			var event = arg || window.event;
			fileBrowser.close();
			return treeView.stop(event);
		},

	stop: function (event) {
			if (event.stopPropagation)
				event.stopPropagation();
			else
				event.cancelBubble = true;
			return false;
		}
};

function treeNode(type, rec) {
	this.type = type;

	if (type >= TREE.FOLDER)
		this.stub = true;

	if (type >= TREE.NODE)
		this.closed = true;

	this.parent = null;
	this.row = null;
	for (n in rec)
		this[n] = rec[n];
}

treeNode.prototype = {
	length: [].length,
	_push: [].push,
	_pop: [].pop,

	newSub: function (type, rec) {
			var item = new treeNode(type, rec);
			item.parent = this;
			this._push(item);
			return item;
		}, 

	addTree: function (tree) {
			for (l in tree) {
				var it = tree[l];
				if (typeof it == "string")
					this.newSub(TREE.LINK, {name:l, link:it});
				else
					this.newSub(TREE.NODE, {name:l})
						.addTree(it);
			}
		},

	folderClick: function (event) {
			var self = this.parentNode.treeItem;
			treeView.folderClick.call(self);
		},

	trig: function () {
			if (this.stub){
				this.subReq();
				return;
			}

			if (this.type >= TREE.NODE)
				this.open(this.closed);
		},

	getPathArray: function () {
			if (!this.parent)
				return [this.name];

			var up = this.parent.getPathArray();
			up.push(this.name);
			return up;
		},

	getPath: function () {
			return this.getPathArray().join('/');
		},

	create: function (tbody, is_last) {
			if (this.type != TREE.ROOT) {
				var row = tbody.insertRow(-1),
				    ctrl = row.insertCell(0),
				    text = row.insertCell(1);

				this.row = row;
				row.className = 'tvr_line';
				row.treeItem = this;
				ctrl.className = is_last ? 'tvbg_last' : 'tvbg_middle';

				text.innerHTML = this.name;
				if (this.type < TREE.NODE)
					_(text).setEvents({ click: treeView.leaf });
				else {
					_(ctrl).setEvents({ click: treeView.ctrl });
					_(text).setEvents({ click: treeView.node });
				}
			}

			switch (this.type) {
			case TREE.LEAF:
				text.className = "ic_leaf";
				break;

			case TREE.FILE:
				text.className = "ic_file";
				break;

			case TREE.LINK:
				text.className = "ic_link";
				break;

			case TREE.FAIL:
				text.className = "ic_fail";
				break;

			case TREE.NODE:
			case TREE.FOLDER:
				ctrl.innerHTML = [
					"<img class='tv_ctrl' src='/i/ic_", this.closed ? 'plus':'minus', ".gif'/>"].join('');
				text.className = this.closed ? 'ic_folder_c' : 'ic_folder_o';

				row = tbody.insertRow(-1);
				row.setAttribute('style', '');
				row.style.display = 'none';
				row.className = 'tvr_folder';
				ctrl = row.insertCell(0);
				ctrl.className = is_last ? 'tvbg_gap':'tvbg_skip';
				text = row.insertCell(1);
				text.className = 'tv_box';

			case TREE.ROOT:
				var tbl = $_("table"),
				    body = $_("tbody");
				tbl.className = (text) ? 'tvt_sub' : 'tvt_block';
				tbl.appendChild(body);
				this.subTable = tbl;
				this.subCreate();
				if (text)
					text.appendChild(tbl);
			}
		},

	open: function (yes) {
			if (this.subTable && this.row) {
				this.row.nextSibling.style.display = yes && this.length > 0 ? '' : 'none';
				var td = this.row.firstChild,
				    img = td.firstChild;
				img.src = img.src.replace(yes ? 'plus':'minus', !yes ? 'plus':'minus');
				td.nextSibling.className = yes ? 'ic_folder_o':'ic_folder_c';
				this.closed = !yes;
			}
		},

	subEvalList: function (text) {
			var sub = eval(text);
			sub.sort();
			delete this.stub;
			if (sub.length == 0) {
				this.newSub(TREE.FAIL, {'name':_l('Nothing here')});
			} else
				for (var i = 0; i < sub.length; ++i) {
					var it = sub[i],
					    type = TREE.FILE,
					    name = it.substr(1);
					switch (it.charAt(0)) {
					case '+': type = TREE.FOLDER; break;
					case '!': type = TREE.FAIL; name = _l(name); break;
					}
					this.newSub(type, {'name':name});
				}
			this.subCreate();
		},

	subEval: function (text) {
			var sub = eval(text);
			sub.sort(function(l, r) {
					if (((l.mode ^ r.mode) & 040000) == 0)
						return (l.name > r.name) ? 1 : ((l.name < r.name) ? -1 : 0);
					return (r.mode & 040000) ? 1 : -1;
				});
			delete this.stub;
			for (var i = 0; i < sub.length; ++i) {
				var it = sub[i];
				this.newSub(it.mode & 040000 ? TREE.FOLDER : TREE.FILE, it);
			}
			this.subCreate();
		},

	subCreate: function () {
			if ('subTable' in this) {
				var tbody = this.subTable.firstChild;
				for (var i = 0; i < this.length; ++i)
					this[i].create(tbody, i == this.length - 1);

				this.closed = true;
			}
		},

	subOnReq: function (aj, state) {
			if (aj.readyState == 4 && aj.status == 200) {
				this.subEvalList(aj.responseText);
				this.trig();
			}
		},

	subReq: function () {
			ajaxGet(
				['/req/', this.getPath(), '?list=1'].join(''),
				this.subOnReq, this);
		},

	selectPath: function (path) {
		}
};

var fileBrowser = {
	close: function () {
			$('_popup_').del();
		},

	show: function(name, place) {
			if ($("_popup_").el)
				return this.close();

			var div = $_('div');
			div.id = '_popup_';
			div.innerHTML = 
				"<div class='all' onclick='return treeView.out(arguments);'></div><div class='file_browser'></div>";
			document.body.appendChild(div);

			var tr = new treeNode(TREE.ROOT, { name: name });
			tr.create();
			tr.subReq();

			$(div.lastChild).placeUnder(place).append(tr.subTable);
		}
};

/* ------------------------------ fake upload part ---------------------------------*/
var fakeUpload = {
	cut: function (path) {
			var bs = path.lastIndexOf('\\');
			return bs >= 0 ? path.substr(bs+1) : path;
		},

	onHover: function (self, id) {
			$(id+'_go').setSubClass('butt', 'hover');
		},

	onOut: function (self, id) {
			$(id+'_go').setSubClass('butt', 'out');
		}
}
