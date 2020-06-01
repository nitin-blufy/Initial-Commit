public class OnlineEnrollmentPageCntrl {
    public Double offset{get{
        TimeZone tz = UserInfo.getTimeZone();
        //Milliseconds to Day
        return tz.getOffset(DateTime.now()) / (1000 * 3600 * 24.0);
    }}
    
    public CourseDetailModel crsDetailObj{get;set;}
    public ContactModel 	 cstmrObj{get;set;}
    public Integer index {get;set;}
    public Boolean termsnCon{get;set;}
    public AccoutStudentModel stuDetailsToAdd {get;set;}
    public String logoImageURL{get;set;}
    public Boolean checkReqFieldsBlank {get;set;}
    
    public OnlineEnrollmentPageCntrl(){
        stuDetailsToAdd = new AccoutStudentModel();
        crsDetailObj = new CourseDetailModel();
        cstmrObj = new ContactModel();
        termsnCon = false;
        checkReqFieldsBlank = false;
        logoImageURL = '/servlet/servlet.FileDownload?file=';
        List<Document> listDocument = [SELECT name FROM document WHERE Name =: Label.LogoDocumentName];
        
        if(listDocument.size()>0){
            logoImageURL = logoImageURL + listDocument[0].id;
        }
        system.debug('logoImageURL-->'+logoImageURL);
        for(Online_Process_Config__mdt procCon: [SELECT MasterLabel, Field_Api_Name__c, Section__c, Type__c, Sequence__c,Required__c 
                                                 FROM   Online_Process_Config__mdt WHERE Active__c=True AND 
                                                 Type__c='Visible' AND Section__c != null ORDER BY Sequence__c]){
                                                     FieldsModel fm = new FieldsModel(procCon.MasterLabel, procCon.Field_Api_Name__c,procCon.Required__c);
                                                     if(procCon.Section__c.equalsIgnoreCase('Contact Details')){
                                                         cstmrObj.conFieldList.add(fm);                                             
                                                     }if(procCon.Section__c.equalsIgnoreCase('Contact Address Details')){
                                                         cstmrObj.conAddFieldList.add(fm);       
                                                     }else if(procCon.Section__c.equalsIgnoreCase('Student Details')){
                                                         stuDetailsToAdd.stuFieldList.add(fm);
                                                         //cstmrObj.stuDetail[0].stuFieldList.add(fm);
                                                     }
                                                 }
        
        String clsId = ApexPages.currentPage().getParameters().get('id');
        if(String.isNotBlank(clsId)){
            fetchClsDetails(clsId);
        }
    }
    
    private void fetchClsDetails(String clsId){
        List<Class__c> clsList = [SELECT Id, Name,Course__c, Course__r.Name,Location__r.Name, Teacher__r.Name,
                                  educato__Frequency__c,Course__r.educato__Description__c,
                                  Days_of_Week__c, Start_Date__c, End_Date__c, Start_Time__c, End_Time__c 
                                  FROM Class__c WHERE Id=:clsId];
        if(clsList.size() > 0){
            Class__c cls = clsList.get(0);
            crsDetailObj.cls = clsList.get(0);
            crsDetailObj.crsName  = cls.Course__r.Name;
            crsDetailObj.crDescription = cls.Course__r.educato__Description__c;
            crsDetailObj.clsName  = cls.Name;
            crsDetailObj.location = cls.Location__r.Name;
            crsDetailObj.tchrName = cls.Teacher__r.Name;
            crsDetailObj.strtDate = (cls.Start_Date__c != null ? cls.Start_Date__c : null);
            crsDetailObj.endDate = (cls.End_Date__c != null ? cls.End_Date__c : null);
            crsDetailObj.stTime   =  Datetime.newInstance(System.today(), cls.Start_Time__c);
            crsDetailObj.endTime  =  Datetime.newInstance(System.today(), cls.End_Time__c);
            fetchFeeDetails(cls.Id,cls.Course__c,cls.educato__Frequency__c);
        }
    }
    
    private void fetchFeeDetails(String clsId,String courseId,String clsFrequency){
        for(Course_Fee__c crFee: [SELECT Id, Name, Fee__c, Fee__r.Name, Fee__r.Amount__c, Fee__r.Unit_Price__c, Fee__r.Schedule__c, Fee__r.Type__c, Fee__r.Frequency__c, Fee__r.Required__c, Fee__r.Override__c
                                  FROM Course_Fee__c WHERE Course__c =: courseId AND Fee__r.Amount__c != null AND Fee__r.Type__c != null ORDER BY Fee__r.Type__c DESC]){
                                      FeeWrapper fw = new FeeWrapper();
                                      fw.feeId      = crFee.Fee__c;                         
                                      fw.feeName    = crFee.Fee__r.Name;
                                      fw.feeType    = crFee.Fee__r.Type__c;
                                      fw.feeFrequency = crFee.Fee__r.Frequency__c;  
                                      fw.feeAmount = crFee.Fee__r.Amount__c;
                                      fw.isSelected = crFee.Fee__r.Required__c;
                                      fw.isOverride = crFee.Fee__r.Override__c;
                                      if(crFee.Fee__r.Type__c == ConstantClass.tutionFeeType && crFee.Fee__r.Frequency__c == clsFrequency && crFee.Fee__r.Required__c){
                                          Integer noOfLessInCurrMonth = 0;
                                          crsDetailObj.crsefee = crFee.Fee__r.Amount__c;
                                          if(crFee.Fee__r.Frequency__c.equalsIgnoreCase(ConstantClass.monthlyFrequency)){
                                              if(crsDetailObj.enrolDate.month() == System.today().month()){
                                                  Integer numberOfDays = Date.daysInMonth(crsDetailObj.enrolDate.year(), crsDetailObj.enrolDate.month());
                                                  Date lastDayOfMonth = Date.newInstance(crsDetailObj.enrolDate.year(), crsDetailObj.enrolDate.month(), numberOfDays);
                                                  
                                                  List<Session__c> sessList  = [SELECT Id, Name, Class__c, Sequence__c, Session_Date__c
                                                                                FROM Session__c
                                                                                WHERE Class__c =:clsId AND Status__c =: ConstantClass.scheduledStatus
                                                                                AND Session_Date__c >=:crsDetailObj.enrolDate AND Session_Date__c <=: lastDayOfMonth];  
                                                  noOfLessInCurrMonth = sessList.size();
                                              }
                                          }else{//Calculate prorated number of lesson for Term/Fixed type class on the bases of selected date
                                              List<Class_Term__c> clsTermList = [SELECT Id, Name, Sequence__c, Sessions__c, Start_Date__c, End_Date__c 
                                                                                 FROM Class_Term__c
                                                                                 WHERE Class__c=: clsId AND Status__c =:ConstantClass.ScheduledStatus AND Allow_Enrollment__c = True AND 
                                                                                 Sessions__c > 0 AND Start_Date__c != null AND End_Date__c >: crsDetailObj.enrolDate ORDER BY Sequence__c];
                                              Class_Term__c clsTerm = new Class_Term__c();
                                              if(clsTermList.size() > 0){
                                                  //get specifi class term according to the selected enrolment date
                                                  for(Class_Term__c clsTermTemp: clsTermList){
                                                      if(clsTermTemp.Start_Date__c <= crsDetailObj.enrolDate && crsDetailObj.enrolDate < clsTermTemp.End_Date__c){
                                                          clsTerm = clsTermTemp;
                                                          break;
                                                      }
                                                  }    
                                                  //Check if no class term avaialble according to the enrolment date, Then check next term
                                                  if(clsTerm.Id == null){
                                                      for(Class_Term__c clsTermTemp: clsTermList){
                                                          if(clsTermTemp.End_Date__c > crsDetailObj.enrolDate){
                                                              clsTerm = clsTermTemp;
                                                              break;
                                                          }
                                                      } 
                                                  }    
                                              }        
                                              //Fetch number of remaining session on the bases of term selected
                                              if(clsTerm.Id != null){
                                                  List<Session__c> sessList  = [SELECT Id, Name, Class__c, Sequence__c, Session_Date__c, Teacher__c, Status__c  
                                                                                FROM Session__c
                                                                                WHERE Class_Term__c =:clsTerm.Id AND Status__c =: ConstantClass.scheduledStatus
                                                                                AND Session_Date__c >=: crsDetailObj.enrolDate];  
                                                  noOfLessInCurrMonth = sessList.size();
                                                  System.debug('@@--->'+clsTerm.Id );
                                                  System.debug('@@--->'+sessList.size());
                                              }
                                          }
                                          System.debug('@@--->'+noOfLessInCurrMonth);
                                          Decimal packFee = crFee.Fee__r.Unit_Price__c * noOfLessInCurrMonth;
                                          fw.feeProratedAmount = packFee;
                                          crsDetailObj.listCrseFeeWrpper.add(fw);
                                      }
                                      else if(crFee.Fee__r.Type__c != ConstantClass.tutionFeeType){
                                          crsDetailObj.listCrseFeeWrpper.add(fw);
                                      }    
                                  }
    }
    
    public void addNewStudent(){
        Boolean checkDynStuReqFieldsBlank = false;
        
        if(String.isBlank(stuDetailsToAdd.firstName) || String.isBlank(stuDetailsToAdd.lastName) || String.isBlank(stuDetailsToAdd.slcdGender) ||
           stuDetailsToAdd.stuDob == NULL || String.isBlank(stuDetailsToAdd.slcdRelation)){
               checkReqFieldsBlank = true;
           }
        else
            checkReqFieldsBlank = false;
        
        
        if(stuDetailsToAdd.stuFieldList.size() > 0){
            for(FieldsModel fm : stuDetailsToAdd.stuFieldList){
                if(fm.fieldRequired && String.isBlank(fm.fieldValue)){
                    fm.showRequired = true;
                }
                else
                    fm.showRequired = false;
            }
            
            for(FieldsModel fm : stuDetailsToAdd.stuFieldList){
                if(fm.showRequired){
                    checkDynStuReqFieldsBlank = true;
                    break;
                }
            }
        }
        system.debug('stuDetailsToAdd.stuFieldList-->'+stuDetailsToAdd.stuFieldList);
        system.debug('checkReqFieldsBlank-->'+checkReqFieldsBlank);
        if(!checkReqFieldsBlank && !checkDynStuReqFieldsBlank){
            cstmrObj.stuDetail.add(stuDetailsToAdd);
            generateEnrolmntSummary();
            stuDetailsToAdd = new  AccoutStudentModel();
            for(Online_Process_Config__mdt procCon: [SELECT MasterLabel, Field_Api_Name__c, Section__c, Type__c, Sequence__c,Required__c 
                                                     FROM   Online_Process_Config__mdt WHERE Active__c=True AND 
                                                     Type__c='Visible' AND Section__c = 'Student Details' ORDER BY Sequence__c]){
                                                         FieldsModel fm = new FieldsModel(procCon.MasterLabel, procCon.Field_Api_Name__c,procCon.Required__c);  
                                                         stuDetailsToAdd.stuFieldList.add(fm);
                                                     }
            system.debug('stuDetailsToAdd.stuFieldList-->'+stuDetailsToAdd.stuFieldList);
        }        
    }
    
    public void deleteStudent (){
        system.debug('index-->'+index);
        cstmrObj.stuDetail.remove(index);
        cstmrObj.totalEnrlFee = 0;
        for(AccoutStudentModel stu : cstmrObj.stuDetail){
            cstmrObj.totalEnrlFee += stu.totalFeeAmt;
        }
    }
    
    public void generateEnrolmntSummary(){
        for(AccoutStudentModel stu : cstmrObj.stuDetail){
            if(!stu.isAdded){
                for(FeeWrapper crFee : crsDetailObj.listCrseFeeWrpper){
                    if(crFee.isSelected){
                        if(crFee.feeType == ConstantClass.tutionFeeType)
                            stu.totalFeeAmt += crFee.feeProratedAmount;
                        else
                            stu.totalFeeAmt += crFee.feeAmount;
                        stu.listStuCrseFeeWrpper.add(crFee);
                        system.debug('stu.totalFeeAmt-->'+stu.totalFeeAmt);
                    }
                }
                stu.isAdded = true;
            }
        }
        system.debug('cstmrObj.stuDetail-->'+cstmrObj.stuDetail.size());
        cstmrObj.totalEnrlFee = 0;
        for(AccoutStudentModel stu : cstmrObj.stuDetail){
            cstmrObj.totalEnrlFee += stu.totalFeeAmt;
        }
    }
    
    public Pagereference completeEnrollment(){
        List<Account> listAccount = new List<Account>();
        String recTypeId = ConstantClass.customerRecTypeId;
        system.debug(cstmrObj.stuDetail.size());
        Account parAcc 		= new Account();
        parAcc.RecordTypeId = recTypeId;
        parAcc.FirstName    = cstmrObj.cstmrDetail.firstName;
        parAcc.LastName     = cstmrObj.cstmrDetail.lastName;
        parAcc.PersonEmail  = cstmrObj.cstmrDetail.email;
        parAcc.phone    	= cstmrObj.cstmrDetail.phone;
        for(FieldsModel fm: cstmrObj.conFieldList)
            parAcc.put(fm.fieldApiName, fm.fieldValue);  
        for(FieldsModel fm: cstmrObj.conAddFieldList)
            parAcc.put(fm.fieldApiName, fm.fieldValue);  
        upsert parAcc;   
        
        if(cstmrObj.stuDetail.size() > 0){
            for(AccoutStudentModel stu : cstmrObj.stuDetail){
                Account stuAcc 		   = new Account();
                stuAcc.Parent__c	   = parAcc.Id;
                stuAcc.RecordTypeId    = recTypeId;
                stuAcc.FirstName       = stu.firstName;
                stuAcc.LastName        = stu.lastName;
                stuAcc.Gender__c       = stu.slcdGender;
                stuAcc.PersonBirthdate = stu.stuDob;
                stuAcc.Relationship_with_contact__c = stu.slcdRelation;
                for(FieldsModel fm: stu.stuFieldList)
                    stuAcc.put(fm.fieldApiName, fm.fieldValue);  
                listAccount.add(stuAcc);
            }
        } 
        upsert listAccount;
        
        return new Pagereference('/'+parAcc.Id);
    }
    
    public List<SelectOption> getGenderList(){
        List<SelectOption> genList = new List<SelectOption>();
        genList.add(new SelectOption('','--Select Gender--')); 
        for(String genValue : UtilityClass.getPickValues('Account','educato__Gender__c'))
            genList.add(new SelectOption(genValue,genValue)); 
        return genList;
    }
    
    public List<SelectOption> getRelationList(){
        List<SelectOption> relList = new List<SelectOption>();
        relList.add(new SelectOption('','--Select Relationship--')); 
        for(String relValue : UtilityClass.getPickValues('Account','educato__Relationship_with_contact__c')){
            relList.add(new SelectOption(relValue,relValue));
        } 
        return relList;
    }
    
    public class CourseDetailModel{
        public String crsName {get;set;}
        public String crDescription {get;set;}
        public String clsName {get;set;}
        public String location {get;set;}
        public String tchrName {get;set;}
        public Date strtDate {get;set;}
        public Date endDate {get;set;}
        public DateTime stTime {get;set;}
        public DateTime endTime {get;set;}
        public Date enrolDate {get;set;}
        public String comments {get;set;}
        public Decimal crsefee {get;set;}
        public Class__c cls {get;set;}
        public List<FeeWrapper> listCrseFeeWrpper {get;set;}
        public CourseDetailModel(){
            cls = new Class__c();
            crsefee = 0;
            listCrseFeeWrpper = new  List<FeeWrapper>();
            enrolDate = System.today();
        }
    }
    
    public class ContactModel{
        public AccoutModel cstmrDetail{get;set;}
        public List<FieldsModel> conFieldList{get;set;}
        public List<FieldsModel> conAddFieldList{get;set;}
        public String refCode {get;set;}
        public String proCode {get;set;}
        public Decimal totalEnrlFee {get;set;}
        public List<AccoutStudentModel> stuDetail{get;set;}        
        
        public ContactModel(){
            cstmrDetail 	= new AccoutModel();
            totalEnrlFee = 0;
            conFieldList 	= new List<FieldsModel>();
            conAddFieldList = new List<FieldsModel>();
            stuDetail  = new List<AccoutStudentModel>();            
        }
    }
    
    public class AccoutModel{
        public String firstName{get;set;}
        public String lastName{get;set;}
        public String email{get;set;}
        public String phone{get;set;}
        
        public AccoutModel(){}
    }
    
    //For student
    public class AccoutStudentModel{
        public String firstName{get;set;}
        public String lastName{get;set;}
        public String slcdGender{get;set;}
        public String slcdRelation{get;set;}
        public Boolean isAdded {get;set;}
        public Date   stuDob{get;set;}
        public Decimal totalFeeAmt {get;set;}
        public List<FieldsModel>  stuFieldList{get;set;}
        public List<FeeWrapper> listStuCrseFeeWrpper {get;set;}
        public AccoutStudentModel(){
            isAdded = false;
            totalFeeAmt = 0; 
            stuFieldList   = new List<FieldsModel>();
            listStuCrseFeeWrpper = new List<FeeWrapper>();
        }
    }
    
    public class FieldsModel{
        public String fieldLabel{get;set;}
        public String fieldValue{get;set;}
        public Boolean fieldRequired{get;set;}
        String fieldApiName;
        public Boolean showRequired {get;set;}
        
        public FieldsModel(String fieldLabel, String fieldApiName,Boolean fieldRequired){
            this.fieldLabel   = fieldLabel;
            this.fieldApiName = fieldApiName;
            this.fieldRequired = fieldRequired;
            this.showRequired = false;
        }
    }
    
    public class FeeWrapper{ 
        public String  feeId{get;set;}
        public String  feeName{get;set;}
        public String  feeType{get;set;}
        public String  feeFrequency{get;set;}
        public Decimal tutionFeeUnitPrice{get;set;}
        public Decimal feeAmount{get;set;}
        public Decimal feeProratedAmount{get;set;}
        public Boolean isSelected{get;set;}
        public Boolean isOverride{get;set;}
        
        public FeeWrapper(){
            feeAmount  = 0;
            feeProratedAmount = 0;
            tutionFeeUnitPrice = 0;
            isSelected = false;
            isOverride = false;
        }
    }
}