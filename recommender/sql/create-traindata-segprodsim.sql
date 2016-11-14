-- train dataset for product * buyers sim
drop table if exists foo;
create table foo as (select A.*, B.buyerid from segments_products_similarities_withcountry_2016 A, buyer_segments_map_2016 B where A.segid = B.segid);
drop table if exists bar;
create table bar as (select A.*, screeningid is not null as flag, rank() over (partition by A.buyerid order by sim desc, tiebreaker) rnk from (select *, random () tiebreaker from foo) A left outer join (select distinct buyerid, screeningid from activities_2016) B
on kb = screeningid and 'RM' || A.buyerid = B.buyerid);
drop table if exists zob;
create table zob as (select A.* from bar A join buyers_profiles_withcountry_2016 B on A.buyerid = B.buyerid);

select count(distinct buyerid) from zob;
select flag, count(*) from zob group by flag;
select flag, avg(rnk) from zob group by flag;
\copy zob to 'segprodsim_train_2016.csv'

------- TRAINING FROM 2015

drop table if exists buyer_segments_map_2015;
create table buyer_segments_map_2015 as (
       select A.buyerid, B.segid from (
       	      select distinct norm_personid as buyerid
	      	     from participants_2015
		     where norm_personid is not null and x102791_role like 'buyer%'
	      ) A
	      left outer join segments_withcountries_2013_2016 B
	      on A.buyerid = B.buyerid);
update buyer_segments_map_2015 set segid = 0 where segid is null;
select create_activities ('reelport_2015', 'activities_2015');
select create_buy_or_seg_prod_sim_withcountry ('segments_profiles_withcountry', 'products_profiles_withcountry_2013_2016', 'segments_products_similarities_withcountry_2013_2016');
select create_buyers_profiles_withcountry ('reelport_2015', 'products_profiles_withcountry_2013_2016', 'buyers_profiles_withcountry_2015');
drop table if exists foo;
create table foo as (select A.*, B.buyerid from segments_products_similarities_withcountry_2013_2016 A, buyer_segments_map_2015 B, products_2015 C
       where A.segid = B.segid and A.kb = C.screeningnumber);
drop table if exists bar;
create table bar as (select A.*, screeningid is not null as flag, rank() over (partition by A.buyerid order by sim desc, tiebreaker) rnk from (select *, random () tiebreaker from foo) A left outer join (select distinct buyerid, screeningid from activities_2015) B
on kb = screeningid and 'RM' || A.buyerid = B.buyerid);
drop table if exists zob;
create table zob as (select A.* from bar A join buyers_profiles_withcountry_2015 B on A.buyerid = B.buyerid);

select count(distinct buyerid) from zob;
select flag, count(*) from zob group by flag;
select flag, avg(rnk) from zob group by flag;
\copy zob to 'segprodsim_train_2015.csv'

------- TRAINING FROM 2014

drop table if exists buyer_segments_map_2014;
create table buyer_segments_map_2014 as (
       select A.buyerid, B.segid from (
       	      select distinct norm_personid as buyerid
	      	     from participants_2014
		     where norm_personid is not null and x102791_role like 'buyer%'
	      ) A
	      left outer join segments_withcountries_2013_2016 B
	      on A.buyerid = B.buyerid);
update buyer_segments_map_2014 set segid = 0 where segid is null;
select create_activities ('reelport_2014', 'activities_2014');

select create_buyers_profiles_withcountry ('reelport_2014', 'products_profiles_withcountry_2013_2016', 'buyers_profiles_withcountry_2014');
drop table if exists foo;
create table foo as (select A.*, B.buyerid from segments_products_similarities_withcountry_2013_2016 A, buyer_segments_map_2014 B, products_2014 C
       where A.segid = B.segid and A.kb = C.screeningnumber);
drop table if exists bar;
create table bar as (select A.*, screeningid is not null as flag, rank() over (partition by A.buyerid order by sim desc, tiebreaker) rnk from (select *, random () tiebreaker from foo) A left outer join (select distinct buyerid, screeningid from activities_2014) B
on kb = screeningid and 'RM' || A.buyerid = B.buyerid);
drop table if exists zob;
create table zob as (select A.* from bar A join buyers_profiles_withcountry_2014 B on A.buyerid = B.buyerid);

select count(distinct buyerid) from zob;
select flag, count(*) from zob group by flag;
select flag, avg(rnk) from zob group by flag;
\copy zob to 'segprodsim_train_2014.csv'

