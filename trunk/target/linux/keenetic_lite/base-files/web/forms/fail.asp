<%	setMibsVars("DEVICE_NAME");
	htmlHead("ZyXEL "+DEVICE_NAME, "nolinks"); %>
<style type="text/css">
table, div { font-size: 14px; }
body, div {
	padding: 0px;
	margin: 0px 0px 0px 0px;
	font-family: arial, verdana, tahoma, helvetica, sans-serif;
}
body {
	background: #C5C9CF url('/i/config_bg.gif') repeat-x;
}
div.back {
	width: 100%;
	text-align: center;
}
div.outer {
	margin: 48px 8px 8px 8px;
	display: inline-block;
	background: #e7e7e7;
	width: 400px;
	border: 1px solid;
	border-color: #555;
}
div.header {
	padding: 8px 8px 20px 8px;
	border: 1px solid #FFFFFF;
}
#logo_line {
	display: block;
	background: #0C2F83 url('/i/logo.gif') no-repeat;
	text-align: left;
	height: 26px;
	vertical-align: bottom;
	font-size: 26px;
	color: #eef;
	font-weight: bold;
	font-family: Arial, Tahoma, sans-serif;
	text-align: right;
	font-style: italic;
	padding: 11px 33px 13px 245px;
}
#logo_underline {
	background: red;
	height: 4px;
	margin: 0px;
}
input[type=button] {
	background: #e7e7e7 url('/i/button_bg.gif') repeat-x;
	color: #333;
	border: 1px solid;
	border-color: #aba5a1;
	font-size: 14px;
}
input[type=button]:focus {
	border: dotted 1px #aba5a1;
}
input[type=button]:hover {
	color: #384e83;
}
</style>
<script type="text/javascript"><!--
var error = {
		title: "<%=RESULT_TITLE;%>",
		text:  "<%=RESULT_COMMENT;%>"
	},
    lang = {};

function _l(str) {
	var out = (str in lang) ? lang[str] : str;

	if (arguments.length > 1) {
		switch (arguments.length) {
			case 6: out = out.replace("#5", arguments[5]);
			case 5: out = out.replace("#4", arguments[4]);
			case 4: out = out.replace("#3", arguments[3]);
			case 3: out = out.replace("#2", arguments[2]);
			case 2: out = out.replace("#1", arguments[1]);
		}
	}

	return out;
}

function __translate_all() {
	var elHeader = document.getElementById("header"),
	    elText   = document.getElementById("text"),
	    broken_title  = error.title.split("|"),
	    broken_text   = error.text.split("|");

	elHeader.innerHTML = _l.apply(broken_title, broken_title);;
	elText.innerHTML   = _l.apply(broken_text, broken_text);
}
--></script>
</head>
<body>
<div class='back'>
<div class='outer'>
<div id='logo_line'><%=DEVICE_NAME;%></div>
<div id='logo_underline'></div><div class="header">
<h2 id='header'><%=RESULT_TITLE;%></h2>
<p id='text'><%=RESULT_COMMENT;%></p>
<input type="button" value="Назад" onclick="history.go (-1)"/>
</div>
</div>
</div>
<script type="text/javascript">__translate_all();</script>
</body>
</html>
