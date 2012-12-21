##############
# Create table for the list of countries and their financial supervisors for the paper "Who is Watching?"
# Author: Christopher Gandrud
# Updated: 21 July 2012
##############

# Load required packages
library(RCurl)
library(foreign)
library(reshape)
library(xtable)

# Load data
setwd("/Users/christophergandrud/Dropbox/Fin_trans/tables/")

URL <- "https://dl.dropbox.com/u/12581470/code/Replicability_code/Fin_Trans_Replication_Journal/Gandrud_Financial_Regulation_DV.csv"

URL <- getURL(URL)

FinData <- read.csv(textConnection(URL))

# Just keep the first year a country was observed/had a particular governance style
FinSub <- FinData[!duplicated(FinData[, c(1, 3)]), ]

# Add variable labels
FinSub <- rename(FinSub, c(country = "Country"))
FinSub <- rename(FinSub, c(year = "First Year Observed"))
FinSub <- rename(FinSub, c(reg_4state = "Supervisors"))
FinSub <- rename(FinSub, c(sec_reg_name = "Supervisors' Name Type"))

# Relable Single Specialised -> Unified Specialized
# Change to American spelling
FinSub$Supervisors <- as.character(FinSub$Supervisors)

FinSub$Supervisors <- gsub("Specialised", "Specialized", x = FinSub$Supervisors)
FinSub$Supervisors <- gsub("Single", "Unified", x = FinSub$Supervisors)


# Create table
print.xtable(xtable(FinSub, caption = "Country Sample and Supervisor Type (1987-2006)", label = "SampleTable", align = c("l", "l", "c", "r", "r")), caption.placement=getOption("xtable.caption.placement", "top"), size=getOption("xtable.size", "tiny"), include.rownames = FALSE, tabular.environment=getOption("xtable.tabular.environment", "longtable"), floating=getOption("xtable.floating", FALSE), file = "CountrySampleTable.tex")




