/******************************************************************************/
/******************************************************************************/
/*********************************  SECTION 1 *********************************/
/******************************************************************************/
/******************************************************************************/

* Import data;
LIBNAME SASDATA "/folders/myfolders/";
DATA  EXAM;
	SET SASDATA.EXAM_DATA;
RUN;


/* Select data where period equals to 4 months */
DATA QUESTION1;   * new name of fixed data set;
 SET EXAM;          *name of original data set;
 WHERE PER = 4;
RUN;



/******************************************************************************/
/* QUESTION a */

/* Calculate the percentage of children that were in stress (FIS) during the delivery and calculate an exact 95% confidence interval. Use 2 decimalson al reported values */
/******************************************************************************/

* ------------------OUR WAY---------------;
/* Variables to change: 
    - my_dataset: the dataset
    - var_of_interest: variable to work with
*/

/* CHANGE VALUES HERE */
PROC MEANS DATA = QUESTION1;
    VAR FIS;
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

*LCL_TWO_SIDED = 0.27917->0.28, UCL_TWO_SIDED = 0.39931->0.40	  ;


/******************************************************************************/
/* QUESTION b */
/******************************************************************************/

*OUR WAY------------------------------------------------------------ ;

/* Variables to change:
    - my_dataset: the dataset
    - var_of_interest: variable to work with
*/

/* CHANGE my_dataset AND var_of_interest HERE */
PROC MEANS DATA = question1 NOPRINT;
    VAR BW;
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






*MORE THAN 1 NEW OBSERVATION------------------------------------------------------------ ;


PROC MEANS DATA=QUESTION1;
	VAR BW;
	OUTPUT OUT=SUMMARY MEAN=MEAN_CU VAR=VAR_CU N=N_CU; 
RUN;

DATA SUMMARY;
	SET SUMMARY;
	N_new = 2;  * HOW MANY NEW OBSERVATIONS;
run;

DATA PI_SVAR;
	SET SUMMARY;
	F_U = QUANTILE('F', 1-0.01/2, N_new -1, N_CU-1);
	F_L = QUANTILE('F',   0.01/2, N_new -1, N_CU-1);
	LCL = VAR_CU*F_L;
	UCL = VAR_CU*F_U;
	DROP TYPE FREQ;
RUN;

PROC PRINT DATA=PI_SVAR;
RUN;

/******************************************************************************/
/* QUESTION c */
/******************************************************************************/
/* Add a variable for pre-term children (PREPROCESSING!) */
DATA PRETERM;
    SET QUESTION1;
    PRE = (GA < 37);
RUN;

*OUR WAY------------------------------------------------------------ ;

* first run the wilcoxon;

/* wilcoxon test statistic = min(S1,S2) check below */

PROC NPAR1WAY DATA= PRETERM; *replace DATA_NAME;
	CLASS PRE; *replace CLASS_VARIABLE (binary values);
	VAR BW; *replace VARIABLE_NAME;
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
	N1 = 45;
	N2 = 208;
	S1 = 1438.0;
	S2 = 30693.0	; * this is the sum of scores;
	* now actual mann-whitney part;
	U2 = S2 - N2*(N2+1) /2;
	U1 = S1 - N1*(N1+1) /2;
	PROB2 = U2 / (N1*N2);
	PROB1 = U1 / (N1*N2);
RUN;

PROC PRINT DATA=MANN;
	VAR U1 PROB1 U2 PROB2;
RUN;
/******************************************************************************/
/* QUESTION d */
/******************************************************************************/

/* ARGUMENTS:
    (1) data seems reasonably normal
    (2) variances are similar
    (3) the t-test is robust against violation of normality
*/

/* OPTION1: CHECK FOR NORMALITY PER GROUP */
PROC SORT DATA = PRETERM;
    BY PRE;
RUN;

PROC UNIVARIATE DATA = PRETERM NORMAL;
    BY PRE;
    VAR BW;
RUN;

*Anderson-Darling(i have ties)	A-Sq	0.27927	Pr > A-Sq	>0.2500, i do not reject normality;


/* Check for homogeneity of variances(need to run this as well!!) */
PROC TTEST DATA = PRETERM;
    CLASS PRE;
    VAR BW;
RUN;

*0.5884 ftest (Pr > F);
* Specify that we are talking about the t test for equal variances;


