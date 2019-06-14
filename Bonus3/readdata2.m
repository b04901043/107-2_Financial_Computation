function [St,r,q,sigma,t,T,n,Smax_t,nrolls,num_of_rep]=readdata2(path)
    %READDATA1 Summary of this function goes here
    %   Detailed explanation goes here
    fileID = fopen(path,'r');
    data = fscanf(fileID,'%f');
    St=data(1);
    r=data(2);
    q=data(3);
    sigma=data(4);
    t=data(5);
    T=data(6);
    n=data(7);
    Smax_t=data(8);
    nrolls=data(9);
    num_of_rep=data(10);
    
    fclose(fileID);
end

