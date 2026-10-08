function [oct_start,count,stride] = snc_get_indexing(nvdims,var_size,varargin)
% Common private function for setting up indexing for NC_VARGET.

if nvdims == 0
    % This will happen in the case of a singleton.  No need to go further.
    oct_start = 0;
    count = 1;
    stride = 1;
    return
end

switch(numel(varargin))

    case 0
        % retrieve everything.
        oct_start = zeros(1,nvdims);
        count = var_size;
        stride = ones(1,nvdims);

    case 1
        % if only oct_start was provided, then the count is implied to be one.
        oct_start = varargin{1};
        count = ones(1,nvdims);
        stride = ones(1,nvdims);

    case 2
        % just a contiguous hyperslab.
        oct_start = varargin{1};
        count = varargin{2};
        stride = ones(1,nvdims);

    case 3
        oct_start = varargin{1};
        count = varargin{2};
        stride = varargin{3};
end

oct_start = oct_start(:)';
count = count(:)';
stride = stride(:)';

% If the user had set non-positive numbers in "count", then we replace them
% with what we need to get the rest of the variable.
negs = find((count<0) | isinf(count));
count(negs) = (var_size(negs) - oct_start(negs)) ./ stride(negs);


% Ok, now do some final validation.
v = version('-release');
switch(v)
    case {'14','2006a','2006b','2007a'}
        if any(oct_start<0)
            error('snctools:indexing:badStartIndex', ...
                'The START argument should be nonnegative.');
        end

        if any(count<=0)
            error('snctools:indexing:badStartIndex', ...
                'The COUNT argument should be positive.');
        end

        if any(stride<=0)
            error('snctools:indexing:badStartIndex', ...
                'The STRIDE argument should be positive.');
        end

        if ~isnumeric(oct_start) || ~isnumeric(count) || ~isnumeric(stride)
            error('snctools:indexing:badIndexType', ...
                'Any index arguments should be numeric');
        end

        if (numel(oct_start) ~= numel(count)) || (numel(count) ~= numel(stride)) ...
                || (numel(stride) ~= nvdims)
            error('snctools:indexing:badIndexLength', ...
                'The lengths of the index arguments should be %d.', nvdims);
        end

    otherwise
        validateattributes(oct_start,{'numeric'},{'nonempty','integer','nonnegative'},'','START');
        validateattributes(count,{'numeric'},{'nonempty','integer','positive'},'','COUNT');
        validateattributes(stride,{'numeric'},{'nonempty','integer','positive'},'','STRIDE');
        
        if (numel(oct_start) ~= numel(count)) || (numel(count) ~= numel(stride)) ...
                || (numel(stride) ~= nvdims)
            error('snctools:indexing:badIndexLength', ...
                'The lengths of the index arguments should be %d.', nvdims);
        end
end

oct_start = double(oct_start);
count = double(count);
stride = double(stride);


return