/******************************************************************************/
/* QUESTION e */
/******************************************************************************/
PROC MEANS DATA = QUESTION1 N MEAN STD;
    VAR TTP;
RUN;

DATA GRUBBS;
    SET QUESTION1;
    ALPHA = 0.05;
    N = 252;
    MEAN = 3.4906590;
    STD = 2.3372008;
    /* */
    U = ABS( (TTP - MEAN) / STD);
    T = TINV(1 - ALPHA/(2*N), N -2);
    CRIT = SQRT( ((N - 1 )**2 * T**2) / (N*(T**2 + N - 2)) );
RUN;

PROC SORT DATA = GRUBBS;
    BY DESCENDING U;
RUN;

PROC PRINT DATA = GRUBBS (OBS = 1);
    VAR U CRIT;
RUN;


* our way----------;




/* Values to change:
    - my_dataset
    - var_of interest
    - exact_criteria: Exact criteria according to slides Week 2, Lecture 1, Slide 25/26
*/

/* 1. Run this first */
/* CHANGE my_dataset AND var_of_interest HERE */
PROC MEANS DATA = question1;
    VAR TTP;
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
    SET question1;  * CHANGE TO DATA SET;

    U = (TTP - &Y)/ &S;  * CHANGE TO VARIABLE OF INTEREST (TTP);
    GRUBBS_STATISTICS = ABS(U);
    /* Two sided */
    T_QUANTILE_TS = QUANTILE('T', 1 - &ALPHA/(2 * &N), &N - 2);
    APPROXIMATE_CRITERIA_TWO_SIDED = SQRT(( (&N - 1)**2 * T_QUANTILE_TS**2 ) / ( &N * ((T_QUANTILE_TS**2) + (&N - 2)) ));
    
    /* One sided */
    T_QUANTILE_OS = QUANTILE('T', 1 - &ALPHA/(&N), &N - 2);
    APPROXIMATE_CRITERIA_ONE_SIDED = SQRT(( (&N - 1)**2 * T_QUANTILE_OS**2 ) / ( &N * ((T_QUANTILE_OS**2) + (&N - 2)) ));

    exact_criteria = 3.38; /* UPDATE WITH VALUE IN THE SLIDES */
RUN;

/* 4. Sort data, the highest W is the test statistic */
PROC SORT DATA = Grubbs;
    BY GRUBBS_STATISTICS;
RUN;

/* 5. Print data. */
PROC PRINT DATA = Grubbs;
RUN;

* WE CHECK GRUBBS STATISTIC AT THE END (MAXIMUM(SORTED)) AND COMPARE TO CRITERIA ;
* GRUBBS STATISTIC (4.19608) > APPROXIMATE_CRITERIA_TWO_SIDED	(3.67368) ;

* SO THE PERSON WITH THE ID 247 IS AN OUTLIER (WE HAVE AT LEAST 1 OULIER)  ;


/******************************************************************************/
/* QUESTION f */
/******************************************************************************/


*OUR WAY--------------------- ;

/* Values to change:
    - my_dataset
    - var_of_interest
    - m_y
    - m_d
*/

/* CHANGE var_of_interest AND my_dataset HERE */
PROC SORT DATA = question1 OUT = Hampel;
    BY TTP;
RUN;

/* 1. Compute median of var_of_interest */
/* CHANGE var_of_interest HERE */
PROC UNIVARIATE DATA = Hampel normal;  
    VAR TTP;
RUN;

/* 2. Update this with the median in the previous step */
%let m_y = 3.178645;   

/* 3. Compute D (Absolute deviation) */
DATA Hampel;
    SET Hampel;
    D = ABS(TTP - &m_y);   * CHANGE VARIABLE OF INTEREST (TTP);
RUN;

/* 4. Compute median of D */
PROC UNIVARIATE DATA = Hampel;
    VAR D;
RUN;

/* 5. Update this with the median in the previous step */
%let m_d = 1.590691;

/* 6. Compute absolute normalized value */
DATA Hampel;
    SET Hampel;
    Z = ABS(TTP - &m_y)/&m_d;  * CHANGE VARIABLE OF INTEREST (TTP);
    IS_OUTLIER = Z > 3.5;    * ALWAYS SAME;
RUN;

/* 7. Report any observation where Z is greater than 3.5 */
PROC PRINT DATA = Hampel;
RUN;


