
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
