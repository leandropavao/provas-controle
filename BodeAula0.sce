clc
clear

s=poly(0,"s");

//Definição de parâmetros
atraso=1.0;

//Definição da FT (sem o atraso)
//G=1.83*(1+1/(5.5*s)+(0.45*s)/(0.045*s+1))*(2/(5*s+1));
Kc=1.83;
taui=5.5;
taud=0.45;

G=Kc*(1+1/(taui*s)+taud*s/(0.1*taud*s+1))*2*0.25*4/(5*s+1);
Gsl=syslin('c',G);

//Definição das frequências para o gráfico em tempo^-1. 
fmin=0.01/(2*%pi);
fmax=10/(2*%pi);
step=0.01/(2*%pi);
frange=fmin:step:fmax;

[frq,repf]=repfreq(Gsl,frange);
[db,phi]=dbphi(repf);

[linhas,colunas]=size(db);
for i=1:colunas
    frq(i)=frq(i)*2*%pi;
    AR(i)=10^(db(1,i)/20);
    PA(i)=phi(1,i)-frq(i)*atraso*(180/%pi);
end

//Determinação de PM e GM
step = 0.001;
wcfound = 0;
wgfound = 0;
marginsfound = 0;

frqtest=0; //Frequência a ser testada.
while marginsfound == 0
    frqtest=frqtest+step/2*%pi; //Testamos valores de frequência somando um step em rad.
    
    if frqtest > fmax then //se frequência maior que frequência máxima, provavelmente não há wc
        marginsfound = 1; //encerrar para não entrar em loop infinito
    end
    
    //Calcular razão de amplitude e ângulo de fase para a freq. de teste
    [frq2,repf2]=repfreq(Gsl,frqtest);
    [db2,phi2]=dbphi(repf2);
    frq2=frq2*2*%pi;
    AR2=10^(db2/20);
    PA2=phi2-((180/%pi)*atraso*frq2);
    
    //Se phi cruzou -180 e wc ainda não havia sido encontrado;
    if PA2 < -180 && wcfound == 0 then
        ARc = AR2;
        PAc = PA2;
        wc = frq2;
        wcfound = 1; //wc já foi encontrado, portanto o programa não entrará novamente nesse if
    end
    //Se AR cruzou 1 e wg ainda não havia sido encontrado;
    if AR2 < 1 && wgfound == 0 then
        ARg = AR2;
        PAg = PA2;
        wg = frq2;
        wgfound = 1; //wg já foi encontrado, portanto o programa não entrará novamente nesse if 
    end
    
    //se wg e wc foram encontrados, podemos calcular as margens;
    if wgfound == 1 && wcfound == 1 then
        GM = 1/ARc;
        PM = 180+PAg;
        marginsfound = 1;
    end   
end


subplot(2,1,1);
plot('ll',frq',AR);
gca().sub_ticks = [8 8]; 
xlabel("Freq. (rad/tempo)");
ylabel("Razão de amplitudes");

subplot(2,1,2);
plot('ln',frq',PA);
gca().sub_ticks = [8 4];
xlabel("Freq. (rad/tempo)");
ylabel("Ângulo de fase (graus)");