* HAMPELS IS FOR MULTIPLE OUTLIERS SO YOU GET 1s FOR OUTLIERS;
* HR STATISTIC (Z)  6.36145	 > 3.5;
*IN THE END YES THE MAXIMAL IS AN OUTLIER ;

/******************************************************************************/
/* QUESTION g */
/******************************************************************************/

PROC CORR DATA = QUESTION1 PEARSON SPEARMAN;
    VAR BW TTP;
RUN;
* RESULTS ;
* PEARSON -0.06505     0.3037 ;
*SPEARMAN -0.10751      0.0885 ;


/* With alpha = 0.1:
    For pearson NOT reject independence
    For spearman reject independence  (0.10 >  0.0885 (PVALUE))
*/

/******************************************************************************/
/* QUESTION h */
/******************************************************************************/
/*  Tau = - 0.02725 
    alpha = 1/(1 - tau) = 0.9735 < 1.
    Does not satisfy alpha >= 1. so its a bad copula
    See slides W3-2 (p. 43/48)
*/
PROC CORR DATA = QUESTION1 KENDALL;
    VAR AGEM TTP;     * variables of interest ;
RUN;


/******************************************************************************/
/* QUESTION i */
/******************************************************************************/
PROC FREQ DATA = QUESTION1;
    TABLES TRT*FIS / CHISQ;
    WHERE TRT^=1;
RUN;

PROC FREQ DATA = QUESTION1;
    TABLES TRT*FIS / CHISQ;
    WHERE TRT ^= 2; *ALL EXCEPT TRT = 2;
RUN;

* grup 0 is the control group cause he keeps it;
* Chi-Square (0.0258) > a/2 (2 here is the number of tests i run (THAT IS BONFERONI CORRECTION!!));
* BONFERONI ->IM TRYING TO BE MORE CONSERVATIVE IN IDIVIDUAL TEST SO I KEEP MY TOTAL ERROR PROBABLITY CONSTANT;

/******************************************************************************/
/* QUESTION j */
/******************************************************************************/
PROC MIXED DATA = QUESTION1;
    CLASS TRT;
    MODEL IMP = TRT / SOLUTION;
    LSMEANS TRT / DIFF ADJUST = SCHEFFE;
    LSMEANS TRT / DIFF ADJUST = TUKEY;
RUN;






* OUR WAY---------------;

* first sort;

/* replace DATA_NAME */
/* replace TREATMENT_VARIABLE with the variable indicating groups */
/* replace ID_VARIABLE with the variable that indicates individuals */
PROC SORT DATA=QUESTION1; 
BY TRT ID; 
RUN;

* uncomment the line of code for desired test;

* replace DATA_NAME, it must be the same with above code;
* replace TREATMENT_VARIABLE and ID_VARIABLE with same variables from above;
PROC MIXED DATA=QUESTION1 METHOD=Type3 CL; 
	CLASS TRT ID;
	MODEL IMP = TRT   /SOLUTION OUTP=PRED CL;
	*LSMEANS TREATMENT_VARIABLE/DIFF; *least square difference;
	*LSMEANS TREATMENT_VARIABLE/DIFF ADJUST=BON; *bonferroni;
	*LSMEANS TREATMENT_VARIABLE/DIFF ADJUST=SIDAK; *sidak;
	LSMEANS TRT/DIFF ADJUST=TUKEY; *tukey studentized range;
	LSMEANS TRT/DIFF ADJUST=SCHEFFE; *scheffe;
	*LSMEANS TREATMENT_VARIABLE/DIFF ADJUST=DUNNETT; *dunnett;

/* 	below line indicates the control group as 0.  */
/* 	change 0 with any number you like as the control group.  */
/* 	Also note that you can use control group approach with any test except for TUKEY.  */
/* 	Below example is for BONFERRONI; */

	*LSMEANS TREATMENT_VARIABLE/DIFF=CONTROL('0') ADJUST=BON;

/* to run HOLM-BONFERRONI uncomment below line and also the first BONFERRONI line */
	*ODS OUTPUT Diffs=LSD; *Output to perform Holm-Bonferonni correction;
RUN;

*HIGHER P VALUES-> YOU ARE MORE CONSERVATIVE (HARDER TO REJECT) ;
*HERE THEY ARE GETTING HIGHER CAUSE SCEFFE IS THE MOST CONSERVATIVE;
*RESULTS IS THE TABLES IN THE END;


