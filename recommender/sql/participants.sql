drop table if exists participants;

create table participants (
UserId	varchar,
	FirstName_EN	varchar,
	LastName_EN	varchar,
	ParticipatingCompanyName_EN	varchar,
	ParticipatingCompanyId	varchar,
	Email	varchar,
	JobTitle_EN	varchar,
	Headline_EN	varchar,
	Description_EN	varchar,
	ParticipatingIndividualProfileIsPublished	varchar,
	ParticipatingIndividualProfileIsVisible	varchar,
	NumberOfTimesParticipatingIndividualProfileViewed	varchar,
	DelegateGroup_EN	varchar,
	AppointmentSetting	varchar,
	NumberMeetingRequestsSentByParticipatingIndividual	smallint,
	NumberMeetingRequestsSentByParticipatingIndividualAccepted	smallint,
	NumberMeetingRequestsSentByParticipatingIndividualPending	smallint,
	NumberMeetingRequestsSentByParticipatingIndividualDeclinedCancelled	smallint,
	NumberMeetingRequestsReceivedByParticipatingIndividual	smallint,
	NumberMeetingRequestsReceivedByParticipatingIndividualAccepted	smallint,
	NumberMeetingRequestsReceivedByParticipatingIndividualPending	smallint,
	NumberMeetingRequestsReceivedByParticipatingIndividualDeclinedCancelled	smallint,
	NumberMessagesSentByParticipatingIndividual	smallint,
	NumberMessagesSentByParticipatingIndividualRead	smallint,
	NumberMessagesReceivedByParticipatingIndividual	smallint,
	NumberMessagesReceivedByParticipatingIndividualRead	smallint,
	NumberSocialNetworkProfiles	smallint,
	X100482_Buyer	varchar,
	X100494_Seller	varchar,
	X100581_ParticipantMainActivity_hierarchy	varchar,
	X100581_ParticipantMainActivity_name	varchar,
	X101048_Participationtype_hierarchy	varchar,
	X101048_Participationtype_name	varchar,
	X101049_BusinessFunction_hierarchy	varchar,
	X101049_BusinessFunction_name	varchar,
	X101050_ParticipatingMipFormats	varchar,
	X101057_ParticipantGenres_hierarchy	varchar,
	X101057_ParticipantGenres_name	varchar,
	X101114_Companyactivities_hierarchy	varchar,
	X101114_Companyactivities_name	varchar,
	X101115_Alsoparticipatingin__hierarchy	varchar,
	X101115_Alsoparticipatingin__name	varchar,
	X101154_Continent_Country_hierarchy	varchar,
	X101154_Continent_Country_name	varchar,
	X102275_PS	varchar,
	X102276_PL	varchar,
	X102791_Role	varchar,
	X103381_ETicketurl	varchar,
	X103952_Businessfunction_hierarchy	varchar,
	X103952_Businessfunction_name	varchar,
	X106649_ParticipationType_hierarchy	varchar,
	X106649_ParticipationType_name	varchar,
	X10074_PublishStartDate	varchar,
	X10075_PublishStopDate	varchar,
	X10078_ParticipatingIndividualCustomSort	varchar,
	X108275_ParticipatingMipDoc	varchar,
	X100482_Buyer_en	varchar,
	X100494_Seller_en	varchar,
	X100581_ParticipantMainActivity_en_hierarchy	varchar,
	X100581_ParticipantMainActivity_en_name	varchar,
	X101048_Participationtype_en_hierarchy	varchar,
	X101048_Participationtype_en_name	varchar,
	X101049_BusinessFunction_en_hierarchy	varchar,
	X101049_BusinessFunction_en_name	varchar,
	X101050_ParticipatingMipFormats_en	varchar,
	X101057_ParticipantGenres_en_hierarchy	varchar,
	X101057_ParticipantGenres_en_name	varchar,
	X101114_Companyactivities_en_hierarchy	varchar,
	X101114_Companyactivities_en_name	varchar,
	X101115_Alsoparticipatingin__en_hierarchy	varchar,
	X101115_Alsoparticipatingin__en_name	varchar,
	X101154_Continent_Country_en_hierarchy	varchar,
	X101154_Continent_Country_en_name	varchar,
	X102275_PS_en	varchar,
	X102276_PL_en	varchar,
	X102791_Role_en	varchar,
	X103381_ETicketurl_en	varchar,
	X103952_Businessfunction_en_hierarchy	varchar,
	X103952_Businessfunction_en_name	varchar,
	X106649_ParticipationType_en_hierarchy	varchar,
	X106649_ParticipationType_en_name	varchar,
	X10074_PublishStartDate_en	varchar,
	X10075_PublishStopDate_en	varchar,
	X10078_ParticipatingIndividualCustomSort_en	varchar,
	X108275_ParticipatingMipDoc_en	varchar,
	dummy char(1));

drop table if exists participants_2013;
create table participants_2013 as table participants with no data;
\copy participants_2013 from '/home/thierry/MIP/03_Company and Individual Information/2013/Participating_Individual_Extract_Report_MIPJunior_2013_160414135957.Csv' with CSV delimiter ',' quote '"' HEADER;
alter table participants_2013 add column norm_personid integer;
update participants_2013 set norm_personid = regexp_replace (x103381_eticketurl_en, '.+Contact=(\d+)', E'\\1')::integer;


drop table if exists participants_2014;
create table participants_2014 as table participants with no data;
\copy participants_2014 from '/home/thierry/MIP/03_Company and Individual Information/2014/Participating_Individual_Extract_Report_MIPJunior_2014_160414135211.Csv' with CSV delimiter ',' quote '"' HEADER;
alter table participants_2014 add column norm_personid integer;
update participants_2014 set norm_personid = regexp_replace (x103381_eticketurl_en, '.+Contact=(\d+)', E'\\1')::integer;

drop table if exists participants_2015;
create table participants_2015 as table participants with no data;
\copy participants_2015 from '/home/thierry/MIP/03_Company and Individual Information/2015/Participating_Individual_Extract_Report_MIPJunior_2015_160414133616.Csv' with CSV delimiter ',' quote '"' HEADER;
alter table participants_2015 add column norm_personid integer;
update participants_2015 set norm_personid = regexp_replace (x103381_eticketurl_en, '.+Contact=(\d+)', E'\\1')::integer;

drop table if exists participants_2013_2015;
create table participants_2013_2015 as (select * from participants_2013 union select * from participants_2014 union select * from participants_2015);
