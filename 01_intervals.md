# Week 1: Intervals

1. [Motivation](#motivation)
2. [Confidence intervals](#ci)
    1. [For mean](#cimean)
    2. [For standard deviation](#cistd)
    3. [For proportions](#ciprop)
    4. [For percentiles](#cipercent)
3. [Prediction intervals](#pi)
    1. [For one observation](#pione)
    2. [For variance](#pivar)


## Motivation <a name="motivation"></a>

We want to be able to make some "big statements" about our populations. For instance, suppose we are measuring the quality of our product (any measurement you can imagine to measure quality) and we may want to know what the "average" quality of our product will be. With a confidence interval we can say that with "high probability" (usually 95%) our measurement will be in that range. 

**GENERAL NOTE**: For the codes below, when asked about 1-sided, just replace `ALPHA/2 ` with `ALPHA`.

## Confidence intervals <a name="ci"></a>

It tells you that a given variable will lie in an interval [a, b] with a condifence level "alpha". 

Example: 

If my variable is `mean`, `alpha = 0.05` (5%) and the interval is `[20, 30]` then it means that the `mean` of the population will lie `95%` of the times between `20` and `30`.

### For mean <a name="cimean"></a>

#### Assumptions
- Population is infinite
- Data is normally distributed `N(mu, sigma^2)`. 
- However if `n` is big, by the Central Limit theorem normality can be _apriori_ assumed.

#### Code

##### Exact
```
/* Variables to change: 
    - my_dataset: the dataset
    - var_of_interest: variable to work with
*/

/* 1. Compute the mean, std and N of the dataset */
/* CHANGE VALUES HERE */
PROC MEANS DATA = my_dataset; /* CHANGE my_dataset */
    VAR var_of_interest; /* CHANGE var_of_interest */
    /* my_mean */ 
    OUTPUT OUT = my_summary MEAN = my_mean STD = my_std N = my_n;
RUN;

/* 2. Run this to compute the values */
/* NOTHING TO CHANGE HERE */
DATA CI_MEAN;
    SET my_summary;
    ALPHA = 0.05;
    T_VALUE = QUANTILE('T', 1 - ALPHA/2, my_n - 1);
    LCL = my_mean - my_std*T_VALUE/SQRT(my_n);
    UCL = my_mean + my_std*T_VALUE/SQRT(my_n);
RUN;

/* Columns LCL and UCL have the solution */ 
/* NOTHING TO CHANGE HERE */
PROC PRINT DATA = CI_MEAN;
RUN;
```

#### Special case: Exponentially distributed data

```
/* Variables to change: 
    - my_dataset: the dataset
    - var_of_interest: variable to work with
*/

/* 1. Compute the mean, std and N of the dataset */
/* CHANGE my_dataset AND var_of_interest HERE */
PROC MEANS DATA = my_dataset; 
    VAR var_of_interest;
    OUTPUT OUT = my_summary MEAN = my_mean STD = my_std N = my_n;
RUN;

/* NOTHING TO CHANGE HERE */
DATA CI_MEAN_EXP;
    SET my_summary;
    SUM = my_mean * my_n;
    Q_LOWER = QUANTILE('GAMMA', 0.975, my_n, 1);
    Q_UPPER = QUANTILE('GAMMA', 0.025, my_n, 1);
    LCL = SUM / Q_LOWER ;
    UCL = SUM / Q_UPPER ;
RUN;

/* LOOK AT LCL (LOWER CONFIDENCE LIMIT) AND UCL (UPPER CONFIDENCE LIMIT) */
PROC PRINT DATA = CI_MEAN_EXP;
RUN;
```

### For standard deviation <a name="cistd"></a>

#### Assumptions
- Population is infinite
- Data is normally distributed `N(mu, sigma^2)`. 

TODO: Check what if not normally distributed... I couldn't find the answer in the slides...

#### Code

```
/* Variables to change: 
    - my_dataset: the dataset
    - var_of_interest: variable to work with
*/

/* 1. Compute the mean, std and N of the dataset */
/* CHANGE VALUES HERE */
PROC MEANS DATA = my_dataset; /* CHANGE my_dataset */
    VAR var_of_interest; /* CHANGE var_of_interest */
    /* my_mean */ 
    OUTPUT OUT = my_summary MEAN = my_mean STD = my_std N = my_n;
RUN;

/* 2. Run this to compute the values */
/* NOTHING TO CHANGE HERE */
DATA CI_STD;
    SET my_summary;
    ALPHA = 0.05;
    CHI_SQUARE_L = QUANTILE('CHISQUARE', 1 - ALPHA/2, my_n - 1);
    CHI_SQUARE_U = QUANTILE('CHISQUARE',   ALPHA/2, my_n - 1);
    LCL = SQRT((my_n-1) * my_std**2 / CHI_SQUARE_L);
    UCL = SQRT((my_n-1) * my_std**2 / CHI_SQUARE_U);
    DROP _TYPE_ _FREQ_;
RUN;

/* Columns LCL and UCL have the solution */ 
/* NOTHING TO CHANGE HERE */
PROC PRINT DATA = CI_STD;
RUN;
```

### For proportions <a name="ciprop"></a>

#### Assumptions
- Data is bernoulli distributed with parameter `B(p)`

#### Code

##### Approximate
```
/* Variables to change: 
    - my_dataset: the dataset
    - var_of_interest: variable to work with
*/

/* CHANGE VALUES HERE */
PROC MEANS DATA = my_dataset;
    VAR var_of_interest;
    OUTPUT OUT = my_summary MEAN = my_mean N = my_n; 
RUN;

/* NOTHING TO CHANGE HERE */
DATA CI_PROP;
    SET my_summary;
    ALPHA = 0.05;
    Z_VALUE = QUANTILE('NORMAL', 1 - ALPHA/2); 
    VAR  = my_mean*(1 - my_mean); 
    LCL = my_mean - Z_VALUE * SQRT(VAR/my_n); 
    UCL = my_mean + Z_VALUE * SQRT(VAR/my_n); 
RUN;

/* NOTHING TO CHANGE HERE */
/* Values to look at LCL, UCL */
PROC PRINT DATA=CI_PROP;
RUN;
```

##### Exact
```
/* Variables to change: 
    - my_dataset: the dataset
    - var_of_interest: variable to work with
*/

/* CHANGE VALUES HERE */
PROC MEANS DATA = my_dataset;
    VAR var_of_interest;
    OUTPUT OUT = my_summary MEAN = Y N = N; 
RUN;

/* NOTHING TO CHANGE HERE */
DATA CI_PROP;
    SET my_summary;
    ALPHA = 0.05;

    /* Exact value (two-sided) */
    F_VALUE_L = QUANTILE('F', 1 - ALPHA/2, 2*(1 + N*(1 - Y)), 2*N*Y);
    F_VALUE_U = QUANTILE('F', ALPHA/2, 2*N*(1 - Y), 2*(N*Y + 1 ));
    LCL_TWO_SIDED = (N*Y) / (N*Y + (1 + N*(1 - Y))*F_VALUE_L );
    UCL_TWO_SIDED = (N*Y + 1) / (N*Y + 1 + N*(1 - Y)*F_VALUE_U );
    
    /* One sided */
    F_VALUE_L_O = QUANTILE('F', 1 - ALPHA, 2*(1 + N*(1 - Y)), 2*N*Y);
    F_VALUE_U_O = QUANTILE('F', ALPHA, 2*N*(1 - Y), 2*(N*Y + 1 ));
    LCL_ONE_SIDED = (N*Y) / (N*Y + (1 + N*(1 - Y))*F_VALUE_L_O );
    UCL_ONE_SIDED = (N*Y + 1) / (N*Y + 1 + N*(1 - Y)*F_VALUE_U_O );
    DROP _TYPE_ _FREQ_;
RUN;

/* NOTHING TO CHANGE HERE */
/* Variables to look at: LCL_TWO_SIDED, UCL_TWO_SIDED or LCL_ONE_SIDED, UCL_ONE_SIDED*/
PROC PRINT DATA=CI_PROP;
RUN;
```

### For percentiles <a name="cipercent"></a>

#### Assumptions
- Population is infinite

#### Code

##### Approximate
```
/* Variables to change:
    - P: the percentile (ex: 25 is first quartile, etc...)
    - my_dataset: the dataset
    - var_of_interest: variable to work with
*/

/* CHANGE my_dataset AND var_of_interest HERE*/
PROC MEANS DATA = my_dataset;
    VAR var_of_interest;
    OUTPUT OUT = my_summary N = N; 
RUN;

/* CHANGE P HERE */
DATA CI_PERCENTILE;
    SET my_summary;

    P = 25/100; 
    ALPHA = 0.05;
    Z_VALUE = QUANTILE('NORMAL', 1 - ALPHA/2);
    P_L = P - Z_VALUE * SQRT(P*(1 - P)/N);
    P_U = P + Z_VALUE * SQRT(P*(1 - P)/N);
    N_L = FLOOR(N*P_L);
    N_U = FLOOR(N*P_U) + 1;
RUN;

/* NOTHING TO CHANGE HERE */
PROC PRINT DATA = CI_PERCENTILE;
RUN;

/* CHANGE my_dataset AND var_of_interest HERE */
PROC RANK DATA = my_dataset OUT = ranked_values; 
    var var_of_interest;
    RANKS my_ranks;
RUN;

/* LOOK AT THE N_L AND N_U OUTPUTS, THEN SEARCH FOR THOSE INDEXES IN ranked_values */
```

##### Exact
```
/* Variables to change:
    - P: the percentile (ex: 25 is first quartile, etc...)
    - my_dataset: the dataset
    - var_of_interest: variable to work with
*/

/* CHANGE my_dataset AND var_of_interest HERE*/
PROC MEANS DATA = my_dataset;
    VAR var_of_interest;
    OUTPUT OUT = my_summary N = N; 
RUN;

/* CHANGE P HERE */
DATA CI_PERCENTILE;
    SET my_summary;
    ALPHA = 0.05;
    Y = 25/100; * Y INDEED IS P, BUT TO AVOID TYPOS, WE USE Y;

    /* Exact value (two-sided) */
    P_L_TS = QUANTILE('F', 1 - ALPHA/2, 2*(1 + N*(1 - Y)), 2*N*Y);
    P_U_TS = QUANTILE('F', ALPHA/2, 2*N*(1 - Y), 2*(N*Y + 1 ));
    N_L_TWO_SIDED = FLOOR(N*P_L_TS);
    N_U_TWO_SIDED = FLOOR(N*P_U_TS) + 1;
    
    /* One sided */
    P_L_OS = QUANTILE('F', 1 - ALPHA, 2*(1 + N*(1 - Y)), 2*N*Y);
    P_U_OS = QUANTILE('F', ALPHA, 2*N*(1 - Y), 2*(N*Y + 1 ));
    N_L_ONE_SIDED = FLOOR(N*P_L_OS);
    N_U_ONE_SIDED = FLOOR(N*P_U_OS) + 1;
    DROP _TYPE_ _FREQ_;
RUN;

/* NOTHING TO CHANGE HERE */
PROC PRINT DATA = CI_PERCENTILE;
RUN;

/* CHANGE my_dataset AND var_of_interest HERE */
PROC RANK DATA = my_dataset OUT = ranked_values; 
    var var_of_interest;
    RANKS my_ranks;
RUN;

```


## Prediction Intervals <a name="pi"></a>

Prediction intervals tell us that when seeing a new (unseen) observation, its measurement will lie with high probability in a reange `[LCL, UCL]`.

### For one observation <a name="pione"></a>

#### Assumptions
- Population is infinite
- Data is normally distributed `N(mu, sigma^2)`
- `y0 - y_sample_average` is normally distributed (consequence) `N(0, (n+1)sigma^2 / n)`


#### Code
```
/* Variables to change:
    - my_dataset: the dataset
    - var_of_interest: variable to work with
*/

/* CHANGE my_dataset AND var_of_interest HERE */
PROC MEANS DATA = my_dataset NOPRINT;
    VAR var_of_interest;
    OUTPUT OUT = my_summary MEAN = my_mean STD = my_std N = my_n; 
RUN;

/* NOTHING TO CHANGE HERE */
DATA PI_ONE_MEAN_BASED;
    SET my_summary;

    ALPHA = 0.05;
    T_VALUE = QUANTILE('T', 1 - ALPHA/2, my_n - 1);

    LPL = my_mean - my_std*T_VALUE*SQRT((my_n+1)/my_n);
    UPL = my_mean + my_std*T_VALUE*SQRT((my_n+1)/my_n);
    DROP _TYPE_ _FREQ_;
RUN;

/* NOTHING TO CHANGE HERE */
/* Variables to look at: LPL and UPL */
PROC PRINT DATA = PI_ONE_MEAN_BASED;
RUN;
```

#### What to do for non-normal data?

We have the next alternatives

- Use a statistic with a parameter free distribution and use this distribution for prediction
- Use distribution free or non-parametric methods
    - F distribution
- Transform the data such that it is almost normal and then apply the procedures suitable for normality distributed data
    - For continuous variables: Box-Cox transformation
    - For counts: square root, anscombe, freeman-tukey, **logarithmic**, arcsine

##### Example Code for a transformation

If one decides to transform its data, then a similar procedure as the one described next should be used

```
/* Example for Prediction Interval with logarithmic transformation */
/* Variables to change:
    - my_dataset: the dataset
    - var_of_interest: variable to work with
    - M: number of new observations
*/

/* CHANGE my_dataset AND var_of_interest HERE */
DATA my_log_dataset;
    SET my_dataset;
    /* Make transformation*/
    LOG_VAR = Log(var_of_interest);
    /* Other transformations: */
    *SR_VAR = sqrt(var_of_interest);
    *ANSCOMBE_VAR = 2*sqrt(var_of_interest + 3/8);
    *F_T_VAR = sqrt(var_of_interest ) + sqrt(var_of_interest + 1);
    *ANSCOMBE_VAR = 2*arcsin(sqrt(var_of_interest));
run;

/* NOTHING TO CHANGE HERE */
PROC MEANS DATA = my_log_dataset NOPRINT;
    VAR LOG_VAR;
    OUTPUT OUT = my_summary MEAN = my_mean STD = my_std N = my_n; 
RUN;

/* NOTHING TO CHANGE HERE */
DATA PI_MEAN_LOG;
    SET my_summary;
    ALPHA = 0.05;
    T_VALUE = QUANTILE('T', 1 - ALPHA/2, my_n - 1);
    /* Transform back */
    LPL = EXP(my_mean - my_std*T_VALUE*SQRT((my_n + 1)/my_n));
    UPL = EXP(my_mean + my_std*T_VALUE*SQRT((my_n + 1)/my_n));
    DROP _TYPE_ _FREQ_;
RUN;

/* NOTHING TO CHANGE HERE */
PROC PRINT DATA = PI_MEAN_LOG;
RUN;
```

### For variance <a name="pivar"></a>

#### Assumptions
- Population is infinite
- Original data (size `N`) is normally distributed `N(mu, sigma^2)`
- New sample (size `M`) is also normally distributed `N(mu, sigma^2)`

### Code
```
/* Variables to change:
    - my_dataset: the dataset
    - var_of_interest: variable to work with
    - M: number of new observations
*/

/* CHANGE my_dataset AND var_of_interest HERE */
PROC MEANS DATA = my_dataset;
    VAR var_of_interest;
    OUTPUT OUT = my_summary VAR = my_var N = my_n; 
RUN;

/* CHANGE M HERE */
DATA my_summary;
    SET my_summary;
    M = 8; /* Number of new observations */
run;

/* NOTHING TO CHANGE HERE */
DATA PI_SVAR;
    SET my_summary;
    ALPHA = 0.05;
    F_U = QUANTILE('F', 1 - ALPHA/2, M - 1, my_n - 1);
    F_L = QUANTILE('F',   ALPHA/2, M - 1, my_n - 1);
    LCL = my_var*F_L;
    UCL = my_var*F_U;
    DROP _TYPE_ _FREQ_;
RUN;

PROC PRINT DATA = PI_SVAR;
RUN;
```