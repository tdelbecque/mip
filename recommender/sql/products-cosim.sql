create or replace function init_products_cosim () returns void as $init_products_cosim$
       drop type if exists products_cosim_type cascade;
       create type products_cosim_type as (
       	      ka   		       integer,
	      kb   		       integer,
	      ---------------------------------------------------------------------
	      co_play		       integer,
	      co_screen		       integer,
	      co_usage		       real,	-- synthesis of co-play & co-screen
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
	      co_sim		       real	-- synthesis of similarity attributes
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

