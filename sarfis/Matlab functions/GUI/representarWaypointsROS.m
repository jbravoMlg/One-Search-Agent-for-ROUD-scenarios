function representarWaypointsROS()
% REPRESENTARWAYPOINTSROS Draw the ROS 2 published X/Y path
% on the active axes, ignoring altitudee (Z).

    ax = gca;
    hold(ax, 'on');

    % Crear nodo y suscriptor
    node = ros2node("/matlab_gui_node");
    sub = ros2subscriber(node, "/kml_path", "std_msgs/Float32MultiArray");

    disp('Waiting for waypoint message from /kml_path...');
    msg = receive(sub, 10);

    if isempty(msg)
        warning('No message received within 10 seconds.');
        return;
    end

    data = msg.data;

    if mod(length(data), 3) ~= 0
        error('Invalid message. Length is not a multiple of 3 (X, Y, Z).');
    end

    puntos = reshape(data, 3, []);  % points(1,:) = X, points(2,:) = Y, points(3,:) = Z

    % Dibujar solo en plano X-Y (UTM)
    plot(ax, puntos(1,:), puntos(2,:), 'r-', 'LineWidth', 2, ...
        'DisplayName', 'KML path');

    xlabel(ax, 'Este (m)');
    ylabel(ax, 'Norte (m)');
    title(ax, 'XY path (without altitude)');
    legend(ax, 'show');
    axis(ax, 'tight');
    grid(ax, 'on');

    disp(['Rendered ', num2str(size(puntos, 2)), ' points (X,Y).']);
end
