--
-- creates products table
-- 

create or replace function create_products
(
       IN catalog_table_in text,
       IN products_table_out text
)
returns void as $create_products$
declare
	products_table_name	text;
	languages_table_name	text;
	platforms_table_name	text;
	formats_table_name	text;
begin
	products_table_name :=	format ('%s',		products_table_out);
	languages_table_name := format ('%s_languages', products_table_out);
	platforms_table_name := format ('%s_platforms', products_table_out);
	formats_table_name   := format ('%s_formats', 	products_table_out);
	
	execute format ('drop table if exists %s', products_table_name);
	
-- Deduplicates products
	execute format ('create table %s as (
		       		select P.* from %s as P,
				       	   	(select max (productid) as i from %s group by screeningnumber) as Q
					   where productid = i and screeningnumber is not null)',
			products_table_name, catalog_table_in, catalog_table_in);
	execute format ('alter table %s add primary key (screeningnumber)', products_table_name);

-- Creates new fields tables for interesting multivalued fields and last production year
	execute format ('alter table %s
			       add column languages_arr text[],
			       add column formats_arr text[],
			       add column platforms_arr text[],
			       add column freshyearprod smallint', products_table_name);
	execute format ($$update %s set
       		       		languages_arr	= regexp_split_to_array (languagesavailable, E' \\| '),
       				platforms_arr   = regexp_split_to_array (SalesrightsPlatform, E' \\| '),
       				formats_arr	= regexp_split_to_array (format, E' \\| '),
       				freshyearprod 	= case
       		     				  when position ('2017' in yearofproduction) > 0 then 2017 
       		     				  when position ('2016' in yearofproduction) > 0 then 2016
       						  when position ('2015' in yearofproduction) > 0 then 2015 
       						  when position ('2014' in yearofproduction) > 0 then 2014 
       						  when position ('2013' in yearofproduction) > 0 then 2013 
       						  when position ('2012' in yearofproduction) > 0 then 2012 
       						  when position ('2011' in yearofproduction) > 0 then 2011 
       						  when position ('2010' in yearofproduction) > 0 then 2010
       						  when position ('2009' in yearofproduction) > 0 then 2009
       						  when position ('2008' in yearofproduction) > 0 then 2008
       						  when position ('2007' in yearofproduction) > 0 then 2007
       						  when position ('2006' in yearofproduction) > 0 then 2006
       						  when position ('2005' in yearofproduction) > 0 then 2005
       						  when position ('2004' in yearofproduction) > 0 then 2004
       						  when position ('2003' in yearofproduction) > 0 then 2003
       						  when position ('2002' in yearofproduction) > 0 then 2002
       						  when position ('2001' in yearofproduction) > 0 then 2001
       						  when position ('2000' in yearofproduction) > 0 then 2000
						  else 2015
		     				  end
			$$, products_table_name);
/*
	execute format ('drop table if exists %s', languages_table_name);
	execute format ($$create table %s as (
		       		 select screeningnumber as k,
				 	regexp_split_to_table (languagesavailable, E' \\| ') as v
				 from %s)$$, languages_table_name, products_table_name);
*/
end
$create_products$ language plpgsql;

create or replace function init_catalog () returns void as $init_catalog$
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
	       dummy char(1))
$init_catalog$ language sql;
