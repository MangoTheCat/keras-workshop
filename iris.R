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
  step_center(all_predictors()) %>%
  step_scale(all_predictors()) %>%
  # (optionally add steps for imputation (step_knnimpute, etc))
  # now estimate the scalings from the training set to be used to 
  # scale with the `bake` function
  prep(training = fullData$train)

## Create x and y matrix

xIris <- map(fullData, ~ bake(object = dummy_recipes,
                              newdata = .x,
                              all_predictors(),
                              composition = "matrix"))

yIris <- map(fullData, ~ bake(object = dummy_recipes,
                              newdata = .x,
                              all_outcomes(),
                              composition = "matrix"))


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
