%macro slrs2(_date1_,_date2_);
	proc sql;
		/*Получаем для каждого сотрудника записи, где справа даты
		и зарплаты до начала исслеуемого периода, а слева даты и 
		зарплаты за исследуемый период*/
		create table help1 as
			select a.employee_id as id,
				a.employee_gender as gender,
				a.salary_change_date as first_date,
				a.salary as first_salary,
				b.salary_change_date as second_date,
				b.salary as second_salary
			from hw.salary_history as a,
				hw.salary_history as b
			where (a.employee_id=b.employee_id) and
				(a.salary_change_date>"&_date1_"d) and
				(a.salary_change_date<="&_date2_"d) and
				(b.salary_change_date<="&_date1_"d);
		
		/*Выбираем для каждого сотрудника записи с последней
		известной зарплатой до исследуемого периода*/
		create table help2 as
			select * from help1 as a
			where a.second_date in
				(select max(b.second_date) format=DDMMYYS10.
				from help1 as b
				where (a.id=b.id) and
				(a.first_date=b.first_date));
		
		/*Теперь для каждого сотрудника оставляем только запись
		с зарплатой на окончание исследуемого периода*/
		create table help2_again as
			select * from help2 as a
			group by id
			having first_date=max(first_date);
		
		/*Вычисляем относительное прирост*/
		create table help3 as
			select id, gender, (first_salary/second_salary-1) as change
			from help2_again;
		
		/*Выбираем сотрудников, устроенных в фирме на момент
		начала исследуемого периода*/
		create table help4 as
			select * from hw.salary_history
			where salary_change_date <= "&_date2_"d;
		
		/*Оставляем от них только тех, у кого не менялась зарплата за
		исследуемый период и пишем им относительный прирост равным нулю*/
		create table help5 as
			select distinct employee_id as id,
				employee_gender as gender, 0 as change
			from help4 as a
			where not exists (select employee_gender
					from help4 as b
					where (a.employee_id=b.employee_id) and
						(b.salary_change_date>"&_date1_"d) and
						(b.salary_change_date<="&_date2_"d));
		
		/*Объединяем таблицы*/
		create table help6 as
			select id, gender, change from help3
			union
			select id, gender, change from help5;
		
		/*Создаем требуемую таблицу*/
		select distinct gender label="Пол работников",
			"&_date1_"d label="Начало исследуемого периода" format=DDMMYY10.,
			"&_date2_"d label="Конец исследуемого периода" format=DDMMYY10.,
			mean(change) label="Среднее изменение зарплаты работников за данный период"
				format=percent7.2
		from help6
		group by gender;
		
		/*Удаляем вспомогательные таблицы*/
		drop table help1,help2,help3,help4,help5,help6,help2_again;
	quit;
%mend slrs2;

/*Засекаем время работы (выведется в лог)*/
OPTIONS FULLSTIMER;
%slrs2(01jul2004,01jul2005);
OPTIONS NOFULLSTIMER;