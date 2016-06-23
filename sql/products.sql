drop table if exists catalog_pattern;

create table catalog_pattern (
       ProductId integer,
       CompanyParticipantId integer,
       Title varchar,
       Description varchar,
       ProgrammesProjectsIPs varchar,
       ScreeningNumber smallint,
       New boolean,
       CompanyAtoZ char(1),
       GenreMipJunior varchar,
       Yearofproduction varchar,
       ProgrammesProductionStatus varchar,
       Format varchar,
       Agegroup varchar,
       Numberofepisodes varchar,
       Salesrightscountries varchar,
       Numberofseriesseasons varchar,
       Licencingtarget varchar,
       ProgrammeCreditsauthors varchar,
       ProgrammeCreditsdirector varchar,
       ProgrammeCreditsproducer varchar,
       ProgrammeCreditsmainbroadcaster varchar,
       ProjectCreditscoproductionpartners varchar,
       ProjectCreditsadditionalpartners varchar,
       ProjectCreditsproductionbudget varchar,
       ProjectCreditsfinancestillrequired varchar,
       ProjectCreditsproductioncompletiondate varchar,
       SalesrightsPlatform varchar,
       Languagesavailable varchar,
       YearofProductionStartDate smallint,
       YearofProductionEndDate smallint,
       Format1lengthinminutes smallint,
       Format2lengthinminutes smallint,
       Format1numberofepisodes smallint,
       Format2numberofepisodes smallint,
       Numberofcopies smallint,
       Numberofviewsdownloaded smallint,
       Licensingaudiencetype varchar,
       dummy char(1));

-- 2013

drop table if exists catalog_2013;
create table catalog_2013 as table catalog_pattern with no data;
\copy catalog_2013 from '/home/thierry/MIP/sql/products.2013.csv' with CSV delimiter ',' quote '"' HEADER;
alter table catalog_2013 add column normtitle varchar;
update catalog_2013 set normtitle=normstr(title);

drop table if exists products_2013;
create table products_2013 as (select P.* from catalog_2013 as P, (SELECT MAX (productid) as i from catalog_2013 group by normtitle) as Q where productid = i);

alter table products_2013
      add column languages_arr varchar[],
      add column formats_arr varchar[],
      add column platforms_arr varchar[];
      
update products_2013 set
       languages_arr	= regexp_split_to_array (languagesavailable, E' \\| '),
       platforms_arr   	= regexp_split_to_array (SalesrightsPlatform, E' \\| '),
       formats_arr	= regexp_split_to_array (format, E' \\| ');
 
drop table if exists languages_2013;
create table languages_2013 as (select productid as k,  regexp_split_to_table (languagesavailable, E' \\| ') as v from products_2013);


--2014

drop table if exists catalog_2014;
create table catalog_2014 as table catalog_pattern with no data;
\copy catalog_2014 from '/home/thierry/MIP/sql/products.2014.csv' with CSV delimiter ',' quote '"' HEADER;
alter table catalog_2014 add column normtitle varchar;
update catalog_2014 set normtitle=normstr(title);

drop table if exists products_2014;
create table products_2014 as (select P.* from catalog_2014 as P, (SELECT MAX (productid) as i from catalog_2014 group by normtitle) as Q where productid = i);

alter table products_2014
      add column languages_arr varchar[],
      add column formats_arr varchar[],
      add column platforms_arr varchar[];
      
update products_2014 set
       languages_arr	= regexp_split_to_array (languagesavailable, E' \\| '),
       platforms_arr   	= regexp_split_to_array (SalesrightsPlatform, E' \\| '),
       formats_arr	= regexp_split_to_array (format, E' \\| ');
 
drop table if exists languages_2014;
create table languages_2014 as (select productid as k,  regexp_split_to_table (languagesavailable, E' \\| ') as v from products_2014);

drop table if exists sim_title_2013_2014;
create table sim_title_2013_2014 as select k1, k2, str_similarity(k1,k2) as v from (select A.normtitle as k1, B.normtitle as k2 from products_2013 as A, products_2014 as B) as A;

drop table if exists sim_formats_2013_2014;
create table sim_formats_2013_2014 as select k1, k2, array_jaccard(f1,f2) as v
       from (select A.normtitle as k1, A.formats_arr as f1, B.normtitle as k2, B.formats_arr as f2 from products_2013 as A, products_2014 as B) as A;

drop table if exists sim_languages_2013_2014;
create table sim_languages_2013_2014 as select k1, k2, array_jaccard(f1,f2) as v
       from (select A.normtitle as k1, A.languages_arr as f1, B.normtitle as k2, B.languages_arr as f2 from products_2013 as A, products_2014 as B) as A;

drop table if exists sim_platforms_2013_2014;
create table sim_platforms_2013_2014 as select k1, k2, array_jaccard(f1,f2) as v
       from (select A.normtitle as k1, A.platforms_arr as f1, B.normtitle as k2, B.platforms_arr as f2 from products_2013 as A, products_2014 as B) as A;
