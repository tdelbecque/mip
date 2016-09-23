create or replace function products_addcountry
(
	IN products_table_in text,
	IN companyadmin_table_in text,
	IN products_table_out text
)
returns void as $products_addcountry$
declare
	tmpl1 text :=
	$tmpl1$
	create table %I as (
	select A.*, B.country_en from %I A
	left outer join (select distinct companyid, country_en from %I) B
	on (companyparticipantid = companyid))
	$tmpl1$;
begin
	execute format (tmpl1, products_table_out, products_table_in, companyadmin_table_in);
end $products_addcountry$ language plpgsql;
