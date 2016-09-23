--
-- historical data
--
select products_addcountry ('products_2013', 'companiesadmin_2013', 'products_withcountry_2013');
select products_addcountry ('products_2014', 'companiesadmin_2014', 'products_withcountry_2014');
select products_addcountry ('products_2015', 'companiesadmin_2015', 'products_withcountry_2015');

select create_products_profiles_withcountry ('products_withcountry_2013', 'products_profiles_withcountry_2013');
select create_products_profiles_withcountry ('products_withcountry_2014', 'products_profiles_withcountry_2014');
select create_products_profiles_withcountry ('products_withcountry_2015', 'products_profiles_withcountry_2015');
drop table if exists products_profiles_withcountry_2013_2015;
create table products_profiles_withcountry_2013_2015 as (select * from products_profiles_withcountry_2013 union select * from products_profiles_withcountry_2014 union select * from products_profiles_withcountry_2015);

drop table if exists buyers_profiles_withcountry_2013_2015;
select create_buyers_profiles_withcountry ('reelport_2013_2015', 'products_profiles_withcountry_2013_2015', 'buyers_profiles_withcountry_2013_2015');

--
-- IN R : computes the segment table:
-- doSegmentWithCountries () ==> segments_profiles_withcountry table
--

--
-- NOVA reports
--
drop table if exists participants_2016;
create table participants_2016 as table participants with no data;
\copy participants_2016 from '/home/thierry/MIP/data/2016/Participating_Individual_Extract_Report_MIPJunior_2016_160914134114.csv' with CSV delimiter ',' quote '"' HEADER;
alter table participants_2016 add column norm_personid integer;
update participants_2016 set norm_personid = regexp_replace (x103381_eticketurl_en, '.+Contact=(\d+)', E'\\1')::integer;

\i companies_admin.sql

drop table if exists catalog_2016;
create table catalog_2016 (like catalog_pattern);
-- sh: perl -ne 's/\x0d\x0a//;s/""//g;print "$_;\n" if ($. == 1 or $. > 23)' < mipjunior_2016_20160920.csv > mipjunior_2016_20160920_clean.csv
\copy catalog_2016 from '/home/thierry/MIP/data/2016/mipjunior_2016_20160920_clean.csv' with csv delimiter ';' quote '"' HEADER;

select create_products('catalog_2016', 'products_2016');
select products_addcountry ('products_2016', 'companiesadmin_2016', 'products_withcountry_2016');
drop table if exists products_2013_2016;
create table products_2013_2016 as (select * from products_2013 union select * from products_2014 union select * from products_2015 union select * from products_2016);

select create_products_profiles ('products_2016', 'products_profiles_2016');
select create_products_profiles_withcountry ('products_withcountry_2016', 'products_profiles_withcountry_2016');
drop table if exists products_profiles_withcountry_2013_2016;
create table products_profiles_withcountry_2013_2016 as (select * from products_profiles_withcountry_2013 union select * from products_profiles_withcountry_2014 union select * from products_profiles_withcountry_2015 union select * from products_profiles_withcountry_2016);

select create_products_similarities_from_profiles ('products_profiles_2016', 'products_cosim_2016');
select create_products_similarities_from_profiles_withcountry ('products_profiles_withcountry_2016', 'products_cosim_withcountry_2016');

select create_buyers_or_segments_products_similarities ('segments_profiles', 'products_profiles_2016', 'segments_products_similarities_2016');

select create_buy_or_seg_prod_sim_withcountry ('segments_profiles_withcountry', 'products_profiles_withcountry_2016', 'segments_products_similarities_withcountry_2016');
--
-- Segment 0: unclassified users
--

drop table if exists seg0reco2;
create table seg0reco2 as
(select *, rank() over (partition by ka order by co_usage desc, co_sim desc, tiebreaker) as rnk from (select *, random() as tiebreaker from products_cosim_2016 where ka != kb) A);

drop table if exists seg0reco2_withcountry;
create table seg0reco2_withcountry as
(select *, rank() over (partition by ka order by co_usage desc, co_sim desc, tiebreaker) as rnk from (select *, random() as tiebreaker from products_cosim_withcountry_2016 where ka != kb) A);

--
-- seg0reco3 contains reco for unclassified users
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

drop table if exists reco1;
create table reco1
as (select segid, ka, A.kb, co_usage, co_sim, sim, random () as tiebreaker from products_cosim_2016 A, segments_products_similarities_2016 B
where A.kb = B.kb and A.ka != A.kb);

drop table if exists reco1_withcountry;
create table reco1_withcountry
as (select segid, ka, A.kb, co_usage, co_sim, sim, random () as tiebreaker from products_cosim_withcountry_2016 A, segments_products_similarities_withcountry_2016 B
where A.kb = B.kb and A.ka != A.kb);

drop table if exists reco2;
create table reco2 as
(select *, rank() over (partition by segid, ka order by co_usage desc, co_sim desc, sim desc, tiebreaker) as rnk from reco1);

drop table if exists reco2_withcountry;
create table reco2_withcountry as
(select *, rank() over (partition by segid, ka order by co_usage desc, co_sim desc, sim desc, tiebreaker) as rnk from reco1_withcountry);

drop table if exists reco3;
create table reco3 as
(select segid, ka, array_agg(kb order by rnk)::integer[] as kbs from reco2 group by segid, ka);

drop table if exists reco3_withcountry;
create table reco3_withcountry as
(select segid, ka, array_agg(kb order by rnk)::integer[] as kbs from reco2_withcountry group by segid, ka);

drop table if exists reco4;
create table reco4 as (select * from seg0reco3 union select * from reco3);
alter table reco4 add primary key (segid, ka);

drop table if exists reco4_withcountry;
create table reco4_withcountry as (select * from seg0reco3_withcountry union select * from reco3_withcountry);
alter table reco4_withcountry add primary key (segid, ka);
