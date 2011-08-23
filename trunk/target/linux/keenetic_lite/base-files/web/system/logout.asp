<% htmlHead("Logout"); %>
</head>

<script type="text/javascript"><!--
function logout() {
	if (confirm("Завершение работы с веб-конфигуратором интернет-центра.")) {
		sendSyncAjaxRequest('logout', null, null);
		window.top.location.replace("/free/bye.asp");
	} else
		window.location.replace("/status.asp");
}
--></script>
<body class="body" onload="logout()">
</body>
</html>
