library(keras)
library(rsample)
library(recipes)
library(tidyverse)
library(mlbench)

###########################

data("BreastCancer")

###########################
# Data Prep

set.seed(19)

bc_data <- BreastCancer %>%
  select(-Id) %>%
  mutate_at(vars(-Class), as.numeric)

## Split into train and test
bc_split <- initial_split(bc_data, prop = 0.8, strata = Class)

bc_train <- training(bc_split)
bc_test <- testing(bc_split)

# Preprocess

bc_recipe <- recipe(Class ~ ., data = bc_train) %>%
  step_center(all_predictors()) %>%
  step_scale(all_predictors()) %>%
  step_meanimpute(all_predictors()) %>%
  step_dummy(Class, role = "outcome") %>%
  prep(bc_train)

bc <- list(train = bc_train, test = bc_test)

bcX <- map(bc, ~ bake(bc_recipe, .x, all_predictors(), composition = "matrix"))
bcY <- map(bc, ~ bake(bc_recipe, .x, all_outcomes(), composition = "matrix"))

# write_rds(xData, "./Training/Material/Workshops/Workshop_DeepLearning/Data/BreastCancerCleanFeatures.rds")
# write_rds(yData, "./Training/Material/Workshops/Workshop_DeepLearning/Data/BreastCancerCleanTarget.rds")


###################

# Build keras model

bcModel <- keras_model_sequential()

bcModel %>%
  layer_dense(units = 5, input_shape = 9) %>%
  layer_dropout(rate = 0.3) %>%
  layer_dense(units = 1, activation = "sigmoid")

bcModel %>%
  compile(
    optimizer = "rmsprop",
    loss = "binary_crossentropy",
    metrics = "accuracy"
  )

hist <- bcModel %>%
  fit(bcX$train, bcY$train, 
      epochs = 30, 
      validation_split = 0.2)


bcModel %>% evaluate(bcX$test, bcY$test)

bcModel %>% predict_classes(bcX$test)




