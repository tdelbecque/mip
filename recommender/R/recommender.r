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

createCosimTrainData <- function (file) {
    data <- read.table (file, h=FALSE, sep='\t')
    names (data) <- c('co_agegroup_preschool',
                      'co_agegroup_toddler',
                      'co_agegroup_kids',
                      'co_agegroup_tnt',
                      'co_agegroup_family',
                      'co_genre_animation',
                      'co_genre_liveaction', 
                      'co_genre_education', 
                      'co_genre_featurefilm', 
                      'co_genre_art', 
                      'co_genre_game', 
                      'co_genre_shorts', 
                      'co_genre_other', 
                      'co_boys', 
                      'co_girls', 
                      'co_country_france', 
                      'co_country_uk', 
                      'co_country_canada', 
                      'co_country_germany', 
                      'co_country_us', 
                      'co_country_southkorea', 
                      'co_country_china', 
                      'co_country_brazil', 
                      'co_country_italy', 
                      'co_country_spain', 
                      'co_country_other', 
                      'flag')

    m <- glm (flag ~ ., data=data)
    write.table (m$coefficients, sep='*', quote=FALSE, eol=' +\n')
    data
}

createProdsegTrainData <- function (file) {
    data <- read.table (file, h=FALSE, sep='\t')
    names (data) <- c (
        'segid',
        'kb',
        'p_agegroup_preschool',
        'p_agegroup_toddler',
        'p_agegroup_kids',
        'p_agegroup_tnt',
        'p_agegroup_family',
        'p_genre_animation',
        'p_genre_liveaction',
        'p_genre_education',
        'p_genre_featurefilm',
        'p_genre_art',
        'p_genre_game',
        'p_genre_shorts',
        'p_genre_other',
        'p_boys',
        'p_girls',
        'p_country_france',
        'p_country_uk',
        'p_country_canada',
        'p_country_germany',
        'p_country_us',
        'p_country_southkorea',
        'p_country_china',
        'p_country_brazil',
        'p_country_italy',
        'p_country_spain',
        'p_country_other',
        'sim',
        'buyerid',
        'tiebreaker',
        'flag',
        'rnk')

    data$flagnum <- ifelse (data$flag == 't', 1, 0)
    data$flag <- NULL
    data$segid <- data$kb <- data$sim <-
        data$buyerid <- data$tiebreaker <- data$flag <- data$rnk  <- NULL

    m <- glm (flagnum ~ ., data=data)
    write.table (m$coefficients, sep='*', quote=FALSE, eol=' +\n')
    data
}
