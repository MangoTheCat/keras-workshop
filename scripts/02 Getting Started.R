

# Chapter 2. Getting Started with Keras -----------------------------------


library(keras)

is_keras_available()

# if not you may need to run:
# install_keras()

# Train Test Split --------------------------------------------------------

library(rsample)
## Create training and test sets

set.seed(367)

data_split <- initial_split(iris, strata = "Species", prop = 0.8)

fullData <- list(train = analysis(data_split), 
                 test = assessment(data_split))

# Pre-processing ----------------------------------------------------------

library(recipes)
library(purrr)

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

# If you're lost just do

xIris <- readRDS("data/xIris.rds")
yIris <- readRDS("data/yIris.rds")

# Exercise 2-5 ---------------------------------------------------------

# 1.	Load the BreastCancer data
library(mlbench)
data("BreastCancer")

# 2.	Remove the Id column and convert all but the Class column to numeric
bc <- BreastCancer %>%
  select(-Id) %>%
  mutate_at(vars(-Class), as.numeric)

# 3.	Split the data so that 80% is used for training and 20% for testing
set.seed(82)
bcSplit <- initial_split(bc, strata = "Class", prop = 0.8)

bcFull <- list(train = analysis(bcSplit), 
               test = assessment(bcSplit))


# 4.	Create dummy variables for the class variable 
# 5.	Scale the numeric variables
# 6.	Replace all missing values with 0
# 7.	Convert the target and feature data frames to matrices

bc_recipe <- recipe(Class ~ ., data = bcFull$train) %>%
  step_dummy(Class, one_hot = TRUE, role = "outcome") %>%
  step_center(all_predictors()) %>%
  step_scale(all_predictors()) %>%
  step_meanimpute(all_predictors(), means = 0) %>%
  prep(bcFull$train)

bcX <- map(bcFull, ~ bake(object = bc_recipe, 
                          new_data = .x,
                          all_predictors(),
                          composition = "matrix"))

bcY <- map(bcFull, ~ bake(object = bc_recipe, 
                          new_data = .x,
                          all_outcomes(),
                          composition = "matrix"))




############# Building models -----------------

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

# Exercise page 2-11
# 1.	Load the pre-cleaned BreastCancer data
# 2.	Create a model with:
#   a.	A dense layer with 5 hidden units
# b.	A dense, output layer using the "sigmoid" activation function
# 3.	Compile the model using "binary_crossentropy" as the loss function
# 4.	Fit the model over 20 epochs
# Extension Questions
# 5.	Change the activation function in the first dense layer to "relu", what effect does this have?
#   6.	Increase the number of hidden units in the dense layer, does this have any impact?
#   7.	What effect does adding additional layers to your model have? 

# Exercise - Breast Cancer Model --------------

# reload cleaned data
bcX <- readRDS("data/bcX.rds")
bcY <- readRDS("data/bcY.rds")


bcModel <- keras_model_sequential()

bcModel %>%
  layer_dense(units = 5, input_shape = 9) %>%
  layer_dropout(rate = 0.3) %>%
  layer_dense(units = 2, activation = "sigmoid")

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

### Evaluate and predict model --------------

model %>% 
  evaluate(xIris$test, yIris$test)

model %>% 
  predict(xIris$test) %>%
  head()

model %>%
  predict_classes(xIris$test) 


# Exercise page 2-12 ----------
# 1.	Using the model that you built in the last exercise and the pre-cleaned test breast cancer data evaluate the performance of your model
# 2.	Predict the classes for the test data

bcModel %>% evaluate(bcX$test, bcY$test)

bcModel %>% predict_classes(bcX$test)


############# Controlling Layers --------------------

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


# Exercise page 2-16
# 1.	Using the pre-cleaned Boston House Price data, build a model from scratch to predict the house price deciding:
#   a.	An initial number of layers
# b.	The number of hidden units
# c.	The activation function(s) to use
# 2.	Add a dropout layer to your model, does this improve performance on the test data?
#   

