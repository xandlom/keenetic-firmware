<% htmlHead("Torrents"); %>
<script type="text/javascript"><!--
<%	setMibsVars("OP_MODE", 
		"TRNT_ENABLED", "TRNT_PORT", "TRNT_RPC_PORT", "TRNT_FOLDER",
		"TRNT_USER_NAME", "TRNT_USER_PASSWORD", 
		"TRNT_EXTERNAL_ACCESS_ENABLED", 
		"TRNT_USE_WEB_ACCOUNT_ENABLED", 
		"TRNT_AUTO_START_ENABLED",
		"TRNT_UMOUNT_BY_WPS_BUTTON",
		"WAN_IP_ADDR", "LAN_IP_ADDR",
		"FTP_ACCESS_ENABLED", "FTP_PORT",
		"SMB_ACCESS_ENABLED", "SMB_NAME");

	swap_status = checkSwap(TRNT_FOLDER);

	ext_string = "";
	if (TRNT_EXTERNAL_ACCESS_ENABLED)
		ext_string = "разрешить управлять им через Интернет, ";

	if (TRNT_ENABLED)
		info_installed =
			"Можно изменить основные параметры Transmission, например номер порта и учетную "+
			"запись для управления Transmission. Кнопка «Остановить клиент» приостанавливает "+
			"работу Transmission, кнопка «Запустить все торренты» запускает Transmission и "+
			"все существующие на нем торренты. Закаченные файлы хранятся в папке downloads "+
			"внутри рабочей папки Transmission.";
	else
		info_installed =
			"Вы можете включить Transmission и выбрать порт для входящих соединений в сети BitTorrent "+
			"и порт для управления Transmission. Можно также разрешить автозапуск Transmission при "+
			"обнаружении рабочей папки.";

	info_new = 
		"Для автономного обмена файлами в сети BitTorrent, надо подключить USB-диск. "+
		"Чтобы создать рабочую папку Transmission на подключенном диске щелкните «Установить».";

	if (swap_status == 'ok')
		info_text = info_installed;
	else
		info_text = info_new;

	disk = "";
	path = "";
	sub = "/downloads";

	smb_link = SMB_NAME + '/' + TRNT_FOLDER + sub;

	if (isAgent("indows"))
		smb_link = "\\\\" + slashesToBack(smb_link);
	else
		smb_link = "<a href='smb://" + smb_link + "'>smb://" + smb_link + "</a>";

	web_link = "http://" + LAN_IP_ADDR + ":" + TRNT_RPC_PORT + "/";

	link_port = '';
	if (FTP_PORT != 21)
		link_port = ':' + FTP_PORT;

	ftp_link = "ftp://" + LAN_IP_ADDR + link_port + '/' + TRNT_FOLDER + sub;
%>

var info_texts = [
	"<%=info_new;%>",
	"<%=info_installed;%>"];

_ru["Error: swap file is not loaded or corrupted! Please wait..."] = "Ошибка: Файл подкачки повреждён! Исправляем...";
_ru["Swap file has not been fixed...Bye!"] = "Ошибка: Файл подкачки восстановить не удалось.";
_ru["Swap file fixed...OK!"] = "Файл подкачки исправлен.";
_ru["Transmission running..."] = "Transmission запущен";
_ru["Transmission is already running..."] = "Transmission уже работает";
_ru["Transmission stopped..."] = "Transmission остановлен";
_ru["Waiting for time synchronisation by NTP..."] = "Ожидание синхронизации часов через Интернет";
_ru["Running failed due NTP server inaccessible..."] = "Запуск провалился из-за недоступности NTP сервера";
_ru["Transmission disabled..."] = "Работа Transmission отключена";
_ru["Transmission is not installed on this disk..."] = "На этом диске Transmission не установлен";
_ru["<a href='/homenet/lan.asp'>Transmission is stopped, please set ip addresses for gateway and DNS...</a>"] = "<a href='/homenet/lan.asp'>Без адреса шлюза и DNS запуск не возможен.</a>";

var mib_disk = "",
    mib_disk_off = 0,
    disks_list = <% getMedia("", 1); %>,
    swapPresented  = <%=q=(swap_status=="ok"); %>,
    current_folder = "<%=addslashes(TRNT_FOLDER);%>",
    current_disk_off = 0,
    installed = -1;

treeView.nodeClick = function () {
	if (this.type == TREE.FOLDER) {
		var field = $('path').el,
		    path = this.getPath();
		field.value = /^\w+\/\w+(\/.*)$/.exec(path)[1];
		fileBrowser.close();
		field.focus();
		validateField.apply(field);
	}
};

