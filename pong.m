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
global datos_bola;
global datos_ia;

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
posinitx_player = 30;
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

k1 = 0;
valor = 1;
bolaValor = 0;
datos = 100;%200000;
datos_bola = zeros(1,datos);
datos_ia = zeros(1,datos);
while(true)
    if(bolaValor >posy_ball)
        valor = -1;
        bolaValor = posy_ball;
    end
        
    if(bolaValor < posy_ball)
       valor = 1 ;
       bolaValor = posy_ball;
    end
    k1 = k1+1;
    collision()
    collision_ia_player()
    move_ball()
    move_ia(k1,valor)

    set(ia_player,'position', [posinitx_player,posinity_player,base_player,height_player],'FaceColor','w' )
    set(ball,'position',[posx_ball posy_ball size_ball size_ball]);

    datos_ia(:,k1) = posinity_player;
    datos_bola(:,k1) = posy_ball;
    pause(0.2)

    if k1 == datos
        break
    end
end
net = feedforwardnet(6) 
net.trainParam.goal = 0.00001;
net.trainParam.min_grad = 0;
net.trainParam.max_fail = 25;
net.trainParam.epochs = 1000;
net = train(net,datos_ia, datos_bola );
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
    
    if(posinity_player <= 0 && valor == -1)
       valor = 0;
    %     y(:,k1) = [move_ia];
    else
        %si la posicion del jugador + la altura(se toma la altura por que la
        %posicion que el objeto retorno es una y es la de abajo es por ello que
        %se debe sumar la altura) es mayor que el alto del escenario y este
        %esta subiendo entonces no lo deja subir mas o superara el escenario
        if((posinity_player+height_player) >= height_axes && valor == 1)
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
            angulo = (height_player)/3
            %aqui la condicion inicial if fue true entonces existe rebote
            speed_ballx = -speed_ballx;
            %aqui se especifica en cual de las 2 de las 3 diviciones toca para
            %asi variar el angulo de rebote
            if((posy_ball+size_ball)>posinity_player && (posy_ball+size_ball)<posinity_player+angulo)
                speed_bally = -1
            else
            %aqui se especifica en cual de las 2 de las 3 diviciones toca para
            %asi variar el angulo de rebote
                 if((posy_ball+size_ball)>posinity_player+angulo &&(posy_ball+size_ball)<posinity_player+angulo*2)
                    speed_bally = 1
                 end
            end
       end



end