#assert existence of
#commonfile
source(commonfile)
#bamfile
load(bamfile)
#pwmfile
load(paste0(pwmdir,pwmid,'.pwmout.RData'))
#tmpdir 

#stablize the variance (helps when there are few high coverage sites).
tfun <- function(x){
    y = x
    y[x>0] = sqrt(x[x>0])
    y
}

unlink(paste0(tmpdir,'*tf',pwmid,'*'))

makeTFmatrix <- function(coords,prefix='',offset=0){
    cwidth = width(coords[[1]][1])
    obschrnames=names(allreads)
    validchr = obschrnames[which(obschrnames%in%ncoords)]
    for(chr in validchr){
    print(chr)
        chrcoord=shift(coords[[chr]],offset)
	pluscoord=allreads[[chr]]$plus
	minuscoord=allreads[[chr]]$minus
        irp=IRanges(start=pluscoord,width=1)
        fos=findOverlaps(chrcoord,irp)
        pos.unique.hits = unique(queryHits(fos))
        pos.offset=pluscoord[subjectHits(fos)]-start(chrcoord)[queryHits(fos)]+1
        ubd=findInterval(c(0,pos.unique.hits),queryHits(fos))
	rre = rle(pos.offset/(2*wsize+1)+queryHits(fos))	
	rval= rre$lengths
	rre$lengths = rep(1,length(rre$lengths))
	posset = inverse.rle(rre)
	uquery=floor(posset)
	uoffset = (posset-uquery)*(2*wsize+1)
	pos.triple = cbind(round(uquery),round(uoffset),tfun(rval))
	pos.mat=sparseMatrix(i=round(uoffset),j=round(uquery),x=tfun(rval),dims=c(2*wsize,length(chrcoord)),giveCsparse=F)
    #
        irn=IRanges(start=minuscoord,width=1)
        fos=findOverlaps(chrcoord,irn)
        neg.unique.hits = unique(queryHits(fos))
        neg.offset=minuscoord[subjectHits(fos)]-start(chrcoord)[queryHits(fos)]+1
        ubd=findInterval(c(0,neg.unique.hits),queryHits(fos))
	rre = rle(neg.offset/(2*wsize+1)+queryHits(fos))	
	rval= rre$lengths
	rre$lengths = rep(1,length(rre$lengths))
	negset = inverse.rle(rre)
	uquery=floor(negset)
	uoffset = (negset-uquery)*(2*wsize+1)
	neg.triple = cbind(round(uquery),round(uoffset),tfun(rval))
	neg.mat=sparseMatrix(i=round(uoffset),j=round(uquery),x=tfun(rval),dims=c(2*wsize,length(chrcoord)),giveCsparse=F)
#
        save(pos.mat,neg.mat,pos.triple,neg.triple,file=paste0(tmpdir,prefix,'tf',pwmid,'-',chr,'.RData'))
	gc()
	    }
}

makeTFmatrix(coords2,'positive.')
makeTFmatrix(coords2,'background.',10000)

#
#####
