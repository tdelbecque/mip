create or replace function remove_empty_columns
(
	IN table_in_out	text,
	IN lowlim_in integer default 0
)
returns void as $remove_empty_columns$
declare
	tmpl1 text :=
	$tmpl1$
	select column_name from information_schema.columns where table_name = '%s';
	$tmpl1$;

	tmpl2 text :=
	$tmpl2$
	select count(*) from %s where %I is not null 
	$tmpl2$;

	tmpl3 text :=
	$tmpl3$
	alter table %I drop column %I
	$tmpl3$;
	
	X RECORD;
	nbNotNull integer;
	nbRemoved integer default 0;
begin
	for X in execute format (tmpl1, table_in_out) LOOP
	    execute format (tmpl2, table_in_out, quote_ident (X.column_name)) into nbNotNull;
	    IF nbNotNull <= lowlim_in THEN
	       execute format (tmpl3, table_in_out, X.column_name);
	       nbRemoved := nbRemoved + 1;
	       --	RAISE NOTICE '% %', quote_ident (X.column_name), nbNotNull;
	    END IF;   
	END LOOP;
	RAISE NOTICE '% removed', nbRemoved;
end
$remove_empty_columns$ language plpgsql;

create or replace function display_columns_filling
(
	IN table_in_out	text
)
returns void as $display_columns_filling$
declare
	tmpl1 text :=
	$tmpl1$
	select column_name from information_schema.columns where table_name = '%s';
	$tmpl1$;

	tmpl2 text :=
	$tmpl2$
	select count(*) from %s where %I is not null 
	$tmpl2$;

	X RECORD;
	nbNotNull integer;
begin
	for X in execute format (tmpl1, table_in_out) LOOP
	    execute format (tmpl2, table_in_out, quote_ident (X.column_name)) into nbNotNull;
	    RAISE NOTICE '% %', quote_ident (X.column_name), nbNotNull;
	END LOOP;
end
$display_columns_filling$ language plpgsql;
