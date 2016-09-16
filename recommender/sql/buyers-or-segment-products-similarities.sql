create or replace function create_buyers_or_segments_products_similarities
(
	IN	buyers_or_segments_profiles_table_in	text,
	IN	products_profiles_table_in		text,
	IN	buyers_or_segments_products_similarities_table_out	text

)
returns void as $create_buyers_or_segments_products_similarities$
declare
	tmpl1	text :=
	$tmpl1$
	create table %s as (
	       select segid,
	       	      screeningnumber as kb,
		      (A.agegroup_preschool * p_agegroup_preschool)::real as p_agegroup_preschool,
		      (A.agegroup_toddler * p_agegroup_toddler)::real	  as p_agegroup_toddler,
		      (A.agegroup_kids * p_agegroup_kids)::real		  as p_agegroup_kids,
		      (A.agegroup_tnt * p_agegroup_tnt)::real		  as p_agegroup_tnt,
		      (A.agegroup_family * p_agegroup_family)::real	  as p_agegroup_family,
		      (A.genre_animation * p_genre_animation)::real	  as p_genre_animation,
		      (A.genre_liveaction * p_genre_liveaction)::real	  as p_genre_liveaction,
		      (A.genre_education * p_genre_education)::real	  as p_genre_education,
		      (A.genre_featurefilm * p_genre_featurefilm)::real	  as p_genre_featurefilm,
		      (A.genre_art * p_genre_art)::real			  as p_genre_art,
		      (A.genre_game * p_genre_game)::real		  as p_genre_game,
		      (A.genre_shorts * p_genre_shorts)::real		  as p_genre_shorts,
		      (A.genre_other * p_genre_other)::real		  as p_genre_other,
		      (A.boys * p_boys)::real				  as p_boys,
		      (A.girls * p_girls)::real				  as p_girls,
		      0::real  	 					  as sim
		from %s A, %s B
	)
	$tmpl1$;

	tmpl2	text :=
	$tmpl2$
	update %s set sim = p_agegroup_preschool + p_agegroup_toddler + p_agegroup_kids +
	       	      	    p_agegroup_tnt + p_agegroup_family +
			    p_genre_animation + p_genre_liveaction + p_genre_education +
			    p_genre_featurefilm + p_genre_art + p_genre_game + p_genre_shorts + p_genre_other +
			    p_boys + p_girls
	$tmpl2$;		    
begin
	execute format ('drop table if exists %s', buyers_or_segments_products_similarities_table_out);
	execute format (tmpl1,
		        buyers_or_segments_products_similarities_table_out,
		       	products_profiles_table_in,
			buyers_or_segments_profiles_table_in);
	execute format (tmpl2, buyers_or_segments_products_similarities_table_out);
	execute format ('alter table %s add primary key (segid, kb)', buyers_or_segments_products_similarities_table_out);
end
$create_buyers_or_segments_products_similarities$ language plpgsql;

