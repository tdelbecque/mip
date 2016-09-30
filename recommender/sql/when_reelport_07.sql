drop table if exists reelport_2016_07;
---- CHANGE FILE NAME !
create table reelport_2016_07 (like reelport_pattern_2016);
\copy reelport_2016_07 from '/home/thierry/MIP/data/2016/EXTRACT_2016-fixed_Playlist_20160929_clean.csv' with csv delimiter ';' quote '"' header;
alter table reelport_2016_07 drop column Shortlisted;
alter table reelport_2016_07 drop column RecommendedVia;
alter table reelport_2016_07 drop column FirstActionAt;

drop table if exists reelport_2016;
create table reelport_2016 as table reelport_2016_07;

----------
/*
drop table if exists reelport_2016_14;

create table reelport_2016_14 (like reelport_pattern_2016);
\copy reelport_2016_14 from '/home/thierry/MIP/data/2016/EXTRACT_2016-fixed_Playlist_20161014_clean.csv' with csv delimiter ';' quote '"' header;
alter table reelport_2016_14 drop column Shortlisted;
alter table reelport_2016_14 drop column RecommendedVia;
alter table reelport_2016_14 drop column FirstActionAt;

drop table reelport_2016;
create table reelport_2016 as (select * from reelport_2016_07 union select * from reelport_2016_14);
*/
-------------------

select create_activities ('reelport_2016', 'activities_2016');
select create_cousage ('activities_2016', 'cousage_2016');
drop table if exists toucheditems;
create table toucheditems as
(select substring(buyerid, 3)::integer as buyerid,
	array_agg(screeningid)::integer[] as touched from activities_2016 group by buyerid);

select merge_products_cosim_cousage ('products_cosim_0_2016', 'cousage_2016', 'products_cosim_2016');
select merge_products_cosim_cousage ('products_cosim_0_withcountry_2016', 'cousage_2016', 'products_cosim_withcountry_2016');


select create_buyers_profiles ('reelport_2016', 'products_2013_2016', 'buyers_profiles_2016');
alter table buyers_profiles_2016 add primary key (buyerid);
select create_buyers_profiles_withcountry ('reelport_2016', 'products_profiles_withcountry_2013_2016', 'buyers_profiles_withcountry_2016');
alter table buyers_profiles_withcountry_2016 add primary key (buyerid);
drop table if exists buyers_profiles_withcountry_2013_2016;
create table buyers_profiles_withcountry_2013_2016 as (
       select * from buyers_profiles_withcountry_2013_2015 union
       select * from buyers_profiles_withcountry_2016);


-- this is set segid = 0 to buyers not assigned to a segment
drop table if exists buyer_segments_map_2016;
create table buyer_segments_map_2016 as (
       select A.buyerid, B.segid from (
       	      select distinct norm_personid as buyerid
	      	     from participants_2016
		     where norm_personid is not null and x102791_role like 'buyer%'
	      ) A
	      left outer join segments_withcountries_2013_2016 B
	      on A.buyerid = B.buyerid);
update buyer_segments_map_2016 set segid = 0 where segid is null;


--
-- Segment 0: unclassified users
--

-- Replay here when reelport available

-- segment 0 : create rank variable
drop table if exists seg0reco2;
create table seg0reco2 as
(select *, rank() over (partition by ka order by co_usage desc, co_sim desc, tiebreaker) as rnk from (select *, random() as tiebreaker from products_cosim_2016 where ka != kb) A);

drop table if exists seg0reco2_withcountry;
create table seg0reco2_withcountry as
(select *, rank() over (partition by ka order by co_usage desc, co_sim desc, tiebreaker) as rnk from (select *, random() as tiebreaker from products_cosim_withcountry_2016 where ka != kb) A);

--
-- seg0reco3 contains reco for unclassified users : aggregate in an array
--
drop table if exists seg0reco3;
create table seg0reco3 as
(select 0 as segid, ka, array_agg(kb order by rnk)::integer[] as kbs from seg0reco2 group by ka);

