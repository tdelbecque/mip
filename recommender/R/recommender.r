library (RPostgreSQL)
library (flexclust)

getConnection <- function (dbname) {
    m <- dbDriver("PostgreSQL")
    dbConnect(m, dbname=dbname)
}

closeConnection <- function (con) {
    postgresqlCloseConnection(con)
}

fetchData <- function (con, tableName) {
    rs <- dbSendQuery(con, paste ("select * from ", tableName, sep=''))
    ds <- fetch (rs, -1)
    dbClearResult(rs)
    ds
}

createClusterTablePretrained <- function (con, model, predictTable, newSegmentTable) {
    predictData <- fetchData (con, predictTable)
    p <- predict (model, newdata=predictData [,18:32])
    dbSendQuery (con,
                 paste ("drop table if exists ",
                        newSegmentTable,
                        sep=''))
    dbSendQuery (con,
                 paste ("create table ",
                        newSegmentTable,
                        " (like buyers_segments_pattern)",
                        sep = ''))
    for (i in 1:nrow (predictData))
        dbSendQuery (con,
                     paste ("insert into ",
                            newSegmentTable,
                            " values (",
                            predictData$buyerid [i],
                            ",",
                            p [i],
                            ")",
                            sep = ''))
    
}

createClusterTable <- function (con, learnTable, predictTable, newSegmentTable, k=20) {
    learnData <- fetchData (con, learnTable)
    cl <- cclust (x = learnData [,18:32], k=20)
    predictData <- fetchData (con, predictTable)
    p <- predict (cl, newdata=predictData [,18:32])
    dbSendQuery (con,
                 paste ("drop table if exists ",
                        newSegmentTable,
                        sep=''))
    dbSendQuery (con,
                 paste ("create table ",
                        newSegmentTable,
                        " (like buyers_segments_pattern)",
                        sep = ''))
    for (i in 1:nrow (predictData))
        dbSendQuery (con,
                     paste ("insert into ",
                            newSegmentTable,
                            " values (",
                            predictData$buyerid [i],
                            ",",
                            p [i],
                            ")",
                            sep = ''))

}

doSegmentWithCountries <- function (){
    set.seed(1)
    classifyingAttributes <- 29:54
    dataTable <- 'buyers_profiles_withcountry_2013_2015'
    modelFileName <- 'segments_withcountry_20.RData'
    segmentsTable <- 'segments_withcountries_2013_2015'
    segmentsProfilesTable <- 'segments_profiles_withcountry'
    
    data <- fetchData (con, dataTable)
    segments_withcountry_20 <- cclust (x=data [,classifyingAttributes], k=20)
    save (segments_withcountry_20, file=modelFileName)
    p <- predict (segments_withcountry_20, newdata=data [,classifyingAttributes])
    dbSendQuery (con,
                 paste ("drop table if exists ", segmentsTable));
    dbSendQuery (con,
                 paste ("create table ",
                        segmentsTable,
                        " (like buyers_segments_pattern)",
                        sep = ''))
    for (i in 1:nrow (data))
        dbSendQuery (con,
                     paste ("insert into ",
                            segmentsTable,
                            " values(",
                            data$buyerid [i],
                            ",",
                            p [i],
                            ")",
                            sep = ''))
    rs <- dbSendQuery (con,
                 paste ("select create_segments_profiles_with_country ('",
                        segmentsTable,
                        "','",
                        dataTable,
                        "','",
                        segmentsProfilesTable,
                        "')",
                        sep=''))
    dbClearResult(rs)
}

mapBuyersSegments2016 <- function () {
    classifyingAttributes <- 29:54
    segmentsTable <- 'segments_withcountries_2013_2016'
    modelFileName <- 'segments_withcountry_20.RData'
    dataTable <- 'buyers_profiles_withcountry_2013_2016'
    
    load (modelFileName)
#    con <- getConnection ('test')
    data <- fetchData (con, dataTable)
    p <- predict (segments_withcountry_20, newdata=data [,classifyingAttributes])
    dbSendQuery (con,
                 paste ("drop table if exists ", segmentsTable));
    dbSendQuery (con,
                 paste ("create table ",
                        segmentsTable,
                        " (like buyers_segments_pattern)",
                        sep = ''))
    for (i in 1:nrow (data))
        dbSendQuery (con,
                     paste ("insert into ",
                            segmentsTable,
                            " values(",
                            data$buyerid [i],
                            ",",
                            p [i],
                            ")",
                            sep = ''))
    closeConnection (con)
}
