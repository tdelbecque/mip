drop table if exists buyers_profiles_with_compid;
create table buyers_profiles_with_compid as (select A.*, B.participatingcompanyid from buyers_profiles_2013_2015 A, (select distinct participatingcompanyid, norm_personid from participants_2013_2015) B where A.buyerid = B.norm_personid);

drop table if exists companies_profiles;
create table companies_profiles as (
select participatingcompanyid,
       SUM (weight) as weight,
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
       0::real as p_girls
from buyers_profiles_with_compid
group by participatingcompanyid);

update companies_profiles
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
	    p_girls = girls::real / weight;
