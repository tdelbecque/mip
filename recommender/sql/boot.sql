\set ON_ERROR_STOP on

-- when needed, create table 'buyers_segments' as :
-- 	createClusterTablePretrained (con, cl, 'buyers_profiles_2013_2015', 'buyers_segments')
--
-- when needed : doSegmentWithCountries () ==> segments_profiles_withcountry
--

\i import-products.sql
\i products-addcountry.sql
\i products-profiles.sql
\i products-profiles-withcountry.sql
\i products-cosim.sql
\i products-cosim-withcountry.sql
\i buyers_profiles.sql
\i buyers_profiles_withcountry.sql
\i reelport.sql
\i participants.sql
\i buy-or-seg-prod-sim-withcountry.sql
\i buyers-or-segment-products-similarities.sql
\i buyers_segments.sql
\i segments_profiles_withcountry.sql
\i utils.sql

select init_catalog ();
select init_products_profiles ();
select init_products_profiles_withcountry ();
select init_products_cosim ();
select init_products_cosim_withcountry ();
select init_buyers_profiles ();
select init_buyers_profiles_withcountry ();
select init_reelport ();
select init_reelport_2016 ();
select init_buyers_segments ();

drop table if exists catalog_2013;
create table catalog_2013 (like catalog_pattern);
\copy catalog_2013 from '/home/thierry/MIP/sql/products.2013.csv' with CSV delimiter ',' quote '"' HEADER;

drop table if exists catalog_2014;
create table catalog_2014 (like catalog_pattern);
\copy catalog_2014 from '/home/thierry/MIP/sql/products.2014.csv' with CSV delimiter ',' quote '"' HEADER;

drop table if exists catalog_2015;
create table catalog_2015 (like catalog_pattern);
\copy catalog_2015 from '/home/thierry/MIP/sql/products.2015.csv' with CSV delimiter ',' quote '"' HEADER;

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

drop table if exists reelport_2015;
drop table if exists reelport_2013_2015;
create table reelport_2015 as (select * from reelport_2015_online union select * from reelport_2015_onsite);
create table reelport_2013_2015 as (select * from reelport_2013 union select * from reelport_2014 union select * from reelport_2015);


select create_products('catalog_2013', 'products_2013');
select create_products('catalog_2014', 'products_2014');
select create_products('catalog_2015', 'products_2015');
drop table if exists products_2013_2015;
create table products_2013_2015 as (
       select * from products_2013 union
       select * from products_2014 union
       select * from products_2015);
alter table products_2013_2015 add primary key (screeningnumber);
select create_buyers_profiles ('reelport_2013_2015', 'products_2013_2015', 'buyers_profiles_2013_2015');

\qecho '>>>>>>>>>>> SEGMENTS PROFILE NO COUNTRY'
\qecho 'IN CASE OF FAILURE : createClusterTablePretrained (con, cl, "buyers_profiles_2013_2015", "buyers_segments")'
\qecho '(after clusterModel.RData)'
\prompt '(enter)' 'xyz'

drop table if exists segments_profiles;
select create_segments_profiles ('buyers_segments', 'buyers_profiles_2013_2015', 'segments_profiles');

select create_products_profiles ('products_2013', 'products_profiles_2013');
select create_products_profiles ('products_2014', 'products_profiles_2014');
select create_products_profiles ('products_2015', 'products_profiles_2015');

\i prolog_2016.sql

\qecho '>>>>>>>>>> END OF BOOST'
