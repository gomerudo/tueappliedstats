# Week 2: Outliers test for one-sample data

1. [Motivation](#motivation)
2. [Hypothesis testing](#hyp)
3. [Doornbos test](#doorn)
4. [Grubbs test](#grubbs)
5. [Dixon test](#dixon)
6. [Hample's method](#hample)
7. [Tukey's method](#tukey)
8. [Homogeneity tests (outliers for sample variance)](#homo)
9. [Multiple outliers](#multiple)

## Motivation <a name="motivation"></a>

When dealing with sample data, there may be observations that are "strange" with respect to the population, these observations are called 'outliers'. When finding an outlier one would like to be able to "report" it and treat it accordingly (Note: in the lecture we did not cover how to deal with an outlier). The tests we use here "blame" one or more observations of being 'outliers'.

## Hypothesis testing for outliers <a name="hyp"></a>

### Types of hypothesis testing

1. Two-sided: `P( |Tn| > t )`
2. One-sided: `P( Tn < t )` or `P( Tn > t )`

We always reject when `p < alpha`. Otherwise, we DO NOT reject (different than accepting!)

### Types of errors

- Type 1: False positive (incorrectly rejecting null hypothesis)
- Type 2: False negative (incorrectly NOT rejecting null hypothesis)

### General assumption for outliers

- Data is normal

### General idea 

The idea is that we make assumptions of the distribution of the data (saying all the observations are part of that distribution). What we want to test is if there is/are observation(s) following a different distribution (contamination). 

- **Null hypothesis**: 
All observations `y_i` follow the same distribution `F` (our assumption is that `F` is Normal)
- **Alternative hypothesis**: 
The observation(s) `y_i` follow a mixed-distribution `H = (1 - a) F + a G`

where: 
 `G` contaminated distribution (or noise)

When testing for outliers, there are two things to deal with:

- **Masking effect**: A single outlier test may not detect outliers when multiple outliers are present.
- **Swamping effect**: A multiple outlier test becomes significant even if just a single outlier is present.
___

## Doornbos test (Single outlier) <a name="doorn"></a>

Doornbos performs the test for each of observation, based on the value `w_k` and a t-distribution criteria. We report ONLY ONE observation as outlier.

We define the next variables:

- `y_k`: The suspicious observation (outlier candidate)
- `y_bar = sum(y_i) / n`: the sample average
- `y_k_bar`: the sample average, excluding the observation `y_k` 
- `s^2 = sum(y_i - y_bar)^2 / n`: the sample variance
- `s_k^2`: the sample variance, excluding observation `y_k`
- `u_k = (y_k - y_bar)/s`: The standardized value for the observation `y_k` 
- `v_k = (y_k - y_bar)/( s*sqrt((n - 1)/n) )`: The internally studentized value for `y_k` (not t-distributed)
- `w_k = (y_k - y_bar)/( s_k*sqrt(n*(n - 1)/n) )`: The externally studentized value for `y_k` (t-distributed with `n - 2` d.o.f. )

The idea of defining the `s_k`, `u_k`, `v_k` and `w_k` values is to treat `y_k` as a new observation.


### Code

```
/* Values to change:
    - my_dataset
    - var_of interest
*/

/* 1. Run this first */
/* CHANGE my_dataset AND var_of_interest HERE */
PROC MEANS DATA = my_dataset;
    VAR var_of_interest;
    OUTPUT OUT = my_summary  MEAN = Y  STD = S  VAR = S2;
RUN;

/* 2. Write the values from (1) here */
/* CHANGE THESE!!!! */
%let Y = ;
%let S = ;
%let N = ;

%let ALPHA = 0.05;

/* 3. Execute test */
/* CHANGE var_of_interest HERE */
DATA DOORNBOS;
    SET my_dataset;

    U = (var_of_interest - &Y)/ &S;
    W = SQRT( (&N * (&N - 2) * U**2)/((&N - 1)**2 - &N * U**2) );
    DOORNBOS_STATISTICS = ABS(W);

    CRITERIA_TWO_SIDED = QUANTILE('T', 1 - &ALPHA/(2 * &N), &N - 2);
    CRITERIA_ONE_SIDED = QUANTILE('T', 1 - &ALPHA/(&N), &N - 2);

    CRITERIA_BONFERRONI = QUANTILE('T', 1 - (&ALPHA/2)/&N, &N - 2);
RUN;

/* 4. Sort data, the highest W is the test statistic */
PROC SORT DATA = DOORNBOS;
    BY DOORNBOS_STATISTICS;
RUN;

/* 5. Print data. */
PROC PRINT DATA = DOORNBOS;
RUN;
```

___

## Grubbs (Single outlier) <a name="grubbs"></a>

Perhaps the most studied technique for outliers detection.

Contrarely to Doontboos, Grubbs performs the test for each of observation, based on the value `u_k` and a t-distribution criteria. Again, we report ONLY ONE observation as outlier. 

For Grubbs, we need to check the exact test criterion in the slides (week 2, lecture 1) or compute an approximate criteria (if we choose this, we need to write/report that we are using an approximate criteria!!!)

We define the next variables:

- `y_k`: The suspicious observation (outlier candidate)
- `y_bar = sum(y_i) / n`: the sample average
- `y_k_bar`: the sample average, excluding the observation `y_k` 
- `s^2 = sum(y_i - y_bar)^2 / n`: the sample variance
- `s_k^2`: the sample variance, excluding observation `y_k`
- `u_k = (y_k - y_bar)/s`: The standardized value for the observation `y_k` 
- `v_k = (y_k - y_bar)/( s*sqrt((n - 1)/n) )`: The internally studentized value for `y_k` (not t-distributed)
- `w_k = (y_k - y_bar)/( s_k*sqrt(n*(n - 1)/n) )`: The externally studentized value for `y_k` (t-distributed with `n-2` d.o.f * )

The idea of defining the `s_k`, `u_k`, `v_k` and `w_k` values is to treat `y_k` as a new observation.

* Degrees of Freedom

### Code

```
/* Values to change:
    - my_dataset
    - var_of interest
    - exact_criteria: Exact criteria according to slides Week 2, Lecture 1, Slide 25/26
*/

/* 1. Run this first */
/* CHANGE my_dataset AND var_of_interest HERE */
PROC MEANS DATA = my_dataset;
    VAR var_of_interest;
    OUTPUT OUT = my_summary  MEAN = Y  STD = S  VAR = S2;
RUN;

/* 2. Write the values from (1) here */
/* CHANGE THESE!!!! */
%let Y = 3.4906590;
%let S = 2.3372008;
%let N = 252;

%let ALPHA = 0.05;

/* 3. Execute test */
/* CHANGE var_of_interest AND exact_criteria (if needed) HERE */
DATA Grubbs;
    SET my_dataset;

    U = (var_of_interest - &Y)/ &S;
    GRUBBS_STATISTICS = ABS(U);
    /* Two sided */
    T_QUANTILE_TS = QUANTILE('T', 1 - &ALPHA/(2 * &N), &N - 2);
    APPROXIMATE_CRITERIA_TWO_SIDED = sqrt(( (&N - 1)**2 * T_QUANTILE_TS**2 ) / ( &N * ((T_QUANTILE_TS**2) + (&N - 2)) ));
    
    /* One sided */
    T_QUANTILE_OS = QUANTILE('T', 1 - &ALPHA/(&N), &N - 2);
    APPROXIMATE_CRITERIA_ONE_SIDED = sqrt(( (&N - 1)**2 * T_QUANTILE_OS**2 ) / ( &N * ((T_QUANTILE_OS**2) + (&N - 2)) ));

    exact_criteria = 3.38; /* UPDATE WITH VALUE IN THE SLIDES */
RUN;

/* 4. Sort data, the highest W is the test statistic */
PROC SORT DATA = Grubbs;
    BY GRUBBS_STATISTICS;
RUN;

/* 5. Print data. */
PROC PRINT DATA = Grubbs;
RUN;
```
___

## Dixon (Single outlier) <a name="dixon"></a>

Dixon does not use the studentized values and instead, it is based on the ordered dataset. Depending on the size of the dataset, the Upper and Lower Tails are computed differently as next:

- `3 <= n <= 7`
- `8 <= n <= 10`
- `11 <= n <= 13`
- `n >= 14`

The criterias are in the slides (week 2, lecture 1, page 28)

### Code

```
/* Values to change:
    - my_dataset
    - var_of_interest
*/

/* CHANGE my_dataset and var_of_interest here */
PROC SORT DATA = my_dataset OUT = DIXON;
    BY var_of_interest;
RUN;

/* Print criteria */
DATA DIXON;
    SET DIXON;

    /* If N > 30, we need to compute the criteria our selves */
    /* Uncomment and update this with the sorted values in DIXON */
    Y_N = ;
    Y_N_1 = ;
    Y_N_2 = ;
    Y_3 = ;
    Y_2 = ;
    Y_1 = ;

    /* If 3 <= N <= 7 */
    *QU = (Y_N - Y_N_1) / (Y_N - Y_1);
    *QL = (Y_2 - Y_1) / (Y_N - Y_1);

    /* If 8 <= N <= 10 */
    *QU = (Y_N - Y_N_1) / (Y_N - Y_2);
    *QL = (Y_2 - Y_1) / (Y_N_1 - Y_1);    

    /* If 11 <= N <= 13 */
    *QU = (Y_N - Y_N_2) / (Y_N - Y_2);
    *QL = (Y_2 - Y_1) / (Y_N_2 - Y_1);

    /* If  N >= 14 */
    *QU = (Y_N - Y_N_2) / (Y_N - Y_3);
    *QL = (Y_3 - Y_1) / (Y_N_2 - Y_1);

    EXACT_CRITERIA = 0.710; /* Update values with the ones in Week 2, Lecture 1, Slides 28/29 */
RUN;

/* Print data */ 
PROC PRINT DATA = DIXON;
RUN;
```

___

## Hample's method (One or few outliers) <a name="hample"></a>

- It is considered distribution free, although the assumption still is normally distributed.
- Based on median absolute deviation. Roughly, we will find an outlier when it deviates too much from the median.
- The statistic is called "absolute normalized value" and it is considered an outlier if the value is larger than 3.5.

### Code

```
/* Values to change:
    - my_dataset
    - var_of_interest
    - m_y
    - m_d
*/

/* CHANGE var_of_interest AND my_dataset HERE */
PROC SORT DATA = my_dataset OUT = Hampel;
    BY var_of_interest;
RUN;

/* 1. Compute median of var_of_interest */
/* CHANGE var_of_interest HERE */
PROC UNIVARIATE DATA = Hampel normal;  
    VAR var_of_interest;
RUN;

/* 2. Update this with the median in the previous step */
%let m_y = ;

/* 3. Compute D (Absolute deviation) */
DATA Hampel;
    SET Hampel;
    D = ABS(var_of_interest - &m_y);
RUN;

/* 4. Compute median of D */
PROC UNIVARIATE DATA = Hampel;
    VAR D;
RUN;

/* 5. Update this with the median in the previous step */
%let m_d = ;

/* 6. Compute absolute normalized value */
DATA Hampel;
    SET Hampel;
    Z = ABS(var_of_interest - &m_y)/&m_d;
    IS_OUTLIER = Z > 3.5;
RUN;

/* 7. Report any observation where Z is greater than 3.5 */
PROC PRINT DATA = Hampel;
RUN;
```

___

## Tukey's method (One of few outliers) <a name="tukey"></a>

- It is the boxplot approach.
- Basically, it defines a range based on percentiles form which the observations within are considered fair and the observations out of range are considered outliers.
- We need to compute the first quartile (percentile = 25) and the third quartile (percentile = 75) and then follow the equations: `y_k < p_25(y) - 1.5 * IQR` and `y_k > p_25(y) + 1.5 * IQR`.


### Code

**Option 1: All information (only if statistics are requested)**
```
/* Variables to change:
    - my_dataset
    - var_of_interest
    - p_25: first quartile
    - p_75: third quartile
*/

/* 1. Compute percentiles of var_of_interest */
/* CHANGE var_of_interest AND my_dataset HERE */
PROC UNIVARIATE DATA = my_dataset;
    VAR var_of_interest;
RUN;

/* 2. Replace the percentiles here */
%let p_25 = ;
%let p_75 = ;

/* DO NOT CHANGE THIS */
%let IQR = &p_75 - &p_25;

/* 3. REPLACE my_dataset HERE */
DATA TUKEY;
    SET my_dataset;
    LOWER = &p_25 - 1.5 * &IQR;
    UPPER = &p_75 + 1.5 * &IQR;
RUN;

/* 4. SORT DATA */
PROC SORT DATA = TUKEY;
    BY var_of_interest;
RUN;

/* MAKE THE TEST. CHANGE var_of_interest HERE */
DATA TUKEY;
    SET TUKEY;
    IF var_of_interest > UPPER OR var_of_interest < LOWER THEN OUTLIER = 1;
        ELSE OUTLIER = 0;
RUN;

PROC PRINT DATA = TUKEY;
RUN;
```

**Option 2: Boxplot**
```
/* Variables to change:
    - my_dataset
    - var_of_interest
*/

/*Outlier detection using BOXPLOT*/
DATA TUKEY;
    SET my_dataset;
    GROUP = 1; /* We make this to plot only one variable */
RUN;

PROC BOXPLOT DATA = TUKEY;
   PLOT  var_of_interest *GROUP / boxstyle = schematicid;
   ID dataset_id; /* This line is to print the outliers */
RUN;
```

___

## Homogeneity tests (outliers for sample variance) <a name="homo"></a>

This requires at least 2 datasets (i.e., multiple datasets are supported). It is similar to test for homogeneity since we are assuming equal variance. 

### Requirements
- Sample size of the datasets is the same for all of them.

For this, two approaches are known:

### Doornboos

Follow next steps:
1. Compute all variances.
2. Order them (the variances).
3. Take the first element (the smallest variance).
4. Sum all the the variances and compute: `C = s_first^2 / sum_of_variances`

#### Code

To compute the statistic, check Week 2, Lecture 1, Slide 34

```
DATA Doornboos;
    STATISTIC = D /* The value that has been manually computed */
    N = n_value; /* Number of datasets */
    K = k_value; /* Number of observations in each dataset (size of the dataset) */
    ALPHA = 0.05;

    QUANTILE = QUANTILE('F', ALPHA/N, (K - 1), (K - 1)*(N - 1) );
    C_critical = 1 / (1 + (N - 1)/ QUANTILE)
    REJECT = C_critical < STATISTIC;
RUN;
```

### Cochran 

Follow next steps:

1. Compute all variance.
2. Order them (the variances).
3. Take the last element (the biggest std. dev).
4. Sum all the the variances and compute: `C = s_last^2 / sum_of_variances`
4. Compute the critical value with the code below and compare it against `ALPHA`

#### Code

To compute the statistic, check Week 2, Lecture 1, Slide 34

```
DATA COCHRAN;
    STATISTIC = C /* The value that has been manually computed */
    N = n_value; /* Number of datasets */
    K = k_value; /* Number of observations in each dataset (size of the dataset) */
    ALPHA = 0.05;

    QUANTILE = QUANTILE('F', ALPHA/N, (K - 1), (K - 1)*(N - 1) );
    C_critical = 1 / (1 + (N - 1)/ QUANTILE)
    REJECT = C_critical < STATISTIC;
RUN;
```

## Multiple outliers <a name="multiple"></a>

For this, the next procedure should be performed, although we did not cover it in detail:

1. Order the observations (sort)
2. Pick `k` as the number of outliers we suspect there are (extreme top values)
3. Make a subset of the first k elements and thest if `y(k + 1)` is an outlier
    a. If it is an outlier, then the higher values are also outliers
    b. If not an outlier, repeat the procedure with k++
