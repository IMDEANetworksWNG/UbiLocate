function [Rss] = Smoothing_1D_faster(data,n_sensors, isFB)
    
    % number of sensors
    [N,~]=size(data);

    % number of groups of sensor
    p=N-n_sensors+1;
    
    % variable to save the correaltion matrix
    Rss=zeros(n_sensors,n_sensors);
    
    data_matrix = buffer(data,n_sensors,n_sensors-1);
    
    data_aux = data_matrix(:,n_sensors:end);
    
    R_aux = (data_aux*data_aux');
    
    % condition to check whether forward and backword is applied
    if (isFB)
        % exchange matrix
        J = flipud(eye(length(R_aux)));
        % estimate the backward matrix
        R_b = J*conj(R_aux)*J;

        % estimate the final correlation matrix
        Rss = Rss + (R_aux + R_b)/2;
    else
        % only forward
        Rss=Rss+R_aux;
    end

    Rss=Rss./p;
end
