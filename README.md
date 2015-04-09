Clustering by fast search and find of density peaks by Alex Rodriguez and Alessandro Laio (2014).

This package is implemented in R and investigated another option for the rho (local density) computation: mean distance to M nearest neighbors, where M is computed as some constant percentage of the number of samples N.

How to use
#Step 1. read data from sample file
dataInfo = loadDataInfo("flame.txt")
#Step 2. plot the data distribution
plotData(dataInfo$df)
#Step 3. compute the local density ρ and the distance δ from points of higher density
clusterResult = densityPeakCluster(dataInfo)
#Step 4. draw the decision graph
plotDeltaRho(clusterResult)

plotData(dataInfo$df,"flame", clusterResult$peaks)

plotMLRatio(dataInfo)

