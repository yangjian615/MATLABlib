function [out] = test_optional_input(in)
    %
    % The input 'in' is optional. I want to see if I can call this function with an
    % undefined variable.
    %
    % The answer is no.
    %
    %    >> out = test_optional_input(qpdkjfa);
    %    Undefined function or variable 'qpdkjfa'.
    %
    % However,
    %
    %    >> a = zeros(0,1);
    %    >> isempty(a)
    %    
    %    ans =
    %    
    %         1
    %    
    %    >> out = test_optional_input(a)
    %
    %    out =
    %    
    %         4
    %
    out = 2 + 2;
end