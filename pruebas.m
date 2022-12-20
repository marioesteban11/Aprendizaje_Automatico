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

global posinitx_player_izq
global posinity_player_izq

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

%jugador_derecha
posinitx_player = 30;
posinity_player = 15;
base_player = 1;
height_player = 7; 
ia_player = rectangle('position',[posinitx_player,posinity_player,base_player,height_player],'FaceColor','w');

%jugador izquierda
posinitx_player_izq = 5;
posinity_player_izq = 15;
base_player = 1;
height_player = 7; 
ia_player_izq = rectangle('position',[posinitx_player_izq,posinity_player_izq,base_player,height_player],'FaceColor','y');


speed_ballx = randi([-1,1],1);
speed_bally = randi([-1,1],1);
while speed_ballx == 0 || speed_bally == 0
    speed_ballx = randi([-1,1],1);
    speed_bally = randi([-1,1],1);
end


load("net_der.mat");
load("net_izq.mat");

time = 0;
valor = 0;
p_valor = 0;
k1 = 0;
valor_izq = 0;
%Pong controlado por la red neuronal
while(time <= 1000)
    time = time+1;
    p_valor_der = sim(net_der,[posy_ball + (size_ball / 2); posinity_player + (height_player / 2); speed_ballx; speed_bally]);
    p_valor_izq = sim(net_izq,[posy_ball + (size_ball / 2); posinity_player_izq + (height_player / 2); speed_ballx; speed_bally]);
    p_valor_der = round(p_valor_der);
    p_valor_izq = round(p_valor_izq);
    if p_valor_der(1,1) == 1
        valor = 1;
    elseif p_valor_der(1,1) == 0
        valor = -1;
    end
    if p_valor_izq(1,1) == 1
        valor_izq = 1;
    elseif p_valor_izq(1,1) == 0
        valor_izq = -1;
    end
%     if p_valor_der(1,1) >= 0.5
%         valor = p_valor_der;
%     elseif p_valor_der(1,1) < 0.5
%         valor = -p_valor_der;
%     end
%     if p_valor_izq(1,1) >= 0.5
%         valor_izq = p_valor_izq;
%     elseif p_valor_izq(1,1) < 0.5
%         valor_izq = -p_valor_izq;
%     end
    collision()
    collision_ia_player()
    move_ball()
    move_ia(k1,valor)

    move_ia_left(k1,valor_izq);
    collision_ia_player_left()


    set(ia_player,'position', [posinitx_player,posinity_player,base_player,height_player],'FaceColor','w' )
    set(ia_player_izq,'position', [posinitx_player_izq,posinity_player_izq,base_player,height_player],'FaceColor','y' )
    set(ball,'position',[posx_ball posy_ball size_ball size_ball]);
    pause(0.2)
end



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
    global size_ball;
    global width_axes;
    global height_axes;
    global speed_ballx;
    global speed_bally;
    
    global puntos_humano;
    global puntos_IA;


    if((posx_ball+size_ball)>=(width_axes))
        speed_ballx = -speed_ballx;
        posx_ball = 10;
        posy_ball = 10;
        speed_ballx = 1;
        
    end
    if((posx_ball-size_ball)<0)
        speed_ballx = -speed_ballx;
        posx_ball = 10;
        posy_ball = 10;
        speed_ballx = 1;
    end
    if((posy_ball+size_ball)>=height_axes)
        speed_bally = -speed_bally;
        
    end
    if((posy_ball-size_ball)<0)
        speed_bally = -speed_bally;
        
    end
   
end

function move_ia(k1,valor)
    %cargamos las variables globales
    global posinity_player;
    global posinity_player_izq;
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
           (posx_ball+size_ball) >= (posinitx_player) && (posx_ball+size_ball) <= (posinitx_player+base_player))
            %aqui se divide en 3 el area y que ocupa el jugador con la finalidad 
            %de saber en cual de los 3 lugares toco la pelota logrando asi que 
            %la pelota no solo rebote en un lugar como se vera luego -> angulo
            %tendra el equivalente de cada division del alto
            angulo = (height_player)/3;
            %aqui la condicion inicial if fue true entonces existe rebote
            speed_ballx = -speed_ballx;
            %aqui se especifica en cual de las 2 de las 3 diviciones toca para
            %asi variar el angulo de rebote
            if((posy_ball+size_ball)>posinity_player && (posy_ball+size_ball)<posinity_player+angulo)
                r = rand([1 1])
                speed_bally = -1;
            else
            %aqui se especifica en cual de las 2 de las 3 diviciones toca para
            %asi variar el angulo de rebote
                 if((posy_ball+size_ball)>posinity_player+angulo &&(posy_ball+size_ball)<posinity_player+angulo*2)
                     r = rand([1 1])
                    speed_bally = 1;
                 end
            end
    end
end



function move_ia_left(k1,valor)
    %cargamos las variables globales
    global posinity_player_izq;
    global y;
    global anchoEsc;
    global height_axes;
    global height_player;
    if(posinity_player_izq <= 0 && valor < 0)
       valor = 0;
    %     y(:,k1) = [move_ia];
    else
        %si la posicion del jugador + la altura(se toma la altura por que la
        %posicion que el objeto retorno es una y es la de abajo es por ello que
        %se debe sumar la altura) es mayor que el alto del escenario y este
        %esta subiendo entonces no lo deja subir mas o superara el escenario
        if((posinity_player_izq+height_player) >= height_axes && valor > 0)
    %         y(:,k1) = [move_ia];
            valor = 0;
        else
            %si ninguna de las condiciones anteriores es verdadera entonces se
            %dejara mover al jugador libremente
            posinity_player_izq = posinity_player_izq+valor;
    %         y(:,k1) = [move_ia];
            %se reinicia move_ia ya que sino ocacionara que este se siga
            %moviendo a lo largo del escenario
            valor = 0; 
            
        end
    end
    
end

function collision_ia_player_left()
    global posinity_player_izq;
    global posinitx_player_izq;
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
    
    if(posy_ball+size_ball>=posinity_player_izq && (posinity_player_izq+height_player)>=(posy_ball) &&...
       (posx_ball-size_ball) <= (posinitx_player_izq) && (posx_ball+size_ball) >= (posinitx_player_izq+base_player))
        angulo = (height_player)/3
        speed_ballx = -speed_ballx;
        if((posy_ball+size_ball)>posinity_player_izq && (posy_ball+size_ball)<posinity_player_izq+angulo)
            r = rand([1 1]);
            speed_bally = -1;
        else
             if((posy_ball+size_ball)>posinity_player_izq+angulo &&(posy_ball+size_ball)<posinity_player_izq+angulo*2)
                 r = rand([1 1]);
                speed_bally = 1;
             end
        end
   end
end

