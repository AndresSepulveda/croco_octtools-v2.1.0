function [time_unit_att, time_second_unit_att, calendar_att] = ...
    oct_get_time_attributes(Yorig) ;

    % GET_TIME_ATTRIBUTES Get time and calendar attributes for CROCO NetCDF files
    %
    % Inputs:
    %   Yorig - Reference year (optional) for time origin
    %
    % Outputs:
    %   time_unit_att - Time unit attribute string
    %   calendar_att  - Calendar type attribute string

    % Initialize default values
    time_unit_att = 'days';
    time_second_unit_att = 'seconds';
    calendar_att = 'none';

    % Check if valid Yorig is provided
    % if nargin >= 1 && ~isempty(Yorig)
    if ~isempty(Yorig)
        disp([' Time reference is ', sprintf('%04d', Yorig), '-01-01 00:00:00'])
        time_unit_att = ['days since ', sprintf('%04d', Yorig), '-01-01 00:00:00'];
        time_second_unit_att = ['seconds since ',sprintf('%04d', Yorig),'-01-01 00:00:00'];
        calendar_att = 'proleptic_gregorian';
    else
        disp(' No time reference')
    end
    
end