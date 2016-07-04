create or replace function init_products_cosim () returns void as $init_products_cosim$
       drop type if exists products_cosim_type cascade;
       create type products_cosim_type as (
       	      ka   		       integer,
	      kb   		       integer,
	      ---------------------------------------------------------------------
	      co_agegroup_preschool    integer,
	      co_agegroup_toddler      integer,
	      co_agegroup_kids	       integer,
	      co_agegroup_tnt	       integer,
	      co_agegroup_family       integer,
	      co_genre_animation       integer,
	      co_genre_liveaction      integer,
	      co_genre_education       integer,
	      co_genre_featurefilm     integer,
	      co_genre_art	       integer,
	      co_genre_game	       integer,
	      co_genre_shorts	       integer,
	      co_genre_other	       integer,
	      co_boys		       integer,
	      co_girls		       integer,
	      co_sim		       real,	-- synthesis of similarity attributes
	      ---------------------------------------------------------------------
	      co_play		       integer,
	      co_screen		       integer,
	      co_usage		       real	-- synthesis of co-play & co-screen
	      );

       create or replace function compute_sim (x products_cosim_type) returns real as $compute_sim$
	      begin
	      return x.co_agegroup_preschool + x.co_agegroup_toddler +
		     x.co_agegroup_kids + x.co_agegroup_tnt + x.co_agegroup_family +
		     x.co_genre_animation + x.co_genre_liveaction + x.co_genre_education +
		     x.co_genre_featurefilm + x.co_genre_art + x.co_genre_game + x.co_genre_shorts + x.co_genre_other +
		     x.co_boys + x.co_girls;
	      end
       $compute_sim$ language plpgsql;

       drop type if exists products_cousage_type cascade;
       create type products_cousage_type as (
       	      ka   		       integer,
	      kb   		       integer,
	      ---------------------------------------------------------------------
	      co_play		       integer,
	      co_screen		       integer,
	      co_usage		       real	-- synthesis of co-play & co-screen
	      );

        create or replace function compute_cousage (x products_cousage_type) returns real as $compute_cousage$
	       begin
	       return x.co_play + x.co_screen;
	       end
	$compute_cousage$ language plpgsql;
	
$init_products_cosim$ language sql;

create or replace function create_products_similarities_from_profiles
(
	IN	products_profiles_table_in	text,
	IN	products_sim_table_out		text
)
returns void as $create_products_similarities_from_profiles$
declare
	tmpl1 text :=
	$tmpl1$
	insert into %s
	select A.screeningnumber	as ka,
	       B.screeningnumber	as kb,
	       ---------------------------------------------------------------------
	       0			as co_play,
	       0			as co_screen,
	       0			as co_usage,
	       ---------------------------------------------------------------------	       
	       A.agegroup_preschool * B.agegroup_preschool	as co_agegroup_preschool,
	       A.agegroup_toddler * B.agegroup_toddler 		as co_agegroup_toddler,
	       A.agegroup_kids * B.agegroup_kids 		as co_agegroup_kids,
	       A.agegroup_tnt * B.agegroup_tnt 			as co_agegroup_tnt,
	       A.agegroup_family * B.agegroup_family 		as co_agegroup_family,
	       A.genre_animation * B.genre_animation 		as co_genre_animation,
	       A.genre_liveaction * B.genre_liveaction 		as co_genre_liveaction,
	       A.genre_education * B.genre_education 		as co_genre_education,
	       A.genre_featurefilm * B.genre_featurefilm 	as co_genre_featurefilm,
	       A.genre_art * B.genre_art 			as co_genre_art,
	       A.genre_game * B.genre_game 			as co_genre_game,
	       A.genre_shorts * B.genre_shorts 			as co_genre_shorts,
	       A.genre_other * B.genre_other 			as co_genre_other,
	       A.boys * B.boys 					as co_boys,
	       A.girls * B.girls 				as co_girls,
	       0       	 					as co_sim
	       from %s A, %s B
	$tmpl1$;

	tmpl2 text :=
	$tmpl2$
	$tmpl2$;
begin
	execute format ('drop table if exists %s', products_sim_table_out);
	execute format ('create table %s of products_cosim_type', products_sim_table_out);
	execute format (tmpl1,
		       products_sim_table_out,
		       products_profiles_table_in,
		       products_profiles_table_in);
	execute format ('alter table %s add primary key (ka, kb)', products_sim_table_out);
	execute format ('update %s as x set co_sim = compute_sim (x.*::products_cosim_type)', products_sim_table_out);
end
$create_products_similarities_from_profiles$ language plpgsql;

create or replace function create_cousage
(
	IN	activities_table_in	text,
	IN	cousage_table_out	text
)
returns void as $create_cousage$
declare
	tmpl1 text :=
	$tmpl1$
	create table cousage_elem_tmp as (
	select A.screeningid as ka,
	       B.screeningid as kb,
	       (A.playlisted * B.playlisted)::integer		as co_play,
	       (A.screensec > 0 and B.screensec > 0)::integer	as co_screen
	from %s A, %s B
	where A.buyerid = B.buyerid
	)
	$tmpl1$;

	tmpl2 text :=
	$tmpl2$
	insert into %s
	select ka, kb,
	       sum (co_play)	as co_play,
	       sum (co_screen)	as co_screen,
	       0::integer	as co_usage
	from cousage_elem_tmp
	group by ka, kb
	$tmpl2$;
begin
	execute format ('drop table if exists %s', cousage_table_out);
	drop table if exists cousage_elem_tmp;
	execute format (tmpl1, activities_table_in, activities_table_in);
	execute format ('create table %s of products_cousage_type', cousage_table_out);
	execute format (tmpl2, cousage_table_out);
	execute format ('update %s as x set co_usage = compute_cousage (x.*::products_cousage_type)',
		       cousage_table_out);
	execute format ('alter table %s add primary key (ka, kb)', cousage_table_out);
end
$create_cousage$ language plpgsql;

create or replace function merge_products_cosim_cousage
(
	IN	products_cosim_table_in		text,
	IN	products_cousage_table_in	text,
	IN	products_cosim_table_out	text
)
returns void as $merge_products_cousage_sim$
declare
	tmpl1 text :=
	$tmpl1$
	insert into %s
	select A.ka,
	       A.kb,
	       A.co_agegroup_preschool,
	       A.co_agegroup_toddler,
	       A.co_agegroup_kids,
	       A.co_agegroup_tnt,
	       A.co_agegroup_family,
	       A.co_genre_animation,
	       A.co_genre_liveaction,
	       A.co_genre_education,
	       A.co_genre_featurefilm,
	       A.co_genre_art,
	       A.co_genre_game,
	       A.co_genre_shorts,
	       A.co_genre_other,
	       A.co_boys,
	       A.co_girls,
	       A.co_sim,
	       case when B.co_play is null then 0 else B.co_play end as		co_play,
	       case when B.co_screen is null then 0 else B.co_screen end as 	co_screen,
	       case when B.co_usage is null then 0 else B.co_usage end as   	co_usage
	from %s A
	left outer join %s B on (A.ka = B.ka and A.kb = B.kb)
	$tmpl1$;
begin
	execute format ('drop table if exists %s', products_cosim_table_out);
	execute format ('create table %s of products_cosim_type', products_cosim_table_out);
	execute format (tmpl1, products_cosim_table_out, products_cosim_table_in, products_cousage_table_in);
	execute format ('alter table %s add primary key (ka, kb)', products_cosim_table_out);	
end
$merge_products_cousage_sim$ language plpgsql;
