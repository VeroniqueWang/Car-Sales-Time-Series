data sales;
infile '/folders/myfolders/Final Project.txt' dlm='09'X firstobs=2;
input INDEX YEAR MONTH DATE AUTOSALE;
run;

* plot;
proc sgplot data=sales  pad=(bottom=15%);
series x=date y=autosale / markers;
run;

* Variable time;
data sales2;
set sales;
TIME=_n_;
run;

*Dummy variables with seasonal component;
data sales3;
set sales2;
month1 = 0;
if month = '1' then month1 = 1;
month2 = 0;
if month = '2' then month2 = 1;
month3 = 0;
if month = '3' then month3 = 1;
month4 = 0;
if month = '4' then month4 = 1;
month5 = 0;
if month = '5' then month5 = 1;
month6 = 0;
if month = '6' then month6 = 1;
month7 = 0;
if month = '7' then month7 = 1;
month8 = 0;
if month = '8' then month8 = 1;
month9 = 0;
if month = '9' then month9 = 1;
month10 = 0;
if month = '10' then month10 = 1;
month11 = 0;
if month = '11' then month11 = 1;
run;
* base level: month 12 (December)


*Timer series;
proc reg data=sales3 plots=none;
model autosale = time month1 month2 month3 month4 month5 month6 month7 month8 month9 month10 month11;
run;

*Check Assumptions;
proc reg data=sales3 plots(only)=(residualbypredicted residualplot qqplot 
  residualhistogram);
 model autosale = time month1 month2 month3 month4 month5 month6 month7 month8 month9 month10 month11;
run;

*Check autocorrelation (Durbin-Watson);
proc reg data=sales3 plots=none; 
model autosale = time month1 month2 month3 month4 month5 month6 month7 month8 month9 month10 month11 / dwprob;
run;

*Model with autogressive term (positive autocorrelation);
proc arima data=sales3 plots=none; 
identify var=autosale crosscor=(time month1 month2 month3 month4 month5 month6 month7 month8 month9 month10 month11) noprint;
estimate input=(time month1 month2 month3 month4 month5 month6 month7 month8 month9 month10 month11) p=(1);
run;

*Check Assumption;
proc arima data=sales3 plots(only)=(series(corr crosscorr) residual(hist normal smooth)); 
identify var=autosale crosscor=(time month1 month2 month3 month4 month5 month6 month7 month8 month9 month10 month11) noprint;
estimate input=(time month1 month2 month3 month4 month5 month6 month7 month8 month9 month10 month11) p=(1);
run;

*Transformation;
data sales4;
set sales3; 
sqrtautosale=sqrt(autosale);
lnautosale = log(autosale);
run;

*Check assumptions;
proc arima data=sales4 plots(only)=(series(corr crosscorr) residual(hist normal smooth)); 
identify var=sqrtautosale crosscor=(time month1 month2 month3 month4 month5 month6 month7 month8 month9 month10 month11) noprint;
estimate input=(time month1 month2 month3 month4 month5 month6 month7 month8 month9 month10 month11) p=(1);
run;

*forecasting;
proc arima data=sales4 plots(only)=forecast(forecast); 
identify var=sqrtautosale crosscor=(time month1 month2 month3 month4 month5 month6 month7 month8 month9 month10 month11) noprint;
estimate input=(time month1 month2 month3 month4 month5 month6 month7 month8 month9 month10 month11) p=(1);
forecast lead=12;
run;