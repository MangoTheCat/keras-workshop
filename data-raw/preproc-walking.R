# This is the pre-processing we did to build the walking data file.
# Download the raw data from:
# https://archive.ics.uci.edu/ml/datasets/Dataset+for+ADL+Recognition+with+Wrist-worn+Accelerometer
# Or direct from:
# https://archive.ics.uci.edu/ml/machine-learning-databases/00283/ADL_Dataset.zip
#
# Extract to a data-raw directory.
#

# script to preprocess the accelerometer data

library(tidyverse)

# Initialise array for data:
#   Rows will be observations
#   Columns will be:
#   * Time point (sequential count integer)
#   * x-, y-, z-directional accelerometer data time series (integer)
#   * Activity label (1-7)
#   * Person label (0-14)

data_files <- list.files("data-raw", pattern = "*.csv", full.names = TRUE)

dataset <- data.frame()

# Add data from each file in turn
for (k in seq_along(data_files)) {
  
  #cat("Reading file", k, "/", length(data_files), "\n")
  
  d <- read_csv(data_files[k], col_names = c("obs", "acc_x", "acc_y", "acc_z", "activity"), col_types = "ddddd")
  
  # Add a column with a label representing the person
  d$person <- k
  
  dataset <- bind_rows(dataset, d)
}

head(dataset)

# Reshape data into 3 dimensions:
#   0-dimension ("rows") is observations (1926896 in total)
#   1-dimension ("columns") is time series values (260 = 5{seconds}*52{Hz} in total)
#   2-dimension ("leaves") are as follows (5 in total):
#     * 3 directions (x-, y-, z-acceleration)
#     * Activity type labels
#     * Person labels

# Chop the time series into 260-length (5 second) sections every 52 points (every 1 second)
m <- (nrow(dataset) - 208) %/% 52 
reshaped_data <- array(0, dim = c(m, 260, 5))

for (k in seq_len(m)) {
  
  start <- 52*(k-1) + 1
  stop <- start + 259
  
  # If the count column's value at "stop" is smaller than at "start", we've changed person because the     # counts start again from 1, so discard.
  # If the activity label column is not all the same, we have more than one activity in that section,      # so discard.
  
  if (dataset[stop, "obs"] < dataset[start, "obs"] ||
      !all(dataset[start:stop, "activity"] == dataset[start, "activity"])) {
    next
  }
  
  # Else copy all but count column to the new data block
  reshaped_data[k, , ] <- as.matrix(dataset[start:stop, -1])
}

# Remove the extra rows, which will have person label 0
reshaped_data <- reshaped_data[(reshaped_data[, 1, 5] != 0), , ]

# Select only observations that correspond to "walking", which is activity label 4.
walking <- reshaped_data[(reshaped_data[, 1, 4] == 4), , ]

walking_x <- walking[,,1:3] %>%
  apply(c(1, 3), scale) %>% # scaling within each series so no issue with train/test
  aperm(c(2,1,3))           # undo apply's ridiculous transpose

dimnames(walking_x) <- list(NULL, NULL, c("acc_x", "acc_y", "acc_z"))

walking_labels <- walking[,1,5] %>%
  as.integer()

walkingData <- list(x = walking_x, 
                    labels = walking_labels)

saveRDS(walkingData, "walking.rds")

# And for people that fall behind -----

set.seed(19)
m <- nrow(walking_x)

# generate random indicies
indices <- sample(1:m, m)

ind_train <- indices[1:floor(m*0.6)]
ind_val <- indices[ceiling(m*0.6):floor(m*0.8)]
ind_test <- indices[ceiling(m*0.8):m]

walkingData$y <- to_categorical(walkingData$labels - 1)

xWalk <- list(train = walkingData$x[indTrain, ,],
              val = walkingData$x[indVal, ,],
              test = walkingData$x[indTest, ,])

yWalk <- list(train = walkingData$y[indTrain, ],
              val = walkingData$y[indVal, ],
              test = walkingData$y[indTest, ])

saveRDS(xWalk, "xWalk.rds")
saveRDS(yWalk, "yWalk.rds")

