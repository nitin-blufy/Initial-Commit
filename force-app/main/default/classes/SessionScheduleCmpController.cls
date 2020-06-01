/**
* @author
* @date 
*
* 
*
* Objects :-  Session__c, Class__c, Class_Term__c, Teacher & Student(API Name- Account), Teacher_Leave__c, Holiday__c, Student_Session__c  
Controller :- SessionScheduleCmpController
Desc:- generate sessions when a schedule button is clicked by user on Class_Term__c name TERM 1.
Term 1 is created by a trigger name- ClassTrigger & handler class name- ClassTriggerHelper   
*/
public class SessionScheduleCmpController {
    static Set<String> fieldsApiName;
    static boolean isClassAccessible = false;
    static boolean isSessionAccessible = false;
    
    @auraEnabled
    // generating sessions through sessionWrapper on Class_Term__c by fetching Class__c and Teacher fields 
    public static List<sessionWrapper> generateSession(String clsTermId){
        fieldsApiName = new Set<String>{'Id', 'Name', 'Course__c','Teacher__c', 'Start_Time__c', 'End_Time__c', 'Days_of_Week__c','Location__c',
            'Duration__c','Duration_Unit__c','Starting_Module__c'};
            isClassAccessible = FieldPremissionCrudUtility.checkReadPermission('educato__Class__c',fieldsApiName,false);    
        Boolean isClsTermAccessible = FieldPremissionCrudUtility.checkReadPermission('educato__Class_Term__c',  new Set<String>{'Id', 'Name', 'Class__c', 'Start_Date__c', 'Sessions__c', 'Status__c', 'Skip__c'}, false);
        Boolean isHolidayAccessible = FieldPremissionCrudUtility.checkReadPermission('educato__Holiday__c', new Set<String>{'Id','Start_Date__c','End_Date__c'}, false);
        Boolean isTchrLeaveyAccessible = FieldPremissionCrudUtility.checkReadPermission('educato__Teacher_Leave__c', new Set<String>{'Id', 'Name', 'Status__c', 'Start_Date__c', 'End_Date__c','Teacher__c'}, false);
        Boolean isTchrWrkHressible = FieldPremissionCrudUtility.checkReadPermission('educato__Teacher_Working_Hours__c', new Set<String>{'Id','Day__c','End_Time__c','Start_Time__c','Active__c','Teacher__c'}, false);
        Boolean isCourseModuleAccessible = FieldPremissionCrudUtility.checkReadPermission('educato__Course_Module__c', new Set<String>{'Id','Name',
            'Module__c','Duration__c','Sequence__c','Course__c'}, false);
        Boolean isModuleAccessible = FieldPremissionCrudUtility.checkReadPermission('educato__Module__c', new Set<String>{'Id','Name'}, false);
        Boolean isModuleLessonAccessible = FieldPremissionCrudUtility.checkReadPermission('educato__Module_Lesson__c', new Set<String>{'Id','Name',
            'Duration__c','Module__c','Lesson_Name__c','Lesson__c','Sequence__c'}, false);
        
        List<sessionWrapper> sessList  = new List<sessionWrapper>();
        if(isClsTermAccessible && isHolidayAccessible && isTchrLeaveyAccessible && isTchrWrkHressible && isCourseModuleAccessible && isModuleAccessible && isModuleLessonAccessible){
            List<Class_Term__c> clsTermList = [SELECT Id, Name, Class__c, Class__r.Name, Class__r.Teacher__c, Class__r.Teacher__r.Name, Start_Date__c,End_Date__c, 
                                               Class__r.Start_Time__c, Class__r.End_Time__c, Class__r.Days_of_Week__c, Sessions__c, Class__r.Duration__c,
                                               Class__r.Duration_Unit__c, Exclude_Public_Holidays__c, Class__r.Location__c,
                                               Class__r.educato__Course__c,
                                               Class__r.educato__Starting_Module__c,Class__r.educato__Starting_Module__r.educato__Sequence__c  
                                               FROM Class_Term__c WHERE Id=:clsTermId AND Status__c='Draft' LIMIT 1];
            
            if(clsTermList.size() > 0){
                Class_Term__c clsTrm = clsTermList.get(0);
                String courseId = clsTrm.Class__r.educato__Course__c;
                Decimal strtngModuleSeq = 0;
                List<educato__Course_Module__c> listCourseModule = new List<educato__Course_Module__c>();
                List<String> listModuleId = new List<String>();
                Set<String> setModuleId = new Set<String>();
                Map<Id,educato__Module__c> mapModuleToModuleLessons = new Map<Id,educato__Module__c>();
                Map<Decimal,educato__Course_Module__c> mapSequenceToCourseModule = new Map<Decimal,educato__Course_Module__c>();
                Map<Decimal,educato__Module_Lesson__c> mapSequenceToModuleLesson = new Map<Decimal,educato__Module_Lesson__c>();
                Map<String,String> mapSequenceToModuleLessonId = new Map<String,String>();
                
                if(String.isNotBlank(clsTrm.Class__r.educato__Starting_Module__c) && clsTrm.Class__r.educato__Starting_Module__r.educato__Sequence__c != NULL)
                    strtngModuleSeq = clsTrm.Class__r.educato__Starting_Module__r.educato__Sequence__c;
                
                if(strtngModuleSeq > 0){
                    listCourseModule = [SELECT Id,Name,educato__Module__c,educato__Module__r.Name,educato__Duration__c,educato__Sequence__c
                                        FROM educato__Course_Module__c WHERE educato__Course__c =: courseId AND 
                                        educato__Sequence__c >=: strtngModuleSeq ORDER BY educato__Sequence__c];
                    system.debug('listCourseModule-->'+listCourseModule.size() );
                    
                    if(listCourseModule.size() > 0){
                        for(educato__Course_Module__c cModule : listCourseModule){
                            setModuleId.add(cModule.educato__Module__c);
                        }
                    }
                    
                    if(setModuleId.size() > 0){
                        mapModuleToModuleLessons = new Map<Id,Module__c>([SELECT Id,Name,(SELECT Id,Name,educato__Duration__c,
                                                                                          educato__Module__c,educato__Lesson_Name__c,
                                                                                          educato__Lesson__c
                                                                                          FROM Module_Lessons__r ORDER BY Sequence__c) 
                                                                          FROM Module__c WHERE Id IN:setModuleId]);
                    }
                    system.debug('mapModuleToModuleLessons-->'+mapModuleToModuleLessons);
                }
                
                Integer sessCount = 1;
                if(listCourseModule.size() > 0){
                    for(educato__Course_Module__c cModule : listCourseModule){
                        Decimal modDuration = cModule.educato__Duration__c;
                        While(modDuration > 0){
                            if(sessCount <= clsTrm.Sessions__c){
                                mapSequenceToCourseModule.put(sessCount,cModule);
                                sessCount++;
                            }
                            modDuration = modDuration - clsTrm.Class__r.Duration__c;
                        }
                    }
                    
                    Integer sessCountForLesson = 1;
                    if(mapModuleToModuleLessons.keySet().size() > 0){
                        for(Course_Module__c module : listCourseModule){
                            if(mapModuleToModuleLessons.get(module.educato__Module__c).Module_Lessons__r.size() > 0){
                                for(educato__Module_Lesson__c modless : mapModuleToModuleLessons.get(module.educato__Module__c).Module_Lessons__r){     
                                    Decimal modLessDuration = modless.educato__Duration__c;
                                    While(modLessDuration > 0){                                
                                        if(sessCountForLesson <= clsTrm.Sessions__c){  
                                            system.debug('educato__Lesson_Name__c-->'+modless.educato__Lesson_Name__c);
                                            mapSequenceToModuleLesson.put(sessCountForLesson,modless);
                                            mapSequenceToModuleLessonId.put(modless.educato__Module__c+'*'+modless.educato__Lesson__c,modless.Id);
                                            sessCountForLesson++;
                                        }
                                        modLessDuration = modLessDuration - clsTrm.Class__r.Duration__c;
                                    }
                                }
                            }
                        }
                        system.debug('mapSequenceToModuleLesson-->'+mapSequenceToModuleLesson);
                    }
                }
                system.debug('mapSequenceToModuleLesson-->'+mapSequenceToModuleLesson.keySet().size());
                // comparing teacher availablity based on Teacher_Leave__c through Dates.       
                Map<Date, Teacher_Leave__c> tchrLeaveMap = new Map<Date, Teacher_Leave__c>();
                for(Teacher_Leave__c tchrLv: [SELECT Id, Name, Status__c, Start_Date__c, End_Date__c 
                                              FROM Teacher_Leave__c WHERE Teacher__c =: clsTrm.Class__r.Teacher__c AND 
                                              Start_Date__c != null AND End_Date__c != null AND Status__c != 'Rejected']){
                                                  
                                                  for(Date stDt=tchrLv.Start_Date__c; stDt<=tchrLv.End_Date__c; stDt=stDt.addDays(1))
                                                      tchrLeaveMap.put(stDt, tchrLv);
                                              }
                List<String> listTeachWorkHour = new List<String>();
                for(Teacher_Working_Hours__c techWrkHour : [SELECT Id,Day__c,End_Time__c,Start_Time__c,Active__c,Teacher__c
                                                            FROM Teacher_Working_Hours__c WHERE Active__c = true AND
                                                            Teacher__c =: clsTrm.Class__r.Teacher__c AND 
                                                            Start_Time__c <=: clsTrm.Class__r.Start_Time__c AND End_Time__c >=: clsTrm.Class__r.End_Time__c]){
                                                                if(techWrkHour.Day__c.contains(clsTrm.Class__r.Days_of_Week__c)){
                                                                    listTeachWorkHour.add(techWrkHour.Teacher__c);
                                                                }
                                                            }
                // comparing and omit the holidays which occur during generate sessions        
                List<Date> listOfHolidays = new List<Date>();
                for (Holiday__c holidays : [Select Id,Start_Date__c,End_Date__c,Start_Time__c,End_Time__c from Holiday__c WHERE Start_Date__c != null AND Start_Time__c <: clsTrm.Class__r.Start_Time__c AND End_Time__c >: clsTrm.Class__r.End_Time__c]){
                    if (holidays.End_Date__c!=NULL){
                        while (holidays.Start_Date__c<=holidays.End_Date__c){
                            listOfHolidays.add(holidays.Start_Date__c);
                            holidays.Start_Date__c = holidays.Start_Date__c.addDays(1);                       
                        }
                    }else{
                        listOfHolidays.add(holidays.Start_Date__c);
                    }
                }
                Date sDate = clsTrm.Start_Date__c;
                DateTime stDate = DateTime.newInstance(sDate.year(),sDate.month(),sDate.day(),00,00,00);
                
                Date eDate = clsTrm.End_Date__c;
                DateTime endDate = DateTime.newInstance(eDate.year(),eDate.month(),eDate.day(),00,00,00);
                system.debug('stDate@@-->'+stDate);
                Integer i = 1;
                system.debug('endDate-->'+endDate);
                while(i<=clsTrm.Sessions__c && stDate <= endDate){                
                    /*  if (clsTrm.Skip__c){
//  Holiday__c dates should omit and Days_of_Week__c multi-picklist must contain corresponding week of Start_Date__c 
if((!ConstantClass.isEscapePublicHoliday && !listOfHolidays.contains(stDate.date())) && clsTrm.Class__r.Days_of_Week__c.contains(stDate.format('EEE'))){
sessList.add(createSess(clsTrm, i, tchrLeaveMap, stDate));
//sessList.add(fillSession(cls, i, stDate.date()));
//sess.Start_Date__c = Datetime.newInstance(dt, cls.Start_Time__c);
//sess.End_Date__c = Datetime.newInstance(dt, cls.End_Time__c);
i++;            
}
}
// Holiday dates shouldn't omit while inserting schedule sessions by verfying Skip checkbox is False in class Term.
else if(clsTrm.Class__r.Days_of_Week__c.contains(stDate.format('EEE'))) {
sessList.add(createSess(clsTrm, i, tchrLeaveMap, stDate));
i++;        
}*/
                    
                    if(clsTrm.Class__r.Days_of_Week__c.contains(stDate.format('EEE'))){
                        system.debug('stDate---->'+stDate);
                        if(!(listOfHolidays.contains(stDate.date()) && clsTrm.Exclude_Public_Holidays__c == true)){
                            
                            if(listOfHolidays.contains(stDate.date())){
                                sessList.add(fillSessWrapper(clsTrm, i, tchrLeaveMap,listTeachWorkHour, stDate,'It is Holiday'
                                                             ,mapSequenceToCourseModule,mapSequenceToModuleLesson,mapSequenceToModuleLessonId));
                                //i++;
                            }else{
                                sessList.add(fillSessWrapper(clsTrm, i, tchrLeaveMap,listTeachWorkHour, stDate,null
                                                            ,mapSequenceToCourseModule,mapSequenceToModuleLesson,mapSequenceToModuleLessonId));
                                //i++;    
                            }
                            i++;
                        }
                    }
                    //System.debug('@@@-->'+stDate);
                    stDate = stDate.addDays(1);
                }
            }
        }
        return sessList;
    }
    // Function for inserting schedule sessions
    public static sessionWrapper fillSessWrapper(Class_Term__c clsTrm, Integer i, Map<Date, Teacher_Leave__c> tchrLeaveMap,List<String> listTeachWorkHour, DateTime stDate,String messageOnRemarks,
                                                Map<Decimal,educato__Course_Module__c> mapSequenceToCourseModule,Map<Decimal,educato__Module_Lesson__c> 
                                               mapSequenceToModuleLesson,Map<String,String> mapSequenceToModuleLessonId){
        sessionWrapper sess = new sessionWrapper();
        if(isClassAccessible){
            sess.seqNo        = i;
            sess.clsId        = clsTrm.Class__c;
            sess.clsName      = clsTrm.Class__r.Name;
            sess.tchrId       = clsTrm.Class__r.Teacher__c;
            sess.tchrName     = clsTrm.Class__r.Teacher__r.Name;
            sess.clsLocId	  = clsTrm.Class__r.Location__c;
            sess.status       = ConstantClass.ScheduledStatus;
            sess.stDate       = stDate.date();
            sess.sessDay      = stDate.format('EEE');
            sess.stTime       = clsTrm.Class__r.Start_Time__c;
            sess.duration     = clsTrm.Class__r.Duration__c;
            sess.durationUnit = clsTrm.Class__r.Duration_Unit__c;
            sess.exceptionVal = '';
            sess.module 	  = (mapSequenceToCourseModule.containsKey(i) ? mapSequenceToCourseModule.get(i).educato__Module__r.Name : null);
            sess.lesson 	  = (mapSequenceToModuleLesson.containsKey(i) ? mapSequenceToModuleLesson.get(i).educato__Lesson_Name__c : null);
            String moduleId   = (mapSequenceToCourseModule.containsKey(i) ? mapSequenceToCourseModule.get(i).educato__Module__c : null);
            String lessonId   = (mapSequenceToModuleLesson.containsKey(i) ? mapSequenceToModuleLesson.get(i).educato__Lesson__c : null);
            if(String.isNotBlank(moduleId) && String.isNotBlank(lessonId)){
                String key = moduleId+'*'+lessonId;
                sess.modulelesson = (mapSequenceToModuleLessonId.containsKey(key) ? mapSequenceToModuleLessonId.get(key) : null);
            }
            
            system.debug('sess.stDate-->'+sess.stDate);
            if(String.isNotBlank(messageOnRemarks)){
                sess.isShowMessageOnRemarks = true;
                sess.exceptionVal = messageOnRemarks;
            }
            
            
            if(!listTeachWorkHour.contains(sess.tchrId)){
                if(!sess.isShowMessageOnRemarks)
                    sess.isShowMessageOnRemarks = true;
                //sess.isOnLeave = true;
                sess.exceptionVal   = sess.exceptionVal +'\r\nTeacher is not available.';
                system.debug('sess.exceptionVal-->'+sess.exceptionVal);
            }
            
            if(tchrLeaveMap.containsKey(sess.stDate)){
                if(!sess.isShowMessageOnRemarks)
                    sess.isShowMessageOnRemarks = true;
                //sess.isOnLeave = true;
                if(tchrLeaveMap.get(sess.stDate).Status__c == 'Requested')
                    sess.exceptionVal   = sess.exceptionVal +'\r\nTeacher has requested a leave';
                else if(tchrLeaveMap.get(sess.stDate).Status__c == ConstantClass.approvedStatus)
                    sess.exceptionVal   = sess.exceptionVal +'\r\nTeacher is on leave';
                system.debug('sess.exceptionVal-->'+sess.exceptionVal);
            }
        }
        return sess;
    }
    
