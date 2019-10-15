/* IMPORTING THE TRAIN-DATA */
FILENAME REFFILE '/home/sushantpatkar110/sasuser.v94/Train.xlsx';

PROC IMPORT DATAFILE=REFFILE
	DBMS=XLSX
	OUT=ASSIGN.TRAIN;
	GETNAMES=YES;

LABEL
Donor = "DONOR"
D_ID = "DON ID"
Donor_D	= " PREV DON"
DonCntP1= "LAST 3YRS"
DONCntAll= "NO.OF.TIMES.DON"
DONCntCardP1= "DON WITHREF"
DONCntCardAll= "NO.OF.DON WITHREF"
DONAvgLast= "AvgLast DON"
DONAvgP1= "AVD DON 3YRS"
DONAvgAll= "AVG DON"
DONAvgCardP1= "AVG 3YRREF"
DONTimeLast= "LAST DON"
DONTimeFirst= "FIRST DON"
CallCntP2= "CALLS 1YR"
CallCntP1= "CALLS 3YR "
CallCntAll= "TOTAL CALLS"
CallCntCardP2= "REF CALLS.1YR"
CallCntCardP1= "REF CALLS.3YR"
CallCntCardAll= "TOTAL REF.CALLS"
Donor_Status= "DONOR STATUS"
Donor_Status_Prev_Camp= "PREV STATUS"
DemArea= "LOCATION"
Age= "AGE"
Gender= "GENDER "
DemHomeOwner= "HOME OWNER"	
AreaHomeValue= "HOMEVALUE"
AreaMedIncome= "INCOME_VALUE"
;

FORMAT
Donor BEST12.
D_ID             $CHAR8.
Donor_D          BEST12.
DonCntP1         BEST12.
DONCntAll        BEST12.
DONCntCardP1     BEST12.
DONCntCardAll    BEST12.
DONAvgLast       BEST12.
DONAvgP1         BEST12.
DONAvgAll        BEST12.
DONAvgCardP1     BEST12.
DONTimeLast      BEST12.
DONTimeFirst     BEST12.
CallCntP2        BEST12.
CallCntP1        BEST12.
CallCntAll       BEST12.
CallCntCardP2    BEST12.
CallCntCardP1    BEST12.
CallCntCardAll   BEST12.
Donor_Status     $CHAR1.
Donor_Status_Prev_Camp BEST12.
DemArea          $CHAR2.
Age              BEST12.
Gender           $CHAR1.
DemHomeOwner     $CHAR1.
AreaHomeValue    BEST12.
AreaMedIncome    BEST12.
;
INFORMAT
Donor BEST12.
D_ID             $CHAR8.
Donor_D          BEST12.
DonCntP1         BEST12.
DONCntAll        BEST12.
DONCntCardP1     BEST12.
DONCntCardAll    BEST12.
DONAvgLast       BEST12.
DONAvgP1         BEST12.
DONAvgAll        BEST12.
DONAvgCardP1     BEST12.
DONTimeLast      BEST12.
DONTimeFirst     BEST12.
CallCntP2        BEST12.
CallCntP1        BEST12.
CallCntAll       BEST12.
CallCntCardP2    BEST12.
CallCntCardP1    BEST12.
CallCntCardAll   BEST12.
Donor_Status     $CHAR1.
Donor_Status_Prev_Camp BEST12.
DemArea          $CHAR2.
Age              BEST12.
Gender           $CHAR1.
DemHomeOwner     $CHAR1.
AreaHomeValue    BEST12.
AreaMedIncome    BEST12.
;
RUN;

/* STATISTICS OF TRAIN-DATA */

PROC CONTENTS DATA= ASSIGN.TRAIN ;
PROC MEANS DATA= ASSIGN.TRAIN;
PROC MEANS DATA= ASSIGN.TRAIN NMISS N;
RUN;

/*************************************************************************************/
/*************************************************************************************/
/*************************************************************************************/

