create or replace function init_products_profiles () returns void as $init_products_profiles$
       drop type if exists products_profiles_type cascade;
       create type products_profiles_type as (
       	      screeningnumber		  integer,
       	      agegroup_preschool	  integer,
	      agegroup_toddler		  integer,
	      agegroup_kids		  integer,
	      agegroup_tnt		  integer,
	      agegroup_family		  integer,
	      ------------------------------------------------------------------------
	      genre_animation		  integer,
	      genre_liveaction		  integer,
	      genre_education		  integer,
	      genre_featurefilm		  integer,
	      genre_art			  integer,
	      genre_game		  integer,
	      genre_shorts		  integer,
	      genre_other		  integer,
	      ------------------------------------------------------------------------
	      boys			  integer,
	      girls			  integer)
$init_products_profiles$ language sql;

create or replace function create_products_profiles
(
	IN	products_table_in text,
	IN	profiles_table_out text
)
returns void as $create_products_profiles$
declare
	products_table_name	text;
	languages_table_name	text;
	platforms_table_name	text;
	formats_table_name	text;
	
	tmpl1 text :=
	$tmpl1$
	insert into %s
       	select screeningnumber,
       	       (agegroup is not null and agegroup = 'Pre-school')::integer,
	       (agegroup is not null and agegroup = 'Toddler')::integer,
	       (agegroup is not null and agegroup = 'Kids')::integer,
	       (agegroup is not null and agegroup = 'Tweens & Teens')::integer,
	       (agegroup is not null and agegroup = 'Family')::integer,
	       ------------------------------------------------------------------------
	       (GenreMipJunior is not null and GenreMipJunior = 'Animation')::integer,
	       (GenreMipJunior is not null and GenreMipJunior = 'Live action')::integer,
	       (GenreMipJunior is not null and GenreMipJunior IN ('Discovery / Education / Doc', 'Discovery & Education', 'Education', 'Documentary / Magazine'))::integer,
	       (GenreMipJunior is not null and GenreMipJunior = 'Feature film')::integer,
	       (GenreMipJunior is not null and GenreMipJunior = 'Art / Music / Culture')::integer,
	       (GenreMipJunior is not null and GenreMipJunior = 'Game show')::integer,
	       (GenreMipJunior is not null and GenreMipJunior = 'Shorts')::integer,
	       (GenreMipJunior is not null and GenreMipJunior NOT IN ('Animation', 'Live action',
	       		       	       'Discovery & Education', 'Education', 'Documentary / Magazine', 'Discovery / Education / Doc',
				       'Feature film', 'Art / Music / Culture', 'Game show', 'Shorts'))::integer,
	       ------------------------------------------------------------------------
	       (Licensingaudiencetype is null or Licensingaudiencetype != 'Girls')::integer,
	       (Licensingaudiencetype is null or Licensingaudiencetype != 'Boys')::integer
        from %s
	$tmpl1$;
begin
	products_table_name :=	format ('%s',		products_table_in);
	languages_table_name := format ('%s_languages', products_table_in);
	platforms_table_name := format ('%s_platforms', products_table_in);
	formats_table_name   := format ('%s_formats', 	products_table_in);

execute format ('drop table if exists %s', profiles_table_out);
	execute format ('create table %s of products_profiles_type', profiles_table_out);
	execute format (tmpl1, profiles_table_out, products_table_name);
	execute format ('alter table %s add primary key (screeningnumber)', profiles_table_out);
end
$create_products_profiles$ language plpgsql;