    @auraEnabled
    // inserting sessions when a schedule button is clicked on Class_Term__c UI
    public static List<Session__c> insertSessions (List<sessionWrapper> sessList,Id recordId) {
        fieldsApiName = new Set<String>{'Class__c','Sequence__c','Teacher__c','Status__c','Location__c','Session_Date__c','Duration__c','Duration_Unit__c','Start_Time__c','Class_Term__c','Notes__c','Exception__c'};
            isSessionAccessible = FieldPremissionCrudUtility.checkReadPermission('educato__Session__c',fieldsApiName,true,false); 
        Boolean isClsTermAccessible = FieldPremissionCrudUtility.checkReadPermission('educato__Class_Term__c',  new Set<String>{'Name','Start_Date__c','End_Date__c','Status__c'},true,false);
        Boolean isClassAccessible = FieldPremissionCrudUtility.checkReadPermission('educato__Class__c',new Set<String>{'Type__c','End_Date__c','Advance_Scheduling_Unit__c','Next_Schedule_Date__c','Last_Session_Date__c','Last_Session_Scheduled_Date__c','Sessions__c'},true,false);
        if(isSessionAccessible && isClsTermAccessible && isClassAccessible){    
            List <Session__c> insertSessList = new List<Session__c>();
            for(sessionWrapper sess : sessList){
                insertSessList.add(fillSession(sess, recordId));
            } 
            if (insertSessList.size()>0){ 
                insert insertSessList;
                createStudentSessions(insertSessList);
            }
            
            if(recordId!=null && insertSessList.size()>0) {
                // update Class_Term__c records when sessions are inserted and status changed to schedule
                Class_Term__c clsTerm = new Class_Term__c();
                clsTerm.id                                      = recordId;
                clsTerm.Status__c                               = ConstantClass.ScheduledStatus;
                clsTerm.Start_Date__c                           = insertSessList[0].Session_Date__c;
                clsTerm.End_Date__c                             = insertSessList[insertSessList.size()-1].Session_Date__c;
                update clsTerm;   
                
                List<Class__c> clsList = [SELECT Id, Advance_Scheduling_Unit__c, Last_Session_Date__c, Next_Schedule_Date__c,
                                          Advance_Scheduling__c,Type__c 
                                          FROM Class__c 
                                          WHERE Id =: insertSessList[0].Class__c];
                
                // update Class__c records when sessions are inserted
                if(clsList.size() > 0){
                    Class__c clsUpd = clsList.get(0);
                    clsUpd.Last_Session_Date__c           = clsTerm.End_Date__c;
                    clsUpd.Last_Session_Scheduled_Date__c = Date.today();
                    
                    // update Class_c End_date when type is Fixed
                    if (String.isNotBlank(clsUpd.Type__c)){
                        if(clsUpd.Type__c == ConstantClass.fixedType){
                            clsUpd.End_Date__c = clsTerm.End_Date__c;
                        }else{
                            // Update Class__c field name Next_Schedule_Date__c according to Advance_Scheduling_Unit__c(picklist) selection
                            if(String.isNotBlank(clsUpd.Advance_Scheduling_Unit__c) && clsUpd.Advance_Scheduling__c != NULL){
                                Integer days =Integer.valueOf(clsUpd.Advance_Scheduling__c);
                                if(clsUpd.Advance_Scheduling_Unit__c == ConstantClass.schedulingPicklistDay){
                                    clsUpd.Next_Schedule_Date__c = clsUpd.Last_Session_Date__c.addDays(-days); 
                                }else if (clsUpd.Advance_Scheduling_Unit__c == ConstantClass.schedulingPicklistWeek){
                                    clsUpd.Next_Schedule_Date__c = clsUpd.Last_Session_Date__c.addDays(-(days*7));
                                }else if (clsUpd.Advance_Scheduling_Unit__c == ConstantClass.schedulingPicklistMonth){
                                    clsUpd.Next_Schedule_Date__c = clsUpd.Last_Session_Date__c.addMonths(-days);
                                }                    
                            }else{ 
                                clsUpd.Next_Schedule_Date__c = clsUpd.Last_Session_Date__c.addMonths(-ConstantClass.defaultNextScheDtDiff);
                            }              
                        }
                    }
                    update clsUpd;
                }
            }   
            return insertSessList;
        }
        return null;
    } 
    
