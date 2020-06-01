/*
* Author : Shubhi Saxena
* created on : 02/04/2020
*
*
* Objects : Class__c,Session__c
* Description : This Batch Class is used to create session records to auto-maintain the 3 months records scenario
* for the classes with open status & Monthly frequency.
*/

global with sharing class SessionRecordsCreationBatchApex implements Database.Batchable<sObject>{
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        Boolean isClassAccessible = FieldPremissionCrudUtility.checkReadPermission('educato__Class__c',  
                                                                                   new Set<String>{'Id','Name','Next_Schedule_Date__c','Last_Session_Date__c','Start_Date__c','Advance_Scheduling__c'
                                                                                       ,'Start_Time__c','Teacher__c','Duration_Unit__c','Duration__c','Days_of_Week__c','Sessions__c','Location__c'},false);
        Boolean isSessionAccessible = FieldPremissionCrudUtility.checkReadPermission('educato__Session__c',  
                                                                                     new Set<String>{'Id','Sequence__c'},false);
        if(isSessionAccessible && isClassAccessible){
            //**************Retrieving Class with Open Status, Monthly Frequency & Next Schedule Date is Today******************
            String query = 'SELECT Id,Name,Next_Schedule_Date__c,Last_Session_Date__c,Start_Date__c,Advance_Scheduling__c,Location__c,';
            query += 'Start_Time__c,Teacher__c,Duration_Unit__c,Duration__c,Days_of_Week__c,Sessions__c,';
            query += '(SELECT Id,Sequence__c FROM Sessions__r ORDER BY Sequence__c DESC LIMIT 1) FROM Class__c ';
            query += 'WHERE Status__c =\'Open\' AND Frequency__c = \'Monthly\'';
            return Database.getQueryLocator(query);
        }
        return null;
    }
    
    global void execute(Database.BatchableContext bc, List<Class__c> listClass){
        try{
            List<Session__c> listSessionToInsert = new List<Session__c>();
            List<Class__c> listClassToUpdate = new List<Class__c>();
            Set<String> setTeacherId = new Set<String>();
            List<Holiday__c> listOfHolidays = new List<Holiday__c>();
            Map<String,List<Teacher_Working_Hours__c>> mapTeacherIdToTechrWrkHour = new Map<String,List<Teacher_Working_Hours__c>>();
            Map<String,List<Teacher_Leave__c>> mapTeacherIdToTeacherLeave = new Map<String,List<Teacher_Leave__c>>();
            
            Boolean isClassAccessible = FieldPremissionCrudUtility.checkReadPermission('educato__Class__c',new Set<String>{'Next_Schedule_Date__c','Last_Session_Date__c','Last_Session_Scheduled_Date__c','Sessions__c'},true);
            Boolean isSessionAccessible = FieldPremissionCrudUtility.checkReadPermission('educato__Session__c',new Set<String>{'Sequence__c','Class__c','Teacher__c','Session_Date__c','Start_Time__c',
                'Status__c','Duration_Unit__c','Duration__c','Type__c'},true);
            Boolean isHolidayAccessible = FieldPremissionCrudUtility.checkReadPermission('educato__Holiday__c', new Set<String>{'Id','Start_Date__c','End_Date__c','Start_Time__c','End_Time__c'}, false);
            Boolean isTchrLeaveyAccessible = FieldPremissionCrudUtility.checkReadPermission('educato__Teacher_Leave__c', new Set<String>{'Id', 'Name', 'Status__c', 'Start_Date__c', 'End_Date__c','Teacher__c'}, false);
            Boolean isTchrWrkHressible = FieldPremissionCrudUtility.checkReadPermission('educato__Teacher_Working_Hours__c', new Set<String>{'Id','Day__c','End_Time__c','Start_Time__c','Active__c','Teacher__c'}, false);
            
            if(isClassAccessible && isSessionAccessible && isHolidayAccessible && isTchrLeaveyAccessible && isTchrWrkHressible){
                for(Class__c classRec : listClass){
                    setTeacherId.add(classRec.Teacher__c);
                }
                
                if(setTeacherId.size() > 0){
                    mapTeacherIdToTeacherLeave = UtilityClass.getTeacherLeaves(setTeacherId);
                    mapTeacherIdToTechrWrkHour = UtilityClass.getTeacherWorkingHour(setTeacherId);
                    listOfHolidays = UtilityClass.getHolidays();
                }
                
                for(Class__c classRec : listClass){
                    if(classRec.Advance_Scheduling__c != NULL && classRec.Last_Session_Date__c != NULL){
                        //********Adding Months to Last Session Date for which we need to create session records***************
                        Integer numOfMonths = (System.today().addMonths(Integer.valueOf(classRec.Advance_Scheduling__c))).month() - classRec.Last_Session_Date__c.month();
                        if(numOfMonths != NULL && numOfMonths > 0){
                            Date nextMonthSessDate = classRec.Last_Session_Date__c.addMonths(numOfMonths);
                            //**************Retrieving No. of Days in the Month for we need to create session records**************
                            Integer numOfMonthDays = Date.daysInMonth(nextMonthSessDate.year(),nextMonthSessDate.month());
                            Date lstDateOfNextMonth = Date.newInstance(nextMonthSessDate.year(),nextMonthSessDate.month(),numOfMonthDays);
                            //*******Getting the first session to be created after 1 day from Last Session Date****************
                            Date frstDateOfNextMonth = classRec.Last_Session_Date__c.addDays(1);
                            if(classRec.Sessions__r.size() > 0 && classRec.Sessions__r[0].Sequence__c != NULL){
                                system.debug('Integer.valueOf(classRec.Sessions__r[0].Sequence__c-->'+Integer.valueOf(classRec.Sessions__r[0].Sequence__c));
                                List<Session__c> listSession = UtilityClass.createSessionRecords(classRec,frstDateOfNextMonth,lstDateOfNextMonth,Integer.valueOf(classRec.Sessions__r[0].Sequence__c));                        
                                if(listSession != NULL && listSession.size() > 0){
                                    if(listSession.size() > 0){
                                        listSession = UtilityClass.getUpdatedSessions(Integer.valueOf(classRec.Sessions__r[0].Sequence__c),listSession, mapTeacherIdToTeacherLeave, mapTeacherIdToTechrWrkHour, listOfHolidays);
                                    }
                                    //********Updating Last session date with newly Created Session last session of The month************
                                    classRec.put('Last_Session_Date__c',listSession.get(listSession.size() - 1).Session_Date__c);
                                    classRec.put('Last_Session_Scheduled_Date__c',System.today());
                                    //********Updating Next Schedule Date for The next month on which this batch will execute************
                                    classRec.put('Next_Schedule_Date__c',classRec.Next_Schedule_Date__c.addMonths(1));
                                    //classRec.Sessions__c = classRec.Sessions__c + listSession.size();
                                    listSessionToInsert.addAll(listSession);
                                    listClassToUpdate.add(classRec);
                                }
                            }
                            else{
                                system.debug('Session Sequence value is Blank on the Class named '+classRec.Name);
                            }
                        }
                        else{
                            system.debug('Number of Months less than or equal to 0 for '+classRec.Name);
                        }
                    }
                    else{
                        system.debug('Either Advance Scheduling or Last Session Date value is blank.'+classRec.Name);
                    }
                }
                
                if(listSessionToInsert.size() > 0)
                    insert listSessionToInsert;
                
                if(listClassToUpdate.size() > 0)
                    update listClassToUpdate;
            }
            else{
                System.debug('FLS NOT FOUND.');
            }
        }
        catch(Exception e){
            System.debug('Message-->'+e.getMessage());
            System.debug('Line Number-->'+e.getLineNumber());
            
            Boolean isBlufyErrorAccessible = FieldPremissionCrudUtility.checkReadPermission('educato__Blufy_Error_Log__c',new Set<String>{'Process_Name__c','Description__c','Title__c'},true);
            if(isBlufyErrorAccessible){
                Blufy_Error_Log__c blufyErrLg = new Blufy_Error_Log__c();
                blufyErrLg.put('Process_Name__c','SessionRecordsCreationBatchApex');
                blufyErrLg.put('Description__c',e.getMessage());
                blufyErrLg.put('Title__c','Session Creation Batch');
                insert blufyErrLg;
        	}
        }
    }
    
    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }
}