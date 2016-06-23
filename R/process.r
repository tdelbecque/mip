library (RPostgreSQL)


getConnection <- function () {
    m <- dbDriver("PostgreSQL")
    dbConnect(m, dbname="mip")
}

auditCompaniesPerformances <- function (con, year, file) {
    numericFields <-
        tolower (c ('NumberCompanyCategoryCount',
           'NumberCompanyCategoryEntitled',
           'NumberProductsUploaded',
           'NumberPublishedProductsUploaded',
           'NumberProductsEntitled',
           'NumberProductsHighlighted',
           'NumberProductHighlightedEntitled',
           'NumberProductCategoryCount',
           'NumberProductCategoryEntitled',
           'NumberSocialMediaAdded',
           'NumberSocialMediaEntitled',
           'NumberContacts',
           'NumberContactsEntitled',
           'NumberParticipantsAssociated',
           'NumberCompanyDocumentsUploaded',
           'NumberCompanyDocumentsEntitled',
           'NumberCompanyVideosUploaded',
           'NumberCompanyVideosUploadedEntitled',
           'NumberSharers',
           'NumberSharersEntitled',
           'NumberProfilePageViews',
           'NumberProductPageViews',
           'NumberCompanyDocumentDownload',
           'NumberCompanyVideoView',
           'NumberCompanyEnquiries',
           'NumberWebsiteReferrals',
           'NumberShortlistedProfiles',
           'NumberShortlistedProducts',
           'NumberCustomerLeads',
           'CompanyBrandPageViews',
           'NumberShortlistedCompanyBrands',
           'CompanyBrochurePageViews',
           'NumberShortlistedCompanyBrochures',
           'CompanyCaseStudyPageViews',
           'NumberShortlistedCompanyCaseStudys',
           'CompanyDataSheetPageViews',
           'NumberShortlistedCompanyDataSheets',
           'CompanyEventPageViews',
           'NumberShortlistedCompanyEvents',
           'CompanyJobVacancyPageViews',
           'NumberShortlistedCompanyJobVacancys',
           'CompanyOnSiteSpecialPageViews',
           'NumberShortlistedCompanyOnSiteSpecials',
           'CompanyPresentationPageViews',
           'NumberShortlistedCompanyPresentations',
           'CompanyPressReleasePageViews',
           'NumberShortlistedCompanyPressReleases',
           'CompanyWhitePaperPageViews',
           'NumberShortlistedCompanyWhitePapers',
           'DelegatePageViews',
           'NumberShortlistedDelegates'))
    tableName <- paste ("companiesperformances_", year, sep='')
    auditNumericals (con, tableName, numericalFields, file)
}

auditProductsPerformances <- function (con, year, file) {
    numericalFields <-
        c (
            "numberproductimagesuploaded",
            "numberproductimagesentitled",
            "numberproductdocumentsuploaded",
            "numberproductdocumentsentitled",
            "numberproductvideosuploaded",
            "numberproductvideosentitled",
            "numberproductcategoriesselected",
            "numberproductcategoriesentitled",
            "numberproductpageviews",
            "numberproductdocumentdownloads",
            "numberproductvideoviews",
            "numbertimesproductshortlisted",
            "numberproductenquiriesreceived")
    
    tableName <- paste ("productsperformances_", year, sep='')
    auditNumericals (con, tableName, numericalFields, file)
}

closeConnection <- function (con) {
    postgresqlCloseConnection(con)
}

auditNumericals <- function (con, tableName, fields, file) {
    rs <- dbSendQuery(con, paste ("select * from ", tableName, sep=''))
    ds <- fetch (rs, -1)
    dbClearResult(rs)
    if (missing (file))
        file <- stdout ()
    else
        write (file=file, x='', append=FALSE)
    for (f in fields) {
        tbl <- table (ds [[f]])
        if (length (tbl) == 0) {
            write (file=file, x=paste (f, 'IS EMPTY'), append=TRUE);
        } else if (length (tbl) == 1) {
            write (file=file, x=paste (f, 'IS MONOVALUED'), append=TRUE);
        } else {
            write (file=file, x=f, append=TRUE);
            write (file=file, x="\n", append=TRUE);
            write.table (file=file,
                         x=t(as.array (summary (ds [[f]]))),
                         append=TRUE,
                         sep="\t",
                         row.names=FALSE,
                         col.names=TRUE,
                         quote=FALSE)
            write (file=file, append=TRUE, x="\n")
            o <- order (-tbl)
            write.table (file=file,
                         x=t(tbl [o [1:10]]),
                         append=TRUE,
                         sep="\t",
                         row.names=FALSE,
                         col.names=TRUE,
                         quote=FALSE)
        }
        write (file=file, append=TRUE, x="\n______________________________\n")      
    }
    NULL
}
