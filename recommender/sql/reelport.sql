create or replace function create_activities
(
       IN reelport_table_in   text,
       IN activity_table_out  text
)
returns void as $create_activities$
declare
	tmpl1 text :=
	$tmpl1$
	create table %s as (
	       select buyerid,
	       	      screeningid,
		      playlisted::boolean::integer,
	       	      time2sec (totalscreeningtime) as screensec
	       from %s)
	$tmpl1$;
begin
	execute format ('drop table if exists %s', activity_table_out);
	execute format (tmpl1, activity_table_out, reelport_table_in);
end
$create_activities$ language plpgsql;

create or replace function init_reelport () returns void as $init_reelport$
       drop table if exists reelport_pattern;
       create table reelport_pattern (
       	      BuyerCompany	varchar,
      	      BuyerCompanyCountry	varchar,
	      BuyerCompanyID	varchar,
	      BuyerCompanyPhone	varchar,
	      BuyerSalutation	varchar,
	      BuyerFirstname	varchar,
	      BuyerLastname	varchar,
	      BuyerID	varchar,
	      Email	varchar,
	      Genre	varchar,
	      Type	varchar,
	      Companyname	varchar,
	      Companycountry	varchar,
	      SellerCompanyID	varchar,
	      ScreeningId integer,
	      PicturePipeId integer,
	      Title	varchar,
	      Timesviewed	varchar,
	      Timesscreened	varchar,
	      Totalscreeningtime	varchar,
	      Synopsis	varchar,
	      Privatenotes	varchar,
	      Playlisted	integer,
	      Informationforseller	varchar,
	      Sellercontactsalutation	varchar,
	      Sellercontactfirstname	varchar,
	      Sellercontactsurname	varchar,
	      SellerID	varchar,
	      Sellercontactemail	varchar,
	      Sellercontactphone	varchar)
$init_reelport$ language sql;

create or replace function init_reelport_2016 () returns void as $init_reelport_2016$
       drop table if exists reelport_pattern_2016;
       create table reelport_pattern_2016 (
       	      BuyerCompany	varchar,
      	      BuyerCompanyCountry	varchar,
	      BuyerCompanyID	varchar,
	      BuyerCompanyPhone	varchar,
	      BuyerSalutation	varchar,
	      BuyerFirstname	varchar,
	      BuyerLastname	varchar,
	      BuyerID	varchar,
	      Email	varchar,
	      Genre	varchar,
	      Type	varchar,
	      Companyname	varchar,
	      Companycountry	varchar,
	      SellerCompanyID	varchar,
	      ScreeningId integer,
	      PicturePipeId integer,
	      Title	varchar,
	      Timesviewed	varchar,
	      Timesscreened	varchar,
	      Totalscreeningtime	varchar,
	      Synopsis	varchar,
	      Privatenotes	varchar,
	      Playlisted	varchar,
	      Shortlisted	varchar,
	      Informationforseller	varchar,
	      Sellercontactsalutation	varchar,
	      Sellercontactfirstname	varchar,
	      Sellercontactsurname	varchar,
	      SellerID	varchar,
	      Sellercontactemail	varchar,
	      Sellercontactphone	varchar,
	      RecommendedVia varchar,
	      FirstActionAt   varchar)
$init_reelport_2016$ language sql;
