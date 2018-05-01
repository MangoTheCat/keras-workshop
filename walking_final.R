library(keras)
# Use this to limit cpu
use_session_with_seed(1234)


# Load the test data
xWalk <- readRDS("/data/xWalk.rds")
yWalk <- readRDS("/data/yWalk.rds")

# Make an empty model
model <- keras_model_sequential()

# Build our CNN
model %>%
	  layer_conv_1d(filters = 40, kernel_size = 30, strides = 2,
			                activation = "relu", input_shape = c(260, 3)) %>%
  layer_max_pooling_1d(pool_size = 2) %>%
    layer_conv_1d(filters = 40, kernel_size = 10, activation = "relu") %>%
      layer_max_pooling_1d(pool_size = 2) %>%
        layer_flatten() %>%
	  layer_dense(units = 100, activation = "sigmoid") %>%
	    layer_dense(units = 15, activation = "softmax")

    model



    # Compile
    model %>%
	      compile(loss = "categorical_crossentropy",
		                optimizer = "adam",
				          metrics = c("accuracy"))

    # Run
    history <- model %>% fit(xWalk$train, yWalk$train,
			                              epochs = 15, 
						                               batch_size = 128, 
						                               validation_split = 0.3,
									                                verbose = 1)

    # Evaluate
    model %>% 
	      evaluate(xWalk$test, yWalk$test, verbose = 0)

