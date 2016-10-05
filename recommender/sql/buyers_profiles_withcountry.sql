create or replace function init_buyers_profiles_withcountry ()
returns void as $init_buyers_profiles_withcountry$
       drop table if exists buyers_profiles_withcountry_elem_pattern;
       create table buyers_profiles_withcountry_elem_pattern (
              buyerid				  integer,
	      weight				  real,
	      --
	      agegroup_preschool		  smallint,
	      agegroup_toddler			  smallint,
	      agegroup_kids			  smallint,
	      agegroup_tnt			  smallint,
	      agegroup_family			  smallint,
	      --
	      genre_animation		smallint,
	      genre_liveaction		smallint,
	      genre_education		smallint,
	      genre_featurefilm	smallint,
	      genre_art		smallint,
	      genre_game		smallint,
	      genre_shorts		smallint,
	      genre_other		smallint,
	      --
	      boys	smallint,
	      girls	smallint,
	      --
	      country_france		  smallint,
	      country_uk		  smallint,
	      country_canada		  smallint,
	      country_germany		  smallint,
	      country_us		  smallint,
	      country_southkorea	  smallint,
	      country_china		  smallint,
	      country_brazil		  smallint,
	      country_italy		  smallint,
	      country_spain		  smallint,
	      country_other		  smallint,

	      p_agegroup_preschool	real,
	      p_agegroup_toddler	real,
	      p_agegroup_kids		real,
	      p_agegroup_tnt		real,
	      p_agegroup_family		real,
	      p_genre_animation		real,
	      p_genre_liveaction	real,
	      p_genre_education		real,
	      p_genre_featurefilm	real,
	      p_genre_art		real,
	      p_genre_game		real,
	      p_genre_shorts		real,
	      p_genre_other		real,
	      p_boys			real,
	      p_girls			real,
	      p_country_france		real,
	      p_country_uk		real,
	      p_country_canada		real,
	      p_country_germany		real,
	      p_country_us		real,
	      p_country_southkorea	real,
	      p_country_china		real,
	      p_country_brazil		real,
	      p_country_italy		real,
	      p_country_spain		real,
	      p_country_other		real

	      );
              
$init_buyers_profiles_withcountry$ language sql;


create or replace function create_buyers_profiles_withcountry
(
	reelport_table_in	text,
	products_profiles_withcountry_table_in	text,
	profiles_table_out	text
)
returns void as $create_buyers_profiles_withcountry$
declare
	products_table_in	text := products_profiles_withcountry_table_in;
	
	tmpl1	text :=
	$tmpl1$
	create table buyers_profiles_tmp as (
	select substring(A.buyerid, 3)::integer as buyerid,
	       B.*
	       from %I A, %I B
	       where A.screeningid = B.screeningnumber)
	$tmpl1$;

	tmpl2	text :=
	$tmpl2$
	create table %I as (
	select buyerid, count(*) as weight,
       	       SUM(agegroup_preschool) as agegroup_preschool,
	       SUM(agegroup_toddler) as agegroup_toddler,
	       SUM(agegroup_kids) as agegroup_kids,
	       SUM(agegroup_tnt) as agegroup_tnt,
	       SUM(agegroup_family) as agegroup_family,
	       --------------------------------------------------------------------
	       SUM(genre_animation) as genre_animation,
	       SUM(genre_liveaction) as genre_liveaction,
	       SUM(genre_education) as genre_education,
	       SUM(genre_featurefilm) as genre_featurefilm,
	       SUM(genre_art) as genre_art,
	       SUM(genre_game) as genre_game,
	       SUM(genre_shorts) as genre_shorts,
	       SUM(genre_other) as genre_other,
	       --------------------------------------------------------------------
	       SUM(boys) as boys,
	       SUM(girls) as girls,
	       --------------------------------------------------------------------
	       SUM(country_france) as country_france,
	       SUM(country_uk) as country_uk,
	       SUM(country_canada) as country_canada,
	       SUM(country_germany) as country_germany,
	       SUM(country_us) as country_us,
	       SUM(country_southkorea) as country_southkorea,
	       SUM(country_china) as country_china,
	       SUM(country_brazil) as country_brazil,
	       SUM(country_italy) as country_italy,
	       SUM(country_spain) as country_spain,
	       SUM(country_other) as country_other,
 
	       0::real as p_agegroup_preschool,
	       0::real as p_agegroup_toddler,
	       0::real as p_agegroup_kids,
	       0::real as p_agegroup_tnt,
	       0::real as p_agegroup_family,
	       0::real as p_genre_animation,
	       0::real as p_genre_liveaction,
	       0::real as p_genre_education,
	       0::real as p_genre_featurefilm,
	       0::real as p_genre_art,
	       0::real as p_genre_game,
	       0::real as p_genre_shorts,
	       0::real as p_genre_other,
	       0::real as p_boys,
	       0::real as p_girls,

	       0::real as p_country_france,
	       0::real as p_country_uk,
	       0::real as p_country_canada,
	       0::real as p_country_germany,
	       0::real as p_country_us,
	       0::real as p_country_southkorea,
	       0::real as p_country_china,
	       0::real as p_country_brazil,
	       0::real as p_country_italy,
	       0::real as p_country_spain,
	       0::real as p_country_other
	from buyers_profiles_tmp
	group by buyerid)
	$tmpl2$;

	tmpl3	text :=
	$tmpl3$
	update %s
       	set p_agegroup_preschool = agegroup_preschool::real / weight,
	    p_agegroup_toddler = agegroup_toddler::real / weight,
       	    p_agegroup_kids = agegroup_kids::real / weight,
       	    p_agegroup_tnt = agegroup_tnt::real / weight,
       	    p_agegroup_family = agegroup_family::real / weight,
       	    p_genre_animation = genre_animation::real / weight,
       	    p_genre_liveaction = genre_liveaction::real / weight,
	    p_genre_education = genre_education::real / weight,
	    p_genre_featurefilm = genre_featurefilm::real / weight,
	    p_genre_art = genre_art::real / weight,
	    p_genre_game = genre_game::real / weight,
	    p_genre_shorts = genre_shorts::real / weight,
	    p_genre_other = genre_other::real / weight,
	    p_boys = boys::real / weight,
	    p_girls = girls::real / weight,
	    p_country_france = country_france::real / weight,
	    p_country_uk = country_uk::real / weight,
	    p_country_canada = country_canada::real / weight,
	    p_country_germany = country_germany::real / weight,
	    p_country_us = country_us::real / weight,
	    p_country_southkorea = country_southkorea::real / weight,
	    p_country_china = country_china::real / weight,
	    p_country_brazil = country_brazil::real / weight,
	    p_country_italy = country_italy::real / weight,
	    p_country_spain = country_spain::real / weight,
	    p_country_other = country_other::real / weight
	$tmpl3$;
begin
	drop table if exists buyers_profiles_tmp;
	execute format ('drop table if exists %s', profiles_table_out);
	execute format (tmpl1, reelport_table_in, products_table_in);
	execute format (tmpl2, profiles_table_out);
	execute format (tmpl3, profiles_table_out);
end $create_buyers_profiles_withcountry$ language plpgsql;
