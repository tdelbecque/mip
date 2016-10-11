\set ON_ERROR_STOP on

-- !!!!!!
-- !!!!!!

\qecho 'WARNING : DO NOT FORGET drop table if exists segments_withcountries_2013_2016 !!!'
\prompt '(enter)' 'xyz'
-- !!!!!!
-- !!!!!!

drop table if exists reelport_2016_07;
---- CHANGE FILE NAME !
create table reelport_2016_07 (like reelport_pattern_2016);
--\copy reelport_2016_07 from '/home/thierry/MIP/data/2016/EXTRACT_2016-fixed_Playlist_20160929_clean.csv' with csv delimiter ';' quote '"' header;
\copy reelport_2016_07 from '/home/thierry/MIP/data/2016/extract_2016_fixed_Playlist_test10072016_clean.csv' with csv delimiter ';' quote '"' header;
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
drop index if exists toucheditems_idx_buyerid;
create index toucheditems_idx_buyerid on toucheditems(buyerid);

\qecho '>>>>>>>>> MERGE COSIM WITH COUSAGE'
select merge_products_cosim_cousage ('products_cosim_0_withcountry_2016', 'cousage_2016', 'products_cosim_1_withcountry_2016');

\qecho '>>>>>>>>> ADD FRESHNESS'

drop table if exists products_cosim_withcountry_2016;
create table products_cosim_withcountry_2016 as (
       select A.*, freshyearprod
       from products_cosim_1_withcountry_2016 A, products_2016 B
       where A.kb = B.screeningnumber);
drop index if exists products_cosim_withcountry_2016_idx_kb;
create index products_cosim_withcountry_2016_idx_kb on products_cosim_withcountry_2016(kb);

\qecho '>>>>>>>>> BUYER PROFILES'
select create_buyers_profiles_withcountry ('reelport_2016', 'products_profiles_withcountry_2013_2016', 'buyers_profiles_withcountry_2016');
/*
alter table buyers_profiles_withcountry_2016 add primary key (buyerid);
drop table if exists buyers_profiles_withcountry_2013_2016;
create table buyers_profiles_withcountry_2013_2016 as (
       select * from buyers_profiles_withcountry_2013_2015 union
       select * from buyers_profiles_withcountry_2016);
*/
select merge_buyers_profiles_withcountry ('buyers_profiles_withcountry_2013_2015', 'buyers_profiles_withcountry_2016', 'buyers_profiles_withcountry_2013_2016');
alter table buyers_profiles_withcountry_2013_2016 add primary key (buyerid);

-- !!
-- HERE segments_withcountries_2013_2016 SHOULD BE RECOMPUTED
-- !!

\qecho '>>>>>>>>> RESTRICT SEGMENTS MAP TO ACTUAL BUYERS & ADD SEG0 TO THE MAP'
\qecho 'IN CASE OF FAILURE : mapBuyersSegments2016 ()'
\prompt '(enter)' 'xyz'
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

drop table if exists seg0reco2_withcountry;
create table seg0reco2_withcountry as
(select *, rank() over (partition by ka order by co_usage desc, co_sim desc, freshyearprod desc, tiebreaker) as rnk from (select *, random() as tiebreaker from products_cosim_withcountry_2016 where ka != kb) A);

--
-- seg0reco3 contains reco for unclassified users : aggregate in an array
--

drop table if exists seg0reco3_withcountry;
create table seg0reco3_withcountry as
(select 0 as segid, ka, array_agg(kb order by rnk)::integer[] as kbs from seg0reco2_withcountry group by ka);

--
-- other segments
--
-- join with segment similarity
\qecho '>>>>>>>>> JOIN PRODUCT_COSIM, PRODUCT_SEG_SIM'

drop table if exists reco1_withcountry;
create table reco1_withcountry
as (select segid, ka, A.kb, co_usage, co_sim, sim, freshyearprod, random () as tiebreaker from products_cosim_withcountry_2016 A, segments_products_similarities_withcountry_2016 B
where A.kb = B.kb and A.ka != A.kb);

\qecho '>>>>>>>>> CREATE RANK VARIABLE'
drop table if exists reco2_withcountry;
create table reco2_withcountry as
(select *, rank() over (partition by segid, ka order by co_usage desc, co_sim desc, sim desc, freshyearprod desc, tiebreaker) as rnk from reco1_withcountry);

\qecho '>>>>>>>>> GATHER ALL IN ARRAYS'
drop table if exists reco3_withcountry;
create table reco3_withcountry as
(select segid, ka, array_agg(kb order by rnk)::integer[] as kbs from reco2_withcountry group by segid, ka);

\qecho '>>>>>>>>> MERGE WITH SEG0'
drop table if exists reco4_withcountry;
create table reco4_withcountry as (select * from seg0reco3_withcountry union select * from reco3_withcountry);
alter table reco4_withcountry add primary key (segid, ka);

\qecho '>>>>>>>>> SET RECO FOR EACH BUYERID'
drop table if exists reco_prop2;
create table reco_prop2 as (
       select buyerid, ka, kbs
       from buyer_segments_map_2016  A,
       	    reco4_withcountry B
        where A.segid = B.segid);
drop index if exists reco_prop2_idx_buyerid;
create index reco_prop2_idx_buyerid on reco_prop2(buyerid);

\qecho '>>>>>>>>> REMOVE TOUCHED ITEMS'
drop table if exists reco_prop2_clean;
create table reco_prop2_clean as
(select A.buyerid, ka,
	case when touched is null then kbs else my_array_diff (kbs, touched) end as kbs
	from reco_prop2 A left outer join toucheditems B on (A.buyerid = B.buyerid));	

\qecho '>>>>>>>>> EXPORT 4 REELPORT'
drop table if exists reco_list_prop2;
create table reco_list_prop2 as select reco4reelport ('reco_prop2_clean', 100);

\copy reco_list_prop2 to '/home/thierry/MIP/recommender/toreel/safenet_1007_2.csv'

select test_reelport ('reelport_2016', 'unexpected_buyers', 'unexpected_products');

\qecho '>>>>>>>>>>> END OF PROCESS'
