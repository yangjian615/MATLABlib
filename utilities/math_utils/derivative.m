function [dx_dt] = derivative(x, t)
    %
    % Calculate the derivative of x with respect to t
    %

    dt = diff(t);

    dx_dt = zeros(size(x(2:end,:)));
    dx_dt(:,1) = diff(x(:,1)) ./ dt;
    dx_dt(:,2) = diff(x(:,2)) ./ dt;
    dx_dt(:,3) = diff(x(:,3)) ./ dt;
end