-- cousage par proxy

create or replace function create_coproduct_similarities_from_profiles
(
	IN	products_profiles_table1_in	text,
	IN	products_profiles_table2_in	text,
	IN	products_sim_table_out		text
)
returns void as $FUN$
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
begin
	execute format ('drop table if exists %s', products_sim_table_out);
	execute format ('create table %s of products_cosim_type', products_sim_table_out);
	execute format (tmpl1,
		       products_sim_table_out,
		       products_profiles_table1_in,
		       products_profiles_table2_in);
	execute format ('alter table %s add primary key (ka, kb)', products_sim_table_out);
	execute format ('update %s as x set co_sim = compute_sim (x.*::products_cosim_type)', products_sim_table_out);
end
$FUN$ language plpgsql;

drop table foobarzob2;
create table foobarzob2 as (select A.*, random () as tiebreaker, B.co_usage as importance from foobarzob A, products_cousage_2014 B where B.ka = B.kb and A.kb = B.kb and A.ka != B.kb);

create table foobarzob3 as (
select *, rank () over (partition by ka order by co_sim desc, importance desc, tiebraker) as rnk from foobarzob2);

create table foobarzob4 as (select * from foobarzob3 where rnk = 1);

create table foobarzob5 as (
select A.ka, B.ka as kb, C.co_usage from foobarzob4 A, foobarzob4 B, products_cousage_2014 C where A.kb = C.ka and B.kb = C.kb);

select count(*), x from (select max (co_usage) as x, ka from foobarzob5 group by ka) A group by x;
