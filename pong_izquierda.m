clear all; close all; clc;

global posx_ball;
global posy_ball;
global speed_ballx;
global speed_bally;
global width_axes;
global height_axes;
global size_ball;
global axis;
global posinitx_player
global posinity_player
global height_player
global base_player;
global datos_valor
global datos_bola_ia

%ancho y alto del escenario
width_axes = 35;
height_axes = 35;


%ejes
axis = axes;
axis.GridAlpha = 0.5;
axis.XLim = [0,width_axes];
axis.YLim = [0,height_axes];
axis.Color = 'black';
%visualizar gráfica de ejes
set (axis,'position',[0.1 0.1 0.8 0.8]);


%pelota
posx_ball = 15;
posy_ball = 20;
size_ball = 1.3;
curve_ball = 1;%0.1 sería sin curvas en las esquinas con forma rectangular 
% y 1 se aproxima más a un círculo con más curvas en las esquinas
ball = rectangle('position',[posx_ball posy_ball size_ball size_ball],'curvature',[curve_ball curve_ball],'FaceColor','w');

%jugador
posinitx_player = 5;
posinity_player = 15;
base_player = 1;
height_player = 7; 
ia_player = rectangle('position',[posinitx_player,posinity_player,base_player,height_player],'FaceColor','w');


speed_ballx = randi([-1,1],1);
speed_bally = randi([-1,1],1);
while speed_ballx == 0 || speed_bally == 0
    speed_ballx = randi([-1,1],1);
    speed_bally = randi([-1,1],1);
end

%Entrenamiento
k1 = 0;
valor = 1;
bolaValor = 0;
datos = 20000;
datos_bola_ia = zeros(4,datos);
datos_valor = zeros(2,datos);
while(true)
    if(bolaValor >posy_ball + (size_ball / 2))
        valor = -1;
        bolaValor = posy_ball + (size_ball / 2);
    end
        
    if(bolaValor < posy_ball + (size_ball / 2))
       valor = 1 ;
       bolaValor = posy_ball + (size_ball / 2);
    end
    k1 = k1+1;
    collision()
    collision_ia_player()
    move_ball()
    move_ia(k1,valor)

    set(ia_player,'position', [posinitx_player,posinity_player,base_player,height_player],'FaceColor','w' )
    set(ball,'position',[posx_ball posy_ball size_ball size_ball]);

    datos_bola_ia(1,k1) = posy_ball  + (size_ball / 2);
    datos_bola_ia(2,k1) = posinity_player + (height_player / 2);
    datos_bola_ia(3,k1) = speed_ballx;
    datos_bola_ia(4,k1) = speed_bally;
    if valor == -1
        datos_valor(1,k1) = 0;
    else
        datos_valor(1,k1) = 1;
    end

    pause(0.00002)

    if k1 == datos
        break
    end
end
net_izq = patternnet(5, "trainlm") 
net_izq.trainParam.goal = 0.05;
net_izq.trainParam.min_grad = 0;
net_izq.trainParam.max_fail = 25;
net_izq.trainParam.epochs = 1000;
net_izq = train(net_izq,datos_bola_ia, datos_valor );

%Usando la red neuronal
%Se resetea el estado del entorno a su estado inicial
posx_ball = 15;
posy_ball = 20;
posinitx_player = 5;
posinity_player = 15;
speed_ballx = randi([-1,1],1);
speed_bally = randi([-1,1],1);
while speed_ballx == 0 || speed_bally == 0
    speed_ballx = randi([-1,1],1);
    speed_bally = randi([-1,1],1);
end
time = 0
valor = 0
set(ia_player,'position', [posinitx_player,posinity_player,base_player,height_player],'FaceColor','w' )
set(ball,'position',[posx_ball posy_ball size_ball size_ball]);

%Pong controlado por la red neuronal
while(time <= 1000)
    time = time+1;
    p_valor = sim(net_izq,[posy_ball + (size_ball / 2); posinity_player + (height_player / 2); speed_ballx; speed_bally]);
    p_valor = round(p_valor)
    if p_valor(1,1) == 1
        valor = 1
    elseif p_valor(1,1) == 0
        valor = -1
    end
    collision()
    collision_ia_player()
    move_ball()
    move_ia(k1,valor)

    set(ia_player,'position', [posinitx_player,posinity_player,base_player,height_player],'FaceColor','w' )
    set(ball,'position',[posx_ball posy_ball size_ball size_ball]);
    pause(0.2)
end

save("net_izq.mat", "net_izq");

function move_ball()
%aumenta la velocidad de la pelota en x e y en 1
    global posx_ball;
    global posy_ball;
    global speed_ballx;
    global speed_bally;

    posx_ball = posx_ball + speed_ballx;
    posy_ball = posy_ball + speed_bally;

end

function collision()
    global posx_ball;
    global posy_ball;
    global speed_ballx;
    global speed_bally;
    global width_axes;
    global height_axes;
    global size_ball;

    if(posy_ball+size_ball >= height_axes)
        speed_bally = speed_bally * -1;
    end

    if(posy_ball+size_ball <= 0)
        speed_bally = speed_bally * -1;
    end

    if(posx_ball+size_ball <= 0)
        speed_ballx = speed_ballx * -1;
    end

    if(posx_ball+size_ball >= width_axes)
        speed_ballx = speed_ballx * -1;
    end
   
end

function move_ia(k1,valor)
    %cargamos las variables globales
    global posinity_player;
    global y;
    global anchoEsc;
    global height_axes;
    global height_player;
    
    if(posinity_player <= 0 && valor < 0)
       valor = 0;
    %     y(:,k1) = [move_ia];
    else
        %si la posicion del jugador + la altura(se toma la altura por que la
        %posicion que el objeto retorno es una y es la de abajo es por ello que
        %se debe sumar la altura) es mayor que el alto del escenario y este
        %esta subiendo entonces no lo deja subir mas o superara el escenario
        if((posinity_player+height_player) >= height_axes && valor > 0)
    %         y(:,k1) = [move_ia];
            valor = 0;
        else
            %si ninguna de las condiciones anteriores es verdadera entonces se
            %dejara mover al jugador libremente
            posinity_player = posinity_player+valor;
    %         y(:,k1) = [move_ia];
            %se reinicia move_ia ya que sino ocacionara que este se siga
            %moviendo a lo largo del escenario
            valor = 0; 
            
        end
    end
    
end

function collision_ia_player()
    global posinity_player;
    global posinitx_player;
    global y;
    global anchoEsc;
    global height_axes;
    global height_player;
    global base_player;
    global posx_ball;
    global posy_ball;
    global speed_ballx;
    global speed_bally;
    global width_axes;
    global height_axes;
    global size_ball;
    
    if(posy_ball+size_ball>=posinity_player && (posinity_player+height_player)>=(posy_ball) &&...
       (posx_ball-size_ball) <= (posinitx_player) && (posx_ball+size_ball) >= (posinitx_player+base_player))
        angulo = (height_player)/3;
        speed_ballx = -speed_ballx;
        if((posy_ball+size_ball)>posinity_player && (posy_ball+size_ball)<posinity_player+angulo)
            speed_bally = -1;
        else
             if((posy_ball+size_ball)>posinity_player+angulo &&(posy_ball+size_ball)<posinity_player+angulo*2)
                speed_bally = 1;
             end
        end
   end
end