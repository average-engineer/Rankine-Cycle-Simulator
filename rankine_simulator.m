clear all
close all
clc

%inputs
%pressure at turbine entrance/boiler pressure in bars
p_1 = str2num(input('Enter the boiler pressure: ','s'));
%temperature at turbine entrance in deg Celcius
t_1 = str2num(input('Enter the turbine entrance temperature: ','s'));
%pressure at turbine exit/condenser pressure in bars
p_2 = str2num(input('Enter the condenser pressure: ','s'));

%saturation temperature at boiler pressure
t_sat = XSteam('tSat_p',p_1);

%decide whether turbine is superheated or saturated steam

if(t_sat==t_1) %steam at turbine entrance is saturated
    h_1 = XSteam('hV_p',p_1);
else 
    h_1 = XSteam('h_pt',p_1,t_1);
end

%entropy at turbine entrance
s_1 = XSteam('s_pt',p_1,t_1);

%since expansion in a steam turbine is an isentropic process
%entropy at turbine exit
s_2 = s_1;

%at turbine exit, steam is supposed to be wet steam
%saturated liquid entropy at 0.05 bars
sf_2 = XSteam('sL_p',p_2);

%saturated vapour entropy at 0.05 bars
sg_2 = XSteam('sV_p',p_2);

%dryness fraction of the wet steam at turbine exit
x_2 = (s_2 - sf_2)/(sg_2-sf_2);

%enthalpy of saturated steam at condenser pressure
h_g2 = XSteam('hV_p',p_2);
%enthalpy of saturated liquid at condenser pressure
h_f2 = XSteam('hL_p',p_2);

%enthalpy of mixed steam at turbine exit
h_2 = h_f2 + x_2*(h_g2 - h_f2);

%mixed steam after passing through the condenser becomes saturated liquid
%enthalpy of liquid at condenser exit
h_3 = XSteam('hL_p',p_2);

%Pump is an open system where the liquid pressure is increased and it
%becomes supercooled

%since the pump compartment volume remains constant, it is isochoric

%specific volume of saturated liquid at condenser pressure
vol_3 = XSteam('vL_p',p_2);

%work done by pump 
work_pump = vol_3*(p_1-p_2)*10^2;%flow work done by pump as it is an open system

%enthalpy of liquid at boiler entrance/pump exit
h_4 = h_3 + work_pump;

%work done by turbine
work_turbine = h_1-h_2;

%Net Work
work_net = work_turbine - work_pump;%work done by turbine is done by the system and the work done by the pump is done on the system

%back work ratio = work produced by turbine/work consumed by pump
back_work_ratio = work_turbine/work_pump;

%STATE 1 VARIABLES
%h_1
%s_1
%p_1
%t_1
fprintf('The state variables of state 1 are:\n')
fprintf('Enthalpy (kJ/kg) = %f\n',h_1)
fprintf('Entropy (kJ/kgK)= %f\n',s_1)
fprintf('Temperature (deg.C) = %f\n',t_1)
fprintf('Pressure (bars) = %f\n',p_1)

%STATE 2 VARIABLES
%h_2
%s_2
%p_2
t_2 = XSteam('t_ph',p_2,h_2);
fprintf('The state variables of state 2 are:\n')
fprintf('Enthalpy (kJ/kg) = %f\n',h_2)
fprintf('Entropy (kJ/kgK) = %f\n',s_2)
fprintf('Temperature (K) = %f\n',t_2)
fprintf('Pressure (bars) = %f\n',p_2)

%STATE 3 VARIABLES
%h_3
s_3 = XSteam('sL_p',p_2);
%p_2
t_3 = XSteam('t_ph',p_2,h_3);%ideallt t_3 = t_2
fprintf('The state variables of state 3 are:\n')
fprintf('Enthalpy (kJ/kg) = %f\n',h_3)
fprintf('Entropy (kJ/kgK) = %f\n',s_3)
fprintf('Temperature (K) = %f\n',t_3)
fprintf('Pressure (bars)= %f\n',p_2)