/******************************************************************************/
/* QUESTION k */
/******************************************************************************/
DATA SAMPLE;
    M = 3; /* GROUPS */
    N = 252; /* SAMPLES */
    N1 = ROUND(N/(SQRT(M - 1) + 1), 1);
    N2 = (N - N1)/2;
RUN;

PROC PRINT DATA = SAMPLE;
RUN;


*OUR WAY----------------------- ;

Proc means N data=QUESTION1; *replace DATA_NAME, YOU RUN THIS JUST TO GET THE N;
run;

DATA NGROUPS;
N = 252;   *NUMBER OF CHILDREN;
m = 3;      *TRT GROUPS;
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

*74-109 DEPENDING ON FINAL A;

/* your solutions will possibly have decimals then*/
/* round n2 up and down and calculate n1 accordingly */
/* then calculate A=(m-1)(n1+n2)/(n1*n2) with the pairs of n1 and n2 */
/* pick the n1, n2 pair with the smaller A */




/******************************************************************************/
/******************************************************************************/
/*********************************  SECTION B *********************************/
/******************************************************************************/
/******************************************************************************/

/******************************************************************************/
/* QUESTION a */
/******************************************************************************/



/* Select data where period equals to 4 months */
DATA QUESTION2;   * new name of fixed data set;
 SET EXAM;          *name of original data set;
RUN;


PROC SORT DATA = QUESTION2;
    BY ID PER;
RUN;

PROC TRANSPOSE DATA = QUESTION2 OUT = SIGN  PREFIX = IMP;
    BY ID;
    ID PER;
    VAR IMP;
RUN;

DATA MONTH10;
    SET QUESTION2;
    IMP10 = IMP;
    WHERE PER = 10;
    KEEP ID IMP10;
RUN;

DATA MONTH18;
    SET QUESTION2;
    IMP18 = IMP;
    WHERE PER = 18;
    KEEP ID IMP18;
RUN;


DATA SIGN;
    MERGE MONTH10 MONTH18;
    BY ID;
RUN;

/* Compute statistic */
DATA SIGN;
    SET SIGN;
    DIFF = IMP18 - IMP10;
    PLUS = (DIFF > 0);
    ZER0 = (DIFF = 0);
    MIN = (DIFF < 0);
    WHERE IMP18 ^=. AND IMP10 ^=. ;
RUN;

PROC MEANS DATA = SIGN SUM;
    VAR PLUS ZER0 MIN;
RUN;

/* Sign test using binomial */
DATA SIGNTEST;
    N0 = 112 + 105; /* Number of ties */
    S = 112; /* Value of binomial statistic */
    P = 1 - CDF('BINOM', S - 1, 0.5, N0);   *FOR 1 SIDED;
RUN;

PROC PRINT DATA = SIGNTEST;
RUN;

/* Without binomial statistic (using SAS) */
/* Remember, this is for two-sided test */ 
PROC UNIVARIATE DATA = SIGN NORMAL;
    VAR DIFF;
RUN;

*RESULT:;
*3.5 TEST STATISTIC , PVALUE(2SIDED) 0.6839 ;
*1 SIDED DIVIDE 0.6839/2 > ALPHA SO I DONT REJECT H0 =Mimp10 = Mimp18;



* ;
*-----------------------our way------------------------------------;

* Variables to change:
    - my_dataset
    - id_of_dataset: the subject/person/observation id of the datset
    - measurementB: your variable B
    - measurementA: your variable A
*/

/* CHANGE  AND id_of_dataset HERE */
PROC SORT DATA = my_dataset;
    BY id_of_dataset;
RUN;

/* CHANGE my_dataset, measurementB AND measurementA HERE.*/
DATA my_dataset;
    SET my_dataset;
    /* Pick just one of the below options */
    DIFF  = measurementB - measurementA;
    *RATIO = measurementB/measurementA - 1; /* Sas tests for mu = 0 all time */
    *LOG_DIFF = LOG(measurementB)- LOG(measurementA);
RUN;

/* CHANGE my_dataset AND PICK AN OPTION DIFF/RATIO/LOG_DIFF HERE */
PROC UNIVARIATE DATA = my_dataset NORMAL;
    /* Pick just one of the below options */
    VAR DIFF;
    *VAR RATIO;
    *VAR LOG_DIFF;
