<%	setMibsVars("DEVICE_NAME");
	htmlHead("ZyXEL "+DEVICE_NAME, "nolinks"); %>
<link rel='stylesheet' type='text/css' href='/css/msg.css?=<%=rvsn();%>'/>
<script type="text/javascript"><!--
var error = {
	code:    "<%=ERROR_CODE;%>",
	message: "<%=ERROR_MESSAGE;%>",
	text:    "<%=ERROR_TEXT;%>"
};

var messages = {
en: {
	200: "Data follows",
	204: "No Content",
	301: "Redirect",
	302: "Redirect",
	304: "User local copy",
	400: "Page not found",
	401: "Unauthorized",
	403: "Forbidden",
	404: "Site or Page Not Found",
	405: "Access Denied",
	413: "Request Entity Too Large",
	415: "Unsupported Media Type",
	420: "Process Failed",
	500: "Web Error",
	501: "Not Implemented",
	503: "Site Temporarily Unavailable. Try again." },
ru: {
	200: "Всё нормально",
	204: "No Content",
	301: "Redirect",
	302: "Redirect",
	304: "User local copy",
	400: "Страница не найдена",
	401: "Нет авторизации",
	403: "Закрыто",
	404: "Страница не найдена",
	405: "В доступе отказано",
	413: "Слишком длинный запрос",
	415: "Неподдерживаемый тип данных",
	420: "Сбой обработки",
	500: "Web Error",
	501: "Не реализовано",
	503: "Site Temporarily Unavailable. Try again." },
};

var lang = {
	"Incorrect file format": "Неверный формат файла",
	"Missing post data": "Отсутствуют данные",
	"File is too small": "Неверный формат файла. Файл слишком мал.",
	"Missing kernel header. Wrong firmware file format.": "Нет заголовка ядра",
	"Missing firmware magic. Wrong firmware file format.": "Нет признака ПО",
	"Firmware checksum not correct.": "Ошибочная контрольная сумма",
	"This firmware not for #1.": "Это ПО не для #1.",
	"Config file internal buffer overflow": "Переполнение внутреннего буфера",
	"Compress buffer overflow": "Переполнение буфера переполнения",
	"Memory overflow": "Переполнение памяти",
	"Cannot open URL <b>#1</b>": "Неверный путь к странице <b>#1</b>",
	"Invalid URL #1": "Кривой путь #1",
	"Access Denied<br/>Secure access is required.": "Нет доступа<br/>Требуется разрешение на доступ",
	"Page Not Found": "Страница не найдена",
	"Maximum upload data size is #1 bytes": "Нельзя залить более #1 байт",
	"Not enough memory": "Недостаточно памяти",
	"Insufficient memory": "Исчерпана память",
	"Bad HTTP request": "Неверный HTTP запрос",
	"Bad request type": "Неверный тип запроса",
	"Bad URL format": "Неферный формат пути",
	"Don't support plain auth": "Простая авторизация не поддерживается",
	"Access to this document requires a password": "Требуется пароль",
	"Access Denied<br/>Unknown User": "Неизвестный Пользователь",
	"Access Denied<br/>Prohibited User": "Заблокированный Пользователь",
	"Access Denied<br/>Wrong Password": "Ошибочный Пароль",
	"Access Denied<br/>All users login slots is busy now": "Все сессии уже использованы",
	"Access to this document requires a User ID": "Для доступа требуется Идентификатор Пользователя",
	"mkswap error: #1": "Ошибка создания файла подкачки: #1",
	"No space left on device": "Недостаточно свободного места"
};

function _l(str) {
	var out = (str in lang) ? lang[str] : str;

	if (arguments.length > 1) {
		switch (arguments.length) {
			case 6: out = out.replace("#5", _l(arguments[5]));
			case 5: out = out.replace("#4", _l(arguments[4]));
			case 4: out = out.replace("#3", _l(arguments[3]));
			case 3: out = out.replace("#2", _l(arguments[2]));
			case 2: out = out.replace("#1", _l(arguments[1]));
		}
	}

	return out;
}

function __translate_all() {
	var elHeader = document.getElementById("header"),
	    elText   = document.getElementById("text"),
	    broken   = error.text.split("|");

	elHeader.innerHTML = [error.code, messages.ru[error.code]].join(' ');
	elText.innerHTML   = _l.apply(broken, broken);

	var group = window.top.document.getElementById('busy');
	if (group) {
		group.parentNode.removeChild(group);
		delete group;
	}
}
--></script>
</head>
<body>
<div class='back'>
<div class='outer'>
<div id='logo_line'><%=DEVICE_NAME;%></div>
<div id='logo_underline'></div><div class="header">
<h2 id='header'><%=ERROR_CODE;%> <%=ERROR_MESSAGE;%></h2>
<p id='text'><%=ERROR_TEXT;%></p>
<input type='button' value='Вернуться' onclick='javascript:window.<%
	if (testVar("submit_url"))
		write("window.top.location.replace(\"/?page=", submit_url, "\")");
	else
		write("history.back()");
%>'/>
</div>
</div>
</div>
<script type="text/javascript">__translate_all();</script>
</body>
</html>