%STATE 4 VARIABLES
%h_4
s_4 = XSteam('s_ph',p_1,h_4);%ideally pump process is isentropic
%p_1
t_4 = XSteam('t_ph',p_1,h_4);
fprintf('The state variables of state 4 are:\n')
fprintf('Enthalpy (kJ/kg) = %f\n',h_4)
fprintf('Entropy (kJ/kgK) = %f\n',s_4)
fprintf('Temperature (K)= %f\n',t_4)
fprintf('Pressure (bars) = %f\n',p_1)

fprintf('Net work done by the cycle is: %f\n',work_net)
fprintf('Back work ratio of the cycle is: %f\n',back_work_ratio)

%intermediate stages in boiler
%economiser stage
h_5 = XSteam('hL_p',p_1);
s_5 = XSteam('sL_p',p_1);
t_5 = XSteam('t_ph',p_1,h_5);

%superheat stage
h_6 = XSteam('hV_p',p_1);
s_6 = XSteam('sV_p',p_1);
t_6 = XSteam('t_ph',p_1,h_6);

%plotting the saturation dome for T-S plot
T = [0:2:374];
svap = arrayfun(@(t) XSteam('sV_t',t),T);
sliq = arrayfun(@(t) XSteam('sL_t',t),T);

%plotting the saturation curve for H-S plot
P = [0:2:300];
sliq1 = arrayfun(@(p) XSteam('sL_p',p),P);
hliq = arrayfun(@(p,s) XSteam('h_ps',p,s),P,sliq1);
svap1 = arrayfun(@(p) XSteam('sV_p',p),P);
hvap = arrayfun(@(p,s) XSteam('h_ps',p,s),P,svap1);

%T-S Plot
figure(1)
hold on
plot([s_1 s_2],[t_1 t_2],s_2,t_2,'*','linewidth',3,'color','r')
plot([s_2 s_3],[t_2 t_3],s_3,t_3,'*','linewidth',3,'color','r')
plot([s_3 s_4],[t_3 t_4],s_4,t_4,'*','linewidth',3,'color','r')
plot([s_4 s_5],[t_4 t_5],s_5,t_5,'*','linewidth',3,'color','r')
plot([s_5 s_6],[t_5 t_6],s_6,t_6,'*','linewidth',3,'color','r')
plot([s_6 s_1],[t_6 t_1],s_1,t_1,'*','linewidth',3,'color','r')
plot(svap,T,'--')
plot(sliq,T,'--')
text(s_1,t_1,'1')
text(s_2,t_2,'2')
text(s_3,t_3,'3')
text(s_4,t_4,'4')
text(s_5,t_5,'5')
text(s_6,t_6,'6')
xlabel('Entropy (kJ/kgK)')
ylabel('Temperature (K)')
title('T-S Graph')

%H-S Plot
figure(2)
hold on
plot([s_1 s_2],[h_1 h_2],s_2,h_2,'*','linewidth',3,'color','r')
plot([s_2 s_3],[h_2 h_3],s_3,h_3,'*','linewidth',3,'color','r')
plot([s_3 s_4],[h_3 h_4],s_4,h_4,'*','linewidth',3,'color','b')
plot([s_4 s_5],[h_4 h_5],s_5,h_5,'*','linewidth',3,'color','r')
plot([s_5 s_6],[h_5 h_6],s_6,h_6,'*','linewidth',3,'color','r')
plot([s_6 s_1],[h_6 h_1],s_1,h_1,'*','linewidth',3,'color','r')
text(s_1,h_1,'1')
text(s_2,h_2,'2')
text(s_3,h_3,'3')
text(s_4,h_4,'4')
text(s_5,h_5,'5')
text(s_6,h_6,'6')
plot(svap1,hvap,'--')
plot(sliq1,hliq,'--')
xlabel('Entropy (kJ/kgK)')
ylabel('Enthalpy (kJ/kg)')
title('H-S Plot')












