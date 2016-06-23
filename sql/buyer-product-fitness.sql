drop index if exists i_buyers_products_fitness;
drop table if exists buyers_products_fitness;

create table buyers_products_fitness as (
       select buyerid, screeningnumber,
              A.p_agegroup_preschool * B.agegroup_preschool +
	      A.p_agegroup_toddler * B.agegroup_toddler +
	      A.p_agegroup_kids * B.agegroup_kids +
	      A.p_agegroup_tnt * B.agegroup_tnt +
	      A.p_agegroup_family * B.agegroup_family +
	      A.p_genre_animation * B.genre_animation +
	      A.p_genre_liveaction * B.genre_liveaction +
	      A.p_genre_education * B.genre_education +
	      A.p_genre_featurefilm * B.genre_featurefilm +
	      A.p_genre_art * B.genre_art +
	      A.p_genre_game * B.genre_game +
	      A.p_genre_shorts * B.genre_shorts +
	      A.p_genre_other * B.genre_other +
	      A.p_boys * B.boys +
	      A.p_girls * B.girls as fitness
       from buyers_profiles A, products_profiles B);

create index i_buyers_products_fitness on buyers_products_fitness(screeningnumber);
