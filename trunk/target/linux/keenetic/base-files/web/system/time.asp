<% htmlHead("Дата и время"); %>
<script type="text/javascript"><!--
<%
	setMibsVars("NTP_ENABLED", "TIMEZONE", "NTP_SERVER");
	setTimeVars(); /* time, date */
	writeMibProps("TIMEZONE", "NTP_ENABLED");

write("\nmib.time = \""+time+"\";\n");
write("mib.date = \""+date+"\";\n");
%>
function setCurrentTime(event) {
	var form = this.form;
	var date = new Date();

	form.date.value = [
			Fmt.dd(date.getDate()), Fmt.dd(date.getMonth() + 1), date.getFullYear()
		].join('/');

	form.time.value = [
			Fmt.dd(date.getHours()), Fmt.dd(date.getMinutes()), Fmt.dd(date.getSeconds())
		].join(':');

	form.submit();
}

function submit(event) {
	switch (this.name) {
	case "time":
		if (mib.time == this.time.value && mib.date == this.date.value)
			_(this, 'time,date') .enable(false);
	}

	return true;
}

function update(event, form, type) {
	var init = (type === 'init');
	switch (form.name) {
	case "time":
		if (init) {
			_(form, "date")   .setParser("date");
			_(form, "time")   .setParser("time");
			_(form, "date,time,setCurrent") .enable(mib.NTP_ENABLED == 0);
		}
		break;

	case "ntp":
		if (init)
			_(form, "NTP_SERVER")   .setParser("host");

		_(form, "NTP_SERVER")
			.enable(form.NTP_ENABLED.checked);
	}
}
--></script>
</head>

<body class="body">
<% writeLeafOpen("Системное время", 
	"Правильно установленное время необходимо для корректного отображения событий "+
	"в системном журнале интернет-центра. Можно использовать автоматическую "+
	"синхронизацию с сервером точного времени по протоколу NTP, установить дату и "+
	"время самостоятельно или взять время компьютера."); %>

<% writeFormOpen("ntp"); %>
<table id='ntp' class="sublayout">
<tr>
	<td class='label'></td>
	<td class='field'>
		<%=checkBox("NTP_ENABLED"); %><label for='NTP_ENABLED'>Автоматически синхронизировать время</label>
	</td>
</tr>
<tr>
	<td class='label'>Адрес NTP-сервера:</td>
	<td class='field'>
		<%=inputText("NTP_SERVER", 20, 50); %>
	</td>
</tr>
<tr>
	<td class='label'></td>
	<td class='submit'>
		<%=submit("Применить");%>
	</td>
</tr>
</table>
</form>

<% writeLeafSubheader("Текущее время интернет-центра"); %>

<% writeFormOpen("time"); %>
<table id='time' class="sublayout">
<tr>
	<td class='label'>Часовой пояс:</td>
	<td class='field'>
		<% writeSelectOpen("TIMEZONE"); %>
