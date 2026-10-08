function [f,p]=uigetfile(varargin)
global UIFILES
fn=UIFILES{1}; UIFILES(1)=[];
[p,n,e]=fileparts(fn); f=[n,e]; p=[p,filesep];
disp(['[stub uigetfile] ',fn])
