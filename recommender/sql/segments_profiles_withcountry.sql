create or replace function create_segments_profiles_with_country
(
	IN segments_table_in	text,
	IN buyers_profiles_withcountry_table_in	text,
	IN segments_profiles_table_out		text
)
returns void as $create_segments_profiles_with_country$
declare
	tmpl1 text :=
	$tmpl1$
	create table segments_profiles_tmp as (
	select A.segid, B.*
	from %I A, %I B
	where A.buyerid = B.buyerid)
	$tmpl1$;

	tmpl2	text :=
	$tmpl2$
	create table %I as (
	       select segid,
	       SUM(weight) as weight,
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
	       from segments_profiles_tmp
	group by segid)
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
	drop table if exists segments_profiles_tmp;
	execute format (tmpl1, segments_table_in, buyers_profiles_withcountry_table_in);
	execute format (tmpl2, segments_profiles_table_out);
	execute format (tmpl3, segments_profiles_table_out);
end $create_segments_profiles_with_country$ language plpgsql;
