function [oct_start, count] = nc_varput_validate_indexing(nvdims,data,oct_start,count,stride)
% Check that any given oct_start, count, and stride arguments actually make sense
% for this variable.  

% Singletons are a special case.  We need to set the oct_start and count 
% carefully.
if nvdims == 0

    if (isempty(oct_start) && isempty(count) && isempty(stride))

        % This is the case of "nc_varput(file,var,single_datum);"
        oct_start = 0;
        count = 1;
        
    elseif ((oct_start ==0) && (count == 1))
        
        return

    else     
        error('snctools:nc_varput:badIndexing',...
            'Do not use indexing for singleton variables.');
    end

    return;

end

% If START and COUNT not given, and if not a singleton variable, then START 
% is [0,..] and COUNT is the size of the data.  
if isempty(oct_start) && isempty(count) && ( nvdims > 0 )
    oct_start = zeros(1,nvdims);
    count = zeros(1,nvdims);
    for j = 1:nvdims
        count(j) = size(data,j);
    end
end

% Check that the oct_start, count, and stride arguments have the same length.
if (numel(oct_start) ~= numel(count)) || (~isempty(stride) && numel(oct_start) ~= numel(stride))
    error('snctools:nc_varput:badIndexLength', ...
          'The START, COUNT, and STRIDE arguments must have the same length.');
end