/* DATA PREPROCESSING */
/* < SETTING AGE AS 18 ABOVE > */
DATA ASSIGN.TRAIN;
SET ASSIGN.TRAIN;
IF Age > 0 AND Age < 18 THEN Age = 18;
IF Donor_status = 'A' then Donor_status = 0;
IF Donor_status = 'S' then Donor_status = 1;
IF Donor_status = 'N' then Donor_status = 2;
IF Donor_status = 'E' then Donor_status = 3;
IF Donor_status = 'F' then Donor_status = 4;
IF Donor_status = 'L' then Donor_status = 5;
IF Gender = "U" THEN Gender = 2;
IF Gender = "M" THEN Gender = 0;
IF Gender = "F" THEN Gender = 1;
IF DemHomeOwner = 'U' THEN DemHomeOwner = 0;
IF DemHomeOwner = 'H' THEN DemHomeOwner = 1;
RUN;


/* MEAN IMPUTATION VIF<=4 Use PROC STDIZE to replace missing values with mean */


PROC STDIZE DATA= ASSIGN.TRAIN OUT=ASSIGN.SITrain
REPONLY               
METHOD=MEAN;          /* MEAN */
VAR DONOR_D DONAvgCardP1 Age ;   
RUN;
PROC PRINT DATA=assign.sitrain;
RUN;

/* MULTICOLINEARITY */
/*< BY CHECKING VIF & COLLINEARITY >*/

PROC REG DATA=ASSIGN.SITRAIN;
MODEL Donor = Donor_D DonCntP1 DONCntAll 
DONCntCardP1 DONCntCardAll DONAvgLast DONAvgP1 DonAvgAll 
DONAvgCardP1 DONTimeLast DONTimeFirst CallCntP2 
CallCntP1 CallCntAll CallCntCardP2 CallCntCardP1 
CallCntCardAll Donor_Status_Prev_Camp Age AreaHomeValue 
AreaMedIncome/ tol vif collin;
RUN;

PROC REG DATA=ASSIGN.SITRAIN;
MODEL Donor = Donor_D DonCntP1 DONCntAll 
DONCntCardP1 DONCntCardAll DONAvgLast DONAvgP1 DonAvgAll 
DONAvgCardP1 DONTimeLast DONTimeFirst CallCntP2                 /* CallcntCardALl removed */
CallCntP1 CallCntAll CallCntCardP2 CallCntCardP1 
Donor_Status_Prev_Camp Age AreaHomeValue 
AreaMedIncome/ tol vif collin;
RUN;

PROC REG DATA=ASSIGN.SITRAIN;
MODEL Donor = Donor_D DonCntP1 DONCntAll 
DONCntCardP1 DONCntCardAll DONAvgLast DONAvgP1 DonAvgAll 
DONAvgCardP1 DONTimeLast DONTimeFirst CallCntP2                 /* CallCntAll removed */
CallCntP1 CallCntCardP2 CallCntCardP1 
Donor_Status_Prev_Camp Age AreaHomeValue 
AreaMedIncome/ tol vif collin;
RUN;

PROC REG DATA=ASSIGN.SITRAIN;
MODEL Donor = Donor_D DonCntP1 DONCntAll 
DONCntCardP1  DONAvgLast DONAvgP1 DonAvgAll 
DONAvgCardP1 DONTimeLast DONTimeFirst CallCntP2                 /* DONCntCardAll removed */
CallCntP1 CallCntCardP2 CallCntCardP1 
Donor_Status_Prev_Camp Age AreaHomeValue 
AreaMedIncome/ tol vif collin;
RUN;


PROC REG DATA=ASSIGN.SITRAIN;
MODEL Donor = Donor_D DonCntP1 DONCntAll 
DONCntCardP1  DONAvgLast DONAvgP1 DonAvgAll 
DONAvgCardP1 DONTimeLast DONTimeFirst CallCntP2                 /* DONCntCardAll removed */
CallCntCardP2 CallCntCardP1 
Donor_Status_Prev_Camp Age AreaHomeValue 
AreaMedIncome/ tol vif collin;
RUN;

PROC REG DATA=ASSIGN.SITRAIN;
MODEL Donor = Donor_D DonCntP1 DONCntAll 
DONCntCardP1  DONAvgLast  DonAvgAll 
DONAvgCardP1 DONTimeLast DONTimeFirst CallCntP2                 /* DONAvgP1 removed */
CallCntCardP2 CallCntCardP1 
Donor_Status_Prev_Camp Age AreaHomeValue 
AreaMedIncome/ tol vif collin;
RUN;

