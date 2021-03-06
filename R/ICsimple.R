#'Generates Case II interval-Censored Failure Time data
#'
#'The \code{ICSimple} generates case II interval-censored failure time data. The failure
#'time follows the Weibull regression model
#'
#'First the function generates the failure time using [rweibull()]. The \code{shape}
#'is the same and the second parameter is lambda. Lambda is equal to:
#'\deqn{lambda = scale x exp(X*beta)
#'
#'@param n number of observations to be generated
#'@param shape the first parameter of Weibull distribution
#'@param scale the second parameter of Weibull distribution
#'@param pc the proportion of right-censored expected in the sample
#'@param h the maximum of time between the intervals
#'@param X the vector with the values of covariates. The number of rows of \code{X} must be equal \code{n}
#'@param beta the vector with the value of the regression coefficients. The lenght of \code{beta} must be equal \code{n}
#'
#'
#'@keywords interval censored
#'@examples
#'ICsimple(50,0.8,0.8)
ICSimple <- function(n,shape, scale, pc, h, X = as.matrix(0), beta = as.matrix(0)){
  X <- as.matrix(X)
  beta <- as.matrix(beta)
  #CHECAGENS
  if(!is.numeric(n)) stop('"n" must be  numeric')
  if(n < 0) stop('"n" must be greater than or equal to zero')
  if(!is.numeric(scale)) stop('"scale" must be numeric')
  if(scale < 0) stop('"scale" must be greater than or equal to zero')
  if(!is.numeric(shape)) stop('"shape" must be numeric')
  if(shape < 0) stop('"shape" must be greater than or equal to zero')
  if(!is.numeric(pc)) stop('"pc" must be numeric')
  if(pc > 1 | pc < 0) stop('"pc" must be greater than zero and less than 1')
  if(!is.numeric(h)) stop('"h" must be numeric')
  if(h < 0) stop('"h" must be greater than zero')
  if(!all(X == 0) & nrow(X) != n) stop('Number of observations of "x" must be the
                                          same number of observations
                                          random generated')
  if((!all(X == 0)) & (!all(beta == 0)) & (ncol(X) != length(beta))) stop(
    'Lenght of "beta" must be the same number of columns of "x".')
  if(any(!is.numeric(X))) stop('"x" must be numeric')
  if(any(!is.numeric(beta))) stop('"beta" must be numeric')
  # generating times from the following Weibull distribution:
  u <- runif(n)
  lambda <- scale*exp(X%*%beta)
  tau <- qweibull(rep(1-pc,n), shape = shape, scale = lambda)
  t <- rweibull(n, shape = shape, scale = lambda)


  L=c(rep(0,n)) #left interval limit
  R=c(rep(0,n)) #right interval limit

  for (i in 1:n){
    while (R[i]<=min(tau[i],t[i])) {
      a<-runif(1,0,2*h)
      R[i]<-L[i]+a
      L[i]<-R[i]
    }
    L[i]<-R[i]-a
  }

  delta <-as.numeric(t<tau & tau<R)
  R[delta==1] <- tau[delta == 1]

  delta <-as.numeric(tau<t)
  R[delta==1] <- Inf
  L[L == 0] <- -Inf
  event <- rep(0,n)
  event[delta != 1] <- 3
  y <- cbind(L, R)
  dados<-data.frame(y,event, X)
  return(dados)
}

