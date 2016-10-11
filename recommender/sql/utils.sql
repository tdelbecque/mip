--
-- do not forget to create extension as superuser;
-- create extension fuzzystrmatch;
-- create extension plperl;
--
create or replace function init () returns void as $init$
       select init_catalog ();
       select init_buyers_profiles ();
       select init_reelport ();
       select init_buyers_segments ();
       select init_products_profiles ();
       select init_products_cosim ();
$init$ language sql;

CREATE OR REPLACE FUNCTION array_intersect(anyarray, anyarray)
  RETURNS anyarray
  language sql
as $$
    SELECT ARRAY(
        SELECT UNNEST($1)
        INTERSECT
        SELECT UNNEST($2)
    );
$$;

CREATE OR REPLACE FUNCTION array_union(anyarray, anyarray)
  RETURNS anyarray
  language sql
as $$
    SELECT ARRAY(
        SELECT UNNEST($1)
        UNION
        SELECT UNNEST($2)
    );
$$;

create or replace function array_jaccard(anyarray, anyarray)
returns real
language sql
as $$ select (array_length(array_intersect($1,$2),1)::real/array_length(array_union($1,$2),1))::real;$$;

create or replace function array_lintersect(anyarray, anyarray)
returns integer
language sql
as $$select array_length(array_intersect($1, $2), 1);$$;

create or replace function normstr(varchar)
returns varchar
language sql
as $$ select regexp_replace(lower ($1), '[^a-z0-9]', '', 'g');$$;

create or replace function str_similarity(varchar, varchar)
returns real
language sql
as $$select (1.0 - levenshtein($1, $2)::real/greatest(length($1), length($2)))::real;$$;

CREATE OR REPLACE FUNCTION time2sec (t text)
  RETURNS integer AS
$BODY$ 
DECLARE 
    hs INTEGER;
    ms INTEGER;
    s INTEGER;
BEGIN
    SELECT (EXTRACT( HOUR FROM  t::time) * 60*60) INTO hs; 
    SELECT (EXTRACT (MINUTES FROM t::time) * 60) INTO ms;
    SELECT (EXTRACT (SECONDS from t::time)) INTO s;
    SELECT (hs + ms + s) INTO s;
    RETURN s;
END;
$BODY$
  LANGUAGE 'plpgsql';

create or replace function my_array_diff (integer[], integer[]) returns integer[] as $$
       my ($a1, $a2) = @_;
       my %d = ();
       $d {$_} = 1 for @$a2;
       my @r = ();
       for (@$a1) {
       	   push @r, $_ unless defined $d {$_}
       }
       
       return \@r;
$$ language plperl;

create or replace function reco4reelport (tablename text, nbreco integer) returns setof text as $$
declare
	querytext text := $Q$
	         select array_to_string (
       	             		      array_cat (
				      		ARRAY[buyerid, ka]::integer[],
       	      		      			kbs[1:$1]),
					',') as reco
		from %I
		order by buyerid, ka
		$Q$;
begin
	return query execute format (querytext, tablename) using nbreco;
	return;
end
$$ language plpgsql;

create or replace function reco4reelport_seg0 (tablename text, nbreco integer) returns setof text as $$
declare
	querytext text := $Q$
	         select array_to_string (
       	             		      array_cat (
				      		ARRAY[segid, ka]::integer[],
       	      		      			kbs[1:$1]),
					',') as reco
		from %I
		order by segid, ka
		$Q$;
begin
	return query execute format (querytext, tablename) using nbreco;
	return;
end
$$ language plpgsql;

/*
create or replace function create_train_data_for_cosim_learning ()
returns void as
$$
	drop table if exists train_data_for_cosim_learning;
	create table train_data_for_cosim_learning as (
       	       select x.co_agegroup_preschool, x.co_agegroup_toddler,
       	       	      x.co_agegroup_kids, x.co_agegroup_tnt, x.co_agegroup_family,
	      	      x.co_genre_animation, x.co_genre_liveaction, x.co_genre_education, 
	      	      x.co_genre_featurefilm, x.co_genre_art, x.co_genre_game, x.co_genre_shorts, x.co_genre_other,
	      	      x.co_boys, x.co_girls,
	      	      x.co_country_france, x.co_country_uk, x.co_country_canada, x.co_country_germany, x.co_country_us,
	      	      x.co_country_southkorea, x.co_country_china, x.co_country_brazil, x.co_country_italy,
	      	      x.co_country_spain, x.co_country_other,
	      	      b.ka, b.kb
	   	from products_cosim_0_withcountry_2016 x
	   	left outer join cousage_2016 b
	   	on x.ka = b.ka and x.kb = b.kb);

	alter table train_data_for_cosim_learning add column flag smallint;
	update train_data_for_cosim_learning set flag = 1 where ka is not null;
	update train_data_for_cosim_learning set flag = 0 where ka is null;
	alter table train_data_for_cosim_learning drop column ka;
	alter table train_data_for_cosim_learning drop column kb;
	
	--\copy train_data_for_cosim_learning to train_data_for_cosim_learning.csv 
$$ language sql;
*/

create or replace function favorite_rank_avg_from_cosim ()
returns real as
$$
declare
	a	real;
begin
	execute format ('%s', 'drop table if exists rnk1');
	execute format ('%s', 'drop table if exists rnk2');
	execute format ('%s', 'create table rnk1 as
	       (select ka, kb, co_sim, rank() over (partition by ka order by co_sim desc, tiebreaker) as rnk
	       from (select *, random() as tiebreaker from products_cosim_0_withcountry_2016 where ka != kb) A)');
	execute format ('%s', 'create table rnk2 as (select A.* from rnk1 A, cousage_2016 B where A.ka = B.ka and A.kb = B.kb and B.ka != B.kb)');
	execute format ('%s', 'select avg(rnk)::real from rnk2') into a;
	return a;
end
$$ language plpgsql;

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
