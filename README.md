# Keras for R Workshop

All of the models we're building will work on a laptop so if you want to follow along on your own machine then please follow the steps below:

* Install R from https://cran.r-project.org/
* RStudio desktop from https://www.rstudio.com
* Install Anaconda from https://www.anaconda.com/download/

Install the following R packages from CRAN in the usual way: 

```r
install.packages(c("tidyverse", "rsample", "recipes", "keras"))
```

In an R session install the keras/tensorflow python libraries by running:

```r
library(keras)
install_keras()
```

This takes a while as it will install the various python packages that are required. For further instructions please see https://keras.rstudio.com/ and follow the instructions there.

If it worked you should get:

```r
library(keras)
is_keras_available()
[1] TRUE
```
