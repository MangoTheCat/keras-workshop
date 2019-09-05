# Keras for R Workshop

## Environment

You can either use the RStudio Cloud project or use your laptop. It can be a mixed experience configuring everything so the cloud is a safe fallback.

### RStudio Cloud

An environment with this repo checked out is available at: https://rstudio.cloud/project/489173

You will need to setup and account on RStudio Cloud. Afterwards you should be able to deploy the project (this can take a minute or two). Then create a copy in your own space:

![save permanent copy](docs/save-perm.png)

Test it's working with:

```r
library(keras)
is_keras_available()
[1] TRUE
```

This takes a minute the first time and will be quick from then on.

### Local (laptop)

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
