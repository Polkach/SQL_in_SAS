%macro tables;
	proc sql noprint;
		/*Сохраняем пары страна-город в требуемом формате*/
		create table names as
			select distinct(cat('order_fact_',upcase(country),'_',compress(city,' -')))
				as names
			from hw.employees;
		/*Сохраняем количество пар в макропеременную*/
		select count(names) into :total from names;
		/*Сохраняем все пары в массив*/
		select names into :names1-:names999 from names;
		
		/*Создаем требуемую таблицу для каждой пары*/
		%do i=1 %to &total;
			create table &&names&i as
				select * from hw.order_fact as ord
				where cat('order_fact_',(select upcase(country)
					from hw.employees as emp
					where emp.employee_id=ord.employee_id),'_',
					(select compress(city,' -') from hw.employees as emp
					where emp.employee_id=ord.employee_id))="&&names&i";
		%end; 
	quit;
		
	/*Выводим общее количество таблиц и число строк в каждой полученной таблице*/
	proc sql;
		select count(names) label='Таблиц всего' from names;
		%do i=1 %to &total;
			select count(Order_id) label="Строк в таблице &&names&i" from &&names&i;
		%end; 
		drop table names;
	quit;
%mend;

%tables;