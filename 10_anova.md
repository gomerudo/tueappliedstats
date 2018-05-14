```
/* change DATA_NAME and all VARIABLES accordingly */

PROC MIXED DATA=DATA_NAME COVTEST CL METHOD=TYPE3;
	CLASS VARIABLE1 VARIABLE2 VARIABLE3;
/*	Kenan> Im not sure if the below codes would work because of the OUTP=pred statement*/
/*	if it works, it should put the variables in a table called "pred" for later examination*/
/* 	interaction effect between variables A and B is written as A*B */

/*	Jorge says that, "DDFM=SAT" should be there when they ask for confidence intervals*/
	MODEL OUTCOME_VARIABLE = FIXED_VARIABLES_HERE / SOLUTION DDFM=SAT CL OUTP=pred;
	RANDOM RANDOM_VARIABLES_HERE / SOLUTION; * SOLUTION statement here shows the EBLUPs;
/* 	nested effects go like this when VAR_A nested in VAR_B*/
/* 	logic: example, if all patients do not get all treatments, then patient is nested within treatment*/
/* 	VAR_A(VAR_B) */
RUN;
```

```
* observe the residuals to find out if there are ties, then select normality test accordingly;
* dont change anything;
PROC FREQ data=PRED;
TABLE RESID;
run;

* check normality assumption of residuals;
* do not change anything;
PROC UNIVARIATE DATA=PRED NORMAL;
VAR RESID;
RUN;

* check homogenity of variance; 
PROC GLM DATA=PRED;
/* replace VARIABLE_NAME with every variable of anova (in CLASS statment) */
/* run the test 'number of variables' times */
CLASS VARIABLE_NAME; 
MODEL RESID = VARIABLE_NAME;
* HOV below, stands for homogenity of variance;
MEANS VARIABLE_NAME/ HOVTEST=BF; *check indep_samples_cont.md to get the right test for HOVTEST;
RUN; 
```

```
DATA ICC;
	*go the COVARIANCE PARAMETER ESTIMATES of above ANOVA result to get sigmas;
	SIGMA_1 = ; *insert estimate for random effect;
	SIGMA_ALL = ; * insert estimate for residuals;
	ICC = SIGMA_1 / (SIGMA_1 + SIGMA_ALL);

/*	to find the EBLUP find "solution for random effects" table in the result of the anova code */
/*	find the desired ID/person (whatever) in the table read the "estimate" value */
	EBLUP= ;
RUN;
```


```
/* Kruskal Wallis*/
PROC NPAR1WAY DATA=DATA_NAME WILCOXON; *replace DATA_NAME;
CLASS TREATMENT_VARIABLE; * replace TREATMENT_VARIABLE;
VAR OUTCOME_VARIABLE; * replace OUTCOME_VARIABLE
RUN;
```






