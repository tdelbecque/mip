\i buy-or-seg-prod-sim-withcountry.sql

select create_products_similarities_from_profiles_withcountry ('products_profiles_withcountry_2016', 'products_cosim_0_withcountry_2016');
/**/

drop table if exists products_cosim_2016;
create table products_cosim_2016 as (
       select A.*, freshyearprod
       from products_cosim_0_2016 A, products_2016 B
       where A.kb = B.screeningnumber);
--create table products_cosim_2016 as table products_cosim_0_2016;
drop table if exists products_cosim_withcountry_2016;
create table products_cosim_withcountry_2016 as (
       select A.*, freshyearprod
       from products_cosim_0_withcountry_2016 A, products_2016 B
       where A.kb = B.screeningnumber);


select create_buy_or_seg_prod_sim_withcountry ('segments_profiles_withcountry', 'products_profiles_withcountry_2016', 'segments_products_similarities_withcountry_2016');
drop index if exists segments_products_similarities_withcountry_2016_idx_kb;
create index segments_products_similarities_withcountry_2016_idx_kb on segments_products_similarities_withcountry_2016(kb);


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

\i products-cosim-withcountry.sql
select init_products_cosim_withcountry ();
select create_products_similarities_from_profiles_withcountry ('products_profiles_withcountry_2016', 'products_cosim_0_withcountry_2016');
drop table if exists rnk1;
create table rnk1 as
(select ka, kb, co_sim, rank() over (partition by ka order by co_sim desc, tiebreaker) as rnk from (select *, random() as tiebreaker from products_cosim_0_withcountry_2016 where ka != kb) A);
drop table if exists rnk2;
create table rnk2 as (select A.* from rnk1 A, cousage_2016 B where A.ka = B.ka and A.kb = B.kb and B.ka != B.kb);
select avg(rnk) from rnk2;

