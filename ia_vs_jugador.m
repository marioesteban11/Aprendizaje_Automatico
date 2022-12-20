a = figure('KeyPressFcn',@interrupcion,'name','meausered_data','position',[200,50,600,600]);%% xi y xf 
a.Color = [0 0 0];


puntaje = uicontrol(a,'Style','text',...
    'String','Select a data set.',...
    'Position',[240 560 130 30]);
puntaje.String = 'Humano = 0 - Maquina = 0';


global posx_ball;
global posy_ball;
global size_ball;
global ball;
global speed_ballx;
global speed_bally;
global width_axes;
global height_axes;

global ia_player;
global anchoPlayerR;
global altoPlayerR;

global posinitx_player;
global posinity_player;
global vel_pala_der;
global base_player;
global height_player;

%player 2
global ia_player_izq;
global anchoPlayerL;
global altoPlayerL;

global posinitx_player_izq;
global posinity_player_izq;
global vel_pala_izq;
global base_player;
global height_player;

global puntos_humano;
global puntos_IA;


global y;


width_axes = 35;
height_axes = 35;

anchoPlayerR = 0.5;
altoPlayerR = 0.5;
anchoPlayerL = 0.5;
altoPlayerL = 0.5;

posx_ball = 15;
posy_ball = 20;
size_ball = 1.3;



%player 1
posinitx_player = 33;
posinity_player = 15;
vel_pala_der = 0;
base_player = 1;
height_player = 7;
puntos_humano = 0;

%player 2
posinitx_player_izq = 2;
posinity_player_izq = height_axes/2;
vel_pala_izq = 0;
puntos_IA = 0;

global axis;
axis = axes;
axis.GridAlpha = 0.5;
axis.XLim = [0,width_axes];
axis.YLim = [0,height_axes];
axis.Color = 'black';
%visualizar gráfica de ejes
set (axis,'position',[0.1 0.1 0.8 0.8]);

%set (axis,'position',[0.135 0.18 0.7 0.7])
rectangle('position',[0 0 width_axes height_axes],'FaceColor','w');
grid on


matriz = zeros

ball = rectangle('position',[posx_ball posy_ball size_ball size_ball],'curvature',[1 1],'FaceColor','w');
ia_player = rectangle('position',[posinitx_player,posinity_player,base_player,height_player],'FaceColor','b');
ia_player_izq = rectangle('position',[posinitx_player_izq,posinity_player_izq,base_player,height_player],'FaceColor','r');

speed_ballx = 1;
speed_bally = 1;
x = zeros(2,500);
y = zeros(1,500);
k1 = 0;
valor = 0;

load("net_der.mat")
while(true) 
 
    collision_ia_player();
    set(ia_player,'position',[posinitx_player,posinity_player,base_player,height_player]);
    collision_ia_player_izq();
    set(ia_player_izq,'position',[posinitx_player_izq,posinity_player_izq,base_player,height_player]);
    collision();
    moveBall();
    set(ball,'position',[posx_ball posy_ball size_ball size_ball]);
    
    p_valor_der = sim(net_der,[posy_ball + (size_ball / 2); posinity_player + (height_player / 2); speed_ballx; speed_bally]);
    p_valor_der = round(p_valor_der);
    if p_valor_der(1,1) == 1
        valor = 1;
    elseif p_valor_der(1,1) == 0
        valor = -1;
    end


    move_ia(k1, valor);
    move_human();
    pause(0.1);
   
    puntaje.String = strcat('Humano =  ',num2str(puntos_humano),' - ',...
    ' Maquina  =  ', num2str(puntos_IA));
    
end

function collision_ia_player_izq()
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


function collision_ia_player()
    global posinitx_player;
    global posinity_player;
    global vel_pala_der;
    global base_player;
    global height_player;
    global speed_ballx;
    global speed_bally;
    global posy_ball;
    global posx_ball;
    global size_ball;
        
       if(posy_ball+size_ball>=posinity_player && (posinity_player+height_player)>=(posy_ball) &&...
           (posx_ball+size_ball) >= (posinitx_player) && (posx_ball-size_ball) <= (posinitx_player+base_player))
            angulo = (height_player)/3
            speed_ballx = -speed_ballx;
            if((posy_ball+size_ball)>posinity_player && (posy_ball+size_ball)<posinity_player+angulo)
                speed_bally = -1
            else
                 if((posy_ball+size_ball)>posinity_player+angulo &&(posy_ball+size_ball)<posinity_player+angulo*2)
                    speed_bally = 1
                 end
            end
       end
end
            

function move_human()
    global posinity_player_izq;
    global vel_pala_izq;
    global height_player;
    global height_axes;
    global y;
    
    if((posinity_player_izq) <= 0 && vel_pala_izq == -1)
       vel_pala_izq = 0;
    else
        if((posinity_player_izq+height_player) >= height_axes && vel_pala_izq == 1)
            vel_pala_izq = 0;
        else
            posinity_player_izq = posinity_player_izq+vel_pala_izq;
            vel_pala_izq = 0; 
            
        end
    end
end


function move_ia(k1, valor)
    global posinity_player;
    global vel_pala_der;
    global height_player;
    global height_axes;
    global y;
    
    if((posinity_player) <= 0 && valor == -1)
       valor = 0;
    else
        if((posinity_player+height_player) >= height_axes && valor == 1)
            valor = 0;
        else
            posinity_player = posinity_player+valor;
            valor = 0
            vel_pala_der = 0; 
            
        end
    end
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
        puntos_humano = puntos_humano+1;
        posx_ball = 10;
        posy_ball = 10;
        speed_ballx = 1;
        
    end
    if((posx_ball-size_ball)<0)
        speed_ballx = -speed_ballx;
        puntos_IA = puntos_IA+1;
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

function moveBall()
    global posx_ball;
    global posy_ball;
    global speed_ballx;
    global speed_bally;    

    posx_ball = posx_ball+speed_ballx;
    posy_ball = posy_ball+speed_bally;
    
end

function interrupcion(splooge,event)
    global vel_pala_izq
    %arriba 38 
    %abajo 40
    %izquierda 37
    %deerecha 39
    switch event.Character
      case 28
            
      case 30
            vel_pala_izq = 1;
      case 29 	
            
      case 31
            vel_pala_izq = -1
    end 
 end