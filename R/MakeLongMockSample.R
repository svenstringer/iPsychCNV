##' MakeLongMockSample: Unknown 
##'
##' Specifically designed to handle noisy data from amplified DNA on phenylketonuria (PKU) cards. The function is a pipeline using many subfunctions.
##' @title MakeLongMockSample
##' @param Heterozygosity: Percentage of BAF around 0.5.
##' @param CNVDistance: Distance among CNVs, defualt = 1000.
##' @param Type: Unknown, default = Unknown.
##' @param Mean: Unknown, default = Unknown.
##' @param Size: Unknown, default = Unknown.
##' @param ChrMean: Unknown, default = 0.
##' @param ChrSD: Unknown, default = 0.18.
##' @return Data frame with predicted CNVs.
##' @author Marcelo Bertalan, Louise K. Hoeffding. 
##' @source \url{http://biopsych.dk/iPsychCNV}
##' @export
##' @examples 
##' Sample <- MakeLongMockSample(CNVDistance=1000, Type=c(0,1,2,3,4), Mean=c(-0.9, -0.8, -0.7, -0.6, -0.5, -0.4, -0.3, -0.2, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9), Size=c(100, 200, 300, 400, 500, 600, 700, 800, 900, 1000), ChrMean=0, ChrSD=0.18)

