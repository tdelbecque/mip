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
-- alter table catalog_2013 add column normtitle varchar;
-- update catalog_2013 set normtitle=normstr(title);
select create_products ('2013');
analyse products_2013;

--2014

drop table if exists catalog_2014;
create table catalog_2014 as table catalog_pattern with no data;
\copy catalog_2014 from '/home/thierry/MIP/sql/products.2014.csv' with CSV delimiter ',' quote '"' HEADER;
select create_products ('2014');
analyse products_2014;

--2015

drop table if exists catalog_2015;
create table catalog_2015 as table catalog_pattern with no data;
\copy catalog_2015 from '/home/thierry/MIP/sql/products.2015.csv' with CSV delimiter ',' quote '"' HEADER;
select create_products ('2015');
analyse products_2015;
