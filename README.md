##  Clustering by fast search and find of density peaks by Alex Rodriguez and Alessandro Laio (2014).

This package is implemented in R and investigated another option for the rho (local density) computation: * mean distance to M nearest neighbors, where M is computed as some constant percentage of the number of samples N*.

How to use

Step :one:. read data from sample file
dataInfo = loadDataInfo("flame.txt")

Step :two:. plot the data distribution
plotData(dataInfo$df)

Step :three:. compute the local density ρ and the distance δ from points of higher density
clusterResult = densityPeakCluster(dataInfo)

Step :four:. draw the decision graph(a scatterplot of features δ and ρ for all points)
plotDeltaRho(clusterResult)

Step :five:. plot the data distribution using cluster centroids 
plotData(dataInfo$df,"flame", clusterResult$peaks)

Step :six:. plot the SSE with the ratio of the number of samples N.
plotMLRatio(dataInfo)

