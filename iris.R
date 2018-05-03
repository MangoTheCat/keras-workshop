library(keras)
library(caret)
library(tidyverse)

## Sample IDs for training set
trainID <- createDataPartition(iris$Species, p = 0.8) 

trainingData <- iris %>%
  slice(trainID$Resample1)

testData <- iris %>%
  slice(-trainID$Resample1)

fullData <- list(train = trainingData, 
                 test = testData)

## Create dummy variables
dummy <- dummyVars(~ Species, data = iris)

irisDummy <- map(fullData, predict, object = dummy)

head(irisDummy$train)

## Scale the data (split training and test)
numericIris <- map(fullData, select_if, is.numeric)

scaledIris <- map(numericIris, scale)

head(scaledIris$train)

map(scaledIris, replace_na, replace = 0)

## Create x and y matrix
xMatrix <- map(scaledIris, as.matrix)
yMatrix <- map(irisDummy, as.matrix)


# If you're lost just do

xMatrix <- readRDS("/data/xIris.rds")
yMatrix <- readRDS("/data/yIris.rds")

############# Building models

model <- keras_model_sequential()

## Add layers

model %>%
  layer_dense(units = 10, input_shape = 4) %>%
  layer_dense(units = 3, activation = 'softmax')


## Define compilation

model %>% compile(
  optimizer = 'rmsprop',
  loss = 'categorical_crossentropy',
  metrics = 'accuracy'
)

## Train the model

history <- model %>% fit(xMatrix$train, 
                     yIris$train, 
                     epochs = 100, 
                     validation_data = list(xIris$test, yIris$test))

summary(model)

plot(history)


### Evaluate and predict model

model %>% 
  evaluate(xIris$test, yIris$test)


model %>% 
  predict(xIris$test)

model %>%
  predict_classes(xIris$test) 



############# Controlling Layers

model <- keras_model_sequential()

model %>%
  layer_dense(units = 10, input_shape = 4) %>%
  layer_dropout(rate = 0.3) %>%
  layer_dense(units = 3, activation = 'softmax')

model %>% compile(
  optimizer = 'rmsprop',
  loss = 'categorical_crossentropy',
  metrics = 'accuracy'
)

model %>% fit(xIris$train, 
              yIris$train, 
              epochs = 100, 
              validation_data = list(xIris$test, yIris$test))