drop table if exists seg0reco3_withcountry;
create table seg0reco3_withcountry as
(select 0 as segid, ka, array_agg(kb order by rnk)::integer[] as kbs from seg0reco2_withcountry group by ka);

--
-- other segments
--
-- join with segment similarity
\qecho '>>>>>>>>> JOIN PRODUCT_COSIM, PRODUCT_SEG_SIM'
drop table if exists reco1;
create table reco1
as (select segid, ka, A.kb, co_usage, co_sim, sim, random () as tiebreaker from products_cosim_2016 A, segments_products_similarities_2016 B
where A.kb = B.kb and A.ka != A.kb);

drop table if exists reco1_withcountry;
create table reco1_withcountry
as (select segid, ka, A.kb, co_usage, co_sim, sim, random () as tiebreaker from products_cosim_withcountry_2016 A, segments_products_similarities_withcountry_2016 B
where A.kb = B.kb and A.ka != A.kb);

-- create rank variable
drop table if exists reco2;
create table reco2 as
(select *, rank() over (partition by segid, ka order by co_usage desc, co_sim desc, sim desc, tiebreaker) as rnk from reco1);

drop table if exists reco2_withcountry;
create table reco2_withcountry as
(select *, rank() over (partition by segid, ka order by co_usage desc, co_sim desc, sim desc, tiebreaker) as rnk from reco1_withcountry);

-- aggregate in an array
drop table if exists reco3;
create table reco3 as
(select segid, ka, array_agg(kb order by rnk)::integer[] as kbs from reco2 group by segid, ka);

drop table if exists reco3_withcountry;
create table reco3_withcountry as
(select segid, ka, array_agg(kb order by rnk)::integer[] as kbs from reco2_withcountry group by segid, ka);

-- merge with segment 0
drop table if exists reco4;
create table reco4 as (select * from seg0reco3 union select * from reco3);
alter table reco4 add primary key (segid, ka);

drop table if exists reco4_withcountry;
create table reco4_withcountry as (select * from seg0reco3_withcountry union select * from reco3_withcountry);
alter table reco4_withcountry add primary key (segid, ka);

-- add buyerid
-- reco_prop1 : recommendations sans connaitre le profil des buyers (juste basé sur le segment 0)
-- propale 0 de base
/*
drop table if exists reco_prop1;
create table reco_prop1 as (
       select buyerid, ka, kbs
       from  buyerid_2016 A,
       	     (select * from reco4_withcountry where segid = 0) B);
	     
drop table if exists reco_prop1_clean;
create table reco_prop1_clean as
(select A.buyerid, ka,
	case when touched is null then kbs else my_array_diff (kbs, touched) end as kbs
	from reco_prop1 A
	left outer join toucheditems B on (A.buyerid = B.buyerid));
	
drop table if exists reco_list_pro1;
create table reco_list_pro1 as select reco4reelport ('reco_prop1_clean', 100);
\copy reco_list_pro1 to '/home/thierry/MIP/recommender/toreel/reco_list_pro1_07.csv'
*/

-- taking into account reelport report

drop table if exists reco_prop2;
create table reco_prop2 as (
       select buyerid, ka, kbs
       from buyer_segments_map_2016  A,
       	    reco4_withcountry B
        where A.segid = B.segid);
	
drop table if exists reco_prop2_clean;
create table reco_prop2_clean as
(select A.buyerid, ka,
	case when touched is null then kbs else my_array_diff (kbs, touched) end as kbs
	from reco_prop2 A left outer join toucheditems B on (A.buyerid = B.buyerid));	

drop table if exists reco_list_pro2;
create table reco_list_pro2 as select reco4reelport ('reco_prop2', 100);
\copy reco_list_pro2 to '/home/thierry/MIP/recommender/toreel/safenet_1007.csv'