<!--
			<% writeOption("Азия — Актау","AQTT-4 Asia/Aqtau"); %>
			<% writeOption("Азия — Актобе","AQTT-5 Asia/Aqtobe"); %>
			<% writeOption("Азия — Алматы","ALMT-6 Asia/Almaty"); %>
			<% writeOption("Азия — Анадырь","ANAT-12ANAST,M3.5.0,M10.5.0/3 Asia/Anadyr"); %>
			<% writeOption("Азия — Ашхабад","TMT-5 Asia/Ashkhabad"); %>
			<% writeOption("Азия — Баку","AZT-4AZST,M3.5.0/1,M10.5.0/1 Asia/Baku"); %>
			<% writeOption("Азия — Бишкек","KGT-5KGST,M3.5.0/230,M10.5.0/230 Asia/Bishkek"); %>
			<% writeOption("Азия — Владивосток","VLAT-10VLAST,M3.5.0,M10.5.0/3 Asia/Vladivostok"); %>
			<% writeOption("Азия — Екатеринбург","YEKT-5YEKST,M3.5.0,M10.5.0/3 Asia/Yekaterinburg"); %>
			<% writeOption("Азия — Ереван","AMT-4AMST,M3.5.0,M10.5.0/3 Asia/Yerevan"); %>
			<% writeOption("Азия — Иркутск","IRKT-8IRKST,M3.5.0,M10.5.0/3 Asia/Irkutsk"); %>
			<% writeOption("Азия — Камчатка","PETT-12PETST,M3.5.0,M10.5.0/3 Asia/Kamchatka"); %>
			<% writeOption("Азия — Красноярск","KRAT-7KRAST,M3.5.0,M10.5.0/3 Asia/Krasnoyarsk"); %>
			<% writeOption("Азия — Кызылорда","QYZT-6 Asia/Qyzylorda"); %>
			<% writeOption("Азия — Магадан","MAGT-11MAGST,M3.5.0,M10.5.0/3 Asia/Magadan"); %>
			<% writeOption("Азия — Новосибирск","NOVT-6NOVST,M3.5.0,M10.5.0/3 Asia/Novosibirsk"); %>
			<% writeOption("Азия — Омск","OMST-6OMSST,M3.5.0,M10.5.0/3 Asia/Omsk"); %>
			<% writeOption("Азия — Орал","ORAT-4 Asia/Oral"); %>
			<% writeOption("Азия — Самарканд","UZT-5 Asia/Samarkand"); %>
			<% writeOption("Азия — Сахалин","SAKT-10SAKST,M3.5.0,M10.5.0/3 Asia/Sakhalin"); %>
			<% writeOption("Азия — Ташкент","UZT-5 Asia/Tashkent"); %>
			<% writeOption("Азия — Тбилиси","GET-3GEST,M3.5.0,M10.5.0/3 Asia/Tbilisi"); %>
			<% writeOption("Азия — Якутск","YAKT-9YAKST,M3.5.0,M10.5.0/3 Asia/Yakutsk"); %>

			<% writeOption("Европа — Запорожье","EET-2EEST,M3.5.0/3,M10.5.0/4 Europe/Zaporozhye"); %>
			<% writeOption("Европа — Калининград","EET-2EEST,M3.5.0,M10.5.0/3 Europe/Kaliningrad"); %>
			<% writeOption("Европа — Киев","EET-2EEST,M3.5.0/3,M10.5.0/4 Europe/Kiev"); %>
			<% writeOption("Европа — Минск","EET-2EEST,M3.5.0,M10.5.0/3 Europe/Minsk"); %>
			<% writeOption("Европа — Москва","MSK-3MSD,M3.5.0,M10.5.0/3 Europe/Moscow"); %>
			<% writeOption("Европа — Самара","SAMT-4SAMST,M3.5.0,M10.5.0/3 Europe/Samara"); %>
			<% writeOption("Европа — Симферополь","EET-2EEST,M3.5.0/3,M10.5.0/4 Europe/Simferopol"); %>
			<% writeOption("Европа — Ужгород","EET-2EEST,M3.5.0/3,M10.5.0/4 Europe/Uzhgorod"); %>
			
			<% writeOption("UTC—14","<GMT+14>14 Etc/GMT-14"); %>
			<% writeOption("UTC—13","<GMT+13>13 Etc/GMT-13"); %>
			<% writeOption("UTC—12","<GMT+12>12 Etc/GMT-12"); %>
			<% writeOption("UTC—11","<GMT+11>11 Etc/GMT-11"); %>
			<% writeOption("UTC—10","<GMT+10>10 Etc/GMT-10"); %>
			<% writeOption("UTC—9","<GMT+9>9 Etc/GMT-9"); %>
			<% writeOption("UTC—8","<GMT+8>8 Etc/GMT-8"); %>
			<% writeOption("UTC—7","<GMT+7>7 Etc/GMT-7"); %>
			<% writeOption("UTC—6","<GMT+6>6 Etc/GMT-6"); %>
			<% writeOption("UTC—5","<GMT+5>5 Etc/GMT-5"); %>
			<% writeOption("UTC—4","<GMT+4>4 Etc/GMT-4"); %>
			<% writeOption("UTC—3","<GMT+3>3 Etc/GMT-3"); %>
			<% writeOption("UTC—2","<GMT+2>2 Etc/GMT-2"); %>
			<% writeOption("UTC—1","<GMT+1>1 Etc/GMT-1"); %>
			<% writeOption("UTC","GMT0 Etc/GMT0"); %>
			<% writeOption("UTC+1","<GMT-1>-1 Etc/GMT+1"); %>
			<% writeOption("UTC+2","<GMT-2>-2 Etc/GMT+2"); %>
			<% writeOption("UTC+3","<GMT-3>-3 Etc/GMT+3"); %>
			<% writeOption("UTC+4","<GMT-4>-4 Etc/GMT+4"); %>
			<% writeOption("UTC+5","<GMT-5>-5 Etc/GMT+5"); %>
			<% writeOption("UTC+6","<GMT-6>-6 Etc/GMT+6"); %>
			<% writeOption("UTC+7","<GMT-7>-7 Etc/GMT+7"); %>
			<% writeOption("UTC+8","<GMT-8>-8 Etc/GMT+8"); %>
			<% writeOption("UTC+9","<GMT-9>-9 Etc/GMT+9"); %>
			<% writeOption("UTC+10","<GMT-10>-10 Etc/GMT+10"); %>
			<% writeOption("UTC+11","<GMT-11>-11 Etc/GMT+11"); %>
			<% writeOption("UTC+12","<GMT-12>-12 Etc/GMT+12"); %>
			
