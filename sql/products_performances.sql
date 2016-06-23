drop table if exists productsPerformances;
create table productsPerformances (
       ProductId	integer,
	ProductName	varchar,
	ProductDescription	varchar,
	IsPublished	varchar,
	HighlightedListing	varchar,
	NumberProductImagesUploaded	integer,
	NumberProductImagesEntitled	integer,
	NumberProductDocumentsUploaded	integer,
	NumberProductDocumentsEntitled	integer,
	NumberProductVideosUploaded	integer,
	NumberProductVideosEntitled	integer,
	NumberProductCategoriesSelected	integer,
	NumberProductCategoriesEntitled	integer,
	LanguagesEnabled	varchar,
	DateCreated	varchar,
	DateModified	varchar,
	ExhibitorId	varchar,
	ExhibitorName	varchar,
	ProductProfileURL	varchar,
	NumberProductPageViews		integer,
	NumberProductDocumentDownloads	integer,
	NumberProductVideoViews		integer,
	NumberTimesProductShortlisted	integer,
	NumberProductEnquiriesReceived	integer,
	dummy char(1));

drop table if exists productsPerformances_2013;
create table productsPerformances_2013 as table productsPerformances with no data;
\copy productsPerformances_2013 from '/home/thierry/MIP/02_Product Catalogue Performance/Product_Uptake_and_Performance_Report_MIPJunior_2013_160414135948.Csv' with CSV delimiter ',' quote '"' HEADER;

drop table if exists productsPerformances_2014;
create table productsPerformances_2014 as table productsPerformances with no data;
\copy productsPerformances_2014 from '/home/thierry/MIP/02_Product Catalogue Performance/Product_Uptake_and_Performance_Report_MIPJunior_2014_160414135201.Csv' with CSV delimiter ',' quote '"' HEADER;

drop table if exists productsPerformances_2015;
create table productsPerformances_2015 as table productsPerformances with no data;
\copy productsPerformances_2015 from '/home/thierry/MIP/02_Product Catalogue Performance/Product_Uptake_and_Performance_Report_MIPJunior_2015_160414133603.Csv' with CSV delimiter ',' quote '"' HEADER;
