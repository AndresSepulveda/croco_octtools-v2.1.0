function y = oct_ppm2fli(list_file,fli_file)

%function y = oct_ppm2fli(list_file,fli_file)

system(['rm -f ',fli_file]) 
system(['ppm2fli -b 250 -N ',list_file,' ',fli_file]) 
system(['echo ''foreach F (`cat ',list_file,'`)'' > .csh.cmd'])
system(['echo ''rm -f $F'' >> .csh.cmd'])
system(['echo ''end''  >> .csh.cmd'])
system('csh .csh.cmd');
system('rm .csh.cmd');
system(['rm -f ',list_file])
