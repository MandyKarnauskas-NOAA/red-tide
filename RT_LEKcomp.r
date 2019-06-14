################################################################################
############  M. Karnauskas May 2019                                ############
############  code for compiling red tide oral history information  ############
############  produces outputs for SEDAR 61 working paper           ############


# todo:   add inshore/offshore, county categorization

rm(list=ls())
setwd("C:/Users/mkarnauskas/Desktop/RT_severity")

#  download most recent version of live spreadsheet from Google Drive  (search "RT_Summary_Spreadsheet")
#  remove second row 
d <- read.table("RT_Summary_Spreadsheet_Jun13.csv", header=T, skip=0, sep=",", quote="\"")

head(d)
names(d)

d <- d[1:19]   # cut out long character columns

table(d$SEFSC.or.SERO)
table(d$Interview.Number)
length(unique(d$Interview.Number))    # number of interviews == 43
table(d$Interview.ID)
table(d$Interviewee)
table(d$Date.Of.Interview)
table(d$RT.Event.Period)
table(d$Year)
table(d$Community)
table(d$Offshore.or.Inshore.)
table(d$Area.Fished)
table(d$Scale)
table(d$Temporal.Extent)
table(d$Spatial.Extent.of.Red.Tide)
table(d$Map.Legend)
table(d$Areas.Fished.that.are.not.affected.by.RT)
table(d$Species.Targeted)
table(d$Species.Affected)
table(d$Species.NOT.affected)
table(d$Recovery.Time)

############   define areas    #################################################
Pinellas <- c("Clearwater", "Madeira Beach", "St. Petersberg", "Tarpon Springs")
Charlotte <- c("Boca Grande", "Cape Haze", "Placida")
Collier <- c("Chokoloskee",  "Everglades City", "Goodland", "Naples")
Manatee <- c("Cortez", "Cortez\n")
Lee <- c("Fort Myers Beach", "Pine Island", "Plantation Island")

d$County <- NA
d$County[which(d$Community %in% Pinellas)] <- "Pinellas"
d$County[which(d$Community %in% Charlotte)] <- "Charlotte"
d$County[which(d$Community %in% Collier)] <- "Collier"
d$County[which(d$Community %in% Manatee)] <- "Manatee"
d$County[which(d$Community %in% Lee)] <- "Lee"

table(d$Community, d$County)

d$County <- factor(d$County, levels = c("Collier", "Lee", "Charlotte", "Manatee", "Pinellas"))

############   convert comments about severity into 4 categories    ############
table(d$Scale)
d$rat <- NA

# update this section as new interviews come onboard
# key word search
d$rat[grep("minor", d$Scale)] <- "minor"
d$rat[grep("significant", d$Scale)] <- "medium"
d$rat[grep("bad", d$Scale)] <- "major"
d$rat[grep("not bad", d$Scale)] <- "minor"
d$rat[grep("devastating", d$Scale)] <- "devastating"
d$rat[grep("10/10", d$Scale)] <- "devastating"
d$rat[grep("9.5/10", d$Scale)] <- "devastating"
# specific term assignments 
l_min <- c("not bad", "normal", "small", "small events", "patchy")
l_med <- c("bad (3/10)")
l_maj <- c("worst", "extensive", "intense", "major", "severe", "terrible", "miserable")
# convert lists to their categories                            
d$rat[d$Scale %in% l_min] <- "minor"
d$rat[d$Scale %in% l_med] <- "medium"
d$rat[d$Scale %in% l_maj] <- "major"
d$rat[d$Scale %in% l_dev] <- "devastating"
# check results
table(d$Scale, d$rat)
table(d$rat, useNA="always")
matrix(d$Scale[which(is.na(d$rat))])            # check responses markes as NAs
# check carefully the final categorizations!
table(droplevels(d$Scale[which(d$rat=="minor")]))
table(droplevels(d$Scale[which(d$rat=="medium")]))
table(droplevels(d$Scale[which(d$rat=="major")]))
table(droplevels(d$Scale[which(d$rat=="devastating")]))
# end categorization
################################################################################

table(d$rat, d$Year)
d$rat1 <- 5 - as.numeric(as.factor(d$rat))   # convert rankings to 1-4 scale for plotting
table(d$rat, d$rat1)                         # check 
table(d$rat1, d$Year)

# condense events into major red tide periods
#
d$Year1 <- as.numeric(as.character(d$Year))
table(d$Year1)
# major events are 2017-2018, 2013-2015, 2004-2005 (consecutive years with > 1 mention)

# categorize into the above periods
d$event <- NA
d$event[which(d$Year1 < 2004)] <- "prior to 2003"
d$event[which(d$Year1 == 2005 | d$Year1 == 2004)] <- "2004-2005"
d$event[which(d$Year1 >=2013 & d$Year1 <= 2015)] <- "2013-2015"
d$event[which(d$Year1 >=2017)] <- "2017-2018"
table(d$event, d$Year)             # check results

# severity over time
pdf(file="all_events.pdf", width=8, height=5)

