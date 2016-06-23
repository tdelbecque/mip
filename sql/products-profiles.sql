-- products profiles :
--
-- screeningnumber => binary vector on the same attributes as for the buyers
--

drop table if exists products_profiles_2013;
create table products_profiles_2013 as (
       select screeningnumber,
       	       (agegroup is not null and agegroup = 'Pre-school')::integer as agegroup_preschool,
	       (agegroup is not null and agegroup = 'Toddler')::integer    as agegroup_toddler,
	       (agegroup is not null and agegroup = 'Kids')::integer	   as agegroup_kids,
	       (agegroup is not null and agegroup = 'Tweens & Teens')::integer	as agegroup_tnt,
	       (agegroup is not null and agegroup = 'Family')::integer		as agegroup_family,
	       ------------------------------------------------------------------------
	       (GenreMipJunior is not null and GenreMipJunior = 'Animation')::integer		as genre_animation,
	       (GenreMipJunior is not null and GenreMipJunior = 'Live action')::integer	as genre_liveaction,
	       (GenreMipJunior is not null and GenreMipJunior IN ('Discovery & Education', 'Education', 'Documentary / Magazine'))::integer as genre_education,
	       (GenreMipJunior is not null and GenreMipJunior = 'Feature film')::integer  as genre_featurefilm,
	       (GenreMipJunior is not null and GenreMipJunior = 'Art / Music / Culture')::integer as genre_art,
	       (GenreMipJunior is not null and GenreMipJunior = 'Game show')::integer as genre_game,
	       (GenreMipJunior is not null and GenreMipJunior = 'Shorts')::integer as genre_shorts,
	       (GenreMipJunior is not null and GenreMipJunior NOT IN ('Animation', 'Live action',
	       		       	       'Discovery & Education', 'Education', 'Documentary / Magazine',
				       'Feature film', 'Art / Music / Culture', 'Game show', 'Shorts'))::integer as genre_other,
	       ------------------------------------------------------------------------
	       (Licensingaudiencetype is null or Licensingaudiencetype != 'Girls')::integer as boys,
	       (Licensingaudiencetype is null or Licensingaudiencetype != 'Boys')::integer as girls
       from products_2013);


drop table if exists products_profiles_2014;
create table products_profiles_2014 as (
       select screeningnumber,
       	       (agegroup is not null and agegroup = 'Pre-school')::integer as agegroup_preschool,
	       (agegroup is not null and agegroup = 'Toddler')::integer    as agegroup_toddler,
	       (agegroup is not null and agegroup = 'Kids')::integer	   as agegroup_kids,
	       (agegroup is not null and agegroup = 'Tweens & Teens')::integer	as agegroup_tnt,
	       (agegroup is not null and agegroup = 'Family')::integer		as agegroup_family,
	       ------------------------------------------------------------------------
	       (GenreMipJunior is not null and GenreMipJunior = 'Animation')::integer		as genre_animation,
	       (GenreMipJunior is not null and GenreMipJunior = 'Live action')::integer	as genre_liveaction,
	       (GenreMipJunior is not null and GenreMipJunior IN ('Discovery & Education', 'Education', 'Documentary / Magazine'))::integer as genre_education,
	       (GenreMipJunior is not null and GenreMipJunior = 'Feature film')::integer  as genre_featurefilm,
	       (GenreMipJunior is not null and GenreMipJunior = 'Art / Music / Culture')::integer as genre_art,
	       (GenreMipJunior is not null and GenreMipJunior = 'Game show')::integer as genre_game,
	       (GenreMipJunior is not null and GenreMipJunior = 'Shorts')::integer as genre_shorts,
	       (GenreMipJunior is not null and GenreMipJunior NOT IN ('Animation', 'Live action',
	       		       	       'Discovery & Education', 'Education', 'Documentary / Magazine',
				       'Feature film', 'Art / Music / Culture', 'Game show', 'Shorts'))::integer as genre_other,
	       ------------------------------------------------------------------------
	       (Licensingaudiencetype is null or Licensingaudiencetype != 'Girls')::integer as boys,
	       (Licensingaudiencetype is null or Licensingaudiencetype != 'Boys')::integer as girls
       from products_2014);


drop table if exists products_profiles_2015;
create table products_profiles_2015 as (
       select screeningnumber,
       	       (agegroup is not null and agegroup = 'Pre-school')::integer as agegroup_preschool,
	       (agegroup is not null and agegroup = 'Toddler')::integer    as agegroup_toddler,
	       (agegroup is not null and agegroup = 'Kids')::integer	   as agegroup_kids,
	       (agegroup is not null and agegroup = 'Tweens & Teens')::integer	as agegroup_tnt,
	       (agegroup is not null and agegroup = 'Family')::integer		as agegroup_family,
	       ------------------------------------------------------------------------
	       (GenreMipJunior is not null and GenreMipJunior = 'Animation')::integer		as genre_animation,
	       (GenreMipJunior is not null and GenreMipJunior = 'Live action')::integer	as genre_liveaction,
	       (GenreMipJunior is not null and GenreMipJunior IN ('Discovery & Education', 'Education', 'Documentary / Magazine'))::integer as genre_education,
	       (GenreMipJunior is not null and GenreMipJunior = 'Feature film')::integer  as genre_featurefilm,
	       (GenreMipJunior is not null and GenreMipJunior = 'Art / Music / Culture')::integer as genre_art,
	       (GenreMipJunior is not null and GenreMipJunior = 'Game show')::integer as genre_game,
	       (GenreMipJunior is not null and GenreMipJunior = 'Shorts')::integer as genre_shorts,
	       (GenreMipJunior is not null and GenreMipJunior NOT IN ('Animation', 'Live action',
	       		       	       'Discovery & Education', 'Education', 'Documentary / Magazine',
				       'Feature film', 'Art / Music / Culture', 'Game show', 'Shorts'))::integer as genre_other,
	       ------------------------------------------------------------------------
	       (Licensingaudiencetype is null or Licensingaudiencetype != 'Girls')::integer as boys,
	       (Licensingaudiencetype is null or Licensingaudiencetype != 'Boys')::integer as girls
       from products_2015);

drop table if exists products_profiles;
create table products_profiles as (select * from products_profiles_2013 union select * from products_profiles_2014 union select * from products_profiles_2015);

