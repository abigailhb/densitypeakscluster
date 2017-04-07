
library(tools) # for file paths

# Common util functions
# 
printf <- function(...) cat(sprintf(...))

# Scatter-plot original x,y points.
# highlightPoints are indices of points to change to different color
# 
plotData <- function(dframe,title="Unset",highlightPoints)
{
	n=dim(dframe)[1]
	cs=vector(length=n)
	group = length(levels(factor(dframe$c)))
	color = c("black","red","green3","blue","cyan", "magenta","yellow","orange","chartreuse",
		"chocolate","burlywood","brown1","blueviolet",
		"darkgreen","darkmagenta","darkkhaki","deepskyblue4","dodgerblue",
		"darkorange","firebrick1","darkred","forestgreen","darkslateblue",
		"deeppink","goldenrod4","deeppink4","hotpink3","mediumorchid4","maroon") 
	for(i in 1:group){
       	cs[dframe$c==i]=color[i]
	}

	if(!missing(highlightPoints)){
		cs[highlightPoints]="blue"
	}
	
	chars = rep(1,n)
	chars[highlightPoints]=19
	
	# start plot
	plot(dframe$x, dframe$y, type='p', main=title, xlab='X',ylab='Y',col=cs,pch=chars)
}

#
# Scatter plot delta vs rho, with different colors for the different classes.
# clusterResult is list(rho=rho,delta=delta,score=score,peaks=peaks)
#
plotRhoDelta <- function(clusterResult)
{

	delta = clusterResult$delta
	rho = clusterResult$rho
	cs = clusterResult$peaks
	# start plot
	plot(rho,delta, type='p', main="Decision Graph", xlab='Rho',ylab='Delta',pch=as.integer(factor(cs)))
}

# Compute dist from every point to every other point.
# input dframe has x, y
# 
mDist <- function(dframe)
{
	dataDist = dist(dframe[,1:2])
	pds = as.matrix(dataDist)
	diag(pds) <- 9999999
	pds
}

# For each row in the input data, find its Euclidean distance to
# each of the centroids.
centroidDists <- function(dataMatrix, centroidMatrix) {
    dists = apply(dataMatrix, 1, function(point)
        		sapply(1:nrow(centroidMatrix), function(dim)
              	dist(rbind(point, centroidMatrix[dim, ]))))
    t(dists)
}

#compute cluster sum of squares for error
#
clusterDistSum <- function(dataInfo,peaks) {
	dataMatrix = as.matrix(dataInfo$df)
	centroidMatrix = dataMatrix[peaks,]
	cDists = centroidDists(dataMatrix,centroidMatrix)
    sse = sum(apply(cDists, 1, min))
    printf("    The cluster sum of squares for error %f\n",sse)
    sse
}


# dataInto is a list(name,fileName,nClusters,df) where df is the data in a data frame.
# mratio is what pct of points to use to compute M (the number of nearest neighbors to use).
# nClusters is expected number of clusters
# returns a list with rho,delta,peaks,score
# 
densityPeakCluster <- function(dataInfo,mratio=0.04)
{
	data = dataInfo$df
	n = dim(data)[1]
		
	# Dist to every other point
	pds = mDist(data)
	
	# Dist sort indices
	doi = t(apply(pds, 1, order))

	# Local density: mean of dist to closest M neighbors

	m = round(max(n * mratio, 2))
	#printf("m = %d\n",m)

	rho = sapply(1:n, function(i) mean(pds[i,doi[i,1:m]]))

	# subtract from max to invert rho
	rhomax = max(rho)
	rho = exp(log(rho/rhomax, base=0.5))
	rho = rho / max(rho)
	
	# Ref neighbor: The index of the nearest neighbor of higher density
	# The one with max density will have NA

    eps=.Machine$double.eps

    # densities, in distance sort order
	sortedDensities = t(sapply(1:n,function(i) rho[doi[i,]]))

	# index into sortedDensities is not orig index, it's distance sorted index
	refs = sapply(1:n, function(i) doi[i,which(sortedDensities[i,] > rho[i] + eps)[1]])
	
	# Delta: dist from each point to nearest point of higher density
	delta = sapply(1:n, function(i) pds[i, refs[i]])
	
	# special handproductg for max rho
	maxd = max(delta[!is.na(delta) & (delta < 99999)])
	delta[is.na(delta)] = maxd
	delta[delta > 99999] = maxd
	
	delta = delta / max(delta)

	# Find top nCluster points
	product = rho * delta
	peaks = rev(order(product))[1:dataInfo$nClusters]

	# Compute cluster inner distance sum
	score = clusterDistSum(dataInfo, peaks)
		
	# Build the output
	clusterResult = list(rho=rho, delta=delta, score=score, peaks=peaks)
}

# Find high rho*delta points and show them
# 
plotHighScorePoints <- function(data,result)
{
	product = (result$rho * result$delta)
	
	# stats
	u = mean(product)
	s = sqrt(var(product))
	# mean diff, to be insensitive to outliers
	m = mean(abs(product - u)) 
	
	# select outliers: arbitrarily decided on mean + meanDiff * const
	threshold = u + m * 4
	outliers = which(product > threshold)
	
	plotData(data,'High Score Points',outliers)
	
}

# Loads test data set into a list.
# Return is a list(name,fileName,nClusters,df) where df is the data in a data frame.
# 
loadDataInfo <- function(fileName)
{
	# Define data sets
	rowNames = c('x','y','c')
	name = tolower(file_path_sans_ext(fileName))
	dsNames = list() # to set list names
	path = paste(sep="", 'Data Sets\\', fileName)
	dataFrame = read.csv(path,sep="\t", col.names=rowNames, strip.white=TRUE)
	nClusters = length(levels(factor(dataFrame$c)))
	list(name=name, fileName=fileName, nClusters=nClusters, df=dataFrame)
}

# High level function to compare sensitivity of Rho*Delta cluster peak separation from bulk of points.
# This requires the Shape Sets data files from here:  http://cs.joensuu.fi/sipu/datasets/
#   to be in a subdir 'Data Sets'
# 

plotMLRatio <- function(dataInfo)
{
	#
	# Iteration m-ratio values
	#
	mrs = seq(0.01, 0.1, by=0.005) # the mratio values to try

	scores = vector(length=length(mrs)) # for separation scores
	i = 1
	for (mratio in mrs)
	{
		result = densityPeakCluster(dataInfo, mratio)
		scores[i] = result$score
		i = i + 1
	}
	plot(x=mrs, y=scores, type='l', col="deeppink4", 
				main='SSE vs ratio',xlab='ratio',ylab='SSE', lwd = 3)
	legend('topright', legend=dataInfo$fileName, fill="deeppink4", 
		bty = 'n', lwd = 3, border = NA)
}
