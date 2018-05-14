# Preparation

```
/******************************************************************************/
/******************************************************************************/
/*********************************  SECTION 1 *********************************/
/******************************************************************************/
/******************************************************************************/

/******************************************************************************/
/* QUESTION a */
/******************************************************************************/

/* Option 1 */ 
PROC MEANS DATA = QUESTION1 SUM N MEAN STD;
    VAR FIS;
RUN;

/* Option 2 */
DATA CI1_FIS;
    ALPHA = 0.05;
    N = 252;
    P = 85/252;
RUN;

/* Option 2 */ 
DATA CI2_FIS;
    ALPHA = 0.05;
    N = 252;
    MEAN = 0.3373016;
    STD = 0.4737296;
    /* EXACT */
    LCL = MEAN - TINV(1 - ALPHA/2, N - 1) * STD/SQRT(N);
    UCL = MEAN + TINV(1 - ALPHA/2, N - 1) * STD/SQRT(N);
    /* APPROXIMATE */
    Q = QUANTILE('NORMAL', 1 - ALPHA/2);
    LCL2 = MEAN - Q * STD / SQRT(N);
    UCL2 = MEAN + Q * STD / SQRT(N);
RUN;

PROC PRINT DATA = CI2_FIS;
    VAR LCL UCL LCL2 UCL2;
RUN;

/* Option 3, same as option 2 but using SAS */
PROC UNIVARIATE DATA = QUESTION1 CIBASIC;
    VAR FIS;
RUN;

/******************************************************************************/
/* QUESTION b */
/******************************************************************************/
PROC MEANS DATA = QUESTION1 SUM N MEAN STD;
    VAR BW;
RUN;

DATA PI_BW;
    ALPHA = 0.05;
    N = 252;
    MEAN = 3293.21;
    S = 673.1249716;
    UPL = MEAN + TINV(1 - ALPHA/2, N - 1) * S * SQRT((N + 1) / N);
    LPL = MEAN - TINV(1 - ALPHA/2, N - 1) * S * SQRT((N + 1) / N);
RUN;

PROC PRINT DATA = PI_BW;
    VAR LPL UPL;
RUN;

/******************************************************************************/
/* QUESTION c */
/******************************************************************************/
/* Add a variable for pre-term children */
DATA PRETERM;
    SET QUESTION1;
    PRE = (GA < 37);
RUN;

PROC NPAR1WAY DATA = PRETERM;
    CLASS PRE;
    VAR BW;
    EXACT WILCOXON / MC;
RUN;

DATA MANN;
    /* Wilcoxon Scores */
    N1 = 45;
    N2 = 208;
    S2 = 30693;
    /* Mann-Withney U */
    U = S2 - N2*(N2 + 1)/2;
    PROB = U / (N1*N2);
RUN;

/* GET P VALUE FROM WILCOXON*/
PROC PRINT DATA = MANN;
    VAR U PROB;
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

/* OPTION 2: CHECK BOTH GROUPS */
DATA PRETERM;
    SET PRETERM;
    IF PRE = 0 THEN RES = BW - 3504.30288;
        ELSE RES = BW - 2317.46667;
RUN;

PROC UNIVARIATE DATA = PRETERM NORMAL;
    VAR RES;
RUN;

/* Check for homogeneity of variances */
PROC TTEST DATA = PRETERM;
    CLASS PRE;
    VAR BW;
RUN;

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
/******************************************************************************/
/* QUESTION f */
/******************************************************************************/
PROC MEANS DATA = QUESTION1 MEDIAN;
    VAR TTP;
RUN;

DATA HAMPEL;
    SET QUESTION1;
    ABSDEV = ABS(TTP - 3.1786448);
RUN;

PROC MEANS DATA = HAMPEL MEDIAN;
    VAR ABSDEV;
RUN;

DATA HAMPELRULE;
    SET QUESTION1;
    MEDIAN = 3.1786448;
    MD = 1.5906913;
    HR = ABS(TTP - MEDIAN) / MD;
    CRIT = 3.5;
RUN;

PROC SORT DATA = HAMPELRULE;
    BY DESCENDING HR;
RUN;

PROC PRINT DATA = HAMPELRULE (OBS = 1);
    VAR HR CRIT;
RUN;

/******************************************************************************/
/* QUESTION g */
/******************************************************************************/
/* With alpha = 0.1:
    For pearson NOT reject independence
    For spearman reject independence
*/
PROC CORR DATA = QUESTION1 PEARSON SPEARMAN;
    VAR BW TTP;
RUN;

/******************************************************************************/
/* QUESTION h */
/******************************************************************************/
/*  Tau = - 0.02725 
    alpha = 1/(1 - tau) = 0.9735 < 1.
    Does not satisfy alpha >= 1.
    See slides W3-2 (p. 43/48)
*/
PROC CORR DATA = QUESTION1 KENDALL;
    VAR AGEM TTP;
RUN;

/******************************************************************************/
/* QUESTION i */
/******************************************************************************/
PROC FREQ DATA = QUESTION1;
    TABLES TRT*FIS / CHISQ;
    WHERE TRT^1;
RUN;

PROC FREQ DATA = QUESTION1;
    TABLES TRT*FIS / CHISQ;
    WHERE TRT ^= 2; *ALL EXCEPT TRT = 2;
RUN;

/******************************************************************************/
/* QUESTION j */
/******************************************************************************/
PROC MIXED DATA = QUESTION1;
    CLASS TRT;
    MODEL IMP = TRT / SOLUTION;
    LSMEANS TRT / DIFF ADJUST = SCHEFFE;
    LSMEANS TRT / DIFF ADJUST = TUKEY;
RUN;

/******************************************************************************/
/* QUESTION k */
/******************************************************************************/
DATA SAMPLE;
    M = 3; /* GROUPS */
    N = 252; /* SAMPLES */
    N1 = ROUND(N/SQRT(M - 1) + 1, 1);
    N2 = (N - N1)/2;
RUN;

PROC PRINT DATA = SAMPLE;
RUN;
/******************************************************************************/
/******************************************************************************/
/*********************************  SECTION B *********************************/
/******************************************************************************/
/******************************************************************************/

/******************************************************************************/
/* QUESTION a */
/******************************************************************************/

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
    VAR PLUS ZERO MIN;
RUN;

/* Sign test using binomial */
DATA SIGNTEST;
    N0 = 112 + 105; /* Number of ties */
    S = 112; /* Value of binomial statistic */
    P = 1 - CDF('BINOM', S - 1, 0.5, N0);
RUN;

PROC PRINT DATA = SIGNTEST;
RUN;

/* Without binomial statistic (using SAS) */
/* Remember, this is for two-sided test */ 
PROC UNIVARIATE DATA = SIGN NORMAL;
    VAR DIFF;
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
PROC MIXED DATA = QUESTION3 COVTEST CL METHOD = TYPE3;
    CLASS ID PER TRT;
    MODEL IMP = TRT PER PER*TRT / SOLUTION;
    RANDOM ID(TRT) / SOLUTION;
RUN;

DATA ICC;
    SIGMA_ID = 1.5449;
    SIGMA_ALL = 7.0802;
    ICC = SIGMA_ID / (SIGMA_ID + SIGMA_ALL);
    EBLUP = 0.7458;
RUN;

/******************************************************************************/
/* QUESTION D */
/******************************************************************************/
PROC MIXED DATA = QUESTION3 COVTEST;
    CLASS ID PER TRT;
    MODEL IMP = TRT PER TRT*PER / SOLUTION DDFM = SATTERTHWAITE;
    RANDOM ID(TRT);
    LSMEANS TRT*PER / DIFF CL;
RUN;

```