    public static Session__c fillSession(sessionWrapper sess, String clsTermId){
        Session__c session  = new Session__c();
        session.Class__c         = sess.clsId;
        session.Sequence__c      = sess.seqNo;
        session.Teacher__c       = sess.tchrId;
        session.Status__c        = sess.status;
        session.Session_Date__c  = sess.stDate;
        session.Duration__c      = sess.duration;
        session.Duration_Unit__c = sess.durationUnit;
        session.Start_Time__c    = sess.stTime;
        session.Location__c		 = sess.clsLocId;
        session.Class_Term__c    = clsTermId;
        session.Notes__c         = sess.remarks; 
        session.educato__Exception__c = sess.exceptionVal; 
        session.educato__Module_Lesson__c = sess.moduleLesson;
        session.Type__c          = ConstantClass.sessionStandardType;
        if(sess.isShowMessageOnRemarks)
            session.Type__c      = ConstantClass.sessionExceptionType;
        return session;
    }
    
    // Insert student sessions when sessions are created by class enrollments student
    public static void createStudentSessions (List<Session__c> sessList){
        Class__c clsId = new Class__c(id=sessList[0].Class__c);
        List<Student_Session__c> studSessList = new List<Student_Session__c>();
        for(Enrollment__c enroll : [select name,class__c,Student__c from Enrollment__c where Class__c =: clsId.Id]){
            for (integer s=0; s< sessList.size(); s++){
                Student_Session__c stuSess = new Student_Session__c();
                stuSess.Session__c    = sessList[s].id;
                stuSess.Account__c    = enroll.Student__c;
                stuSess.Enrollment__c = enroll.id;
                stuSess.Status__c     = ConstantClass.ScheduledStatus;
                studSessList.add(stuSess);
            }
        }
        
        if(studSessList.size() > 0)
            insert studSessList;
    }
    
    
    // sessionWrapper class for recieving input
    public class sessionWrapper{
        @AuraEnabled public Integer seqNo{get;set;}
        @AuraEnabled public String  clsId{get;set;}
        @AuraEnabled public String  clsName{get;set;}
        @AuraEnabled public String  tchrId{get;set;}
        @AuraEnabled public String  tchrName{get;set;}
        @AuraEnabled public String  clsLocId{get;set;}
        @AuraEnabled public String  status{get;set;}
        @AuraEnabled public Date    stDate{get;set;}
        @AuraEnabled public String  sessDay{get;set;}
        @AuraEnabled public Boolean isOnLeave{get;set;}
        @AuraEnabled public Time    stTime{get;set;}
        @AuraEnabled public Decimal duration{get;set;}
        @AuraEnabled public String durationUnit{get;set;}
        @AuraEnabled public String remarks{get;set;}
        @AuraEnabled public String exceptionVal{get;set;}
        @AuraEnabled public String module{get;set;}
        @AuraEnabled public String lesson{get;set;}
        @AuraEnabled public String modulelesson{get;set;}
        @AuraEnabled public Boolean isShowMessageOnRemarks{get;set;}
        
        // gets true if teacher is on leave while inserting sessions by comparing Date 
        public sessionWrapper(){
            //isOnLeave = false;
            isShowMessageOnRemarks = false;
        }
    }
}