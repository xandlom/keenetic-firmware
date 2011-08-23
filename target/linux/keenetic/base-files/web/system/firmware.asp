<% htmlHead("Firmware Update"); %>
<script type="text/javascript"><!--
<% binary = ""; %>
var msg_notice ="Пожалуйста, не выключайте интернет-центр в процессе обновления!";

function submit () {
	this.busyMessage = 'Preparing for update';
	return confirm(msg_notice);
}

function update(event, form, type) {
	if (type === 'init')
		_(form, "binary") .setParser("-none@bottom");
}
--></script>
</head>
<body class="body">
<% writeLeafOpen("Установка микропрограммы", 
	"Новую версию ПО интернет-центра (микропрограмму) можно получить на сайте "+
	"<a href='http://zyxel.ru/content/support/download/' target='_blank'> zyxel.ru</a><br>"+
	"Если вы получили обновление в zip-архиве, предварительно извлеките его в папку на "+
	"компьютере. Процесс обновления занимает несколько минут. Пожалуйста, не отключайте "+
	"интернет-центр до завершения обновления."); %>

<% writeFormOpen("upgrade", "enctype=\"multipart/form-data\" target='_top'"); %>
<table class="sublayout">
<tr>
	<td class='label'>Текущая версия ПО: </td>
	<td class='field' id='fw'><%=getFwVersion();%></td>
</tr>
<tr>
	<td class='label'>Файл микропрограммы:</td>
	<td class='field'><% writeInputFile("binary", 40); %></td>
</tr>
<tr>
	<td colspan='2' class='submit'>
		<span class='spoiler'><%=rvsn();%></span> <%=submit("send:Обновить");%>
	</td>
</tr>
</table>
</form>

<% writeLeafClose(); %>
<script type="text/javascript">
document.getElementById("fw").innerHTML += [" ", Fmt.fwdate("<%=getFwDate();%>", '-')].join('');
updateAllForms();
</script>
</body>
</html>