PROC REG DATA=ASSIGN.SITRAIN;
MODEL Donor = Donor_D  DONCntAll 
DONCntCardP1  DONAvgLast  DonAvgAll 
DONAvgCardP1 DONTimeLast DONTimeFirst CallCntP2                 /* DONCntP1 removed */
CallCntCardP2 CallCntCardP1 
Donor_Status_Prev_Camp Age AreaHomeValue 
AreaMedIncome/ tol vif collin;
RUN;

/* SPLITTING SITRAIN INTO "TRAIN" AND "VALIDATION" */

DATA TRAIN VALID;
SET ASSIGN.SITRAIN;
IF ranuni(7)<=0.7 THEN OUTPUT TRAIN ; ELSE OUTPUT VALID;
RUN; 

PROC FREQ DATA= Work.train;
RUN;

PROC FREQ DATA=work.valid;
RUN;


/* LOGISTIC REGRESSION MODEL FOR mean imputation and VIF <= 4 */

PROC LOGISTIC DATA= WORK.TRAIN OUTMODEL= work.LOGMODEL plots=all ;
CLASS Donor_Status Gender DemHomeOwner;
MODEL Donor(event='1') = Donor_D  DONCntAll 
DONCntCardP1  DONAvgLast  DonAvgAll 
DONAvgCardP1 DONTimeLast DONTimeFirst CallCntP2              
CallCntCardP2 CallCntCardP1 
Donor_Status_Prev_Camp Age AreaHomeValue 
AreaMedIncome/ OUTROC= ROC ;
ROC;; 
RUN;


/* < TAKING THE TRAINED MODEL ON VALID >*/
PROC LOGISTIC INMODEL= WORK.LOGMODEL ;
SCORE DATA = WORK.VALID OUT = WORK.PREDICTION ;
RUN; 


PROC FREQ DATA=WORK.PREDICTION;
        TABLE Donor*I_Donor / out=CellCounts;
        RUN;
    
PROC PRINT DATA=WORK.PREDICTION;
RUN;

/*************************************************************************************/
/*************************************************************************************/
/*************************************************************************************/

/* MEAN IMPUTATION VIF<=2  Use PROC STDIZE to replace missing values with mean */


PROC STDIZE DATA= ASSIGN.TRAIN OUT=ASSIGN.SITrain
REPONLY              
METHOD=MEAN;          /* MEAN */
VAR DONOR_D DONAvgCardP1 Age ;   
RUN;
PROC PRINT DATA=assign.sitrain;
RUN;


/* MULTICOLINEARITY */
/*< BY CHECKING VIF & COLLINEARITY >*/

PROC REG DATA=ASSIGN.SITRAIN;
MODEL Donor = Donor_D DonCntP1 DONCntAll 
DONCntCardP1 DONCntCardAll DONAvgLast DONAvgP1 DonAvgAll 
DONAvgCardP1 DONTimeLast DONTimeFirst CallCntP2 
CallCntP1 CallCntAll CallCntCardP2 CallCntCardP1 
CallCntCardAll Donor_Status_Prev_Camp Age AreaHomeValue 
AreaMedIncome/ tol vif collin;
RUN;

PROC REG DATA=ASSIGN.SITRAIN;
MODEL Donor = Donor_D DonCntP1 DONCntAll 
DONCntCardP1 DONCntCardAll DONAvgLast DONAvgP1 DonAvgAll 
DONAvgCardP1 DONTimeLast DONTimeFirst CallCntP2                 /* CallcntCardALl removed */
CallCntP1 CallCntAll CallCntCardP2 CallCntCardP1 
Donor_Status_Prev_Camp Age AreaHomeValue 
AreaMedIncome/ tol vif collin;
RUN;

PROC REG DATA=ASSIGN.SITRAIN;
MODEL Donor = Donor_D DonCntP1 DONCntAll 
DONCntCardP1 DONCntCardAll DONAvgLast DONAvgP1 DonAvgAll 
DONAvgCardP1 DONTimeLast DONTimeFirst CallCntP2                 /* CallCntAll removed */
CallCntP1 CallCntCardP2 CallCntCardP1 
Donor_Status_Prev_Camp Age AreaHomeValue 
AreaMedIncome/ tol vif collin;
RUN;

