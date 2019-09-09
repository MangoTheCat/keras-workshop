library(keras)
library(rsample)
library(recipes) ## ** requires devel version of recipes for now **
library(tidyverse)

## Create training and test sets

set.seed(367)

data_split <- initial_split(iris, strata = "Species", prop = 0.8)

fullData <- list(train = analysis(data_split), 
                 test = assessment(data_split))


# Recipes

empty_recipe <- recipe(Species ~ ., data = fullData$train)
empty_recipe

# One hot encode

dummy_recipe <- empty_recipe %>%
  step_dummy(Species, one_hot = TRUE, role = "outcome")

  
dummy_recipe %>%
  prep(fullData$train) %>%
  bake(fullData$train, all_outcomes()) %>%
  head()

# Center and scale  

scale_recipe <- empty_recipe %>%
  step_center(all_predictors()) %>%
  step_scale(all_predictors()) 

scale_recipe %>%
  prep(fullData$train) %>%
  bake(fullData$train,
       all_predictors()) %>%
  head()


# Put it all together and prep

iris_recipe <- recipe(Species ~ ., data = fullData$train) %>%
  step_dummy(Species, one_hot = TRUE, role = "outcome") %>%
  step_center(all_predictors()) %>%
  step_scale(all_predictors()) %>%
  prep(training = fullData$train)

tidy(iris_recipe)

## Create x and y matrix

xIris <- map(fullData, ~ bake(object = iris_recipe,
                              new_data = .x,
                              all_predictors(),
                              composition = "matrix"))

yIris <- map(fullData, ~ bake(object = iris_recipe,
                              new_data = .x,
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
