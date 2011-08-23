<% htmlHead("Серверы домашней сети "); %>
<script type="text/javascript"><!--
<%
	setMibsVarsAndWriteMibProps("TRIGGERPORT_ENABLED");

	DefSrv = 0;
	tr_from = tr_to = tr_proto = in_from = in_to = in_proto = comment = "";
	isbcast = 0;
%>
mib.tbl_name = "<%=mib_tbl_name="TRIGGERPORT_TBL"; %>";
mib.tbl_info = <% writeTableInfo(mib_tbl_name); %>;
mib.protos = { 1: 'TCP', 2: 'UDP', 3: 'TCP & UDP' };
mib.tbl_data = [
<% writeTable(mib_tbl_name,
"	{ tr_from: '$tr_from', tr_to: '$tr_to', tr_proto: '$tr_proto.int', in_from: '$in_from', in_to: '$in_to', in_proto: '$in_proto.int', comment: '$comment' },
", "");
%>	{}
];

mib.tbl_data.pop();

function submit(event)
{
	switch (this.name) {
	case "portTrigAdd":
		this.ip.value = this.isbcast[0].checked ? this.local_ip.value : this.bcast_ip.value;
		break;

	case "portTrigDel":
		return submitStdDelForm(event);
	}

	return true;
}

var presets_tpl = {
	cols: [ 'tr_from', 'tr_to', 'tr_proto', 'in_from', 'in_to', 'in_proto', 'comment' ],
	list: { '': 0 },
	rows: {
		0: [ "", "", 0, "", "", 0, "" ]
	}
};

function update(event, form, type)
{
	var init = (type === 'init');
	switch (form.name) {
	case "portTrigAdd":
		if (init) {
			if (mib.tbl_info.height >= mib.tbl_info.limit) {
				_(form, "/!save") .enable(false);
				_(form, "save") .setParser("disable:В таблице сервисов не осталось свободных строк");
			}

			presets.init(form.DefSrv, presets_tpl);

			_(form, "tr_from,tr_to,in_from,in_to")   .setParser("port");
			_(form, "tr_from,tr_to")   .groupValidation("pool");
			_(form, "in_from,in_to")   .groupValidation("pool");
		}

		if (this.name == "DefSrv" && this.selectedIndex)
			presets.select(form, this.value, presets_tpl);
		break;

	case "portTrigDel":
		updateStdDelForm(event, form, type);
	}
}

function postValidate(form, valid) {
	if (form.name != 'portTrigAdd')
		return valid;

	var v = form.validation,
	    item = {
	    	tr_proto: form.tr_proto.value,
	    	tr_from: v.el("tr_from").parsedValue,
	    	tr_to:   v.el("tr_to").parsedValue };

	var env = hint.box(form.save),
	    hnt = hint.left(env.box);
	if (valid) {
		var idx, tbl = mib.tbl_data;
		for (idx = 0; idx < tbl.length; ++idx) {
			var it = tbl[idx];
			if (it.tr_proto & item.tr_proto) {
				if (!((it.tr_from > item.tr_to) || (it.tr_to < item.tr_from))) {
					hnt.className = "fullist error";
					hnt.innerHTML = [
							"Пересечение с правилом: ",
							'[', it.tr_from, (it.tr_to>it.tr_from ? '-'+it.tr_to : ''), ']:', mib.protos[it.tr_proto], ' - [', it.in_from, (it.in_to>it.in_from ? '-'+it.in_to : ''), ']:', mib.protos[it.in_proto], ' / ', it.comment
						].join('');
					return false;
				}
			}
		}
	}

	hnt.className = "fullist message";
	hnt.innerHTML = ""
	return valid;
}
--></script>
</head>

<body class="body">
<% writeLeafOpen("Доступ к сервисам домашней сети из Интернета", 
	"Можно разрешить интернет-пользователям доступ к определенным сервисам на "+
	"компьютерах домашней сети. Для этого укажите IP-адрес домашнего компьютера, "+
	"на котором запущен нужный сервис, и выберите используемый им протокол и "+
	"диапазон сетевых портов. Для популярных сервисов есть готовый набор стандартных "+
	"установок."); %>

<% writeFormOpen("portTrigSet"); %>
<table class="sublayout">
<tr>
	<td class='label'></td>
	<td class='field'>
		<%=checkBox("TRIGGERPORT_ENABLED"); %><label for='TRIGGERPORT_ENABLED'>Открыть доступ к сервисам домашней сети</label>
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

<% writeLeafSubheader("Список открытых сервисов домашней сети"); %>

<%	writeFormOpen("portTrigAdd");
	write(hidden("ip")); %>
<table class="sublayout">
<tr>
	<td class='label'>Сервис:</td>
	<td class='field'>
		<% writeSelectOpen("DefSrv"); %>
		</select>
	</td>
</tr>
<tr>
	<td class='label'>Протокол:</td>
	<td class='field'>
		<% writeSelectOpen("tr_proto"); %>
			<% writeOption("Только TCP", 1); %>
			<% writeOption("Только UDP", 2); %>
			<% writeOption("TCP и UDP", 3); %>
		</select>
	</td>
</tr>
<tr>
	<td class='label'>Диапазон портов от:</td>
	<td class='field'><%=inputText("tr_from", 5, 5); %></td>
</tr>
<tr>
	<td class='label'>до:</td>
	<td class='field'><%=inputText("tr_to", 5, 5); %></td>
</tr>
<tr>
	<td class='label'>Протокол:</td>
	<td class='field'>
		<% writeSelectOpen("in_proto"); %>
			<% writeOption("Только TCP", 1); %>
			<% writeOption("Только UDP", 2); %>
			<% writeOption("TCP и UDP", 3); %>
		</select>
	</td>
</tr>
<tr>
	<td class='label'>Диапазон портов от:</td>
	<td class='field'><%=inputText("in_from", 5, 5); %></td>
</tr>
<tr>
	<td class='label'>до:</td>
	<td class='field'><%=inputText("in_to", 5, 5); %></td>
</tr>
<tr>
	<td class='label'>Описание:</td>
	<td class='field'><%=inputText("comment", 30, 31); %></td>
</tr>
<tr>
	<td class='label'></td>
	<td class='submit'>
		<%=submit("Добавить");%>
	</td>
</tr>
</table>
</form>

<% writeFormOpen("portTrigDel"); %>
<table class="sublayout">
<tr>
	<td colspan="2"><table id="some_table" class="list">
<tr>
	<th class='check'>&nbsp;</th>
	<th class='list'>Протокол</th>
	<th class='list'>Порты</th>
	<th class='list'>Протокол</th>
	<th class='list'>Порты</th>
	<th class='list' width="50%">Описание</th>
</tr>

<% writeTable(mib_tbl_name,
"<tr class='#.class point'>
	<td class='check'><input type='checkbox' name='select#' value='ON'/></td>
	<td class='list'>$tr_proto[\"\",\"TCP\",\"UDP\",\"TCP и UDP\"]</td>
	<td class='list'>$tr_from.$tr_to</td>
	<td class='list'>$in_proto[\"\",\"TCP\",\"UDP\",\"TCP и UDP\"]</td>
	<td class='list'>$in_from.$in_to</td>
	<td class='list'>$comment</td>
</tr>
", "<tr class='even first'><td colspan='5' class='empty'>Нет записей</td></tr>
");
%></table></td>
</tr>
<tr>
	<td class='label'></td>
	<td class='submit'>
		<%=submit("del:Удалить", "delAll:Удалить все");%>
	</td>
</tr>
</table>
</form>
<% writeLeafClose(); %>
<script type="text/javascript">updateAllForms();</script>
</body>
</html>