plot(d$Year1, d$rat1, col="#FF000030", pch=as.numeric(d$County)+1, cex=2, xlab="year", ylab="event severity rating", axes=F)
axis(1); axis(2, at=4:1, lab=names(table(d$rat))); box()
legend("bottomleft", names(table(d$County))[1:5], pt.cex=2, col="#FF000030", pch=2:6) 
#abline(v=c(2003.5, 2005.5, 2013.5, 2014.5, 2017.5, 2019), lty=2, col=8)

dev.off()


# longevity of event
d$tim <- as.numeric(as.character(d$Temporal.Extent))

pdf(file="temp_extent.pdf", width=8, height=5)

plot(d$Year1, d$tim, col="#FF000030", pch=as.numeric(d$County)+1, cex=2, xlab="year", ylab="temporal extent of event (months)", axes=F)
axis(1); axis(2, las=2); box()
legend("topleft", names(table(d$County)), pt.cex=2, col="#FF000030", pch=2:6) 

dev.off()


# recovery after event
d$recov <- as.numeric(as.character(d$Recovery.Time))
d$Recovery.Time[grep("recover", d$Recovery.Time)]
d$recov[grep("recover", d$Recovery.Time)] <- 70
data.frame(d$Recovery.Time, d$recov)

pdf(file="recovery.pdf", width=8, height=5)

par(mar=c(5,6,1,1))
plot(d$Year1, d$recov, col="#FF000030", pch=as.numeric(d$County)+1, cex=2, xlab="year", ylab="recovery time (years)", axes=F)
axis(1, at=seq(1940, 2020,10)); axis(2, las=2, at=seq(0, 60, 12), lab=0:5)
axis(2, at=70, lab="still \nrecovering", las=2)
legend(1950, 60, names(table(d$County)), pt.cex=2, col="#FF000030", pch=2:6) 

dev.off()


# by event
tab <- table(d$event, d$rat); tab
tab <- tab[c(4,1:3),]       ; tab
tab1 <- tab / rowSums(tab)
tab
tab1

cols=c("#FF000005", "#FF000020", "#FF000050", "#FF000099")[4:1]

pdf(file="by_event.pdf", width=6, height=5)

barplot(t(tab1), beside=F, col=cols, ylim=c(0,1.2), axes=F,  
args.legend=list(x = "top", horiz=T), legend.text=colnames(tab1), 
ylab="proportion of ratings", xlab="red tide event")
axis(2, at=seq(0,1, 0.2), lab=seq(0,1, 0.2), las=2)
abline(h=0)

dev.off()


# by area 

tab <- table(d$County, d$rat)
tab1 <- tab / rowSums(tab)
tab
tab1

chisq.test(tab)
chisq.test(t(tab))
chisq.test(tab1)
chisq.test(t(tab1))

pdf(file="by_area.pdf", width=6, height=5)

barplot(t(tab1), beside=F, col=cols, ylim=c(0,1.2), axes=F,  
args.legend=list(x = "top", horiz=T), legend.text=colnames(tab1),
ylab="proportion of ratings", xlab="home county of interviewee")
axis(2, at=seq(0,1, 0.2), lab=seq(0,1, 0.2), las=2)
abline(h=0)
dev.off()


# by zone 
d$zone <- d$Offshore.or.Inshore.
d$zone[which(d$zone =="none" | d$zone=="neither" | d$zone =="")] <- NA
d$Offshore.or.Inshore.[which(is.na(d$zone))]
table(d$Offshore.or.Inshore., d$zone)          # check reclassification

tab <- table(droplevels(d$zone), d$rat)
#tab <- tab[c(3,4,2,5),]
tab1 <- tab / rowSums(tab)
tab
tab1

pdf(file="by_zone.pdf", width=6, height=5)

barplot(t(tab1), beside=F, col=cols, ylim=c(0,1.2), axes=F,  
args.legend=list(x = "top", horiz=T), legend.text=colnames(tab1),
ylab="proportion of ratings", xlab="zone of fishing")
axis(2, at=seq(0,1, 0.2), lab=seq(0,1, 0.2), las=2)
abline(h=0)
dev.off()


# number of interviewees  
pdf(file="num_interviewees.pdf", width=6, height=4)

tab <- table(d$event, d$County)
tab <- t(tab[c(4,1:3),])
tab
barplot(tab, beside=T, col=2:6, args.legend=list(x=12, y=12, bty="n"), legend.text=rownames(tab), axes=F,
ylab="number of interviewees", xlab="red tide event")
axis(2, las=2)
abline(h=0)
dev.off()


# species affected
d2 <- d[as.numeric(d$Species.Affected)!=1,]
d2$grouper <- 0
d2$grouper[grep("grouper", d2$Species.Affected)] <- 1

tab <- table(d2$event, d2$grouper)
tab <- tab[c(4, 1:3),2:1]
tab1 <- tab/rowSums(tab)
tab
tab1


pdf(file="spp_killed.pdf", width=6, height=6)

b <- barplot(t(tab1), beside=F, col=c(3,4), ylim=c(0,1.3), axes=F,  
args.legend=list(x = "top", horiz=T), legend.text=c("grouper species", "fish species other than grouper"), bty="n", 
ylab="proportion of species-specific fish kill mentions            ", xlab="red tide event")
axis(2, at=seq(0,1, 0.2), lab=seq(0,1, 0.2), las=2)
abline(h=0)
text(b, 1.05, paste("n =", rowSums(tab)), col=)

dev.off()