PROC REG DATA=ASSIGN.SITRAIN;
MODEL Donor = Donor_D DonCntP1 DONCntAll 
DONCntCardP1  DONAvgLast DONAvgP1 DonAvgAll 
DONAvgCardP1 DONTimeLast DONTimeFirst CallCntP2                 /* DONCntCardAll removed */
CallCntP1 CallCntCardP2 CallCntCardP1 
Donor_Status_Prev_Camp Age AreaHomeValue 
AreaMedIncome/ tol vif collin;
RUN;


PROC REG DATA=ASSIGN.SITRAIN;
MODEL Donor = Donor_D DonCntP1 DONCntAll 
DONCntCardP1  DONAvgLast DONAvgP1 DonAvgAll 
DONAvgCardP1 DONTimeLast DONTimeFirst CallCntP2                 /* DONCntCardAll removed */
CallCntCardP2 CallCntCardP1 
Donor_Status_Prev_Camp Age AreaHomeValue 
AreaMedIncome/ tol vif collin;
RUN;

PROC REG DATA=ASSIGN.SITRAIN;
MODEL Donor = Donor_D DonCntP1 DONCntAll 
DONCntCardP1  DONAvgLast  DonAvgAll 
DONAvgCardP1 DONTimeLast DONTimeFirst CallCntP2                 /* DONAvgP1 removed */
CallCntCardP2 CallCntCardP1 
Donor_Status_Prev_Camp Age AreaHomeValue 
AreaMedIncome/ tol vif collin;
RUN;

PROC REG DATA=ASSIGN.SITRAIN;
MODEL Donor = Donor_D  DONCntAll 
DONCntCardP1  DONAvgLast  DonAvgAll 
DONAvgCardP1 DONTimeLast DONTimeFirst CallCntP2                 /* DONCntP1 removed */
CallCntCardP2 CallCntCardP1 
Donor_Status_Prev_Camp Age AreaHomeValue 
AreaMedIncome/ tol vif collin;
RUN;

PROC REG DATA=ASSIGN.SITRAIN;
MODEL Donor = Donor_D DonCntP1 DONCntAll 
DONCntCardP1 DONCntCardAll DONAvgLast DONAvgP1 DonAvgAll 
DONAvgCardP1 DONTimeLast DONTimeFirst CallCntP2                 /* CallcntCardALl removed */
CallCntP1 CallCntAll CallCntCardP2 CallCntCardP1 
Donor_Status_Prev_Camp Age AreaHomeValue 
AreaMedIncome/ tol vif collin;
RUN;

PROC REG DATA=ASSIGN.SITRAIN;
MODEL Donor = Donor_D DonCntP1 DONCntAll 
DONCntCardP1 DONCntCardAll DONAvgLast DONAvgP1 DonAvgAll 
DONAvgCardP1 DONTimeLast DONTimeFirst CallCntP2                 /* CallCntAll removed */
CallCntP1 CallCntCardP2 CallCntCardP1 
Donor_Status_Prev_Camp Age AreaHomeValue 
AreaMedIncome/ tol vif collin;
RUN;

PROC REG DATA=ASSIGN.SITRAIN;
MODEL Donor = Donor_D DonCntP1 DONCntAll 
DONCntCardP1  DONAvgLast DONAvgP1 DonAvgAll 
DONAvgCardP1 DONTimeLast DONTimeFirst CallCntP2                 /* DONCntCardAll removed */
CallCntP1 CallCntCardP2 CallCntCardP1 
Donor_Status_Prev_Camp Age AreaHomeValue 
AreaMedIncome/ tol vif collin;
RUN;


PROC REG DATA=ASSIGN.SITRAIN;
MODEL Donor = Donor_D DonCntP1 DONCntAll 
DONCntCardP1  DONAvgLast DONAvgP1 DonAvgAll 
DONAvgCardP1 DONTimeLast DONTimeFirst CallCntP2                 /* DONCntCardAll removed */
CallCntCardP2 CallCntCardP1 
Donor_Status_Prev_Camp Age AreaHomeValue 
AreaMedIncome/ tol vif collin;
RUN;

