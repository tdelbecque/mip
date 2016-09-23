drop table if exists companiesAdmin_2016;
create table companiesAdmin_2016 (like companiesAdmin);
alter table companiesAdmin_2016 drop column dummy;

\copy company_admin_2016 from '/home/thierry/MIP/data/2016/Company_Admin_Log_MIPJunior_2016_160914134441.csv' with csv delimiter ',' quote '"' HEADER;
