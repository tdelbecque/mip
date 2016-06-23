/*
drop index if exists i_coscreen_2015;
drop table if exists coscreen_2015;

create table coscreen_2015 as (
       select A.screeningid as ka,
       	      B.screeningid as kb
       from reelport_2015 as A, reelport_2015 as B
       where A.screensec > 0 and B.screensec > 0 and A.buyerid = B.buyerid);

create index i_coscreen_2015 on coscreen_2015(ka, kb);

drop index if exists i_coscreenag_2015_kb;
drop table if exists coscreenag_2015;
create table coscreenag_2015 as (
       select ka, kb, count(*) as n
       from coscreen_2015 group by ka, kb);
create index i_coscreenag_2015_kb on coscreenag_2015 (kb);

drop table if exists coscreenranked_2015;
create table coscreenranked_2015 as (
       select ka, kb, n,
       	      rank() over (partition by ka order by n desc) as rnk
       from coscreenag_2015);
*/

--
-- computes coscreening for a given year.
-- example : select create_coscreen ('2014')
--

create or replace function create_coscreen (y text) returns void as $$
begin
	execute format ('drop index if exists i_coscreen_%s', y);
	execute format ('drop table if exists coscreen_%s', y);
	execute format ('
		create table coscreen_%s as (
       		       select A.screeningid as ka,
       	      	       	      B.screeningid as kb
      			from reelport_%s as A, reelport_%s as B
       			where A.screensec > 0 and B.screensec > 0 and A.buyerid = B.buyerid)',
		y,y,y);
	execute format ('create index i_coscreen_%s on coscreen_%s(ka, kb)', y, y);
	
	execute format ('drop index if exists i_coscreenag_%s_kb', y);
	execute format ('drop table if exists coscreenag_%s', y);
	execute format ('
		create table coscreenag_%s as (
       		       select ka, kb, count(*) as n
       		       from coscreen_%s group by ka, kb)',
		y, y);
	execute format ('create index i_coscreenag_%s_kb on coscreenag_%s (kb)', y, y);

	execute format ('drop table if exists coscreenranked_%s', y);
	execute format ('
		create table coscreenranked_%s as (
       		       select ka, kb, n,
       	      	       	      rank() over (partition by ka order by n desc) as rnk
       			from coscreenag_%s)',
		y, y);
	return;
end
$$ language plpgsql;

