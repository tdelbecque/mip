create or replace function create_buy_or_seg_prod_sim_withcountry
(
	IN	buyers_or_segments_profiles_table_in	text,
	IN	products_profiles_table_in		text,
	IN	buyers_or_segments_products_similarities_table_out	text

)
returns void as $create_buy_or_seg_prod_sim_withcountry$
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
	      	      (A.country_france * p_country_france)::real 	  as p_country_france,
	      	      (A.country_uk * p_country_uk)::real		  as p_country_uk,
	      	      (A.country_canada * p_country_canada)::real 	  as p_country_canada,
	      	      (A.country_germany * p_country_germany)::real 	  as p_country_germany,
	      	      (A.country_us * p_country_us)::real 		  as p_country_us,
	      	      (A.country_southkorea * p_country_southkorea)::real as p_country_southkorea,
	      	      (A.country_china * p_country_china)::real 	  as p_country_china,
	      	      (A.country_brazil * p_country_brazil)::real 	  as p_country_brazil,
	      	      (A.country_italy * p_country_italy)::real 	  as p_country_italy,
	      	      (A.country_spain * p_country_spain)::real 	  as p_country_spain,
	      	      (A.country_other * p_country_other)::real 	  as p_country_other,
		      
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
			    p_boys + p_girls +
			    p_country_france + p_country_uk + p_country_canada + p_country_germany + p_country_us +
	      	     	    p_country_southkorea + p_country_china + p_country_brazil + p_country_italy +
			    p_country_spain + p_country_other
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
$create_buy_or_seg_prod_sim_withcountry$ language plpgsql;

