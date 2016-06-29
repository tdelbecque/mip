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