PROC REG DATA=ASSIGN.SITRAIN;
MODEL Donor = Donor_D DonCntP1 DONCntAll 
DONCntCardP1  DONAvgLast  DonAvgAll 
DONAvgCardP1 DONTimeLast DONTimeFirst CallCntP2                 /* DONAvgP1 removed */
CallCntCardP2 CallCntCardP1 
Donor_Status_Prev_Camp Age AreaHomeValue 
AreaMedIncome/ tol vif collin;
RUN;

PROC REG DATA=ASSIGN.SITRAIN;
MODEL Donor = Donor_D  DONCntCardP1  DONAvgLast  DonAvgAll 
DONAvgCardP1 DONTimeLast DONTimeFirst CallCntP2                 /* DONCntAll removed */
CallCntCardP2 CallCntCardP1 
Donor_Status_Prev_Camp Age AreaHomeValue 
AreaMedIncome/ tol vif collin;
RUN;

PROC REG DATA=ASSIGN.SITRAIN;
MODEL Donor = Donor_D  DONCntCardP1   DonAvgAll 
DONAvgCardP1 DONTimeLast DONTimeFirst CallCntP2                 /* DONAvgLast CallCntCardP1  removed */
CallCntCardP2 
Donor_Status_Prev_Camp Age AreaHomeValue 
AreaMedIncome/ tol vif collin;
RUN;


/* SPLITTING SITRAIN INTO "TRAIN" AND "VALIDATION" */

DATA TRAIN VALID;
SET ASSIGN.SITRAIN;
IF ranuni(7)<=0.8 THEN OUTPUT TRAIN; ELSE OUTPUT VALID;
RUN; 

PROC FREQ DATA= Work.train;
RUN;

PROC FREQ DATA=work.valid;
RUN;


/* LOGISTIC REGRESSION MODEL FOR mean imputation and VIF =< 2 */

PROC LOGISTIC DATA= WORK.TRAIN OUTMODEL= LOGMODEL PLOTS=ALL;
CLASS Donor_Status Gender DemHomeOwner;
MODEL Donor(event="1") = Donor_D  DONCntCardP1   DonAvgAll 
DONAvgCardP1 DONTimeLast DONTimeFirst CallCntP2                 
CallCntCardP2 
Donor_Status_Prev_Camp Age AreaHomeValue 
AreaMedIncome;
RUN;

PROC PRINT DATA=work.logmodel;
RUN;

/* < TAKING THE TRAINED MODEL ON VALID >*/
PROC LOGISTIC INMODEL= WORK.LOGMODEL ;
SCORE DATA = WORK.VALID OUT = WORK.PREDICTION ;
RUN; 


PROC FREQ DATA=WORK.PREDICTION;
        TABLE Donor*I_Donor / out=CellCounts;
        RUN;
    
PROC PRINT DATA=WORK.PREDICTION;
RUN;

/*************************************************************************************/
/*************************************************************************************/
/*************************************************************************************/


/* MIDRANGE IMPUTATION  Use PROC STDIZE to replace missing values with mean */


PROC STDIZE DATA= ASSIGN.TRAIN OUT=ASSIGN.SITrain
REPONLY               
METHOD=MIDRANGE;          /*  MIDRANGE */
VAR DONOR_D DONAvgCardP1 Age ;   
RUN;
PROC PRINT DATA=assign.sitrain;
RUN;

/* MULTICOLINEARITY */
/*< BY CHECKING VIF & COLLINEARITY >*/

PROC REG DATA=ASSIGN.SITRAIN;
MODEL Donor = Donor_D DonCntP1 DONCntAll 
DONCntCardP1 DONCntCardAll DONAvgLast DONAvgP1 DonAvgAll 
DONAvgCardP1 DONTimeLast DONTimeFirst CallCntP2 
CallCntP1 CallCntAll CallCntCardP2 CallCntCardP1 
CallCntCardAll Donor_Status_Prev_Camp Age AreaHomeValue 
AreaMedIncome/ tol vif collin;
RUN;