-->			
			<% writeOption("Азербайджан (GMT+4:00)","AZT-4AZST,M3.5.0/1,M10.5.0/1"); %>
			<% writeOption("Армения (GMT+4:00)","AMT-4AMST,M3.5.0,M10.5.0/3"); %>
			<% writeOption("Беларусь (GMT+2:00)","EET-2EEST,M3.5.0,M10.5.0/3"); %>
			<% writeOption("Грузия (GMT+4:00)","GET-3GEST,M3.5.0,M10.5.0/3"); %>
			<% writeOption("Казахстан — Восточное время	(GMT+6:00)","ALMT-6"); %>
			<% writeOption("Казахстан — Западное время	(GMT+5:00)","AQTT-5"); %>
			<% writeOption("Киргизия	(GMT+6:00)","KGT-5KGST,M3.5.0/230,M10.5.0/230"); %>
			<% writeOption("Россия — Владивостокское время	(GMT+10:00)","VLAT-10VLAST,M3.5.0,M10.5.0/3"); %>
			<% writeOption("Россия — Екатеринбургское время	(GMT+5:00)","YEKT-5YEKST,M3.5.0,M10.5.0/3"); %>
			<% writeOption("Россия — Иркутское время	(GMT+8:00)","IRKT-8IRKST,M3.5.0,M10.5.0/3"); %>
			<% writeOption("Россия — Калининградское время	(GMT+2:00)","EET-2EEST,M3.5.0,M10.5.0/2"); %>
			<% writeOption("Россия — Камчатское время	(GMT+12:00)","PETT-12PETST,M3.5.0,M10.5.0/3"); %>
			<% writeOption("Россия — Красноярское время	(GMT+7:00)","KRAT-7KRAST,M3.5.0,M10.5.0/3"); %>
			<% writeOption("Россия — Магаданское время	(GMT+11:00)","MAGT-11MAGST,M3.5.0,M10.5.0/3"); %>
			<% writeOption("Россия — Московское время	(GMT+3:00)","MSK-3MSD,M3.5.0,M10.5.0/3"); %>
			<% writeOption("Россия — Омское время	(GMT+6:00)","OMST-6OMSST,M3.5.0,M10.5.0/3"); %>
			<% writeOption("Россия — Самарское время	(GMT+4:00)","SAMT-4SAMST,M3.5.0,M10.5.0/3"); %>
			<% writeOption("Россия — Якутское время	(GMT+9:00)","YAKT-9YAKST,M3.5.0,M10.5.0/3"); %>
			<% writeOption("Туркмения	(GMT+5:00)","TMT-5"); %>
			<% writeOption("Узбекистан	(GMT+5:00)","UZT-5"); %>
			<% writeOption("Украина	(GMT+2:00)","EET-2EEST,M3.5.0/3,M10.5.0/4"); %>

		</select>
	</td>
</tr>
<tr>
	<td class='label'>Дата:</td>
	<td class='field'><%=inputText("date", 10, 10); %></td>
</tr>
<tr>
	<td class='label'>Время:</td>
	<td class='field'><%=inputText("time", 10, 8); %></td>
</tr>
<tr>
	<td class='label'></td>
	<td class='submit'><input name="setCurrent" type="button" value="Взять с компьютера" onclick="setCurrentTime.call(this, event)"/>
	<%=submit("#time", "Применить");%></td>
</tr>
<tr>
	<td colspan='2'></td>
</tr>
</table>
</form>
<% writeLeafClose(); %>

<script type="text/javascript">updateAllForms();</script>
</body>
</html>