function update_disks(element, dir, disk)
{
	while (element.length > 0)
		element.remove(0);

	var disks = dir.slice(0);
	mib_disk_off = disks.join('/').indexOf(mib_disk) < 0;
	if (mib_disk_off) {
		disks.push("+"+mib_disk);
		disks.sort();
	}

	for (var idx = 0; idx < disks.length; ++idx) {
		var name = disks[idx];
		if (name.charAt(0) == '+') {
			var op = document.createElement("option");
			op.innerHTML = 
			op.value = 
			name = name.substr(1);
			element.appendChild(op);
			if (name == disk)
				op.selected = true;
		}
	}
	element.value = disk;
}

function submit(event)
{
	var form = this,
	    disk = form.disk.value,
	    path = form.path.value;

	form.TRNT_FOLDER.value = [disk, path].join('');
	return true;
}

function updatePath(form, force_check)
{
	var folder = [form.disk.value, form.path.value].join('');
	if (force_check || folder != current_folder)
		ajaxGet(
			['/req/checkSwap/', current_folder = folder].join(''),
			onCheckSwap, form);
}

function onNewPath()
{
	updatePath(this.element.form);
	return true;
}

function onCheckSwap(aj, state)
{
	if (aj.readyState == 4 && aj.status == 200) {
		swapPresented = aj.responseText == 'ok';
		var field = $('path').el;
		update.call(field, {}, field.form, false);
	}
}

autoStatus.done = function (text, changed) {
		var form = document.torrents;
		tickForm(form);

		if (changed) {
			_(form, "start").enable(text.toLowerCase().indexOf("stopped") >= 0);
			_(form, "stop").enable(text.toLowerCase().indexOf("running") >= 0);
		}
		return true;
	};

autoStatus.tick = function () {
	var form = document.forms.torrents,
	    folder = [form.disk.value, form.path.value].join('');
	this.send("cmd=status&TRNT_FOLDER=" + encodeURIComponent(folder), "-");
}

function postValidate(form, valid) {
	var v = form.validation,
	    env = hint.box(form.save),
	    hnt = hint.left(env.box);
	current_disk_off = mib_disk_off && form.disk.value == mib_disk;
	if (valid && current_disk_off) {
		hnt.className = "fullist error";
		hnt.innerHTML = 
			"USB-диск не подключен";
		return false;
	}

	hnt.className = "fullist message";
	hnt.innerHTML = ""
	return valid;
}

function update(event, form, type)
{
	var init = (type === 'init');
	if (init) {
		var current = form.TRNT_FOLDER.value.substr(1),
		    slash_pos = current.indexOf('/');

		mib_disk = current.slice(0, slash_pos);
		update_disks(form.disk, disks_list, mib_disk);
		current_disk_off = mib_disk_off;

		_(form, "TRNT_PORT,TRNT_RPC_PORT") .setParser("port");
		_(form, "disk")                    .setParser("none", onNewPath);
		_(form, "path")                    .setParser("folder@bottom", onNewPath);
		_(form, "TRNT_USER_NAME")          .setParser("login");
		_(form, "TRNT_USER_PASSWORD")      .setParser("password");

		autoStatus.data = <%=getTorrentsStatus();%>;
		autoStatus.init('torrents', 'cmd=status', 'torrents_status');

		_(form, "start,stop").enable(false);
	}

	if (type == 'tick' && autoStatus.data.disks !== disks_list) {
		update_disks(form.disk, autoStatus.data.disks, form.disk.value);
		disks_list = autoStatus.data.disks;
		swapPresented = autoStatus.data.swap == 'ok';
		postponeValidation(form);
	}

	if (installed != swapPresented) {
		installed = swapPresented;
		form.cmd.value = installed ? 'config':'install';
		form.save.value = installed ? 'Применить':'Установить';

		$("_info").html(info_texts[ installed ? 1:0 ]);
	}

	_('#folder').show(true);
	_(form, "disk").enable(true);

	var enabled = form.TRNT_ENABLED.checked && installed;

	_('#tenable').show(installed);
	_('#ports_1,#ports_2,#status').show(enabled);
	_('#links').show(enabled && autoStatus.data.downloads == 'ok');
	_('#account').show(enabled && !form.TRNT_USE_WEB_ACCOUNT_ENABLED.checked);
	_(form, "TRNT_USER_NAME,TRNT_USER_PASSWORD")
		.enable(!form.TRNT_USE_WEB_ACCOUNT_ENABLED.checked);

	if (init) {
		form.path.value = current.substr(slash_pos);
	}
}

function start_onclick(event) {
	_(this.form, "start").enable(false);
	var reply = _(this.form).ajaxSubmit();
	if (/ok$/.test(reply)) {
		autoStatus.request("cmd=start_all", "Запуск...");
	} else {
		autoStatus.message("Submit Failed");
		_(this.form, "start").enable(false);
	}
	return true;
}

function stop_onclick(event) {
	autoStatus.request("cmd=stop_all", "Остановка...");
	return true;
}

function path_onbrowse(event) {
	var dsk = $("disk").el,
	    pth = $("path").el;
	fileBrowser.show('media/'+dsk.value, pth.parentNode);
	return true;
}

