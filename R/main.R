
dataInfo = loadDataInfo("flame.txt")
clusterResult = densityPeakCluster(dataInfo)
plotData(dataInfo$df)
plotDeltaRho(clusterResult)
plotData(dataInfo$df,"spiral", clusterResult$peaks)
plotHighScorePoints(dataInfo$df, clusterResult)
#original
dataDist  <-  dist(dataInfo$df[,1:2])
dc <- estimateDc(dataDist)
rho <- localDensity(dataDist, dc)
delta <- distanceToPeak(dataDist, rho)
peaks <- peakPoints(rho,delta,dataInfo$nClusters)
evaluatePeaks(rho,delta,peaks)
clusterDistSum(dataInfo,peaks)
cluster<-densityClust(dataDist,dc)
plot(cluster)

cluster <- function(dataInfo){
	dataDist  <-  dist(dataInfo$df[,1:2])
	dc <- estimateDc(dataDist)
	rho <- localDensity(dataDist, dc)
	delta <- distanceToPeak(dataDist, rho)
	peaks <- peaksPoints(rho,delta,dataInfo$nClusters)
	peaks
}



