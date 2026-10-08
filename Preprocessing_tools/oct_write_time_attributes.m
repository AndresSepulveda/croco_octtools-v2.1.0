function oct_write_time_attributes(ncid,time_name,cycle,...
                                time_unit_att,...
                                time_second_unit_att, ...
                                calendar_att, ...
                                insecond,...
                                add_cycle) ;
    %-----------------------------------------------------------------------
    % Inputs:
    %   time_unit_att : Time unit attribute string, 
    %                   used by default for time units
    %   time_second_unit_att : Time unit attribute string
    %   calendar_att  : Calendar type attribute string
    %   insecond : optional, switch to have time units in seconds
    %-----------------------------------------------------------------------

    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, time_name), 'calendar', calendar_att);
    %
    if exist('insecond', 'var') && insecond == 1 
        netcdf.putAtt(ncid, netcdf.inqVarID(ncid, time_name), 'units', time_second_unit_att);
    else
        netcdf.putAtt(ncid, netcdf.inqVarID(ncid, time_name), 'units', time_unit_att);
    end
    %
    %Add cycle attribute
    if exist('add_cycle', 'var') && add_cycle == 1 
        netcdf.putAtt(ncid, netcdf.inqVarID(ncid, time_name), 'cycle_length', cycle);
    end

end
