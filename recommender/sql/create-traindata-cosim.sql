--- 2015

select create_products_similarities_from_profiles_withcountry ('products_profiles_withcountry_2015', 'products_cosim_0_withcountry_2015');
select create_activities ('reelport_2015', 'activities_2015');
select create_cousage ('activities_2015', 'cousage_2015');
drop table if exists bar;
create table bar as (
       select x.co_agegroup_preschool, x.co_agegroup_toddler,
       	      x.co_agegroup_kids, x.co_agegroup_tnt, x.co_agegroup_family,
	      x.co_genre_animation, x.co_genre_liveaction, x.co_genre_education, 
	      x.co_genre_featurefilm, x.co_genre_art, x.co_genre_game, x.co_genre_shorts, x.co_genre_other,
	      x.co_boys, x.co_girls,
	      x.co_country_france, x.co_country_uk, x.co_country_canada, x.co_country_germany, x.co_country_us,
	      x.co_country_southkorea, x.co_country_china, x.co_country_brazil, x.co_country_italy,
	      x.co_country_spain, x.co_country_other,
	      b.ka, b.kb
	   from products_cosim_0_withcountry_2015 x
	   left outer join cousage_2015 b
	   on x.ka = b.ka and x.kb = b.kb);
alter table bar add column flag smallint;
update bar set flag = 1 where ka is not null;
update bar set flag = 0 where ka is null;
alter table bar drop column ka;
alter table bar drop column kb;
\copy bar to 'cosim_train_2015.csv'


--- 2014

select create_products_similarities_from_profiles_withcountry ('products_profiles_withcountry_2014', 'products_cosim_0_withcountry_2014');
select create_activities ('reelport_2014', 'activities_2014');
select create_cousage ('activities_2014', 'cousage_2014');
drop table if exists bar;
create table bar as (
       select x.co_agegroup_preschool, x.co_agegroup_toddler,
       	      x.co_agegroup_kids, x.co_agegroup_tnt, x.co_agegroup_family,
	      x.co_genre_animation, x.co_genre_liveaction, x.co_genre_education, 
	      x.co_genre_featurefilm, x.co_genre_art, x.co_genre_game, x.co_genre_shorts, x.co_genre_other,
	      x.co_boys, x.co_girls,
	      x.co_country_france, x.co_country_uk, x.co_country_canada, x.co_country_germany, x.co_country_us,
	      x.co_country_southkorea, x.co_country_china, x.co_country_brazil, x.co_country_italy,
	      x.co_country_spain, x.co_country_other,
	      b.ka, b.kb
	   from products_cosim_0_withcountry_2014 x
	   left outer join cousage_2014 b
	   on x.ka = b.ka and x.kb = b.kb);
alter table bar add column flag smallint;
update bar set flag = 1 where ka is not null;
update bar set flag = 0 where ka is null;
alter table bar drop column ka;
alter table bar drop column kb;
\copy bar to 'cosim_train_2014.csv'
