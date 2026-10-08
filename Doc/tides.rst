Tides
=====

Using the method described by :cite:t:`flather_note_1976`, CROCO is able to 
propagate the different tidal constituents from its lateral boundaries. 

To do so, you will need to add the tidal components to the forcing file.


#. Edit ``crocotools_param.m`` section 5
   ::

        %%%%%%%%%%%%%%%%%%%%% 
        % 
        % 5-Parameters for tidal forcing 
        % 
        %%%%%%%%%%%%%%%%%%%%% 
        % 
        % TPXO file name (TPXO7) 
        % 
        tidename=[CROCOTOOLS_dir,'TPXO7/TPXO7.nc']; 
        % 
        % Number of tides component to process 
        % 
        Ntides=10; 
        % 
        % Chose order from the rank in the TPXO file : 
        % "M2 S2 N2 K2 K1 O1 P1 Q1 Mf Mm" 
        % " 1 2 3 4 5 6 7 8 9 10" 
        % 
        tidalrank=[1 2 3 4 5 6 7 8 9 10]; 
        % 
        % Compare with tidegauge observations 
        % 
        lon0=18.37; 
        lat0=-33.91; % Cape Town location 
        Z0=1; % Mean depth of the tidegauge in Cape Town

#. Launch pre-processing of tides in Matlab:
   ::

        start
        make_tides

#. Check your ``croco_frc.nc`` file

