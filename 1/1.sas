proc sql;
	/*Группируем мужчин по возрасту (группы по три года) и считаем для
	каждой группы среднюю зарплату*/
	create table M as
		select(int((year('01JAN2007'd)-1-year(birth_date))/3.0)*3) as left,
			((int((year('01JAN2007'd)-1-year(birth_date))/3.0)+1)*3) as right,
			avg(salary) as mean
		from hw.employees
		where gender='M'
		group by (int((year('01JAN2007'd)-1-year(birth_date))/3.0)*3);
	/*То же самое для женщин*/
	create table F as
		select(int((year('01JAN2007'd)-1-year(birth_date))/3.0)*3) as left,
			((int((year('01JAN2007'd)-1-year(birth_date))/3.0)+1)*3) as right,
			avg(salary) as mean
		from hw.employees
		where gender='F'
		group by (int((year('01JAN2007'd)-1-year(birth_date))/3.0)*3);
	
	/*Соединяем в единую таблицу по одинаковым возрастным группам*/
	select distinct M.left label='Возрастная категория (от)',
		M.right label='Возрастная категория (по)',
		M.mean label='Средняя зарплата мужчин' format=dollar10.,
		F.mean label='Средняя зарплата женщин' format=dollar10.
	from M,F
	where ((M.left=F.left & M.right=F.right)
		or (M.left>0 & F.left=.)
		or (F.left>0 & M.left=.));
	
	/*Считаем количество строк в полученном отчете*/
	select count(left) label='Всего строк в отчете'
	from (select left from M union select left from F);
	
	/*Вычисляем самую высокооплачиваемую возрастную группу*/
	create table M_max as
		select distinct cat(put(left,best6.),'-',put(right,best2.)) as m1
		from M
		having mean=max(mean);
	create table F_max as
		select distinct cat(put(left,best6.),'-',put(right,best2.)) as f1
		from f
		having mean=max(mean);
	
	/*И объединяем в одну таблицуЯ*/	
	select m1 label='Диапазон наибольшей зарплаты мужчин',
		f1 label='Диапазон наибольшей зарплаты женщин'
	from M_max,F_max;
	
	/*Удаляем вспомогательные таблицы*/
	drop table M, F, M_max, F_max;
quit;