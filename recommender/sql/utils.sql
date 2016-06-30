
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
