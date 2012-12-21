#################
# Create supervisory reform heatmap
# Author --
# Updated 7 February 2012
#################


library(foreign)
library(msm)
library(ggplot2)
library(gridExtra)

### Load Data ###
## Note the data is taken directly from "http://dl.dropbox.com/u/12581470/code/Replicability_code/Financial_Supervision_Governance_Replication/public_fin_trans_data.dta". 
## It was converted into a smaller .csv file for simplicity.

fin.total <- read.csv("http://dl.dropbox.com/u/12581470/code/Replicability_code/Financial_Supervision_Governance_Replication/public.fin.msm.model.csv")

### Change FSA and  number code in the data
x <- 5

fin.total$reg_4state[fin.total$reg_4state == 3] <- x

### Include only years after 1987
  fin <- subset(fin.total, fin.total$year > 1987)

### Create Transition Matrix ###
table <- statetable.msm(reg_4state, idn, data = fin)

### Remove 'to' and 'from'
table <- unname(table)

### Change row and column names/ change to data frame
  rownames(table) <- c("CB/MoF", "Multi. SR", "SEC", "FSA")
  colnames(table) <- c("CB/MoF", "Multi. SR", "SEC", "FSA")
  
  table.df <- data.frame(table)

### Subset just reforms
  table.reforms <- subset(table.df, Var1 != Var2)

### Create heatmap
  fin.heatmap <- ggplot(table.reforms, aes(Var2, Var1)) +
                        geom_tile(aes(fill = Freq)) +
                        geom_text(aes(label = Freq)) +
                        scale_fill_gradient2(low = "white", high = "red", name = "") +
                        xlab("\nAfter Reform") + ylab("Before Reform\n") +
                        theme_bw()
  