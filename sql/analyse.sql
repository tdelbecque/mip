create or replace function fields_analyze (table_name text) returns void as $$
declare
	c		text;
	total		integer;
	notnuls		integer;
	freqval_number	integer;
	freqval		text;
begin
	drop table if exists anal;
	create table anal (field text, non_null real, frequent_value char(50), frequent_value_share real);
	execute format ('select count(*) from %I', table_name) into total;
	for c in select column_name
	      	 from information_schema.columns X
		 where X.table_name = fields_analyze.table_name
	loop
		execute format ('select count(*) from %I where %I is not null', table_name, c) into notnuls;
		if notnuls > 0
		then
			execute format ('select count(*) as n, %I::text from %I group by %I order by n desc limit 1', c, table_name, c)
		   	   	into freqval_number, freqval;
		else
			freqval_number = 0;
			freqval = '';
		end if;
		insert into anal values (c, notnuls::real/total::real, substring (freqval, 1, 50), freqval_number::real/total::real);
	end loop;
end
$$ language plpgsql;
