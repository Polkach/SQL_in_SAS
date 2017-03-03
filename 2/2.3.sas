proc sql;
	create table names as
		select distinct employee_id as id,
			cat('order_fact_',upcase(country),'_',compress(city,' -')) as place
		from hw.employees;
quit;

%macro tables2;
	proc sql noprint;
		select count(id) into :ttl_id from names;
		select count(distinct place) into :ttl_place from names;
		select id into :id1-:id999 from names;
		select place into :place1-:place999 from names;
		select distinct place into :uniq_place1-:uniq_place999 from names;
	quit;
	
	%let tables = &&uniq_place1;
	%do i=2 %to &ttl_place;
		%let tables=%SYSFUNC(compress(%SYSFUNC(cat(&tables.,' ',&&uniq_place&i.)),"'"));
	%end;
	
	data &tables;
		set hw.order_fact; /* ЕДИНСТВЕННЫЙ НЕОБХОДИМЫЙ ПРОХОД */
		attrib place length=$30;
		place='nowhere';
		%do i=1 %to &ttl_id;
			if employee_id=&&id&i then place="&&place&i";
		%end;
		%do i=1 %to &ttl_place;
			if place="%SYSFUNC(scan(&tables,&i))" then output &&uniq_place&i;
		%end;
	run;
	
	proc sql; /* ОТВЕТЫ НА ДОП. ВОПРОСЫ */
		select count(distinct place) label='Таблиц всего' from names;
		%do i=1 %to &ttl_place;
			select count(Order_id) label="Строк в таблице &&uniq_place&i" from &&uniq_place&i;
		%end; 
		drop table names;
	quit;
%mend;

%tables2;