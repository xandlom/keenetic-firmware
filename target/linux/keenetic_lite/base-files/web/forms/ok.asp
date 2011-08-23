<% htmlHead(RESULT_TITLE); %>
<script type="text/javascript"><!--
var obj = {
	interval: 125,

	redirect_url: '<%=submit_url;%>',
	stages: [
			{ id: 'wait', start: 0 },
			{ id: '---',  start: 10000 }
		],

	current_stage: 0,
	time: <% if (testVar("start")) write(start); else write("0"); %>,

	start: function () {
			this.timer = setInterval('obj.tick();', this.interval);
		},

	go: function() {
			clearInterval(this.timer);
			window.top.location.replace(this.redirect_url);
		},

	tick: function () {
			this.time += this.interval;
			var merc_el = document.getElementById('_mercury'),
			    gauge_el = document.getElementById('_gauge'),
			    stages = this.stages,
			    last = stages[stages.length - 1],
			    percent = Math.round(this.time * gauge_el.clientWidth / last.start),
			    idx;

			merc_el.style.width = [percent, 'px'].join('');

			for (idx = 0; idx < stages.length; ++idx) {
				var cur = stages[idx],
				    el = document.getElementById([cur.id, 'stage'].join('_'));

				if (!el)
					continue;

				var nxt = stages[idx+1];

				el.className =
					(cur.start <= this.time) ? 
						(nxt.start > this.time) ?
							'in_progress':
							'done' :
						'queued';
			}

			if (this.time >= last.start)
				this.go();
		}
};
--></script>
</head>
<body class="body">
<% writeLeafOpen("Применение настроек", "Пожалуйста, подождите несколько секунд, пока настройки вступят в силу..."); %>
<table class="sublayout">
<tr><td class="info"><div class='gauge' id='_gauge' style='width: 776px; height: 1.5em;'><div class='mercury' id='_mercury' style='width: 0px;'/></div>
<tr><td class='submit'>
<input type='button' value='Go' onclick='javascript:obj.go();'/>
</td></tr></table>
<% writeLeafClose(); %>
</body>
</html>
<script type="text/javascript"><!--
	obj.start();
--></script>
