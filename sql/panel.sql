drop table if exists panel;

create table panel (
       NDA   varchar,
       CompanyName	varchar,
       Region		varchar,
       country		varchar,
       IDPascom		integer,
       Lastname		varchar,
       Firstname	varchar,
       email		varchar,
       jobTitle 	varchar,
       Tel		varchar,
       Interest		varchar,
       Channel		varchar
);

\copy panel from '/home/thierry/MIP/data/BuyersSelectionsProcess as of 190516 master.csv' with csv delimiter E'\t' quote '"' HEADER;



