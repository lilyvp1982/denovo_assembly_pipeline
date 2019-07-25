args <- commandArgs(TRUE)

if (length(args) < 4)
{
  print ("Need more parameters!")
  print("Usage: Rscript tool.filter.selten.transcripts.R labels datadir th odir")
  
}else
{
  filter_transc=function(species, count_files, th, odir)
  {
    print(species)
    if ( !file.exists(paste(sep="",odir,'/',species,".selected.trs.RData")))
    {
      th=as.numeric(th)
      counts = lapply(count_files, function(h) read.table(h, stringsAsFactors=F))
      rt = cbind("tr.len"=counts[[1]][,2],"total.reads"=rowSums(do.call(cbind, lapply(counts, function(h) h[,3]))))
      rownames(rt) = counts[[1]][,1]
      rt = rt[order(rt[,2]),]
      cs.rt = cumsum(rt[,2])
      cs.rt = cs.rt/cs.rt[length(cs.rt)]
   
      thresh = rt[min(which(cs.rt >=th)),2]
      dir.create(odir,showWarnings=F)
    
      save(file=paste(sep="",odir,'/',species,".selected.trs.RData"),'rt','cs.rt','thresh' )
      write.table(file=paste(sep="",odir,'/',species,".selected.trs.txt"),rownames(rt)[rt[,2]>thresh], row.names=F, col.names=F, quote=F)
    }
    else
      load(file=paste(sep="",odir,'/',species,".selected.trs.RData"))
    
    list("total.reads"=rt, 'thresh'=thresh)
  }
  
  labs = read.table(args[[1]], sep=',', stringsAsFactors=F, header=T)
  rownames(labs)=labs$File
  a=intersect(list.files(args[[2]], pattern=".counts"),paste(sep="",labs$File,".counts"))
  names(a) = gsub(".counts","",a) 
  
  a_n = labs[names(a), "Species"] 
  a=paste(sep="/",args[[2]],a)
 
  a = lapply(unique(a_n), function(h) a[a_n%in% h])
  a_n=unique(a_n)
  names(a) = a_n  
  
  th=args[[3]]
  odir=args[[4]]
  
  
  rl = lapply (a_n, function(i)  filter_transc(i,a[[i]], th=th, odir=odir))
}     