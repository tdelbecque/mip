--
-- references files:
-- 	      reelport_2013_2015 for all users activity during the last 3 years;
--	      products_2013_2015 for the products of the last 3 years.
--

drop table if exists reelport_2013;
create table reelport_2013 (like reelport_pattern);
\copy reelport_2013 from '/home/thierry/MIP/data/extract-2013-new-columns.csv' with CSV delimiter E'\t' quote '"' HEADER;

drop table if exists reelport_2014;
create table reelport_2014 (like reelport_pattern);
\copy reelport_2014 from '/home/thierry/MIP/data/extract-2014-new-columns.csv' with CSV delimiter E'\t' quote '"' HEADER;

drop table if exists reelport_2015_onsite;
drop table if exists reelport_2015_online;
create table reelport_2015_onsite (like reelport_pattern);
create table reelport_2015_online (like reelport_pattern);
\copy reelport_2015_online from '/home/thierry/MIP/data/extract-2015-online-new-columns.csv' with CSV delimiter E'\t' quote '"' HEADER;
\copy reelport_2015_onsite from '/home/thierry/MIP/data/extract-2015-onsite-new-columns.csv' with CSV delimiter E'\t' quote '"' HEADER;

drop table if exists reelport_2013_2015;
create table reelport_2015 as (select * from reelport_2015_online union select * from reelport_2015_onsite);
create table reelport_2013_2015 as (select * from reelport_2013 union select * from reelport_2014 union select * from reelport_2015);

select create_activities ('reelport_2013', 'activities_2013');
select create_activities ('reelport_2014', 'activities_2014');
select create_activities ('reelport_2015', 'activities_2015');
select create_activities ('reelport_2013_2015', 'activities_2013_2015');

--------------------------------------------------------------

drop table if exists catalog_2013;
create table catalog_2013 (like catalog_pattern);
\copy catalog_2013 from '/home/thierry/MIP/sql/products.2013.csv' with CSV delimiter ',' quote '"' HEADER;

drop table if exists catalog_2014;
create table catalog_2014 (like catalog_pattern);
\copy catalog_2014 from '/home/thierry/MIP/sql/products.2014.csv' with CSV delimiter ',' quote '"' HEADER;

drop table if exists catalog_2015;
create table catalog_2015 (like catalog_pattern);
\copy catalog_2015 from '/home/thierry/MIP/sql/products.2015.csv' with CSV delimiter ',' quote '"' HEADER;

select create_products('catalog_2013', 'products_2013');
select create_products('catalog_2014', 'products_2014');
select create_products('catalog_2015', 'products_2015');

create table products_2013_2015 as (select * from products_2013 union select * from products_2014 union select * from products_2015);
alter table products_2013_2015 add primary key (screeningnumber);

select create_products_profiles ('products_2013', 'products_profiles_2013');
select create_products_profiles ('products_2014', 'products_profiles_2014');
select create_products_profiles ('products_2015', 'products_profiles_2015');

select create_products_similarities_from_profiles ('products_profiles_2013', 'products_cosim_2013');
select create_products_similarities_from_profiles ('products_profiles_2014', 'products_cosim_2014');
select create_products_similarities_from_profiles ('products_profiles_2015', 'products_cosim_2015');

------------------------------------------------------------------

-- compute users profiles

select create_buyers_profiles ('reelport_2013_2015', 'products_2013_2015', 'buyers_profiles_2013_2015');
alter table buyers_profiles_2013_2015 add primary key (buyerid);


select create_products_similarities_from_profiles ('products_profiles_2015', 'products_cosim_0_2015');
select create_cousage ('activities_2015', 'products_cousage_2015');
select merge_products_cosim_cousage ('products_cosim_0_2015', 'products_cousage_2015', 'products_cosim_2015');

select create_buyers_or_segments_products_similarities ('segments_profiles', 'products_profiles_2015', 'segments_products_similarities_2015');

create table reco1 as (select segid, ka, A.kb,  co_usage, co_sim, sim, random() as tiebreaker from products_cosim_2015 A , segments_products_similarities_2015 B where A.kb = B.kb);

create table reco2 as (select *, rank() over (partition by segid, ka order by co_usage desc, co_sim desc, sim desc, tiebreaker) as rnk from reco1);

create table reco3 as (select segid, ka, array_agg(kb order by rnk)::integer[] as kbs from reco2 group by segid, ka);
alter table reco3 add primary key (segid, ka);

create table reco4 as (select buyerid, A.ka, kbs from reco3 A, buyers_segments B where A.segid = B.segid);
create index reco4_idx on reco4 (buyerid);

drop table if exists toucheditems;
create table toucheditems as (select substring(buyerid, 3)::integer as buyerid, array_agg (screeningid)::integer[] as touched from activities_2013_2015 group by buyerid);
alter table toucheditems add primary key (buyerid);

create table reco5 as (select A.buyerid, case when touched is null then kbs else my_array_diff (kbs, touched) end as kbs from reco4 A left outer join  toucheditems B on (A.buyerid = B.buyerid));

select * from (select buyerid, unnest(kbs)::integer kb from reco5) A, activities_2013_2015 B where substring (B.buyerid, 3)::integer = A.buyerid and A.kb = B.screeningid limit 10;
