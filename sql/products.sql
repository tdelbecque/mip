create or replace function create_products (y text) returns void as $fun$
declare
	products_table_name	text;
	catalog_table_name	text;
	languages_table_name	text;
	platforms_table_name	text;
	formats_table_name	text;
begin
	catalog_table_name := format ('catalog_%s', y);
	products_table_name := format ('products_%s', y);
	languages_table_name := format ('languages_%s', y);
	platforms_table_name := format ('platforms_%s', y);
	formats_table_name   := format ('formats_%s', y);
	
	execute format ('drop table if exists %s', products_table_name);
	execute format ('create table %s as (
		       		select P.* from %s as P,
				       	   	(select max (productid) as i from %s group by screeningnumber) as Q
					   where productid = i and screeningnumber is not null)',
			products_table_name, catalog_table_name, catalog_table_name);
	execute format ('alter table %s add primary key (screeningnumber)', products_table_name);
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

	execute format ('drop table if exists %s', languages_table_name);
	execute format ($$create table %s as (
		       		 select screeningnumber as k,
				 	regexp_split_to_table (languagesavailable, E' \\| ') as v
				 from %s)$$, languages_table_name, products_table_name);
end
$fun$ language plpgsql;

/*
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
*/

