# Week 5: Multiple testing

!!!!!! Multiple testing is for continuous variables, go to independent samples for binary

1. [Motivation](#motivation)
2. [Least-squares difference](#kolmo)
3. [Bonferroni's and Sidak's correction](#cramer)
4. [Holm-Bonferroni](#holmbon)
5. [Tukey's studentized range](#anderson)
6. [Scheffe's](#shapiro)
7. [Duncan's multiple range test](#skew)
8. [Dunnett's](#chi)
9. [Optimal size calculations for control and treatment groups](#calculate)
10. [Comparison of all corrections from slides](#comparison)
11. [Code for all the tests above except Duncan](#code)

## Motivation <a name="motivation"></a>
- ANOVA points out if at least one of the treatment groups differ from the rest but it does not indicate which groups are different. 
- When all treatment groups are pair-wise tested, cumulative error rate increases heavily because of type 1 error. Familywise error rate FWER (total error probability) becomes `1-(1-alpha)^n` where `n` is the number of the pair-wise tests.
- When there are multiple treatment groups and one group differs from them F-test may fail the reject the `H_0` 

### Remark
The below assumptions of ANOVA must be satisfied for multiple testing.
- Normality of the residuals
- Homogeneity of residual variance across groups
- Normality of random effects
- Random effects and residuals are independent from each other 


## Least-squares difference <a name="kolmo"></a>
LSD approach: first run ANOVA to see if there is a difference, if ANOVA says there is a difference, continue with pairwise comparisons. 

## Bonferroni's and Sidak's correction <a name="cramer"></a>
- Adjusts the p-value to keep FWER rate small. 
- This correction is considered conservative since it ignores dependences among groups.
- For independent tests, Bonferroni is an approximation of Sidak correction.
- Bonferroni and Sidak works best with small number of groups.

## Tukey's studentized range <a name="anderson"></a>
- Focusses on all pairwise comparisons.
- Tukey's test is more powerful than Bonferroni correction in case of all pair-wise comparisons.
- For Tukey, it is more difficult for unbalanced data.

## Scheffe's <a name="shapiro"></a>
- Tukey's test investigate the contrasts. (whatever that means)
- Scheffe is considered as the most conservative test.

## Duncan's multiple range test <a name="skew"></a>
- Duncan tries to cluster the groups.
- It internally sorts all group means and compares them pair-wise.

```
/* replace DATA_NAME */
/* replace TREATMENT_VARIABLE with the variable indicating groups */
/* replace ID_VARIABLE with the variable that indicates individuals */

*first sort;
PROC SORT DATA=DATA_NAME;
BY TREATMENT_VARIABLE ID_VARIABLE;
RUN;

PROC GLM DATA=DATA_NAME; *replace DATA_NAME make it same with above DATA_NAME;
	CLASS TREATMENT_VARIABLE; *replace TREATMENT_VARIABLE make it same with above TREATMENT_VARIABLE;
	MODEL OUTCOME_VARIABLE = TREATMENT_VARIABLE; *replace OUTCOME_VARIABLE;
	MEANS TREATMENT_VARIABLE/DUNCAN;
RUN;
```

## Dunnett's <a name="chi"></a>
- For the cases of comparison with a control group.
- In case of all pairwise comparisons, this one is similar to Tukey.
- P-value is calculated from multivariate t-dist (Kenan > There is no indication anywhere but I think this implies normality assumption.)
- Because all treatments are compared against a control group an imbalanced design is beneficial, if you have chance to select the sample sizes of different groups.

## Optimal size calculations for control and treatment groups <a name="calculate"></a>
- First run the below line to get `NUMBER_OF_DATAPOINTS (N)` 
```
Proc means N data=DATA_NAME; *replace DATA_NAME
run;

/*Then find the number of treatment groups by simply observing data and perform below calculations with a calculator*/

Proc means N data=QUESTION1; *replace DATA_NAME, YOU RUN THIS JUST TO GET THE N;
run;

DATA NGROUPS;
N = ;   * INSERT NUMBER OF CHILDREN;
m = ;   * INSERT TRT GROUPS;
/*n1 = size of control group
n2 = size of other treatment groups*/

n2 = N / ((m-1) + sqrt(m-1));
n2A = FLOOR(n2);
n2B = ceil(n2);

n1A = N - n2A * (m-1);
n1B = N - n2b * (m-1);
A=(m-1)*(N1A+n2A)/(N1A*n2A);
B= (m-1)*(n1B+n2B)/(n1B*n2B);
FINAL_A=(A<B);
RUN;

/* your solutions will possibly have decimals then*/
/* round n2 up and down and calculate n1 accordingly */
/* then calculate A=(m-1)(n1+n2)/(n1*n2) with the pairs of n1 and n2 */
/* pick the n1, n2 pair with the smaller A */
```


## Comparison of all corrections from slides <a name="comparison"></a>

The LSD is frequently applied:
- It is the only test that uses the p-value of the F-test for the joint hypothesis
- Is very powerful, but not most powerful when just a few groups from many groups are truly different
- It does not protect against false differences when just a few groups from many are truly different
- Is easy to misuse as approach
- It is very popular, but the disadvantages are often overlooked

Bonferroni/Sidak corrections
- Can be used for any type of comparisons
(contrasts or characteristics)
- Are almost exact for small number of tests
- Can be improved (Holm-Bonferroni)

Tukey's test compares all pairs
- Protects against false differences
- Is not always the most powerful, but better than Bonferroni/Sidak for larger groups
- Is more complicated for imbalances

Scheffe for all contrasts
- Is a very generic procedure since it can handle any type of group comparisons
- Is less powerful than many other more specialized tests (e.g. one-to-many)

Duncan's multiple range test
- The only test that tries to cluster the groups
- Does not protect FWER, which is considered a serious drawback

Dunnett's one-to-many
- Is the Tukey’s test for all comparisons against a control group
- It is more complicated for imbalances (although a multivariate 𝑡-distribution could be used)
- It protects the FWER, where Scheffé and Bonferroni/Sidak does not do this for this task
- It is more powerful than Bonferroni/Sidak for larger number of groups
- Optimal sample sizes are frequently not applied (unfortunately)

## Code for all the tests above except Duncan <a name="code"></a>
```
* first sort;

/* replace DATA_NAME */
/* replace TREATMENT_VARIABLE with the variable indicating groups */
/* replace ID_VARIABLE with the variable that indicates individuals */
PROC SORT DATA=DATA_NAME; 
BY TREATMENT_VARIABLE ID_VARIABLE; 
RUN;

* uncomment the line of code for desired test;

* replace DATA_NAME, it must be the same with above code;
* replace TREATMENT_VARIABLE and ID_VARIABLE with same variables from above;
PROC MIXED DATA=DATA_NAME METHOD=Type3 CL; 
	CLASS TREATMENT_VARIABLE ID_VARIABLE;
	MODEL OUTCOME_VARIABLE = TREATMENT_VARIABLE   /SOLUTION OUTP=PRED CL; *replace OUTCOME_VARIABLE;
	*LSMEANS TREATMENT_VARIABLE/DIFF; *least square difference;
	*LSMEANS TREATMENT_VARIABLE/DIFF ADJUST=BON; *bonferroni;
	*LSMEANS TREATMENT_VARIABLE/DIFF ADJUST=SIDAK; *sidak;
	*LSMEANS TREATMENT_VARIABLE/DIFF ADJUST=TUKEY; *tukey studentized range;
	*LSMEANS TREATMENT_VARIABLE/DIFF ADJUST=SCHEFFE; *scheffe;
	*LSMEANS TREATMENT_VARIABLE/DIFF ADJUST=DUNNETT; *dunnett;

/* 	below line indicates the control group as 0.  */
/* 	change 0 with any number you like as the control group.  */
/* 	Also note that you can use control group approach with any test except for TUKEY.  */
/* 	Below example is for BONFERRONI; */

	*LSMEANS TREATMENT_VARIABLE/DIFF=CONTROL('0') ADJUST=BON;

/* to run HOLM-BONFERRONI uncomment below line and also the first BONFERRONI line */
	*ODS OUTPUT Diffs=LSD; *Output to perform Holm-Bonferonni correction;
RUN;

* the rest is only for HOLM-BONFERRONI you dont need to change anything;
Proc sort data=LSD;
by Probt;
run;

Data LSD;
set LSD;
  rownum=_n_;
  HolmBonferroni=0.05/(6+1-rownum);
  Reject=(Probt<=HolmBonferroni);
  DROP rownum Estimate StdErr DF tValue;
run;
```