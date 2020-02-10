clf, close, clear, clc
%% Interacting with the API
HealthData=webread('https://health.data.ny.gov/resource/gnzp-ekau.csv?$limit=5000'); 
%reading in the appropriate data (as a table, which has similar properties
%to both cell arrays and matricies). In each of the different analysis
%sections, I will selectively extract the appropriate rows, columns,
%entries, etc to perform the relevant analysis.
%% Data Processing 
% Determining the Index Corresponding to Positive Cancer Diagnosis
diagnosiscodes=str2double(table2array(HealthData(:,15)));
for i=1:length(diagnosiscodes)
    if diagnosiscodes(i)>=11&&diagnosiscodes(i)<=43 %the ccs indexes in [11,43]
    %correspond to positive cancer diagnosis, so instead of text comparison
    %(which can be a more intesive process), I used numerical comparison of
    %the ccs codes 
    %link to source - https://www.hcup-us.ahrq.gov/toolssoftware/ccs/CCSUsersGuide.pdf
        A(i,1)=1;
    else
        A(i,1)=0;
    end
end
cancerdiagnosis=find(A==1);
B=abs(1-A).*(1:length(A))';
% Determining the Index Corresponding to Negative Cancer Diagnosis
noncancerdiagnosis=[];
for i=1:length(B)
    if B(i)~=0
        noncancerdiagnosis=[noncancerdiagnosis;B(i)];
    end
end
% Separating the Data Based on Positive/Negative Cancer Diagnosis
CancerData={};
for i=1:length(cancerdiagnosis)
    cancerindex=cancerdiagnosis(i);
    CancerData=[CancerData;HealthData(cancerindex,:)];
end
NonCancerData={};
for i=1:length(noncancerdiagnosis)
    noncancerindex=noncancerdiagnosis(i);
    NonCancerData=[NonCancerData;HealthData(noncancerindex,:)];
end
% Creating Titles for Graphs
Titles={'Cancer of head and neck','Cancer of esophagus','Cancer of stomach',...
    'Cancer of colon','Cancer of rectum and anus','Cancer of liver and intrahepatic bile duct',...
    'Cancer of pancreas','Cancer of other GI organs; peritoneum','Cancer of bronchus; lung',...
    'Cancer; other respiratory and intrathoracic','Cancer of bone and connective tissue',...
    'Melanomas of skin','Other non-epithelial cancer of skin','Cancer of breast',...
    'Cancer of uterus','Cancer of cervix','Cancer of ovary','Cancer of other female genital organs',...
    'Cancer of prostate','Cancer of testis','Cancer of other male genital organs',...
    'Cancer of bladder','Cancer of kidney and renal pelvis','Cancer of other urinary organs',...
    'Cancer of brain and nervous system','Cancer of thyroid','Hodgkins Disease',...
    'Non-Hodgkins lymphoma','Leukemias','Multiple myeloma','Cancer; other and unspecified primary',...
    'Secondary malignancies','Malignant neoplasm without specification of site','Non-cancer Diagnosis'};
% Note: I didn't want to simply filter out the non-cancer diagnosis data
% points because, for the comparison of severity, they serve as an
% interesting point of reference. This allows for the comparison of not
% only different types of cancer against themselves, but cancer vs
% non-cancer diagnosis as well.
%% Comparing Severity vs Type of Cancer 
% Cancer Analysis
SevAnalysis1(length(cancerdiagnosis),2)=0;
for i=1:length(cancerdiagnosis)
    CurrentCancerSevData=table2array(CancerData(i,:));
    Severity=str2double(CurrentCancerSevData(23));
    Type=str2double(CurrentCancerSevData(15));
    SevAnalysis1(i,1)=Severity;
    SevAnalysis1(i,2)=Type-10; %Have to perform this step because the first 
    %cancer-related diagnosis is at ccs code 11, so this index needs to be
    %shifted so as to start at 1 for the first cancer diagnosis code
end
CancerSevAnalysis=cell(33,1);
for i=1:length(cancerdiagnosis)
    if isempty(CancerSevAnalysis{SevAnalysis1(i,2)})
        CancerSevAnalysis{SevAnalysis1(i,2)}=SevAnalysis1(i,1);
    else
        CancerSevAnalysis{SevAnalysis1(i,2)}=[CancerSevAnalysis{SevAnalysis1(i,2)}; SevAnalysis1(i,1)];
    end