PROC REG DATA=ASSIGN.SITRAIN;
MODEL Donor = Donor_D DonCntP1 DONCntAll 
DONCntCardP1 DONCntCardAll DONAvgLast DONAvgP1 DonAvgAll 
DONAvgCardP1 DONTimeLast DONTimeFirst CallCntP2                 /* CallcntCardALl removed */
CallCntP1 CallCntAll CallCntCardP2 CallCntCardP1 
Donor_Status_Prev_Camp Age AreaHomeValue 
AreaMedIncome/ tol vif collin;
RUN;

PROC REG DATA=ASSIGN.SITRAIN;
MODEL Donor = Donor_D DonCntP1 DONCntAll 
DONCntCardP1 DONCntCardAll DONAvgLast DONAvgP1 DonAvgAll 
DONAvgCardP1 DONTimeLast DONTimeFirst CallCntP2                 /* CallCntAll removed */
CallCntP1 CallCntCardP2 CallCntCardP1 
Donor_Status_Prev_Camp Age AreaHomeValue 
AreaMedIncome/ tol vif collin;
RUN;

PROC REG DATA=ASSIGN.SITRAIN;
MODEL Donor = Donor_D DonCntP1 DONCntAll 
DONCntCardP1  DONAvgLast DONAvgP1 DonAvgAll 
DONAvgCardP1 DONTimeLast DONTimeFirst CallCntP2                 /* DONCntCardAll removed */
CallCntP1 CallCntCardP2 CallCntCardP1 
Donor_Status_Prev_Camp Age AreaHomeValue 
AreaMedIncome/ tol vif collin;
RUN;


PROC REG DATA=ASSIGN.SITRAIN;
MODEL Donor = Donor_D DonCntP1 DONCntAll 
DONCntCardP1  DONAvgLast DONAvgP1 DonAvgAll 
DONAvgCardP1 DONTimeLast DONTimeFirst CallCntP2                 /* DONCntCardAll removed */
CallCntCardP2 CallCntCardP1 
Donor_Status_Prev_Camp Age AreaHomeValue 
AreaMedIncome/ tol vif collin;
RUN;

PROC REG DATA=ASSIGN.SITRAIN;
MODEL Donor = Donor_D DonCntP1 DONCntAll 
DONCntCardP1  DONAvgLast  DonAvgAll 
DONAvgCardP1 DONTimeLast DONTimeFirst CallCntP2                 /* DONAvgP1 removed */
CallCntCardP2 CallCntCardP1 
Donor_Status_Prev_Camp Age AreaHomeValue 
AreaMedIncome/ tol vif collin;
RUN;

PROC REG DATA=ASSIGN.SITRAIN;
MODEL Donor = Donor_D  DONCntAll 
DONCntCardP1  DONAvgLast  DonAvgAll 
DONAvgCardP1 DONTimeLast DONTimeFirst CallCntP2                 /* DONCntP1 removed */
CallCntCardP2 CallCntCardP1 
Donor_Status_Prev_Camp Age AreaHomeValue 
AreaMedIncome/ tol vif collin;
RUN;

PROC REG DATA=ASSIGN.SITRAIN;
MODEL Donor = Donor_D DonCntP1 DONCntAll 
DONCntCardP1 DONCntCardAll DONAvgLast DONAvgP1 DonAvgAll 
DONAvgCardP1 DONTimeLast DONTimeFirst CallCntP2                 /* CallcntCardALl removed */
CallCntP1 CallCntAll CallCntCardP2 CallCntCardP1 
Donor_Status_Prev_Camp Age AreaHomeValue 
AreaMedIncome/ tol vif collin;
RUN;

PROC REG DATA=ASSIGN.SITRAIN;
MODEL Donor = Donor_D DonCntP1 DONCntAll 
DONCntCardP1 DONCntCardAll DONAvgLast DONAvgP1 DonAvgAll 
DONAvgCardP1 DONTimeLast DONTimeFirst CallCntP2                 /* CallCntAll removed */
CallCntP1 CallCntCardP2 CallCntCardP1 
Donor_Status_Prev_Camp Age AreaHomeValue 
AreaMedIncome/ tol vif collin;
RUN;

