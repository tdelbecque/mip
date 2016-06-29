create or replace function init_buyers_segments () returns void as $$
       drop table if exists buyers_segments_pattern;
       create table buyers_segments_pattern (
       	      buyerid integer,
	      segid   integer)
$$ language sql;

create or replace function create_segments_profiles
(
	IN	buyers_segments_table_in	text,
	IN	buyers_profiles_table_in	text,
	IN	segments_profiles_table_out	text
)
returns void as $create_segments_profiles$
declare
	tmpl1 text :=
	$tmpl1$
	create table %s as (
	select segid		as segid,
	       avg(weight)	as weight,
	       --
	       avg(agegroup_preschool) as agegroup_preschool,
	       avg(agegroup_toddler)   as agegroup_toddler,
	       avg(agegroup_kids)      as agegroup_kids,
	       avg(agegroup_tnt)       as agegroup_tnt,
	       avg(agegroup_family)    as agegroup_family,
	       --
	       avg(genre_animation)	as genre_animation,
	       avg(genre_liveaction)	as genre_liveaction,
	       avg(genre_education)	as genre_education,
	       avg(genre_featurefilm)	as genre_featurefilm,
	       avg(genre_art)		as genre_art,
	       avg(genre_game)		as genre_game,
	       avg(genre_shorts)	as genre_shorts,
	       avg(genre_other)		as genre_other,
	       --
	       avg(boys)		as boys,
	       avg(girls)		as girls,
	       --
	       avg(p_agegroup_preschool)	as p_agegroup_preschool,
	       avg(p_agegroup_toddler)		as p_agegroup_toddler,
	       avg(p_agegroup_kids)		as p_agegroup_kids,
	       avg(p_agegroup_tnt)		as p_agegroup_tnt,
	       avg(p_agegroup_family)		as p_agegroup_family,
	       avg(p_genre_animation)		as p_genre_animation,
	       avg(p_genre_liveaction)		as p_genre_liveaction,
	       avg(p_genre_education)		as p_genre_education,
	       avg(p_genre_featurefilm)		as p_genre_featurefilm,
	       avg(p_genre_art)			as p_genre_art,
	       avg(p_genre_game)		as p_genre_game,
	       avg(p_genre_shorts)		as p_genre_shorts,
	       avg(p_genre_other)		as p_genre_other,
	       avg(p_boys)			as p_boys,
	       avg(p_girls)			as p_girls
	 from %s A, %s B
	 where A.buyerid = B.buyerid
	 group by segid)
	$tmpl1$;
begin
	execute format ('drop table if exists %s', segments_profiles_table_out);
	execute format (tmpl1, segments_profiles_table_out, buyers_segments_table_in, buyers_profiles_table_in);
end
$create_segments_profiles$ language plpgsql;
