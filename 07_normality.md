# Week 5: Normality

1. [Motivation](#motivation)
2. [The code for 3-7](#code)
3. [Graphical techniques](#graph)
4. [Kolmogorov-Smirnov](#kolmo)
5. [Cramer-Von Mises](#cramer)
6. [Anderson-Darling](#anderson)
7. [Shapiro-Wilk](#shapiro)
8. [Skewness and Kurtosis](#skew)
9. [Chi-square for normality](#chi)

## Motivation <a name="motivation"></a>
We use several other tests based on the normality assumption. These tests are basically just testing if validity of that assumption.

## The code for 3-7 <a name="code"></a>
```
* run the code one by one to get the summary;
* first run this one;
PROC UNIVARIATE DATA=DATA_NAME NORMAL; *insert data name;
	VAR VARIABLE1 VARIABLE2; *insert as many variables as you want. 1 variable is also OK;
	HISTOGRAM VARIABLE1 VARIABLE2/NORMAL;
	PROBPLOT VARIABLE2 VARIABLE2/NORMAL(MU=est SIGMA=est);
	ODS OUTPUT TestsForNormality=NORMALITYTEST; *dont change this;
RUN;

* then run this one;
*ods rtf file='temp.rtf';
PROC PRINT DATA=NORMALITYTEST; *dont change this;
RUN;
*ods rtf close;
```

## Graphical techniques <a name="graph"></a>
This is a subjective evaluation. Check with your eyes if the data points lie on the line of resulting graphic. It is important that the data points do not follow a trend (for example if the first half of data points lie under the line and the rest lie above the line, this would reject normality.)

## Kolmogorov-Smirnov <a name="kolmo"></a>
- Used for testing against a prefined normal distribution.
- This test actually checks if the data points follow a normal distribution you specify by mean `MU` and standard deviation `SIGMA`.

## Cramer-Von Mises <a name="cramer"></a>
- To be honest, I did not really understand what is the specific use case of this one.

## Anderson-Darling <a name="anderson"></a>
- Almost the same thing with cramer – von mises, but gives more weight to the tails of the distribution
- Has often the same power as the Shapiro-Wilk, but on overall it is somewhat less powerful.
- Is less sensitive to ties
- Recommended as omnibus test

## Shapiro-Wilk <a name="shapiro"></a>
- Tries to fit a regression line to come up with a normality test. (see slide 19)
- A very sensitive and powerful test against non- symmetric departures from normality 
- Probably the most powerful test of all others and thus recommended as omnibus test 
- Sensitive to ties in the data: when ties are a result of rounding, than normality can incorrectly be rejected

## Skewness and Kurtosis <a name="skew"></a>
- Deviations from the classical normal distribution shape.
- WE WOULD BETTER ADD A PICTURE HERE
- Use the below code to get `\gamma_1` and `\gamma_2`, they are estimated and in the table you can find them as `Skewness` and `Kurtosis`
```
PROC UNIVARIATE DATA=DATA_NAME NORMAL; *insert data name;
	VAR VARIABLE1 VARIABLE2; *insert as much variables as you want 1 variable is also OK;
	HISTOGRAM VARIABLE1 VARIABLE2/NORMAL;
	PROBPLOT VARIABLE2 VARIABLE2/NORMAL(MU=est SIGMA=est);
	ODS OUTPUT TestsForNormality=NORMALITYTEST;
RUN;

* first run above code to get GAMMA1 and GAMMA2 for below;

DATA NO_NEED_TO_CHANGE;
	GAMMA1 = ; *skewness result of above code here;
	GAMMA2 = ; *kurtosis result of above code here;
	N = ; *number of data points here;
	SKEWNESS_B1 = (N-2)*GAMMA1/(SQRT(N*(N-1)));
	KURTOSIS_B2 = (((N-2)*(N-3))/((N+1)*(N-1)))*GAMMA2 + 3*((N-1)/(N+1));
RUN;
* ################;
/*After getting `SKEWNESS_B1` and `KURTOSIS_B2` compare them with the values in slides 29-30 of W5-1. An example interpretation is done on slide 37.*/
* ################;
```

## Chi-square for normality <a name="chi"></a>