end
for index=1:33
    if numel(CancerSevAnalysis{index})>=1
        figure
        histogram(CancerSevAnalysis{index})
        xlabel('Severity')
        ylabel('Frequency')
        title(Titles(index))
    end
end
figure
histogram(cell2mat(CancerSevAnalysis))
title('Total Cancer Severity Analysis')
% Non-Cancer Comparison
SevAnalysis2(length(noncancerdiagnosis),2)=0;
for i=1:length(noncancerdiagnosis)
    CurrentNonCancerSevData=table2array(NonCancerData(i,:));
    Severity=str2double(CurrentNonCancerSevData(23));
    Type=str2double(CurrentNonCancerSevData(15));
    SevAnalysis2(i,1)=Severity;
end
NoncancerSevAnalysis=cell(1,1);
for i=1:length(noncancerdiagnosis)
    if isempty(NoncancerSevAnalysis{1})
        NoncancerSevAnalysis{1}=SevAnalysis2(i,1);
    else
        NoncancerSevAnalysis{1}=[NoncancerSevAnalysis{1}; SevAnalysis2(i,1)];
    end
end
figure
histogram(NoncancerSevAnalysis{1})
xlabel('Severity')
ylabel('Frequency')
title('Non-cancer Severity Analysis')
% Note: I selected severity as a variable to look at because I wanted to create 
% a comparison of the severity between the different types of cancer.
%% Comparing Gender Distribution v Type of Cancer 
PieChartTitles={'Female','Male'};
GenderAnalysisMat(length(cancerdiagnosis),2)=0;
for i=1:length(cancerdiagnosis)
    CurrentCancerGenderData=table2array(CancerData(i,:));
    if strcmp(CurrentCancerGenderData(8),'F')==1
        Gender=1; %1 means female
    else
        Gender=2; %2 means male
    end
    Type=str2double(CurrentCancerGenderData(15));
    GenderAnalysisMat(i,1)=Gender;
    GenderAnalysisMat(i,2)=Type-10; %Have to perform this step because the first 
    %cancer-related diagnosis is at ccs code 11, so this index needs to be
    %shifted so as to start at 1 for the first cancer diagnosis code
end
GenderAnalysis=cell(33,1);
for i=1:length(cancerdiagnosis)
    if isempty(GenderAnalysis{GenderAnalysisMat(i,2)})
        GenderAnalysis{GenderAnalysisMat(i,2)}=GenderAnalysisMat(i,1);
    else
        GenderAnalysis{GenderAnalysisMat(i,2)}=[GenderAnalysis{GenderAnalysisMat(i,2)};GenderAnalysisMat(i,1)];
    end
end
for index=1:33
    if numel(GenderAnalysis{index})>=1
        A=[numel(find(GenderAnalysis{index}==1)),numel(find(GenderAnalysis{index}==2))];
        figure
        if numel(find(GenderAnalysis{index}==1))~=0&&numel(find(GenderAnalysis{index}==2))~=0
            pie(A,PieChartTitles)
        elseif numel(find(GenderAnalysis{index}==1))==0
            pie(A,{' ','Male'})
        else
            pie(A,{'Female',' '})
        end
        title(Titles{index})
    end
end
% Non-cancer comparison of gender distribution of illnesses
GenderAnalysisNonCancer(length(noncancerdiagnosis),2)=0;
for i=1:length(noncancerdiagnosis)
    CurrentNoncancerGenderData=table2array(NonCancerData(i,:));
    if strcmp(CurrentNoncancerGenderData(8),'F')==1
        Gender=1; %1 denotes female
    else
        Gender=2; %2 denotes male
    end
    Type=str2double(CurrentNoncancerGenderData(15));
    GenderAnalysisNonCancer(i,1)=Gender;
end
NoncancerGenderAnalysis=cell(1,1);
for i=1:length(noncancerdiagnosis)
    if isempty(NoncancerGenderAnalysis{1})
        NoncancerGenderAnalysis{1}=GenderAnalysisNonCancer(i,1);
    else
        NoncancerGenderAnalysis{1}=[NoncancerGenderAnalysis{1};GenderAnalysisNonCancer(i,1)];
    end
end
figure
pie([numel(find(NoncancerGenderAnalysis{1}==1)),numel(find(NoncancerGenderAnalysis{1}==2))],...
    {'Female','Male'})
title('Non-cancer Gender Analysis')
% Note: I wanted to examine the gender distributions for each of the
% cancers because I wanted to see if being of a certain gender impacted
% one's likelyhood of contracting a particular type of cancer. 