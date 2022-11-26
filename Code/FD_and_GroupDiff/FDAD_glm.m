function fdGLM = FDAD_glm(Def)

    for ds = 1:length(Def.allds)

        load(Def.allds{ds})

        for f = 1:length(Def.fdfiles)
            
            clear X y mdl yhat Rs P 

            switch Def.grouping 
                case 0    % exclude AD    
                    X = fdsubs.(Def.fdfiles(f))(fdsubs.(Def.fdfiles(f))(:,3)<3,4:end);
                    y = fdsubs.(Def.fdfiles(f))(fdsubs.(Def.fdfiles(f))(:,3)<3,3);
                case 1    % group patients (MCI+AD)    
                    X = fdsubs.(Def.fdfiles(f))(:,4:end); % predictors
                    y = fdsubs.(Def.fdfiles(f))(:,3);     % outcome
                    y(y==3)=2; 
                
            end

            y = y-1;   % need levels to be 0 and 1 for binomial distribution

            mdl  = fitglm(X,y,'Distribution','binomial'); % compute model
            yhat = predict(mdl,X);                        % predict scores using the model

            % calculate structure coefficients (Rs), i.e., the correlation between the predictor and the predicted score 

            for x = 1:size(X,2) % run for each predictor

                [rs p] = corrcoef(X(:,x),yhat);
                Rs(x) = rs(1,2); P(x) = p(1,2);

            end

            fdGLM.(Def.allds{ds}).(Def.fdfiles(f)).mdl   = mdl;
            fdGLM.(Def.allds{ds}).(Def.fdfiles(f)).yhat  = yhat;
            fdGLM.(Def.allds{ds}).(Def.fdfiles(f)).Rs    = Rs;
            fdGLM.(Def.allds{ds}).(Def.fdfiles(f)).P     = P;

        end

    end