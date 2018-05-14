
library(tidyverse)
library(keras)

walking <- readRDS("USB/Data/walking.rds")
names(walking)

dim(walking$x)

walking$labels

# Split train and test. Exercise 1

set.seed(20)
m <- nrow(walking$x)
# generate random indicies
indices <- sample(1:m, m)
indTrain <- indices[1:floor(m*0.8)]
indTest <- indices[ceiling(m*0.8):m]

xWalk <- list(train = walking$x[indTrain, ,],
              test = walking$x[indTest, ,])

yWalk <- list(train = walking$y[indTrain, ],
              test = walking$y[indTest, ])

# Make a new model

model <- keras_model_sequential()

# Conv layer
model %>%
  layer_conv_1d(filters = 40, kernel_size = 40, strides = 2,
                activation = "relu", input_shape = c(260, 3))
model

# Max pool
model %>%
  layer_max_pooling_1d(pool_size = 2)
model

# Flatten
model %>%
  layer_flatten()
model

# Finish
model %>%
  layer_dense(units = 100, activation = "sigmoid") %>%
  layer_dense(units = 15, activation = "softmax")
model


model %>% compile(loss = "categorical_crossentropy", optimizer = "adam", metrics = c("accuracy"))
history <- model %>% fit(xWalk$train, yWalk$train,
                         epochs = 15, 
                         batch_size = 128, 
                         validation_split = 0.3,
                         verbose = 1)
