
-- extrait la fitness depuis le panel

create or replace function create_panel_fitness() returns void as $$
begin
       drop table if exists panel_fitness;
       create table panel_fitness as (
          select A.*
	  from 	 buyers_products_fitness A,
	  	 panel B
	  where A.buyerid = B.idpascom);
end
$$ language plpgsql;

create or replace function create_fullreco_2015 () returns void as $$
begin

	drop table if exists fullreco_2015;
	drop index if exists i_fullreco_2015;

	create table fullreco_2015 as (
	-- build a possible reco for (buyerid, ka)
	       select A.buyerid,
	              B.ka,		-- entry product
	      	      B.kb,	   	-- possible reco
	      	      B.n,	   	-- coscreen of the 2 products
	      	      A.fitness,	-- of buyer with kb,
		      C.freshyearprod,		
	      	      random () as tiebreaker
       		from panel_fitness A,
		     -- buyers_products_fitness A,
       	    	     coscreenag_2015 B,
		     products_2015 C
		where A.screeningnumber = kb and C.screeningnumber = kb and ka != kb);
	analyse fullreco_2015;
	create index i_fullreco_2015 on fullreco_2015(buyerid, ka);
end
$$ language plpgsql;

--
--
--

create or replace function create_fullrecoranked_2015 () returns void as $$
begin
	drop table if exists fullrecoranked_2015;

	create table fullrecoranked_2015 as (
       	       select *,
       	       	      rank () over (partition by buyerid, ka
		      	      	    order by n desc, fitness desc, tiebreaker) as rnk
       		from fullreco_2015);
end
$$ language plpgsql;

create or replace function reco4reelport (nbreco integer) returns setof text as $$
begin
       return query
       select array_to_string (
       	      		      array_cat (
			      		ARRAY[buyerid, ka]::integer[],
       	      		      		array_agg(kb order by rnk)::integer[]),
				',') as reco
	from fullrecoranked_2015
	where rnk < reco4reelport.nbreco
	group by buyerid, ka
	order by buyerid, ka;
	return;
end
$$ language plpgsql;

--
--
--

create or replace function reco4reelport (tablename text, nbreco integer) returns setof text as $$
declare
	querytext text := $Q$
	         select array_to_string (
       	             		      array_cat (
				      		ARRAY[buyerid, ka]::integer[],
       	      		      			array_agg(kb order by rnk)::integer[]),
					',') as reco
		from %I
		where rnk <= $1
		group by buyerid, ka
		order by buyerid, ka
		$Q$;
begin
	return query execute format (querytext, tablename) using nbreco;
	return;
end
$$ language plpgsql;

--
--
--

create or replace function create_recoranked_2015_top100 () returns void as $$
begin
	drop table if exists recoranked_2015_top100;
	create table recoranked_2015_top100 as (
	       select * from reco4reelport(100));
end
$$ language plpgsql;

--
--
--

create or replace function create_fullrecoranked_2015 (output_table text, ranking text) returns void as $$
declare
	flag boolean;
	querytxt text :=
		 '
		 create table %I as (
       	       	 select *,
       	       	        rank () over (partition by buyerid, ka
		      	      	      order by %s, tiebreaker) as rnk
       		from fullreco_2015)
		';
begin
	select to_regclass('fullreco_2015') is null into flag;
	if flag
	then
		select create_fullreco_2015 ();
	end if;
	execute format('drop table if exists %I', output_table);
	execute format(querytxt, output_table, ranking);
end
$$ language plpgsql;

/*
select create_fullrecoranked_2015 ('reco_n_fitness', 'n desc, fitness desc');
\copy (select * from reco4reelport('reco_n_fitness', 100)) to 'panelreco_list1.csv';
select create_fullrecoranked_2015 ('reco_fitness_n', 'fitness desc, n desc');
\copy (select * from reco4reelport('reco_fitness_n', 100)) to 'panelreco_list2.csv';

select create_fullrecoranked_2015 ('reco_n_fresh_fitness', 'n desc, freshyearprod desc, fitness desc');
\copy (select * from reco4reelport('reco_n_fresh_fitness', 100)) to 'panelreco_list3.csv';

select create_fullreco_nocontext_2015 ();
select create_fullrecoranked_nocontext_2015 ();
\copy (select * from reco4reelport ('fullrecoranked_nocontext_2015', 100)) to 'panelreco.1/panelreco_nocontext.csv';

*/

create or replace function create_fullreco_nocontext_2015 () returns void as $$
begin

	drop table if exists fullreco_nocontext_2015;
	drop index if exists i_fullreco_nocontext_2015;

	create table fullreco_nocontext_2015 as (
	-- build a possible reco for (buyerid)
	       select A.buyerid,
	              0::integer as ka,		-- entry product
	      	      A.screeningnumber as kb,-- possible reco
	      	      0::integer as n,	-- coscreen of the 2 products
	      	      A.fitness,	-- of buyer with kb
	      	      random () as tiebreaker
       		from panel_fitness A
		     -- buyers_products_fitness A,
		);
	analyse fullreco_nocontext_2015;
	create index i_fullreco_nocontext_2015 on fullreco_nocontext_2015(buyerid);
end
$$ language plpgsql;

--
--
--

create or replace function create_fullrecoranked_nocontext_2015 () returns void as $$
begin
	drop table if exists fullrecoranked_nocontext_2015;

	create table fullrecoranked_nocontext_2015 as (
       	       select *,
       	       	      rank () over (partition by buyerid
		      	      	    order by fitness desc, tiebreaker) as rnk
       		from fullreco_nocontext_2015);
end
$$ language plpgsql;
