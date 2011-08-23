<% htmlHead("VDSL Modem"); %>
<script type="text/javascript"><!--
<%
	setMibsVarsAndWriteMibProps("VDSL_CPE_AUTO_MODE", "VDSL_CARRIER_SET");
%>
mib.all_profiles = 831;
mib.saved_profiles = (mib.VDSL_CPE_AUTO_MODE == mib.all_profiles) ? 0 : mib.VDSL_CPE_AUTO_MODE;

function initProfiles(form, bits) {
		var bit = 1;

		while (bit < 1024) {
			_('#profile_'+bit).check(bits & bit);
			bit <<= 1;
		}
		form.VDSL_CPE_AUTO_MODE.value = bits;
		return bits;
}

function getProfilesBits(form) {
	var o = { bits: 0 };
	_(form, 'profile') .each(function (item, idx, o) {
			if (item.checked)
				o.bits |= item.value;
		}, o);
	return o.bits;
}

function update(event, form, type) {
	var init = (type === 'init');
	if (init) {
		var bits = initProfiles(form, mib.VDSL_CPE_AUTO_MODE);
		_('#all_all').check(bits == mib.all_profiles);
	}

	if (this.name == 'all') {
		var bits = getProfilesBits(form);
		if (bits != mib.all_profiles)
			mib.saved_profiles = getProfilesBits(form);
		initProfiles(form, form.all.checked ? mib.all_profiles : mib.saved_profiles);
	} else
		if (this.name == 'profile') {
			var bits = getProfilesBits(form);
			form.VDSL_CPE_AUTO_MODE.value = bits;
			_('#all_all').check(bits == mib.all_profiles);
		}
}

function postValidate(form, valid) {
	var env = hint.box(form.save),
	    hnt = hint.left(env.box);

	if (form.VDSL_CPE_AUTO_MODE.value == 0) {
		hnt.className = "fullist error";
		hnt.innerHTML = "Необходимо выбрать хотя бы один профайл";
		return false;
	}

	hnt.className = "fullist message";
	hnt.innerHTML = ""
	return valid;
}
//--></script>
</head>
<body class="body">
<% writeLeafOpen("Параметры VDSL",
"По умолчанию интернет-центр настроен на автоматическое определение параметров VDSL-соединения. " +
"Если провайдер требует установку соединения только с определенными параметрами, вы можете установить их в этом меню."); %>

<% writeFormOpen("vdsl"); %>
<%=hidden("VDSL_CPE_AUTO_MODE"); %>
<table class="sublayout part">
<tr>
	<td class='label'>VDSL профиль:</td>
	<td class='field'>
		<%=checkBoxV('profile', 1); %><label for='profile_1'>8a</label>
		<%=checkBoxV('profile', 2); %><label for='profile_2'>8b</label>
		<%=checkBoxV('profile', 4); %><label for='profile_4'>8c</label>
		<%=checkBoxV('profile', 8); %><label for='profile_8'>8d</label>
		<%=checkBoxV('profile', 16); %><label for='profile_16'>12a</label>
		<%=checkBoxV('profile', 32); %><label for='profile_32'>12b</label>
		<%=checkBoxV('profile', 256); %><label for='profile_256'>17a</label>
		<%=checkBoxV('profile', 512); %><label for='profile_512'>30a</label>
		<%=checkBoxV('all', 'all'); %><label for='all_all'>все</label>
	</td>
</tr>
<tr>
	<td class='label'>Набор частот:</td>
	<td class='field'>
		<% writeSelectOpen("VDSL_CARRIER_SET"); %>
			<% writeOption("Автовыбор", 0); %>
			<% writeOption("Annex A (A43)", 1); %>
			<% writeOption("Annex B (B43)", 2); %>
			<% writeOption("Annex C (V43)", 7); %>
		</select>
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
<% writeLeafClose(); %>
<script type="text/javascript">updateAllForms();</script>
</body>
</html>