RUN;



/******************************************************************************/
/* QUESTION b, c */
/******************************************************************************/
DATA MCNEMAR;
    SET SIGN;
    NF10 = (IMP10 < 80);
    NP18 = (IMP18 < 80);
RUN;

PROC FREQ DATA = MCNEMAR;
    TABLES NP10*NP18 / AGREE;
RUN;

DATA MCNEMAR;
    N00 = 240;
    N01 = 0;
    N10 = 2;
    N11 = 0;

    N = N00 + N01 + N10 + N11;
    ALPHA = 0.05;

    P = 2 * CDF('BINOM', N01, 0.5, N01 + N10);
    PO = (N00 + N11) / N;
    PE = ( ((N00 + N10)*(N00 + N01)) + ((N01 + N11)*(N10 + N11)) ) / N**2;

    KAPPA = (PO - PE) / (1 - PE);

    STD = PO*(1 - PO)/(N*(1 - PE)**2);
    LCL = KAPPA - STD * QUANTILE('NORMAL', 1 - ALPHA/2);
    UCL = KAPPA + STD * QUANTILE('NORMAL', 1 - ALPHA/2);
RUN;

PROC PRINT DATA = MCNEMAR;
    VAR P KAPPA LCL UCL;
RUN;


/******************************************************************************/
/******************************************************************************/
/*********************************  SECTION C *********************************/
/******************************************************************************/
/******************************************************************************/

/******************************************************************************/
/* QUESTION B, C */
/******************************************************************************/

*----------------------------OUR WAY------------------------------;

/* change DATA_NAME and all VARIABLES accordingly */



PROC MIXED DATA=exam COVTEST CL METHOD=TYPE3;
	CLASS TRT ID PER;    *WRITE ALL YOUR VARIABLES IN ANY ORDER;
/*	Kenan> Im not sure if the below codes would work because of the OUTP=pred statement*/
/*	if it works, it should put the variables in a table called "pred" for later examination*/
/* 	interaction effect between variables A and B is written as A*B */

/*	Jorge says that, "DDFM=SAT" should be there when they ask for confidence intervals*/
	MODEL IMP = TRT PER TRT*PER / SOLUTION; *DDFM=SAT CL OUTP=pred;   *IF PER WAS RANDOM YOU MOVE TRT AND TRT*PER DOWN ;
	RANDOM ID(TRT) / SOLUTION; * SOLUTION statement here shows the EBLUPs;  * RANDOM EFFECR ID;
/* 	nested effects go like this when VAR_A nested in VAR_B*/
/* 	logic: example, if all patients do not get all treatments, then patient is nested within treatment*/
/* 	VAR_A(VAR_B) */
RUN;

*FOR ICC------------;

DATA ICC;
	*go the COVARIANCE PARAMETER ESTIMATES of above ANOVA result to get sigmas;
	SIGMA_1 = 1.5449; *insert estimate for random effect;
	SIGMA_ALL = 7.0802; * insert estimate for residuals;
	ICC = SIGMA_1 / (SIGMA_1 + SIGMA_ALL);

/*	to find the EBLUP find "solution for random effects" table in the result of the anova code */
/*	find the desired ID/person (whatever) in the table read the "estimate" value */
	EBLUP= 0.7458;


*TRT*PER -> FVALUE(1.58)	PVALUE(0.1785), SO I DONT REJECT THE H0 (Cijs differ from 0) so this models is bad cause the interaction is not playing a factor	 ;

* ICC=0.1791167639;
*VARIANCE COMPONENT ESTIMATES;
*SIGMA_1 = 1.5449; *insert estimate for random effect;
*SIGMA_ALL = 7.0802; * insert estimate for residuals;


/******************************************************************************/
/* QUESTION D */
/******************************************************************************/
PROC MIXED DATA = exam COVTEST;
    CLASS ID PER TRT;
    MODEL IMP = TRT PER TRT*PER / SOLUTION DDFM = SATTERTHWAITE;
    RANDOM ID(TRT);
    LSMEANS TRT*PER / DIFF CL;
RUN;

*PER*TRT	10	0	10	1	0.5398	0.4988	676	1.08	0.2796	0.05	-0.4396	1.5193;
*PER*TRT	10	0	10	2	0.6367	0.4275	677	1.49	0.1369	0.05	-0.2027	1.4761 ;


