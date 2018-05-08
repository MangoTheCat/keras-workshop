library(keras)
library(rsample)
library(recipes)
library(tidyverse)

## Create training and test sets

set.seed(367)
data_split <- initial_split(iris, strata = "Species", prop = 0.8)

fullData <- list(train = analysis(data_split), 
                 test = assessment(data_split))

## Create dummy variables ** would require devel version of recipes for now **
dummy_recipes <- recipe(Species ~ ., data = fullData$train) %>%
  step_dummy(Species, one_hot = TRUE, role = "outcome") %>%
  step_scale(all_predictors()) %>%
  # (I would center too)
  # (optionally add steps for imputation (step_knnimpute, etc))
  # now estimate the scalings from the training set to be used to 
  # scale with the `bake` function
  prep(training = iris)

## Create x and y matrix
xIris <- list(
  train = bake(dummy_recipes, newdata = fullData$train, 
              all_predictors(), 
              composition = "matrix"),
  test = bake(dummy_recipes, newdata = fullData$test, 
               all_predictors(), 
               composition = "matrix")
)
yIris <- list(
  train = bake(dummy_recipes, newdata = fullData$train, 
               all_outcomes(),
               composition = "matrix"),
  test = bake(dummy_recipes, newdata = fullData$test, 
               all_outcomes(),
               composition = "matrix")
  )


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

history <- model %>% fit(xIris$train, 
                     yIris$train, 
                     epochs = 100, 
                     validation_data = list(xIris$test, yIris$test))

summary(model)

plot(history)


### Evaluate and predict model

model %>% 
  evaluate(xIris$test, yIris$test)

model %>% 
  predict(xIris$test) %>%
  head()

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
