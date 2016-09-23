--
--	buyers profiles
--

create or replace function init_buyers_profiles () returns void as $init_buyers_profiles$
       drop table if exists buyers_profiles_elem_pattern;
       create table buyers_profiles_elem_pattern (
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
	      p_girls			real
	      );
              
$init_buyers_profiles$ language sql;

--
--	computes profile of the buyer by looking at his past
--	activity on products
--
--	uses products description and any activity table (such as reelport), provided that
--	it has a buyerid and screeningid fields.
--

create or replace function create_buyers_profiles
(
       reelport_table_in	text, -- user activity
       products_table_in 	text, -- products descriptions
       profiles_table_out 	text
)
returns void as $create_buyers_profiles$
declare
	tmpl1 text :=
	$tmpl1$
	create table buyers_profiles_tmp as (
	select substring(buyerid, 3)::integer as buyerid,
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
	from %s A, %s B
	where A.screeningid = B.screeningnumber)
	$tmpl1$;

	tmpl2 text :=
	$tmpl2$
	create table if not exists %s (like buyers_profiles_elem_pattern)
	$tmpl2$;

	tmpl3 text :=
	$tmpl3$
	insert into %s
	select buyerid,
       	       COUNT(*) as weight,
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
	       
	from buyers_profiles_tmp
	group by buyerid
	$tmpl3$;

	tmpl4 text :=
	$tmpl4$
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
	    p_girls = girls::real / weight
	$tmpl4$;
begin
	drop table if exists buyers_profiles_tmp;
	execute format (tmpl1, reelport_table_in, products_table_in);	-- profiles elements in tmp table
	execute format (tmpl2, profiles_table_out);	  		-- may create output table 
	execute format (tmpl3, profiles_table_out);			-- aggregate raw frequancies
	execute format (tmpl4, profiles_table_out);			-- computes relative frequencies
end
$create_buyers_profiles$ language plpgsql;