MakeLongMockSample <- function(Heterozygosity=10, CNVDistance=1000, Type=c(0,1,2,3,4), Mean=c(-1, -0.45, 0, 0.3, 0.75), Size=300, ChrMean=0, ChrSD=0.18)
{
	library(RColorBrewer)
	library(ggplot2)
	library(ggbio)

	# Defining heterozygosity from BAF 
	#Zygosity <- c(0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1)
	#names(Zygosity) <- c(0.2, 0.4, 0.8, 1.35, 2, 3, 5, 8, 16, 80)
	#HeteroBAF <- as.numeric(names(Zygosity)[which(abs(Zygosity-Heterozygosity)==min(abs(Zygosity-Heterozygosity)))])

	df <- sapply(Mean, function(M)
	{
		df <- sapply(Size, function(S)
		{
			df <- sapply(Type, function(Ty)
			{
				df <- data.frame("Type"=Ty,"Mean"=M,"Size"=S, stringsAsFactors=FALSE)			
				return(df)
			})
			df <- MatrixOrList2df(df)
			return(df)
		})
		df <- MatrixOrList2df(df)
		return(df)
	})
	df2 <- MatrixOrList2df(df)

	DataSize <- (nrow(df2)*CNVDistance)+CNVDistance
	tmp <- sapply(1:nrow(df2), function(i){ Start <- i * CNVDistance; Stop <- Start + df2$Size[i]; data.frame(Start=Start, Stop=Stop, StartPos=Start, StopPos=Stop) })
	tmp2 <- MatrixOrList2df(tmp)
	LongRoi <- cbind(df2,tmp2)
	LongRoi$Chr <- "1"
	colnames(LongRoi)[colnames(LongRoi) %in% "Mean"] <- "CNVmean"
	LongRoi$CN <- LongRoi$Type
	LongRoi$CN[LongRoi$Type == 4 & LongRoi$CNVmean < 0.1] <- 2
	LongRoi$CN[LongRoi$Type == 3 & LongRoi$CNVmean < 0.1] <- 2
	LongRoi$CN[LongRoi$Type == 0 & LongRoi$CNVmean > 0.1] <- 2
	LongRoi$CN[LongRoi$Type == 1 & LongRoi$CNVmean > 0.1] <- 2
	LongRoi$ID <- "LongMockSample.tab"
	LongRoi$CNVID <- 1:nrow(LongRoi)
	LongRoi$Length <- LongRoi$Size
	colnames(LongRoi)[colnames(LongRoi) %in% "Size"] <- "NumSNPs"

	# BAFs
	BAFs <- seq(from=0, to=1, by=0.01) # 101
	BAF_Basic <- rep(0.00001, 101)
	names(BAF_Basic) <- BAFs

	##
	BAFs <- seq(from=0, to=1, by=0.01)
	# 0 or 1
	Y = (100 - Heterozygosity)/36

	BAF_Normal <- rep(0, 101)
	BAF_Normal[c(1:2)] <- BAF_Normal[c(1:2)] + (Y *8)  # 40%
	BAF_Normal[c(3:4)] <- BAF_Normal[c(3:4)] + Y # 5%
	
	BAF_Normal[c(98:99)] <- BAF_Normal[c(98:99)] + Y # 5%
	BAF_Normal[c(100:101)] <- BAF_Normal[c(100:101)] + (Y*8) # 40%
		
	BAF_Normal[c(49:52)] <- BAF_Normal[c(49:52)] + (Heterozygosity/5)
	BAF_Normal[c(50:51)] <- BAF_Normal[c(50:51)] + (Heterozygosity/10)
	

	# BAF Del prob
	BAF_Del <- BAF_Basic
	BAF_Del[1:2] <- BAF_Del[1:2] + 1
	BAF_Del[100:101] <- BAF_Del[100:101] + 1

	# BAF CN=0
	BAF_CN0 <- BAF_Basic
	
	# BAF Dup prob
	BAF_Dup <-  BAF_Basic
	BAF_Dup[1:2] <- BAF_Dup[1:2] + (Y*9)
	BAF_Dup[100:101] <- BAF_Dup[100:101] + (Y*9)
	#BAF_Dup[30:35] <- BAF_Dup[30:35] + 0.05 
	BAF_Dup[32:33] <- BAF_Dup[32:33] + Heterozygosity/4
	#BAF_Dup[65:70] <- BAF_Dup[65:70] + 0.05
	BAF_Dup[67:68] <- BAF_Dup[67:68] + Heterozygosity/4

	# BAF CN=4
	BAF_CN4 <- BAF_Basic
	BAF_CN4[1:2] <- BAF_CN4[1:2] + 1
	BAF_CN4[100:101] <- BAF_CN4[100:101] + 1
	BAF_CN4[23:27] <- BAF_CN4[23:27] + 0.05 
	BAF_CN4[24:26] <- BAF_CN4[24:26] + 0.1 
	BAF_CN4[73:77] <- BAF_CN4[73:77] + 0.05
	BAF_CN4[74:76] <- BAF_CN4[74:76] + 0.1
	BAF_CN4[c(47:53)] <- BAF_CN4[c(47:53)] + 0.05
	BAF_CN4[c(50:51)] <- BAF_CN4[c(50:51)] + 0.1

	BAF <- sample(BAFs, prob=BAF_Normal, replace=TRUE, size=DataSize)
	LRR <- rnorm(DataSize, mean=ChrMean, sd=ChrSD)

	sapply(1:nrow(df2), function(i)
	{
		Type <- df2$Type[i]
		CNVmean <- df2$Mean[i]
		Size <- df2$Size[i]

		Start <- i * CNVDistance
		Stop <- Start+Size
		
		LRR[Start:Stop] <<- LRR[Start:Stop] + CNVmean
		if(Type == 3)
		{
			BAFCNV <- sample(BAFs, prob=BAF_Dup, replace=TRUE, size=(Size+1))
		}
		else if(Type == 1)
		{	
			BAFCNV <- sample(BAFs, prob=BAF_Del, replace=TRUE, size=(Size+1))
		}
		else if(Type == 0)
		{
			BAFCNV <- sample(BAFs, prob=BAF_CN0, replace=TRUE, size=(Size+1))
		}
		else if(Type == 4)
		{
			BAFCNV <- sample(BAFs, prob=BAF_CN4, replace=TRUE, size=(Size+1))
		}
		else if(Type == 2)
		{
			BAFCNV <- sample(BAFs, prob=BAF_Normal, replace=TRUE, size=(Size+1))
		}
		
		BAF[Start:Stop] <<- BAFCNV	
	})		

	Chr <- rep("1", DataSize)
	SNP.Name <- as.character(1:DataSize)
	Position <- 1:DataSize

	df <- data.frame(Name=SNP.Name, Chr=Chr, Position=Position, Log.R.Ratio=LRR, B.Allele.Freq=BAF, stringsAsFactors=F)
	write.table(df, sep="\t", quote=FALSE, row.names=FALSE, file="LongMockSample.tab") 
	return(LongRoi)
}