PROC REG DATA=ASSIGN.SITRAIN;
MODEL Donor = Donor_D DonCntP1 DONCntAll 
DONCntCardP1  DONAvgLast DONAvgP1 DonAvgAll 
DONAvgCardP1 DONTimeLast DONTimeFirst CallCntP2                 /* DONCntCardAll removed */
CallCntP1 CallCntCardP2 CallCntCardP1 
Donor_Status_Prev_Camp Age AreaHomeValue 
AreaMedIncome/ tol vif collin;
RUN;


PROC REG DATA=ASSIGN.SITRAIN;
MODEL Donor = Donor_D DonCntP1 DONCntAll 
DONCntCardP1  DONAvgLast DONAvgP1 DonAvgAll 
DONAvgCardP1 DONTimeLast DONTimeFirst CallCntP2                 /* DONCntCardAll removed */
CallCntCardP2 CallCntCardP1 
Donor_Status_Prev_Camp Age AreaHomeValue 
AreaMedIncome/ tol vif collin;
RUN;

PROC REG DATA=ASSIGN.SITRAIN;
MODEL Donor = Donor_D DonCntP1 DONCntAll 
DONCntCardP1  DONAvgLast  DonAvgAll 
DONAvgCardP1 DONTimeLast DONTimeFirst CallCntP2                 /* DONAvgP1 removed */
CallCntCardP2 CallCntCardP1 
Donor_Status_Prev_Camp Age AreaHomeValue 
AreaMedIncome/ tol vif collin;
RUN;

PROC REG DATA=ASSIGN.SITRAIN;
MODEL Donor = Donor_D  DONCntCardP1  DONAvgLast  DonAvgAll 
DONAvgCardP1 DONTimeLast DONTimeFirst CallCntP2                 /* DONCntAll removed */
CallCntCardP2 CallCntCardP1 
Donor_Status_Prev_Camp Age AreaHomeValue 
AreaMedIncome/ tol vif collin;
RUN;

PROC REG DATA=ASSIGN.SITRAIN;
MODEL Donor = Donor_D  DONCntCardP1   DonAvgAll 
DONAvgCardP1 DONTimeLast DONTimeFirst CallCntP2                 /* DONAvgLast CallCntCardP1  removed */
CallCntCardP2 
Donor_Status_Prev_Camp Age AreaHomeValue 
AreaMedIncome/ tol vif collin;
RUN;


/* SPLITTING SITRAIN INTO "TRAIN" AND "VALIDATION" */

DATA TRAIN VALID;
SET ASSIGN.SITRAIN;
IF ranuni(7)<=0.7 THEN OUTPUT TRAIN; ELSE OUTPUT VALID;
RUN; 

PROC FREQ DATA= Work.train;
RUN;

PROC FREQ DATA=work.valid;
RUN;


/* LOGISTIC REGRESSION MODEL FOR MIDRANGE IMPUTATION WITH VIF =< 2 */

PROC LOGISTIC DATA= WORK.TRAIN OUTMODEL= LOGMODEL PLOTS=ALL;
CLASS Donor_Status Gender DemHomeOwner;
MODEL Donor(event="1") = Donor_D  DONCntCardP1   DonAvgAll 
DONAvgCardP1 DONTimeLast DONTimeFirst CallCntP2                 
CallCntCardP2 
Donor_Status_Prev_Camp Age AreaHomeValue 
AreaMedIncome;
RUN;

PROC PRINT DATA=work.logmodel;
RUN;

/* < TAKING THE TRAINED MODEL ON VALID >*/
PROC LOGISTIC INMODEL= WORK.LOGMODEL ;
SCORE DATA = WORK.VALID OUT = WORK.PREDICTION ;
RUN; 

PROC FREQ DATA=WORK.PREDICTION;
        TABLE Donor*I_Donor / out=CellCounts;
        RUN;
    
PROC PRINT DATA=WORK.PREDICTION;
RUN;

/*************************************************************************************/
/*************************************************************************************/
/*************************************************************************************/

