function fdsubs = FDAD_arrangeData(Def)

    % create matrix with subject info and FD
        
    switch Def.ds
        
        case "ADNI" % arrange data for ADNI
            
            subdata = readtable(Def.subfile); 

            for f=1:length(Def.fdfiles)         

                load(sprintf('%s_%s.mat',Def.fdfiles(f),Def.ds)); % get participants data from a .csv file
                prep_s = 1;

                for all_s = 1:height(subdata)

                    try

                        if strcmp(subdata.SubId(all_s),subjects{prep_s})

                            subs(prep_s,1) = str2num(subjects{prep_s}(4:end)); % Subject ID
                            subs(prep_s,2) = subdata.Age(all_s);               % age

                            switch char(subdata.Group(all_s,:))                % group (1:CTRL; 2:MCI; 3:AD)
                                case 'CN'  
                                    subs(prep_s,3) = 1;
                                case 'MCI'
                                    subs(prep_s,3) = 2;
                                case 'AD'
                                    subs(prep_s,3) = 3;
                            end

                            subs(prep_s,4:4+size(fd,2)-1) = fd(prep_s,:);     % FD data

                            prep_s = prep_s + 1;

                        end

                    catch
                    end

                    eval(sprintf('fdsubs.%s = subs;',Def.fdfiles(f)));            

                end
                
            end
            
        case "BioFIND" % arrange data for BioFIND
            
            for f=1:length(Def.fdfiles)         
            
                subdata = tdfread(Def.subfile); % get participants data from a .tsv file
                
                load(sprintf('%s_%s.mat',Def.fdfiles(f),Def.ds));
                prep_s = 1;

                for all_s = 1:length(subdata.participant_id)
                                       
                    try

                        if strcmp(subdata.participant_id(all_s,5:end),subjects{prep_s})

                            subs(prep_s,1) = str2num(subjects{prep_s}(4:end)); % subject ID
                            subs(prep_s,2) = subdata.age(all_s);               % age

                            if strcmp(subdata.group(all_s,:),'control')        % group (1:CTRL; 2:MCI)
                                subs(prep_s,3) = 1;
                            else
                                subs(prep_s,3) = 2;
                            end

                            subs(prep_s,4:4+size(fd,2)-1) = fd(prep_s,:);      % FD data
                            prep_s = prep_s + 1;

                        end

                    catch
                    end

                    eval(sprintf('fdsubs.%s = subs;',Def.fdfiles(f)));            

                end
                
            end
            
    end
    
end