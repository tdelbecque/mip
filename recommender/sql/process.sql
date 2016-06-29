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

create table reelport_2013_2015 as (select * from reelport_2013 union select * from reelport_2014 union select * from reelport_2015_online union select * from reelport_2015_onsite);

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

------------------------------------------------------------------

-- compute users profiles

select create_buyers_profiles ('reelport_2013_2015', 'products_2013_2015', 'buyers_profiles_2013_2015');
alter table buyers_profiles_2013_2015 add primary key (buyerid);

