# COPY PASTE THE PREAMBULE

preambule <- function () {
    con <- getConnection ("experimental2")
    data <- fetchData (con, "foo-data")

    reco.15 <- read.table ("reco.15", sep=',', h=FALSE)
    names (reco.15) = c ("buyerid", "ka", "kb1", "kb2", "kb3")
    row.names (reco.15) = paste (reco.15$buyerid, reco.15$ka)
    
    reco.16 <- read.table ("reco.16", sep=',', h=FALSE)
    names (reco.16) = c ("buyerid", "ka", "kb1", "kb2", "kb3")
    row.names (reco.16) = paste (reco.16$buyerid, reco.15$ka)

    x <- paste (substring (data$buyerid, 3), data$screeningid)
    is15.index <- grep ("2016-10-15", data$firstactionat)
    is15 <- rep (FALSE, nrow(data))
    is15 [is15.index] <- TRUE
    data$kb1 [is15] <- reco.15 [ x [is15], "kb1"]
    data$kb2 [is15] <- reco.15 [ x [is15], "kb2"]
    data$kb3 [is15] <- reco.15 [ x [is15], "kb3"]
    data$kb1 [!is15] <- reco.16 [ x [!is15], "kb1"]
    data$kb2 [!is15] <- reco.16 [ x [!is15], "kb2"]
    data$kb3 [!is15] <- reco.16 [ x [!is15], "kb3"]
    
    
    data$timesscreened <- as.integer (data$timesscreened)
    recommended <- data [ ! is.na (data$recommendedvia), ]
    notrecommended <- data [ is.na (data$recommendedvia),]
    titles <- tapply (as.character  (data$title), data$screeningid, head, n=1)
    companies <- tapply (as.character  (data$companyname), data$screeningid, head, n=1)

    reco.shown <- c (data$kb1, data$kb2, data$kb3)
    reco.shown <- reco.shown [ ! is.na (reco.shown) ]
    reco.raw <- c (reco.15$kb1, reco.15$kb2, reco.15$kb3,
                   reco.16$kb1, reco.16$kb2, reco.16$kb3)
    
    orderedByTimesScreene.recommended <- orderByTimeScreened (recommended)
    orderedByTimesScreene.notrecommended <- orderByTimeScreened (notrecommended)
    orderedByTimesScreene.notrecommended$rnkreco <-
        orderedByTimesScreene.recommended [ row.names (orderedByTimesScreene.notrecommended), "rnk" ]
    orderedByTimesScreene.all <- orderByTimeScreened (data)
    orderedByTimesScreene.notrecommended$rnkall <-
        orderedByTimesScreene.all [ row.names (orderedByTimesScreene.notrecommended), "rnk" ]

    reco.shown <- c (data$kb1, data$kb2, data$kb3)
    reco.raw <- c (rawreco$kb1, rawreco$kb2, rawreco$kb3)

    reco.shown.table <- table (reco.shown)
    reco.shown.table.o <- order (-table (reco.shown))
    reco.shown.table <- reco.shown.table [reco.shown.table.o]

    
    reco.raw.table <- table (reco.raw)
    reco.raw.table.o <- order (-table (reco.raw))
    reco.raw.table <- reco.raw.table [reco.raw.table.o]
    
    
}

orderByTimeScreened <- function (data) {
    timesscreened.all <- tapply (data$timesscreened, data$screeningid, sum)
    o <- order (-timesscreened.all)
    timesscreened.all <- timesscreened.all [o]
    n <- names (timesscreened.all)
    data.frame (title=titles [n],
                company=companies [n],
                timesscreened=timesscreened.all,
                rnk=1:length (o))
}

