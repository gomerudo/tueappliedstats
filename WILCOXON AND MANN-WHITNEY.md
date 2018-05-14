WILCOXON AND MANN-WHITNEY U TEST

```
* first run the wilcoxon;

/* wilcoxon test statistic = min(S1,S2) check below */

PROC NPAR1WAY DATA= DATA_NAME; *replace DATA_NAME;
	CLASS CLASS_VARIABLE; *replace CLASS_VARIABLE;
	VAR VARIABLE_NAME; *replace VARIABLE_NAME;
	EXACT WILCOXON/MC;
RUN;

* !!!!!!MANN-WHITNEY p-value is the same as WILCOXON p-value;

/* REMARK */
/* the wording of question changes if your gonna use version 1 and 2 below */
/* this might require some thinking. when you run above code you will have an */
/* idea which group has a higher average. reverse engineer that and you should */
/* find out the correct version */

DATA MANN; * this data name here doesnt matter;
	* insert wilcoxon-scores from above;
	N1 = ;
	N2 = ;
	S1 = ;
	S2 = ; * this is the sum of scores;
	* now actual mann-whitney part;
	U2 = S2 - N2*(N2+1) /2;
	U1 = S1 - N1*(N1+1) /2;
	PROB2 = U2 / (N1*N2);
	PROB1 = U1 / (N1*N2);
RUN;

PROC PRINT DATA=MANN;
	VAR U1 PROB1 U2 PROB2;
RUN;
```