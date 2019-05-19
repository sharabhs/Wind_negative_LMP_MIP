set years /1*1/;
set days /1*1/;
set blocks /1*30/;


scalar Bigm /1000/;
parameter LMP(years,days,blocks);
parameter ChargeRate,DischargeRate;
parameter WindGen(years,days,blocks);
WindGen(years,days,blocks) = normal(2000,200);
positive variable SOC;
LMP(years,days,blocks) = uniform(-100,500);
Binary variable CharStat(years,days,blocks) for denoting the status of charging or discharging for the battery ;
scalar Rating Rating of the wind farm in kW /5000/;

positive variable Charging(years,days,blocks),Discharging(years,days,blocks);
positive variable battery;
positive variable waste(years,days,blocks);
positive variable WGen(years,days,blocks);
positive variable sell(years,days,blocks);
variable Revenue;
positive variable Energyinbatt(years,days,blocks);
sell.up(years,days,blocks) = 2000;
battery.up = 1500;
*waste.fx(years,days,blocks) = 0;
Energyinbatt.l(years,days,blocks) = 0;

Equation PowBalanceEQ(years,days,blocks);           PowBalanceEQ(years,days,blocks)..  WGen(years,days,blocks)+Discharging(years,days,blocks)=E=Sell(years,days,blocks)+Charging(years,days,blocks)+Waste(years,days,blocks);
Equation WgenEQ;                                    WgenEQ(years,days,blocks)..        WGen(years,days,blocks)=E=WindGen(years,days,blocks);
Equation ChXorDis(years,days,blocks);               ChXorDis(years,days,blocks)..  Discharging(years,days,blocks)=L=(1-CharStat(years,days,blocks))*BigM;
Equation SocEQ(years,days,blocks);                  SocEQ(years,days,blocks)$(ord(blocks) ge 1)..  Energyinbatt(years,days,blocks)=E=Energyinbatt(years,days,blocks-1)+((Charging(years,days,blocks)-Discharging(years,days,blocks))*0.25);
Equation RevenueEQ;                                 RevenueEQ..  Revenue=E=sum((years,days,blocks),LMP(years,days,blocks)*(Sell(years,days,blocks)*0.25));
Equation BatteryLimit(years,days,blocks);           BatteryLimit(years,days,blocks)..  Energyinbatt(years,days,blocks)=L=Battery;
Equation ChXorDisEQ(years,days,blocks);             ChXorDisEQ(years,days,blocks)..  Charging(years,days,blocks)=L=CharStat(years,days,blocks)*BigM



model WindFarmRevenuemax /all/;
solve WindFarmRevenuemax maximizing Revenue using MIP;
option MINLP = SCIP;
Option LP = OSICPLEX;
option NLP = SCIP;
option MIP = OSICPLEX;
option optcr = 0;
option optca = 0;

execute_unload 'solutiongdx.gdx';

display battery.l;
display CharStat.l;
display Energyinbatt.l;
display Revenue.l;
display LMP;
display sell.l;
display waste.l;
display charging.l;
display discharging.l;
display Wgen.l;