/* MULTIPLE IMPUTATION */
/* STEP1 IMPUTATION  */
PROC MI DATA=ASSIGN.TRAIN nimpute=10 out=MULTIIMP seed=123;
VAR Donor Donor_D DonCntP1 DONCntAll 
DONCntCardP1  DONAvgLast  DonAvgAll 
DONAvgCardP1 DONTimeLast DONTimeFirst CallCntP2                 
CallCntCardP2 CallCntCardP1 
Donor_Status_Prev_Camp Age AreaHomeValue 
AreaMedIncome;
RUN;
 
PROC MEANS DATA = WORK.MULTIIMP n nmiss mean;
RUN;

/* STEP 2 ANALYSIS  */
proc logistic DATA = WORK.MULTIIMP ;
CLASS Donor_Status Gender DemHomeOwner;
MODEL Donor(event='1') = Donor_D  DONCntCardP1   DonAvgAll 
DONAvgCardP1 DONTimeLast DONTimeFirst CallCntP2                 
CallCntCardP2 
Donor_Status_Prev_Camp Age AreaHomeValue 
AreaMedIncome;
by _imputation_;
ods output ParameterEstimates=WORK.PARAM;
RUN;
 
 /* STEP 3 POOLING */
proc mianalyze parms=WORK.param;
modeleffects  Donor_D  DONCntCardP1   DonAvgAll 
DONAvgCardP1 DONTimeLast DONTimeFirst CallCntP2                 
CallCntCardP2 Age AreaHomeValue 
AreaMedIncome;
RUN;

/*extract DATAset*/
DATA WORK.MULTIIMP_1;
SET WORK.MULTIIMP;
WHERE _Imputation_ = 1;
RUN;

DATA WORK.MULTIIMP_2;
SET WORK.MULTIIMP;
WHERE _Imputation_ = 2;
RUN;

DATA WORK.MULTIIMP_3;
SET WORK.MULTIIMP;
WHERE _Imputation_ = 3;
RUN;

DATA WORK.MULTIIMP_4;
SET WORK.MULTIIMP;
WHERE _Imputation_ = 4;
RUN;

DATA WORK.MULTIIMP_4;
SET WORK.MULTIIMP;
WHERE _Imputation_ = 5;
RUN;

/*EXTRACT DATASET 6*/
DATA WORK.MULTIIMP_6;
SET WORK.MULTIIMP;
WHERE _Imputation_ = 6;
RUN;

DATA WORK.MULTIIMP_7;
SET WORK.MULTIIMP;
WHERE _Imputation_ = 7;
RUN;

DATA WORK.MULTIIMP_8;
SET WORK.MULTIIMP;
WHERE _Imputation_ = 8;
RUN;

DATA WORK.MULTIIMP_9;
SET WORK.MULTIIMP;
WHERE _Imputation_ = 9;
RUN;

DATA WORK.MULTIIMP_10;
SET WORK.MULTIIMP;
WHERE _Imputation_ = 10;
RUN;

/* SPLITTING MULTIIMP */ 
DATA TRAIN VALID;
SET WORK.MULTIIMP_6;
IF ranuni(7)<=0.7 THEN OUTPUT TRAIN; ELSE OUTPUT VALID;
RUN;

/* MULTIPLE IMPUTATION MODEL */ 
PROC LOGISTIC DATA= WORK.TRAIN OUTMODEL= LOGMODEL PLOTS=ALL;
CLASS Donor_Status Gender DemHomeOwner;
MODEL Donor(event='1') = Donor_D  DONCntCardP1   DonAvgAll 
DONAvgCardP1 DONTimeLast DONTimeFirst CallCntP2                 
CallCntCardP2 
Donor_Status_Prev_Camp Age AreaHomeValue 
AreaMedIncome;
RUN;

/* TESTING THE MODEL ON VALIDATION DATA */
PROC LOGISTIC INMODEL= WORK.LOGMODEL ;
SCORE DATA = WORK.VALID OUT = WORK.PREDICTION ;
RUN;

PROC FREQ DATA=WORK.PREDICTION;
TABLE Donor*I_Donor / out=CellCounts;
RUN;

/**************  END ************************************************/
/**************  END ************************************************/
/**************  END ************************************************/
/**************  END ************************************************/