--></script>
</head>
<body class="body" onload="Funs.preloadImages(treeView.icons)">
<% writeLeafOpen("!_info", "Управление BitTorrent-клиентом Transmission",
	info_text); %>

<% writeFormOpen("torrents"); %>
<%=hidden("cmd"); %>
<%=hidden("TRNT_FOLDER"); %>
<table class="sublayout" id='folder'>
<tr>
	<td class='label'>Рабочий диск:</td>
	<td class='field'>
		<% writeSelectOpen("disk"); %>
		</select>
	</td>
</tr>
<tr>
	<td class='label'>Рабочая папка:</td>
	<td class='field'><% writeBrowse("path", 40, 121); %></td>
</tr>
</table>

<table class="sublayout" id='tenable'>
<tr>
	<td class='label'></td>
	<td class='field'>
		<%=checkBox("TRNT_ENABLED"); %><label for='TRNT_ENABLED'>Включить BitTorrent-клиент</label>
	</td>
</tr>
</table>

<table class="sublayout" id='ports_1'>
<tr>
	<td class='label'>Порт входящих соединений:</td>
	<td class='field'><%=inputText("TRNT_PORT", 5, 5); %></td>
</tr>
<tr>
	<td class='label'>Порт для управления:</td>
	<td class='field'><%=inputText("TRNT_RPC_PORT", 5, 5); %></td>
</tr><%
	AP_MODE = (OP_MODE == 2) || (OP_MODE == 3);
	if (!AP_MODE) {
		ext_control = "управление из Интернета";
//		if (TRNT_EXTERNAL_ACCESS_ENABLED != 0)
//			ext_control = "<a href='http://" + WAN_IP_ADDR + ":" + TRNT_PORT + "/'>" + ext_control + "</a>";
		write("
<tr>
	<td class='label'></td>
	<td class='field'>
		" + checkBox("TRNT_EXTERNAL_ACCESS_ENABLED") + "<label for='TRNT_EXTERNAL_ACCESS_ENABLED'>Разрешить ", ext_control, "</label>
	</td>
</tr>");
	}
%>
<tr>
	<td class='label'></td>
	<td class='field'>
		<%=checkBox("TRNT_USE_WEB_ACCOUNT_ENABLED"); %><label for='TRNT_USE_WEB_ACCOUNT_ENABLED'>Использовать учетную запись администратора интернет-центра</label>
	</td>
</tr>
</table>

<table class="sublayout" id='account'>
<tr>
	<td class='label'>Имя пользователя:</td>
	<td class='field'><%=inputText("TRNT_USER_NAME", 30, 32); %></td>
</tr>
<tr>
	<td class='label'>Пароль:</td>
	<td class='field'><%=inputPassword("TRNT_USER_PASSWORD", 30, 32); %></td>
</tr>
</table>

<table class="sublayout" id='ports_2'>
<tr>
	<td class='label'></td>
	<td class='field'>
		<%=checkBox("TRNT_AUTO_START_ENABLED"); %><label for='TRNT_AUTO_START_ENABLED'>Автоматически запускать при установке диска</label>
	</td>
</tr><%
	if (!opts_isDef("hide_wps_btn_umount")) write("
<tr>
	<td class='label'></td>
	<td class='field'>
		", checkBox("TRNT_UMOUNT_BY_WPS_BUTTON"), "<label for='TRNT_UMOUNT_BY_WPS_BUTTON'>Использовать кнопку «WPS» для безопасного извлечения дисков</label>
	</td>
</tr>"); %>
</table>

<table class="sublayout" id='submit'>
<tr>
	<td class='label'></td>
	<td class='submit'><%=submit("Установить");%></td>
</tr>
</table>

<table class='sublayout' id='status'>
<tr>
	<td class='label'>Состояние:</td>
	<td class='field' id='torrents_status'></td>
</tr>
<tr>
	<td class='label'></td>
	<td class='field'><%=button("start:Запустить все торренты", "stop:Остановить клиент");%></td>
</tr>
<tr>
	<td class='label' colspan='2'></td>
</tr>
<tr>
	<td class='label'>Web-интерфейс Transmission:</td>
	<td class='field'><a target='_blank' href='<%=web_link;%>'><%=web_link;%></a></td>
</tr>
</table>

<table class='sublayout' id='links'><%
	if (SMB_ACCESS_ENABLED)
		write("
<tr>
	<td class='label'>Папка для файлов:</td>
	<td class='field'>", smb_link, "</td>
</tr>");
	if (FTP_ACCESS_ENABLED)
		write("
<tr>
	<td class='label'>Ссылка на папку через FTP:</td>
	<td class='field'><a target='_blank' href='", ftp_link, "'>", ftp_link, "</a></td>
</tr>"); %>
</table>
</form>
<% writeLeafClose(); %>
<script type="text/javascript">updateAllForms();</script>
</body>
</html>
