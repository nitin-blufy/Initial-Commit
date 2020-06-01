/**
* @author
* @date 
*
* 
*
* Objects :-  Session__c, Class__c, Class_Term__c, Teacher(API Name- Account) Teacher_Leave__c, Holiday__c, Term__c  
Trigger :- ClassTrigger
Desc:- Creating Class term or sessions based on class type, frequency and status equals to open after class updation.
Create Class Term when class is update to Open status which having Type as fixed and Frequency as One-time.
Insert Class Term from Term object when class is update to Open status which having Type as Ongoing and Frequency as Term.
Create Sessions when class is update to Open status which having Frequency as Monthly and Advance scheduling unit as Month(s). 
*/
public class ClassTriggerHelper {
    //-------   Create a Term when A cLass status is updated from draft to open (Mar 23,2020)   -------//
    
    public static void createTerm (List <Class__c> clsList) {
        List <Class_Term__c> clsTermlist = new List <Class_Term__c>();
        List <Session__c> sessList = new List <Session__c>();
        List <Class__c> clsUpdList = new List <Class__c>();
        Set<String> setTeacherId = new Set<String>();
        List<Holiday__c> listOfHolidays = new List<Holiday__c>();
        Map<String,List<Teacher_Working_Hours__c>> mapTeacherIdToTechrWrkHour = new Map<String,List<Teacher_Working_Hours__c>>();
        Map<String,List<Teacher_Leave__c>> mapTeacherIdToTeacherLeave = new Map<String,List<Teacher_Leave__c>>();
        
        Boolean isClassAccessible = FieldPremissionCrudUtility.checkReadPermission('educato__Class__c',new Set<String>{'Id','Name','Start_Date__c','Advance_Scheduling__c','Advance_Scheduling_Unit__c','Type__c'
            ,'Frequency__c','Start_Time__c','Teacher__c','End_Date__c','Duration_Unit__c','Duration__c','Days_of_Week__c','Sessions__c','Location__c'},false);
        Boolean isTermAccessible = FieldPremissionCrudUtility.checkReadPermission('educato__Term__c',new Set<String>{'Id','Name','Start_Date__c','End_Date__c','Sessions__c','Status__c','Sequence__c'},false);    
        Boolean isHolidayAccessible = FieldPremissionCrudUtility.checkReadPermission('educato__Holiday__c', new Set<String>{'Id','Start_Date__c','End_Date__c','Start_Time__c','End_Time__c'}, false);
        Boolean isTchrLeaveyAccessible = FieldPremissionCrudUtility.checkReadPermission('educato__Teacher_Leave__c', new Set<String>{'Id', 'Name', 'Status__c', 'Start_Date__c', 'End_Date__c','Teacher__c'}, false);
        Boolean isTchrWrkHressible = FieldPremissionCrudUtility.checkReadPermission('educato__Teacher_Working_Hours__c', new Set<String>{'Id','Day__c','End_Time__c','Start_Time__c','Active__c','Teacher__c'}, false);
        
        Boolean isClassAccessibleForInsrtUpdte = FieldPremissionCrudUtility.checkReadPermission('educato__Class__c',new Set<String>{'Next_Schedule_Date__c','Last_Session_Date__c','Last_Session_Scheduled_Date__c'},true,false);
        Boolean isSessionAccessible = FieldPremissionCrudUtility.checkReadPermission('educato__Session__c',new Set<String>{'Sequence__c','Class__c','Teacher__c','Session_Date__c','Start_Time__c',
            'Status__c','Duration_Unit__c','Duration__c','Type__c'},true,false);
        Boolean isClsTermAccessible = FieldPremissionCrudUtility.checkReadPermission('educato__Class_Term__c',  new Set<String>{'Name','Start_Date__c','End_Date__c','Sessions__c','Status__c','Sequence__c','Term__c'},true,false);
        
        if(isClassAccessible && isTermAccessible && isHolidayAccessible && isTchrLeaveyAccessible && isTchrWrkHressible){
            List <Term__c> trmList = [SELECT Id,Name,Sessions__c,Start_Date__c,End_Date__c,Sequence__c 
                                      FROM Term__c 
                                      WHERE Sessions__c != null AND Start_Date__c != null AND 
                                      End_Date__c != null AND Sequence__c != null AND Status__c=:ConstantClass.openStatus
                                      ORDER By Sequence__c];
            
            for(Class__c cls : clsList){
                if(cls.Type__c.equalsIgnoreCase(ConstantClass.ongoingClsType) && cls.Start_Date__c != NULL &&
                   cls.Frequency__c.equalsIgnoreCase(ConstantClass.monthlyFrequency)){
                       setTeacherId.add(cls.Teacher__c);
                   }
            }
            
            if(setTeacherId.size() > 0){
                mapTeacherIdToTeacherLeave = UtilityClass.getTeacherLeaves(setTeacherId);
                mapTeacherIdToTechrWrkHour = UtilityClass.getTeacherWorkingHour(setTeacherId);
                listOfHolidays = UtilityClass.getHolidays();
            }
            
            for(Class__c cls : clsList) {
                
                //-------  Create Class Term by verfiying class Type equals to Ongoing & Frequency equals to Term --------//        
                if(cls.Type__c.equalsIgnoreCase(ConstantClass.ongoingClsType) && cls.Start_Date__c != NULL){
                    if (cls.Frequency__c.equalsIgnoreCase(ConstantClass.termFrequency)){
                        for (Term__c term: trmList) {
                            clsTermlist.add(UtilityClass.fillClsTerm(cls, term));
                        } 
                        
                        //-------  Create sessions by verfiying class Type equals to Ongoing & Frequency equals to Month  --------//              
                    }else if (cls.Frequency__c.equalsIgnoreCase(ConstantClass.monthlyFrequency)){
                        if (String.isNotBlank(cls.Advance_Scheduling_Unit__c) && cls.Advance_Scheduling_Unit__c.equalsIgnoreCase(ConstantClass.schedulingPicklistMonth)
                            && cls.Advance_Scheduling__c != NULL){
                                Date sessEndDate = cls.Start_Date__c.addMonths(Integer.valueOf(cls.Advance_Scheduling__c));
                                //sessList.addAll(fillSchSession(cls, null, sessEndDate));
                                // DateTime stDate = (DateTime) cls.Start_Date__c;
                                Integer numberOfDays = Date.daysInMonth(sessEndDate.year(), sessEndDate.month());
                                Date lastDayOfMonth = Date.newInstance(sessEndDate.year(), sessEndDate.month(), numberOfDays);
                                sessList.addAll(UtilityClass.createSessionRecords(cls, cls.Start_Date__c, lastDayOfMonth, 0));    
                            }else {//Adding default month for monthly Frequency
                                Date sessEndDate = cls.Start_Date__c.addMonths(ConstantClass.defaultNextScheDtDiff);
                                //sessList.addAll(fillSchSession(cls, null, sessEndDate));
                                Integer numberOfDays = Date.daysInMonth(sessEndDate.year(), sessEndDate.month());
                                Date lastDayOfMonth = Date.newInstance(sessEndDate.year(), sessEndDate.month(), numberOfDays);
                                sessList.addAll(UtilityClass.createSessionRecords(cls, cls.Start_Date__c, lastDayOfMonth, 0));
                            } 
                    }
                    if(sessList.size() > 0){
                        sessList = UtilityClass.getUpdatedSessions(0,sessList, mapTeacherIdToTeacherLeave, mapTeacherIdToTechrWrkHour, listOfHolidays);
                    }
                    Date nextSchDate = Date.newInstance(cls.Start_Date__c.addMonths(1).year(), cls.Start_Date__c.addMonths(1).month(), 1);
                    //Updating class when sessions are created
                    if (sessList.size() > 0){
                        clsUpdList.add(new class__c(Id = cls.id, 
                                                    Last_Session_Scheduled_Date__c = System.today(),
                                                    Last_Session_Date__c = sessList.get(sessList.size()-1).Session_Date__c,
                                                    Next_Schedule_Date__c= nextSchDate));   
                    }
                    //-------  Create Class Term by verfiying class Type equals to Ongoing & Frequency equals to Fixed  --------//           
                }else if(cls.Type__c.equalsIgnoreCase(ConstantClass.fixedType)){
                    clsTermlist.add(UtilityClass.fillClsTerm(cls, null));
                }
            }
        }
        
        if(isClsTermAccessible){
            if(clsTermlist.size() > 0)
                insert clsTermlist;
        }
        else
            system.debug('FLS NOT FOUND for Class Term');
        
        if(isSessionAccessible){
            if (sessList.size() > 0)
                insert sessList;
        }
        else
            system.debug('FLS NOT FOUND for Session');
        
        if(isClassAccessibleForInsrtUpdte){
            if(clsUpdList.size() > 0)
                update clsUpdList;
        }
        else
            system.debug('FLS NOT FOUND for Class');
    }
    //------- Function for inserting schedule sessions  --------//  
    /*   public static List<Session__c> fillSchSession (Class__c cls, Date sessStartDate, Date sessEndDate){
List <Session__c> sessList = new List <Session__c>();
//Extract number of days in a month from Class session last date 
Integer numberOfDays = Date.daysInMonth(sessEndDate.year(), sessEndDate.month());
Date lastDayOfMonth = Date.newInstance(sessEndDate.year(), sessEndDate.month(), numberOfDays);
DateTime stDate = (DateTime) cls.Start_Date__c;
if(sessStartDate != null)
stDate = sessStartDate;

Integer i = 1;
while(stDate <= lastDayOfMonth){
if(cls.Days_of_Week__c.contains(stDate.format('EEE'))){
Session__c sess = new Session__c();
sess.Sequence__c      = i;
sess.Class__c    	  = cls.Id;
sess.Teacher__c  	  = cls.Teacher__c;
sess.Session_Date__c  = stDate.date();
sess.Start_Time__c    = cls.Start_Time__c;
sess.Status__c 		  = ConstantClass.ScheduledStatus;
sess.Duration_Unit__c = cls.Duration_Unit__c;
sess.Duration__c 	  = cls.Duration__c;
sessList.add(sess);
i++;	    
System.debug('stDate-->'+stDate);
}
stDate = stDate.addDays(1);
}
return sessList;
}*/
    
    
}