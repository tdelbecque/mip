shuffle <- function (m, w=5) {
    for (row in 1:nrow (m)) 
        for (i in 1:(ncol(m) %/% w)) 
            m [row, (i-1)*w + 1:w] <-
                m [row, (i-1)*w + sample (1:w, w, replace=FALSE)]
    u <- ncol (m) %% w
    if (u > 0) {
        n <- ncol (m) - u
        for (row in 1:nrow (m))
            m [,n + 1:u] <- m [, n + sample (1:u, u, replace=FALSE)]
    }
    m
}

test_shuffle <- function (w=5, nrow=2, ncol=15) 
    shuffle (matrix (1:(nrow*ncol), ncol=ncol, byrow=TRUE), w=w)

shuffle_file <- function (filein, fileout, w=5, seed=1) {
    set.seed (seed)
    data <- read.table (filein, h=FALSE, sep=',')
    TOSHUFFLE <<- as.matrix (data [, 3:ncol(data)])
    shuffle_inplace(TOSHUFFLE, w=w)
    write.table (cbind (data [,1:2], TOSHUFFLE), sep=',',
                 row.names=FALSE, col.names=FALSE, file=fileout)
}

shuffle_inplace <- function (m, w=5) {
    C <- nrow (m) %/% 100 + 1
    for (row in 1:nrow (m)) {
        if (row %% C == 0) cat ('+')
        for (i in 1:(ncol(m) %/% w)) 
            TOSHUFFLE [row, (i-1)*w + 1:w] <<-
                m [row, (i-1)*w + sample (1:w, w, replace=FALSE)]
    }
    u <- ncol (m) %% w
    if (u > 0) {
        n <- ncol (m) - u
        for (row in 1:nrow (m)) {
            if (row %% C == 0) cat ('*')
            TOSHUFFLE[,n + 1:u] <<- m[, n + sample (1:u, u, replace=FALSE)]
        }
    }
}
