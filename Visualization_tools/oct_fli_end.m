function y = oct_fli_end(fid,fli_file)

%function y = oct_fli_end(fid,fli_file)

fclose(fid);
oct_ppm2fli('.ppm.list',fli_file)
