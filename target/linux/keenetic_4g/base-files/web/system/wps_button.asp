<% htmlHead("Torrents"); %>
<script type="text/javascript"><!--
<%	setMibsVars(
		"TRNT_UMOUNT_BY_WPS_BUTTON");
%>
--></script>
</head>
<body class="body">
<% writeLeafOpen("Дополнительная функция кнопки «WPS»", 
	"Если вы пользуетесь USB-накопителем, можно назначить кнопке WPS функцию безопасного "+
	"отключения накопителей от интернет-центра. Чтобы не повредить информацию при "+
	"отключении, будет достаточно нажать кнопку WPS на интернет-центре и дождаться, "+
	"пока его индикатор USB перестанет мигать. Затем можно отключить накопитель или "+
	"питание интернет-центра.<br>В системе без установленных дисков сохраняется "+
	"стандартная функция кнопки."); %>

<% writeFormOpen("wpsButton"); %>
<table class="sublayout">
<tr>
	<td class='label'></td>
	<td class='field'>
	    <%=checkBox("TRNT_UMOUNT_BY_WPS_BUTTON"); %><label for='TRNT_UMOUNT_BY_WPS_BUTTON'>Безопасное отключение USB-накопителей</label>
	</td>
</tr>
<tr>
	<td class='label'></td>
	<td class='submit'><%=submit("Применить");%></td>
</tr>
</table>
</form>
<% writeLeafClose(); %>
<script type="text/javascript">updateAllForms();</script>
</body>
</html>
