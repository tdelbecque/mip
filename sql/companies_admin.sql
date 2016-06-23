drop table if exists companiesAdmin;

create table companiesAdmin (
CompanyId	varchar,
	StandReference	varchar,
	CompanyCreatedDate	varchar,
	CompanyLastModifiedDate	varchar,
	FirstName_EN	varchar,
	LastName_EN	varchar,
	Email	varchar,
	NoOfTimesLoggedIn	varchar,
	DateCreated	varchar,
	LastLogin	varchar,
	CompanyName_EN	varchar,
	ParticipatingCompanyName_EN	varchar,
	CompanyType	varchar,
	Address1_EN	varchar,
	Address2_EN	varchar,
	Address3_EN	varchar,
	City_EN	varchar,
	SubRegion_EN	varchar,
	Country_EN	varchar,
	PostCode_EN	varchar,
	Phone_EN	varchar,
	Fax_EN	varchar,
	CompanyEmail_EN	varchar,
	CompanyURL_EN	varchar,
	Headline_EN	varchar,
	CompanyDescription_EN	varchar,
	CompanyPrintedDescription_EN	varchar,
	PrimaryContactFirstName	varchar,
	PrimaryContactLastName	varchar,
	PrimaryContactEmail	varchar,
	CompanyCategoriesSelected	varchar,
	CompanyProductCategoriesSelected	varchar,
	PackageName_EN	varchar,
	Published	varchar,
	ProfileStatus	varchar,
	NumberProductsUploaded	varchar,
	NumberProductsEntitled	varchar,
	NumberVideosActiveCompany	varchar,
	NumberVideosEntitledCompany	varchar,
	NumberVideosActiveProduct	varchar,
	NumberVideosEntitledPerProduct	varchar,
	NumberSocialMediaProfiles	varchar,
	ParentId	varchar,
	Parent_EN	varchar,
	NumberOfSharers	varchar,
	NumberSharersEntitledCompany	varchar,
	StandType	varchar,
	NumberOfParticipantIndividualsCreated	varchar,
	NumberOfMeetingRequestsSent	varchar,
	NumberOfAcceptedMeetingRequestsSent	varchar,
	NumberOfPendingMeetingRequestsSent	varchar,
	NumberOfCancelledOrDeclinedMeetingRequestsSent	varchar,
	NumberOfMeetingRequestsReceived	varchar,
	NumberOfAcceptedMeetingRequestsReceived	varchar,
	NumberOfPendingMeetingRequestsReceived	varchar,
	NumberOfCancelledOrDeclinedMeetingRequestsReceived	varchar,
	NumberOfCompanyBrandsCreated	varchar,
	NumberOfCompanyBrochuresCreated	varchar,
	NumberOfCompanyCaseStudiesCreated	varchar,
	NumberOfCompanyDataSheetsCreated	varchar,
	NumberOfCompanyWhitePapersCreated	varchar,
	NumberOfCompanyPresentationsCreated	varchar,
	NumberOfCompanyPressReleasesCreated	varchar,
	NumberOfCompanyOnSiteSpecialsCreated	varchar,
	NumberOfCompanyJobVacanciesCreated	varchar,
	NumberOfCompanyEventsCreated	varchar,
	X10074_PublishStartDate	varchar,
	X10075_PublishStopDate	varchar,
	X106601_Companyupsellpackage_hierarchy	varchar,
	X106601_Companyupsellpackage_name	varchar,
	X106648_ParticipationType_hierarchy	varchar,
	X106648_ParticipationType_name	varchar,
	X106690_Region_Country_hierarchy	varchar,
	X106690_Region_Country_name	varchar,
	X106719_Additionalprogrammeinformation_hierarchy	varchar,
	X106719_Additionalprogrammeinformation_name	varchar,
	X107048_Credit_IP	varchar,
	X107058_CompanySecondaryActivities_hierarchy	varchar,
	X107058_CompanySecondaryActivities_name	varchar,
	X107059_CompanyActivities_hierarchy	varchar,
	X107059_CompanyActivities_name	varchar,
	X107060_CompanyGenres_hierarchy	varchar,
	X107060_CompanyGenres_name	varchar,
	X107118_CompanyMainActivity_hierarchy	varchar,
	X107118_CompanyMainActivity_name	varchar,
	X108497_ParticipatingMipDoc	varchar,
	X108498_Alsoparticipatingin__hierarchy	varchar,
	X108498_Alsoparticipatingin__name	varchar,
	X10106_PrintedCatalogueContact	varchar,
	X100474_Firsttimer	varchar,
	X101043_ParticipatingMipFormats	varchar,
	X101044_Participationtype_hierarchy	varchar,
	X101044_Participationtype_name	varchar,
	X103091_Additionalstandinfo	varchar,
	X103360_Credits_N_1_programs	varchar,
	X103380_Credits_programs	varchar,
	X105893_Floorplan_standname	varchar,
	X107216_LocateontheFloorPlan	varchar,
	X108265_ParticipatingMipDoc	varchar,
	X109493_Additionalstandinfo	varchar,
	X101045_Participationtype_hierarchy	varchar,
	X101045_Participationtype_name	varchar,
	X101047_ParticipatingMipFormats	varchar,
	X102159_Credits_programs	varchar,
	X102160_Credits_projects	varchar,
	X103361_Credits_N_1_programs	varchar,
	X108266_ParticipatingMipDoc	varchar,
	X10074_PublishStartDate_en	varchar,
	X10075_PublishStopDate_en	varchar,
	X106601_Companyupsellpackage_en_hierarchy	varchar,
	X106601_Companyupsellpackage_en_name	varchar,
	X106648_ParticipationType_en_hierarchy	varchar,
	X106648_ParticipationType_en_name	varchar,
	X106690_Region_Country_en_hierarchy	varchar,
	X106690_Region_Country_en_name	varchar,
	X106719_Additionalprogrammeinformation_en_hierarchy	varchar,
	X106719_Additionalprogrammeinformation_en_name	varchar,
	X107048_Credit_IP_en	varchar,
	X107058_CompanySecondaryActivities_en_hierarchy	varchar,
	X107058_CompanySecondaryActivities_en_name	varchar,
	X107059_CompanyActivities_en_hierarchy	varchar,
	X107059_CompanyActivities_en_name	varchar,
	X107060_CompanyGenres_en_hierarchy	varchar,
	X107060_CompanyGenres_en_name	varchar,
	X107118_CompanyMainActivity_en_hierarchy	varchar,
	X107118_CompanyMainActivity_en_name	varchar,
	X108497_ParticipatingMipDoc_en	varchar,
	X108498_Alsoparticipatingin__en_hierarchy	varchar,
	X108498_Alsoparticipatingin__en_name	varchar,
	X10106_PrintedCatalogueContact_en	varchar,
	X100474_Firsttimer_en	varchar,
	X101043_ParticipatingMipFormats_en	varchar,
	X101044_Participationtype_en_hierarchy	varchar,
	X101044_Participationtype_en_name	varchar,
	X103091_Additionalstandinfo_en	varchar,
	X103360_Credits_N_1_programs_en	varchar,
	X103380_Credits_programs_en	varchar,
	X105893_Floorplan_standname_en	varchar,
	X107216_LocateontheFloorPlan_en	varchar,
	X108265_ParticipatingMipDoc_en	varchar,
	X109493_Additionalstandinfo_en	varchar,
	X101045_Participationtype_en_hierarchy	varchar,
	X101045_Participationtype_en_name	varchar,
	X101047_ParticipatingMipFormats_en	varchar,
	X102159_Credits_programs_en	varchar,
	X102160_Credits_projects_en	varchar,
	X103361_Credits_N_1_programs_en	varchar,
	X108266_ParticipatingMipDoc_en	varchar,
	dummy char(1));

drop table if exists companiesAdmin_2013;
create table companiesAdmin_2013 as table companiesAdmin with no data;

\copy CompaniesAdmin_2013 from '/home/thierry/MIP/03_Company and Individual Information/2013/Company_Admin_Log_MIPJunior_2013_160414135920.Csv' with CSV delimiter ',' quote '"' HEADER;

drop table if exists companiesAdmin_2014;
create table companiesAdmin_2014 as table companiesAdmin with no data;

\copy CompaniesAdmin_2014 from '/home/thierry/MIP/03_Company and Individual Information/2014/Company_Admin_Log_MIPJunior_2014_160414135133.Csv' with CSV delimiter ',' quote '"' HEADER;

drop table if exists companiesAdmin_2015;
create table companiesAdmin_2015 as table companiesAdmin with no data;

\copy CompaniesAdmin_2015 from '/home/thierry/MIP/03_Company and Individual Information/2015/Company_Admin_Log_MIPJunior_2015.csv' with CSV delimiter ',' quote '"' HEADER;

