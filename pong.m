global posx_ball;
global posy_ball;
global speed_ballx;
global speed_bally;
global width_axes;
global height_axes;
global size_ball;
global axis;


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


speed_ballx = 1;
speed_bally = 1;


while(true)
    collision()
    move_ball()

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


