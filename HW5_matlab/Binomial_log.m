function [bino_euro,bino_amer] = Binomial_log(St,K,r,q,sigma,T_t,M,n,Save_t,passing_time)
%BINOMIAL_LOG Summary of this function goes here
%   Detailed explanation goes here
    dT=(T_t)/n;
    npass=n*passing_time/T_t;
    u=exp(sigma*sqrt(dT));
    d=1/u;
    p=(exp(r*dT-q*dT)-d)/(u-d);

    % Initiate Smax table
    s=struct('Amax',[],'Amin',[],'europrice',[],'amerprice',[]);
    tree(1:n+1,1:n+1)=struct(s);

    for i=1:n+1
        for j=1:i
            tree(j,i).Amax=(Save_t*(npass+1) + St*( (1-power(u,i-j+1))/(1-u) + ...
                           power(u,i-j)*d*(1-power(d,j-1))/(1-d) ) -St ) / (i+npass);
            tree(j,i).Amin=(Save_t*(npass+1) + St*( (1-power(d,j))/(1-d) + ...
                           power(d,j-1)*u*(1-power(u,i-j))/(1-u) ) -St ) / (i+npass);
        end
    end
    
    for j=1:n+1
        tree(j,n+1).europrice=nan(M+1,2);
        tree(j,n+1).amerprice=nan(M+1,2);
        for k=1:M+1
            tree(j,n+1).europrice(k,1) = exp( ( ( M-k+1)*log(tree(j,n+1).Amax)...
                                                  +(k-1)*log(tree(j,n+1).Amin) ) / M );
            tree(j,n+1).europrice(k,2)=max( tree(j,n+1).europrice(k,1) - K , 0 );
            tree(j,n+1).amerprice(k,1)=tree(j,n+1).europrice(k,1);
            tree(j,n+1).amerprice(k,2)=tree(j,n+1).europrice(k,2);
        end
    end
    
    for i=n:-1:1
        for j=1:i
            tree(j,i).europrice=nan(M+1,2);
            tree(j,i).amerprice=nan(M+1,2);
            for k=1:M+1
                if(tree(j,i).Amax~=tree(j,i).Amin)
                    tree(j,i).europrice(k,1) = exp( ( (M-k+1)*log(tree(j,i).Amax)+...
                                                      (k-1)*log(tree(j,i).Amin) ) / M);
                    tree(j,i).amerprice(k,1) = exp(( (M-k+1)*log(tree(j,i).Amax)+...
                                                      (k-1)*log(tree(j,i).Amin) ) / M);
                else
                    tree(j,i).europrice(k,1) = tree(j,i).Amax;
                    tree(j,i).amerprice(k,1) = tree(j,i).Amax;
                end
                
                Au = ((i+npass)*tree(j,i).europrice(k,1)+St*power(u,i-j+1)*power(d,j-1)) / (i+1+npass);
                if( abs(Au-tree(j,i+1).europrice(1,1))<1e-5 )
                    Cu1=tree(j,i+1).europrice(1,2);
                    Cu2=tree(j,i+1).amerprice(1,2);
                elseif( abs(Au-tree(j,i+1).europrice(M+1,1))<1e-5 )
                    Cu1=tree(j,i+1).europrice(M+1,2);
                    Cu2=tree(j,i+1).amerprice(M+1,2);
                else
                    Cu1=interp1(tree(j,i+1).europrice(:,1), tree(j,i+1).europrice(:,2), Au, 'linear');
                    Cu2=interp1(tree(j,i+1).amerprice(:,1), tree(j,i+1).amerprice(:,2), Au, 'linear');
                end
                
                Ad = ((i+npass)*tree(j,i).europrice(k,1)+St*power(u,i-j)*power(d,j)) / (i+1+npass);
                if( abs(Ad-tree(j+1,i+1).europrice(1,1))<1e-5 )
                    Cd1=tree(j+1,i+1).europrice(1,2);
                    Cd2=tree(j+1,i+1).amerprice(1,2);
                elseif( abs(Au-tree(j+1,i+1).europrice(M+1,1))<1e-5 )
                    Cd1=tree(j+1,i+1).europrice(M+1,2);
                    Cd2=tree(j+1,i+1).amerprice(M+1,2);
                else
                    Cd1=interp1(tree(j+1,i+1).europrice(:,1), tree(j+1,i+1).europrice(:,2), Ad, 'linear');
                    Cd2=interp1(tree(j+1,i+1).amerprice(:,1), tree(j+1,i+1).amerprice(:,2), Ad, 'linear');
                end
                tree(j,i).europrice(k,2) = ( p*Cu1 + (1-p)*Cd1 ) * exp(-r*dT);
                tree(j,i).amerprice(k,2) = max( ( p*Cu2 + (1-p)*Cd2 ) * exp(-r*dT) ,...
                    tree(j,i).amerprice(k,1)-K );
            end
        end
    end
    bino_euro=tree(1,1).europrice(1,2);
    bino_amer=tree(1,1).amerprice(1,2);
end



