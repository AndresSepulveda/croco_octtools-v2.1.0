function oct_clean_ppm(list_file)
%
%function oct_clean_ppm(list_file)
%
% Remove the .ppm files form the list
%
system(['echo ''foreach F (`cat ',list_file,'`)'' > .csh.cmd'])
system(['echo ''rm -f $F'' >> .csh.cmd'])
system(['echo ''end''  >> .csh.cmd'])
system('csh .csh.cmd');
system('rm .csh.cmd');
system(['rm -f ',list_file])
