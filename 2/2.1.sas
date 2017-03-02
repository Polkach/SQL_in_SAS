%macro slrs(_date_);
	proc sql;
		select employee_id label='ID сотрудника',
		salary format=dollar10. label="Зарплата на момент &_date_"
		from hw.salary_history as up
		where salary_change_date in
		/*Для рассматриваемого сотрудника находим последнюю
		дату изменения зарплаты (устройство на работу - это
		тоже изменение). Если она до нашей даты, то включаем
		зарплату в отчет.*/
		(select max(salary_change_date)
		from hw.salary_history as down
		where (up.employee_id=down.employee_id)
		and (salary_change_date<="&_date_"d));
	quit;
%mend slrs;

%slrs(01jan2000)