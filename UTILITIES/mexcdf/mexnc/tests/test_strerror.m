function test_strerror ( )
% TEST_STRERROR
%
% Test 1:  Normal error message
% Test 2:  Empty set status.
% Test 3:  Non numeric status
% Test 4:  impossible numeric value for status

error_condition = 0;



% Test 1:  Normal retrieval
testid = 'Test 1';
msg = oct_mexnc('STRERROR', -1);


% Test 2:  empty set status
testid = 'Test 2';
try
	msg = oct_mexnc('STRERROR', []);
	error_condition = 1;
catch
	;
end
if error_condition
	msg = sprintf ( '%s:  %s:  succeeded when it should have failed.\n', mfilename, testid );
	error ( msg );
end



% Test 3:  non numeric status
testid = 'Test 3';
try
	msg = oct_mexnc('STRERROR', '-1');
	error_condition = 1;
catch
	;
end
if error_condition
	msg = sprintf ( '%s:  %s:  succeeded when it should have failed.\n', mfilename, testid );
	error ( msg );
end


% Test 4:  impossible status value
msg = oct_mexnc('STRERROR', -10000);


fprintf ( 1, 'STRERROR succeeded\n' );
return
