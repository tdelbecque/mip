drop table if exists reelport_2013;
create table reelport_2013 (
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
	Informationforseller	varchar,
	Sellercontactsalutation	varchar,
	Sellercontactfirstname	varchar,
	Sellercontactsurname	varchar,
	SellerID	varchar,
	Sellercontactemail	varchar,
	Sellercontactphone	varchar);

--\copy reelport_2013 from '/home/thierry/MIP/sql/Fixed Extracts/EXTRACT-2013-fixed.csv' with CSV delimiter E'\t' quote '"' HEADER;
\copy reelport_2013 from '/home/thierry/MIP/data/extract-2013-new-columns.csv' with CSV delimiter E'\t' quote '"' HEADER;

drop table if exists reelport_2014;
create table reelport_2014 as table reelport_2013 with no data;
--\copy reelport_2014 from '/home/thierry/MIP/sql/Fixed Extracts/EXTRACT-2014-fixed.csv' with CSV delimiter E'\t' quote '"' HEADER;
\copy reelport_2014 from '/home/thierry/MIP/data/extract-2014-new-columns.csv' with CSV delimiter E'\t' quote '"' HEADER;

drop table if exists reelport_2015_online;
create table reelport_2015_online as table reelport_2013 with no data;
--\copy reelport_2015_online from '/home/thierry/MIP/sql/Fixed Extracts/EXTRACT-2015-online-fixed.csv' with CSV delimiter E'\t' quote '"' HEADER;
\copy reelport_2015_online from '/home/thierry/MIP/data/extract-2015-online-new-columns.csv' with CSV delimiter E'\t' quote '"' HEADER;

drop table if exists reelport_2015_onsite;
create table reelport_2015_onsite as table reelport_2013 with no data;
--\copy reelport_2015_onsite from '/home/thierry/MIP/sql/Fixed Extracts/EXTRACT-2015-onsite-fixed.csv' with CSV delimiter E'\t' quote '"' HEADER;
\copy reelport_2015_onsite from '/home/thierry/MIP/data/extract-2015-onsite-new-columns.csv' with CSV delimiter E'\t' quote '"' HEADER;

drop table if exists reelport_2015;
create table reelport_2015 as (select * from reelport_2015_online union select * from reelport_2015_onsite);

alter table reelport_2015 add column screensec smallint;
update reelport_2015 set screensec = time2sec (totalscreeningtime);

alter table reelport_2014 add column screensec smallint;
update reelport_2014 set screensec = time2sec (totalscreeningtime);

alter table reelport_2013 add column screensec smallint;
update reelport_2013 set screensec = time2sec (totalscreeningtime);
