function [varargout] = oct_mexnc ( varargin_id )
%    MEXNC is a gateway to the netCDF interface. To use this function, you 
%    should be familiar with the information about netCDF contained in the 
%    "User's Guide for netCDF".  This documentation may be obtained from 
%    Unidata at 
%    <http://my.unidata.ucar.edu/content/software/oct_netcdf/docs.html>.
%
%    R2008b and Beyond
%    -----------------
%    Starting with R2008b, MATLAB comes with native netCDF support.  If 
%    your version of MATLAB is earlier than R2008b, oct_mexnc will use it's own
%    mex-file.  If MATLAB is R2008b or higher, oct_mexnc will use MATLAB's 
%    native package by default.  
%
%
%    OPeNDAP
%    -------
%    Please read the README for details about using OPeNDAP with oct_mexnc.
%
%    Syntax conventions
%    ------------------ 
%    The general syntax for MEXNC is oct_mexnc(funcstr,param1,param2,...). 
%    There is a one-to-one correspondence between functions in the netCDF 
%    library and valid values for funcstr.  For example, 
%    MEXNC('close',ncid) corresponds to the C library call nc_close(ncid).
%
%    The funcstr argument can be either upper or lower case.
%
%    NetCDF has several datatypes to choose from.  
%
%         netCDF           MATLAB equivalent
%         -----------      -----------------
%         DOUBLE           double
%         FLOAT            single
%         INT              int32
%         SHORT            int16
%         SCHAR            int8
%         UCHAR            uint8
%         TEXT             char
%
%    Unsigned matlab types uint64, uint32, uint16, and uint8 have no netCDF
%    equivalents.  Anytime you see the term 'xtype' in the function 
%    descriptions below, it refers to a netCDF datatype.
% 
%    The return status of a MEXNC operation will correspond exactly to the 
%    return status of the corresponding netCDF API function.   A non-zero 
%    value corresponds to an error.  You can use oct_mexnc('STRERROR',status) 
%    to get an error message.
% 
%    Ncid refers to the netCDF file ID.
%
%    Dimid refers to a netCDF dimension ID.
%
%    Varid refers to a netCDF variable ID.  If reading or writing an 
%    attribute, using -1 as the varid will specify a global attribute.
%    See also NC_GLOBAL.
% 
%    NetCDF files use C-style row-major ordering for multidimensional arrays, 
%    while MATLAB uses FORTRAN-style column-major ordering.  This means that 
%    the size of a MATLAB array must be flipped relative to the defined 
%    dimension sizes of the netCDF data set.  For example, if the netCDF 
%    dataset has dimensions 3x4x5, then the equivalent MATLAB array has 
%    size 5x4x3.  The PERMUTE command is useful for making any necessary 
%    conversions when reading from or writing to netCDF data sets.
% 
%    Dataset functions
%    --------------
%      [ncid,status] = oct_mexnc ('CREATE',filename,access_mode );
%          The access mode can be a string such as 'clobber' or 
%          'noclobber', but it is preferable to use the helper functions
% 
%              nc_clobber_mode
%              nc_noclobber_mode
%              nc_share_mode
%              nc_64bit_offset_mode (new in netCDF 3.6)
%              nc_netcdf4_classic 
%          
%          These correspond to named constants in the <netcdf.h> header file.  
%          Check the netCDF User's Guide for more information.  You may also 
%          combine any of these with the bitor function, e.g.
%
%              access_mode = bitor ( nc_write_mode, nc_share_mode );
%
%          The mode is optional, defaulting to nc_noclobber_mode.
%
%          See NC_CLOBBER_MODE, NC_NOCLOBBER_MODE, NC_SHARE_MODE, 
%          NC_64BIT_OFFSET_MODE, NC_NETCDF4_CLASSIC.
%
%      [chunksz_out,ncid,status] = oct_mexnc ('_CREATE',filename,mode,initialsize,chunksz_in);
%          More advanced version of 'create'.  The 'initialsize' parameter sets 
%          the initial size of the file at creation time.  Chunksize is a 
%          tuning parameter, see the oct_netcdf man page for further details.
%
%
%      [ncid,status] = oct_mexnc('OPEN',filename,access_mode);
%          Opens an existing netCDF dataset for access.  Access modes 
%          available are
% 
%              nc_nowrite_mode or 'nowrite'
%              nc_write_mode   or 'write'
%              nc_share_mode   or 'share'
%        
%          If the access_mode is not given, the default is assumed to be 
%          nc_nowrite_mode.
% 
%          See NC_WRITE_MODE, NC_NOWRITE_MODE, NC_SHARE_MODE, 
%
%      [ncid,chunksizehint,status] 
%              = oct_mexnc('_OPEN',filename,access_mode,chunksizehint);
%
%          Same as usual OPEN operation with an additional performance tuning 
%          parameter.  See the oct_netcdf documentation for additional information.
% 
%
%      status = oct_mexnc('CLOSE',ncid);
%          Closes a previously-opened netCDF file.
% 
%
%      status = oct_mexnc('REDEF',ncid);
%          Puts an open netCDF dataset into define mode so that dimensions, 
%          variables, and attributes can be added or renamed and attributes 
%          can be deleted.  
%
% 
%      status = oct_mexnc('ENDDEF',ncid);
%          Takes an open netCDF file out of define mode.
% 
%
%      status = oct_mexnc('_ENDDEF',ncid,h_minfree,v_align,v_minfree,r_align);
%          Same as ENDDEF, but with enhanced performance tuning parameters.  
%          See the man page for oct_netcdf for details.
%
% 
%      status = oct_mexnc('SYNC',ncid );
%          Unless  the NC_SHARE bit is set in OPEN or CREATE, accesses to the 
%          underlying netCDF dataset are buffered by the library.  This 
%          function  synchronizes the state of the underlying dataset and the 
%          library.  This is done automatically by CLOSE and ENDDEF.
% 
%
%      [ndims,nvars, ngatts, unlimdim, status] = oct_mexnc('INQ',ncid);
%          Inquires as to the number of dimensions, number of variables, number 
%          of global attributes, and the unlimited dimension.
% 
%
%      [ndims,status] = oct_mexnc('INQ_NDIMS',ncid);
%          Inquires as to the number of dimensions only. 
% 
%
%      [nvars,status] = oct_mexnc('INQ_NVARS',ncid);
%          Inquires as to the number of variables only. 
%
% 
%      [natts,status] = oct_mexnc('INQ_NATTS',ncid);
%          Inquires as to the number of global attributes only. 
%
% 
%      [unlimdim,status] = oct_mexnc ('INQ_UNLIMDIM',ncid);
%          Inquire as to the unlimited dimension.  As of netCDF 4.0, this
%          will return just the first unlimited dimension.
% 
%
%      status = oct_mexnc('ABORT',ncid);
%          One does not really need this function.  Just ignore it.
%
% 
%      [old_fill_mode,status] = oct_mexnc('SET_FILL',ncid,new_fill_mode)
%          Determines whether or not variable prefilling will be done.  
%          The netCDF dataset shall be writable.  new_fill_mode is
%          either nc_fill_mode to enable prefilling (the default) or 
%          nc_nofill_mode to disable  prefilling.  This function 
%          returns the previous setting in old_fill_mode.
% 
%
%    Dimension functions
%    --------------
%      [dimid,status] = oct_mexnc('DEF_DIM',ncid,name,length);
%          Adds a new dimension to an open netCDF dataset in define 
%          mode. It returns a dimension ID, given the netCDF ID, the 
%          dimension name, and the dimension length.  The dimension
%          length can be 'NC_UNLIMITED', which will define an 
%          unlimited dimension.
%
% 
%      [dimid,status] = oct_mexnc('INQ_DIMID',ncid,name);
%          Returns the ID of a netCDF dimension, given the name of the 
%          dimension. 
% 
%
%      [name,length,status] = oct_mexnc('INQ_DIM',ncid,dimid);
%          Returns information about a netCDF dimension including its 
%          name and its length. The length for the unlimited dimension, 
%          if any, is the number of records written so far.
% 
%
%      [name,status] = oct_mexnc('INQ_DIMNAME',ncid,dimid);
%          Returns the name of a dimension given the dimid.
% 
%
%      [dimlength,status] = oct_mexnc('INQ_DIMLEN',ncid,dimid);
%          Returns the length of a dimension given the dimid.  The 
%          length for the unlimited dimension is the number of records
%          written so far.
% 
%
%      status = oct_mexnc('RENAME_DIM',ncid,dimid,name);
%          Renames an existing dimension in a netCDF dataset open for 
%          writing.
% 
%
%    General Variable functions
%    --------------------------
%      [varid,status] = oct_mexnc('DEF_VAR',ncid,name,xtype,dimids);
%      [varid,status] = oct_mexnc('DEF_VAR',ncid,name,xtype,ndims,dimids);
%          Adds a new variable to a netCDF dataset.  If ndims is not 
%          specified, it is inferred from the length of dimids.  In 
%          order to define a singleton variable (a variable with one 
%          element but no defined dimensions, set dimids = [].
% 
%      status = oct_mexnc('DEF_VAR_CHUNKING',ncid,varid,storage,chunksize);
%          Specifies the variable chunking.  Storage can be either 'chunked'
%          or 'contiguous'.
%
%      status = oct_mexnc('DEF_VAR_DEFLATE',ncid,varid,shuffle,deflate,deflate_level);
%          Sets the deflate parameters for a variable ina netCDF-4 file.
%          shuffle should be non-zero to turn on the shuffle filter.  deflate
%          should be non-zero to turn on the deflate filter.  If the deflate
%          filter is on, the level is specified by a number between 0 and 9 in
%          deflate_level.
%
%      [storage,chunksize,status] = oct_mexnc('inq_var_chunking',ncid,varid);
%          Inquires as to a variable's chunking setup.
%
%      [shuffle,deflate,deflate_level,status] = oct_mexnc('INQ_VAR_DEFLATE',ncid,varid);
%          Returns the deflate settings for a variable in a netCDF-4 file.
%
%      [varid,status] = oct_mexnc('INQ_VARID',ncid,varname);
%          Returns the ID of a netCDF variable, given its name.
%
%      [varname,xtype,ndims,dimids,natts,status] = oct_mexnc('INQ_VAR',ncid,varid);
%          Returns other information about a netCDF variable given its ID.
% 
%
%      [varname,status] = oct_mexnc('INQ_VARNAME',ncid,varid);
%          Returns variable name given its ID.
% 
%
%      [vartype,status] = oct_mexnc('INQ_VARTYPE',ncid,varid);
%          Returns numeric datatype given its ID.
% 
%
%      [varndims,status] = oct_mexnc('INQ_VARNDIMS',ncid,varid);
%          Returns number of dimensions given the varid.
% 
%
%      [dimids,status] = oct_mexnc('INQ_VARDIMID',ncid,varid);
%          Returns dimension identifiers given the varid.
% 
%
%      [varnatts,status] = oct_mexnc('INQ_VARNATTS',ncid,varid);
%          Returns number of variable attributes given the varid.
% 
%
%      status = oct_mexnc('RENAME_VAR',ncid,varid,new_varname);
%          Changes  the  name  of  a  netCDF  variable.
% 
%   Variable I/O functions
%   ----------------------
%     These routines are specialized for the various netCDF datatypes.  
% 
%     The data is automatically converted from the given type to the in-file 
%     netCDF type.  Since MATLAB's default datatype is double precision, most of
%     the time you would want to use the DOUBLE functions.
%
%     Because of the difference between row-major order (C) and column-major 
%     order (MATLAB), you should transpose or permute your data before passing 
%     it into or after receiving it from these I/O routines.  
%
%     MAJOR DIFFERENCE BETWEEN THESE FUNCTIONS AND MexCDF(oct_netcdf-2).
%         These functions do not make use of the add_offset and
%         scale_factor attributes.  That job is left to any user
%         routines written as a wrapper to MexCDF.
%
%         The varid must be the actual varid, substituting the name 
%         of the variable is not allowed.
%
%
%     status = oct_mexnc('PUT_VAR_DOUBLE',ncid,varid,data);
%     status = oct_mexnc('PUT_VAR_FLOAT', ncid,varid,data);
%     status = oct_mexnc('PUT_VAR_INT',   ncid,varid,data);
%     status = oct_mexnc('PUT_VAR_SHORT', ncid,varid,data);
%     status = oct_mexnc('PUT_VAR_SCHAR', ncid,varid,data);
%     status = oct_mexnc('PUT_VAR_UCHAR', ncid,varid,data);
%     status = oct_mexnc('PUT_VAR_TEXT',  ncid,varid,data);
%         These routines write an entire dataset.
%
%
%     [data,status] = oct_mexnc('GET_VAR_DOUBLE',ncid,varid);
%     [data,status] = oct_mexnc('GET_VAR_FLOAT', ncid,varid);
%     [data,status] = oct_mexnc('GET_VAR_INT',   ncid,varid);
%     [data,status] = oct_mexnc('GET_VAR_SHORT', ncid,varid);
%     [data,status] = oct_mexnc('GET_VAR_SCHAR', ncid,varid);
%     [data,status] = oct_mexnc('GET_VAR_UCHAR', ncid,varid);
%     [data,status] = oct_mexnc('GET_VAR_TEXT',  ncid,varid);
%         These routines retrieve an entire dataset.
%
%
%     status = oct_mexnc('PUT_VAR1_DOUBLE',ncid,varid,oct_start,data);
%     status = oct_mexnc('PUT_VAR1_FLOAT', ncid,varid,oct_start,data);
%     status = oct_mexnc('PUT_VAR1_INT',   ncid,varid,oct_start,data);
%     status = oct_mexnc('PUT_VAR1_SHORT', ncid,varid,oct_start,data);
%     status = oct_mexnc('PUT_VAR1_SCHAR', ncid,varid,oct_start,data);
%     status = oct_mexnc('PUT_VAR1_UCHAR', ncid,varid,oct_start,data);
%     status = oct_mexnc('PUT_VAR1_TEXT',  ncid,varid,oct_start,data);
%         These routines write a single value to the location at the given
%         starting index.
%
%
%     [data,status] = oct_mexnc('GET_VAR1_DOUBLE',ncid,varid,oct_start);
%     [data,status] = oct_mexnc('GET_VAR1_FLOAT', ncid,varid,oct_start);
%     [data,status] = oct_mexnc('GET_VAR1_INT',   ncid,varid,oct_start);
%     [data,status] = oct_mexnc('GET_VAR1_SHORT', ncid,varid,oct_start);
%     [data,status] = oct_mexnc('GET_VAR1_SCHAR', ncid,varid,oct_start);
%     [data,status] = oct_mexnc('GET_VAR1_UCHAR', ncid,varid,oct_start);
%     [data,status] = oct_mexnc('GET_VAR1_TEXT',  ncid,varid,oct_start);
%         These routines retrieve a single value from the location at the given
%         starting index.
%
%
%     status = oct_mexnc('PUT_VARA_DOUBLE',ncid,varid,oct_start,count,data);
%     status = oct_mexnc('PUT_VARA_FLOAT', ncid,varid,oct_start,count,data);
%     status = oct_mexnc('PUT_VARA_INT',   ncid,varid,oct_start,count,data);
%     status = oct_mexnc('PUT_VARA_SHORT', ncid,varid,oct_start,count,data);
%     status = oct_mexnc('PUT_VARA_SCHAR', ncid,varid,oct_start,count,data);
%     status = oct_mexnc('PUT_VARA_UCHAR', ncid,varid,oct_start,count,data);
%     status = oct_mexnc('PUT_VARA_TEXT',  ncid,varid,oct_start,count,data);
%         These functions write into a contiguous section of a netCDF variable
%         defined by a starting corner of indices and a vector of edge lengths
%         or counts.
%
%
%     [data,status] = oct_mexnc('GET_VARA_DOUBLE',ncid,varid,oct_start,count);
%     [data,status] = oct_mexnc('GET_VARA_FLOAT', ncid,varid,oct_start,count);
%     [data,status] = oct_mexnc('GET_VARA_INT',   ncid,varid,oct_start,count);
%     [data,status] = oct_mexnc('GET_VARA_SHORT', ncid,varid,oct_start,count);
%     [data,status] = oct_mexnc('GET_VARA_SCHAR', ncid,varid,oct_start,count);
%     [data,status] = oct_mexnc('GET_VARA_UCHAR', ncid,varid,oct_start,count);
%     [data,status] = oct_mexnc('GET_VARA_TEXT',  ncid,varid,oct_start,count);
%         These functions read a contiguous section from a netCDF variable 
%         defined by a starting corner of indices and a vector of edge lengths
%         or corners.
%
%
%     status = oct_mexnc('PUT_VARS_DOUBLE',ncid,varid,oct_start,count,stride,data);
%     status = oct_mexnc('PUT_VARS_FLOAT', ncid,varid,oct_start,count,stride,data);
%     status = oct_mexnc('PUT_VARS_INT',   ncid,varid,oct_start,count,stride,data);
%     status = oct_mexnc('PUT_VARS_SHORT', ncid,varid,oct_start,count,stride,data);
%     status = oct_mexnc('PUT_VARS_SCHAR', ncid,varid,oct_start,count,stride,data);
%     status = oct_mexnc('PUT_VARS_UCHAR', ncid,varid,oct_start,count,stride,data);
%     status = oct_mexnc('PUT_VARS_TEXT',  ncid,varid,oct_start,count,stride,data);
%         These functions write into a non-contiguous section of a netCDF 
%         variable defined by a starting corner of indices, a vector of edge 
%         lengths or counts, and a vector of the sampling interval or strides.
%         For example, a stride of [2 3] would write into every second element
%         along the first dimension, and every third element along the second
%         dimension.
%
%
%     [data,status] = oct_mexnc('GET_VARS_DOUBLE',ncid,varid,oct_start,count,stride);
%     [data,status] = oct_mexnc('GET_VARS_FLOAT', ncid,varid,oct_start,count,stride);
%     [data,status] = oct_mexnc('GET_VARS_INT',   ncid,varid,oct_start,count,stride);
%     [data,status] = oct_mexnc('GET_VARS_SHORT', ncid,varid,oct_start,count,stride);
%     [data,status] = oct_mexnc('GET_VARS_SCHAR', ncid,varid,oct_start,count,stride);
%     [data,status] = oct_mexnc('GET_VARS_UCHAR', ncid,varid,oct_start,count,stride);
%     [data,status] = oct_mexnc('GET_VARS_TEXT',  ncid,varid,oct_start,count,stride);
%         These functions read a non-contiguous section from a netCDF variable 
%         defined by a starting corner of indices, a vector of edge lengths
%         or corners, and a vector of the sampling interval or strides.  
%
%
%     status = oct_mexnc('PUT_VARM_DOUBLE',ncid,varid,oct_start,count,stride,imap,data);
%     status = oct_mexnc('PUT_VARM_FLOAT', ncid,varid,oct_start,count,stride,imap,data);
%     status = oct_mexnc('PUT_VARM_INT',   ncid,varid,oct_start,count,stride,imap,data);
%     status = oct_mexnc('PUT_VARM_SHORT', ncid,varid,oct_start,count,stride,imap,data);
%     status = oct_mexnc('PUT_VARM_SCHAR', ncid,varid,oct_start,count,stride,imap,data);
%     status = oct_mexnc('PUT_VARM_UCHAR', ncid,varid,oct_start,count,stride,imap,data);
%     status = oct_mexnc('PUT_VARM_TEXT',  ncid,varid,oct_start,count,stride,imap,data);
%         These functions write into a mapped section of a netCDF variable 
%         defined by a oct_start, a count, a stride, and vector describing the 
%         mapping between the in-memory data and the netCDF dimensions.  One 
%         possible use of these would be to transpose your data upon output.
%
%
%     [data,status] = oct_mexnc('GET_VARM_DOUBLE',ncid,varid,oct_start,count,stride,imap);
%     [data,status] = oct_mexnc('GET_VARM_FLOAT', ncid,varid,oct_start,count,stride,imap);
%     [data,status] = oct_mexnc('GET_VARM_INT',   ncid,varid,oct_start,count,stride,imap);
%     [data,status] = oct_mexnc('GET_VARM_SHORT', ncid,varid,oct_start,count,stride,imap);
%     [data,status] = oct_mexnc('GET_VARM_SCHAR', ncid,varid,oct_start,count,stride,imap);
%     [data,status] = oct_mexnc('GET_VARM_UCHAR', ncid,varid,oct_start,count,stride,imap);
%     [data,status] = oct_mexnc('GET_VARM_TEXT',  ncid,varid,oct_start,count,stride,imap);
%         These functions read a mapped section from a netCDF variable 
%         defined by a starting corner, a count, a stride, and a mapping between
%         the in-memory data and the netCDF dimensions.  
%
%
%
%   Attribute functions
%   -------------------
%     Any routines marked "*XXX" constitute a suite of routines
%     that are specialized for various datatypes.  Possibilities
%     for XXX include "uchar", "schar", "short", "int", "float", 
%     and "double".  The data is automatically converted to the 
%     external type of the specified attribute.    
%
%
%     status = oct_mexnc('COPY_ATT',ncid_in,varid_in,attname,ncid_out,varid_out);
%         Copies an attribute from one variable to another, possibly
%         within the same oct_netcdf file.
%
%
%     status = oct_mexnc('DEL_ATT',ncid,varid,attname);
%         Deletes an attribute.
%
%
%     [att_value,status] = oct_mexnc('GET_ATT_DOUBLE',ncid,varid,attname);
%     [att_value,status] = oct_mexnc('GET_ATT_FLOAT', ncid,varid,attname);
%     [att_value,status] = oct_mexnc('GET_ATT_INT',   ncid,varid,attname);
%     [att_value,status] = oct_mexnc('GET_ATT_SHORT', ncid,varid,attname);
%     [att_value,status] = oct_mexnc('GET_ATT_SCHAR', ncid,varid,attname);
%     [att_value,status] = oct_mexnc('GET_ATT_UCHAR', ncid,varid,attname);
%     [att_value,status] = oct_mexnc('GET_ATT_TEXT',  ncid,varid,attname);
%         Retrieves an attribute value.   The class of att_value is determined
%         by the funcstr, not the in-file attribute datatype.
%
%
%     [datatype,attlen,status] = oct_mexnc('INQ_ATT',ncid,varid,attname);
%         Retrieves the datatype and length of an attribute given its
%         name.
%
%
%     [attid,status] = oct_mexnc('INQ_ATTID',ncid,varid,attname);
%         Retrieves the numeric id of an attribute given its name.
%
%
%     [att_len,status] = oct_mexnc('INQ_ATTLEN',ncid,varid,attname);
%         Retrieves the length of an attribute given the name.
%
%
%     [attname,status] = oct_mexnc('INQ_ATTNAME',ncid,varid,attid);
%         Retrieves the name of an attribute given its numeric attribute id.
%
%
%     [att_type,status] = oct_mexnc('INQ_ATTTYPE',ncid,varid,attname);
%         Retrieves the numeric id of the datatype of an attribute
%
%
%     status = oct_mexnc('PUT_ATT_DOUBLE',ncid,varid,attname,datatype,attvalue);
%     status = oct_mexnc('PUT_ATT_FLOAT', ncid,varid,attname,datatype,attvalue);
%     status = oct_mexnc('PUT_ATT_INT',   ncid,varid,attname,datatype,attvalue);
%     status = oct_mexnc('PUT_ATT_SHORT', ncid,varid,attname,datatype,attvalue);
%     status = oct_mexnc('PUT_ATT_SCHAR', ncid,varid,attname,datatype,attvalue);
%     status = oct_mexnc('PUT_ATT_UCHAR', ncid,varid,attname,datatype,attvalue);
%     status = oct_mexnc('PUT_ATT_TEXT',  ncid,varid,attname,datatype,attvalue);
%         Writes an attribute value.  The class of attvalue determines which
%         of these functions you should use.  Xtype, on the other hand, 
%         determines what the datatype will be of in-file netCDF attribute.
%
%     status = oct_mexnc('RENAME_ATT',ncid,varid,old_attname,new_attname);
%         Renames an attribute.
%
%
%    Miscellaneous functions
%    --------------
%      error_message = oct_mexnc('STRERROR',error_code);
%          Returns a reference to an error message string corresponding to an 
%          integer netCDF error status or to a system error number, presumably 
%          returned by a previous call to some other netCDF function. 
% 
%
%      lib_version = oct_mexnc('INQ_LIBVERS');
%          Returns a string identifying the version of the netCDF library 
%          and when it was built.
% 
%
%  netCDF 2.4 API
%  --------------
%  These functions constitute the time-tested mexcdf that was build on 
%  top of the netCDF 2.4 API.  They continue to work, but in some cases operate
%  somewhat differently than the MexCDF(oct_netcdf-3) functions.
% 
%      status = oct_mexnc('ENDEF', cdfid)
%      [ndims, nvars, natts, recdim, status] = oct_mexnc('INQUIRE', cdfid)
% 
%      status = oct_mexnc('DIMDEF', cdfid, 'name', length)
%      [dimid, rcode] = oct_mexnc('DIMID', cdfid, 'name')
%      [name, length, status] = oct_mexnc('DIMINQ', cdfid, dimid)
%      status = oct_mexnc('DIMRENAME', cdfid, 'name')
% 
%      status = oct_mexnc('VARDEF', cdfid, 'name', datatype, ndims, [dim])
%      [varid, rcode] = oct_mexnc('VARID', cdfid, 'name')
%      [name, datatype, ndims, dimids, natts, status] = oct_mexnc('VARINQ', cdfid, varid)
%      status = oct_mexnc('VARPUT1', cdfid, varid, coords, value, autoscale)
%      [value, status] = oct_mexnc('VARGET1', cdfid, varid, coords, autoscale)
%      status = oct_mexnc('VARPUT', cdfid, varid, oct_start, count, value, autoscale)
%      [value, status] = oct_mexnc('VARGET', cdfid, varid, oct_start, count, autoscale)
%      status = oct_mexnc('VARPUTG', cdfid, varid, oct_start, count, stride, [], value, autoscale)
%      [value, status] = oct_mexnc('VARGETG', cdfid, varid, oct_start, count, stride, [], autoscale)
%      status = oct_mexnc('VARRENAME', cdfid, varid, 'name')
% 
%      status = oct_mexnc('ATTPUT', cdfid, varid, 'name', datatype, value) 
%      status = oct_mexnc('ATTPUT', cdfid, varid, 'name', datatype, len, value) 
%          
%          A negative value on the length will cause the mexfile to 
%          try to figure out the length itself.
%
%      [datatype, len, status] = oct_mexnc('ATTINQ', cdfid, varid, 'name')
%      [value, status] = oct_mexnc('ATTGET', cdfid, varid, 'name')
%      status = oct_mexnc('ATTCOPY', incdf, invar, 'name', outcdf, outvar)
%      [name, status] = oct_mexnc('ATTNAME', cdfid, varid, attnum)
%      status = oct_mexnc('ATTRENAME', cdfid, varid, 'name', 'newname')
%      status = oct_mexnc('ATTDEL', cdfid, varid, 'name')
% 
%      len = oct_mexnc('TYPELEN', datatype)
%      old_fillmode = oct_mexnc('SETFILL', cdfid, fillmode)
% 
%      old_ncopts = oct_mexnc('SETOPTS', ncopts)
%      ncerr = oct_mexnc('ERR')
%      code = oct_mexnc('PARAMETER', 'NC_...')
%


if nargin<1
    error ( 'MEXNC:oct_mexnc:tooFewInputArguments', 'Mexnc requires at least one input argument' );
end

if ~isa(varargin_id{1},'char')
    error ( 'MEXNC:oct_mexnc:firstArgNotChar', 'Mexnc requires that the first argument be a char funcstr' );
end


varargout = cell(1,nargout);

switch ( version('-release') )
    case { '12', '13', '14', '2006a', '2006b', '2007a', '2007b', '2008a' }
		backend = @mexnc_classic;
	otherwise
		backend = @oct_mexnc_tmw;

end

if ( nargout > 0 )
	[varargout{:}] = backend(varargin_id{:});
else
    backend(varargin_id{:});
end



%------------------------------------------------------------------------------------------
function [varargout] = mexnc_classic ( varargin_id )
% Call the old community code mex-file.

varargout = cell(1,nargout);

if nargout > 0
    [varargout{:}] = feval('vanilla_mexnc', varargin_id{:});
else
    feval('vanilla_mexnc', varargin_id{:});
end



