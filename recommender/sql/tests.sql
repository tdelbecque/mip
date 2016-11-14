--
-- Test file from reel wrt declared products & buyers
--

create or replace function test_reelport
(
       IN	reelport_table_in		text, -- new reel file
       IN	unexpected_buyers_table		text, -- undeclared buyers
       IN	unexpected_products_table	text  -- undeclared products
)
returns void as $test_reelport$
declare
	tmpl1 text :=
	$tmpl1$
	drop table if exists %I
	$tmpl1$;

	tmpl2 text :=
	$tmpl2$
	create table %I as
	(
	select distinct buyerid from (
	       select A.buyerid, B.norm_personid
	       from %I A
	       left outer join participants_2016 B
	       on 'RM' || B.norm_personid = A.buyerid and x102791_role like 'buyer%%') X
	where X.norm_personid is null)
	$tmpl2$;

	tmpl3 text :=
	$tmpl3$
	create table %I as
	(
	select distinct screeningid from ( 
	       select screeningid, screeningnumber
	       from %I
	       left outer join products_2016
	       on screeningid = screeningnumber) X
	where screeningnumber is null)
	$tmpl3$;
x text;
begin
	execute format (tmpl1, unexpected_buyers_table);
	execute format (tmpl1, unexpected_products_table);
	execute format (tmpl2, unexpected_buyers_table, reelport_table_in);
	execute format (tmpl3, unexpected_products_table, reelport_table_in);
end $test_reelport$ language plpgsql;
