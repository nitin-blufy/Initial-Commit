global with sharing class SessionActionController {
    static Set<String> fieldsApiName;
    static boolean isSessionAccessible = false;
    static boolean isStudentSessionAccessible = false;
    static boolean isHistoryAccessible = false;    

    /**
    Name        :   fetchSessionsDetail
    Date        :   03 Mar 2020
    Description :   it's use for to get the session details which we can show on session detail modal
    Developer   :   
    */
    @RemoteAction
    global static List<Session__c> fetchSessionsDetail(String sessionId){ 
        if(FieldPremissionCrudUtility.checkReadPermission('Account', new Set<String>{'Id','Name'}, false) && FieldPremissionCrudUtility.checkReadPermission('educato__Class__c', new Set<String>{'Id','Name'}, false)){
            fieldsApiName = new Set<String>{'Id', 'Duration__c', 'Duration_Unit__c', 'Session_date__c', 'Start_Time__c', 'Notes__c', 'Type__c'};
            isSessionAccessible = FieldPremissionCrudUtility.checkReadPermission('educato__Session__c', fieldsApiName, false);
            if(isSessionAccessible){
                String query = 'SELECT Id, Name, educato__Teacher__r.location__r.Name, educato__Teacher__r.Name, educato__Class__r.Name, educato__Duration__c, educato__Duration_Unit__c, educato__Session_date__c, educato__Start_Time__c, educato__Notes__c, educato__Type__c, educato__Lesson__c, educato__Module__c, educato__Class__r.educato__Course__r.Name FROM Session__c ';
                if(String.isNotBlank(sessionId)){
                    query += 'WHERE Id =: sessionId ';
                }                
                List<Session__c> sessionList = Database.query(query);
                if(sessionList.size() > 0){
                    return sessionList;
                }
            }        
        }    
        return null;
    }      
    
    /**
    Name        :   fecthSessionResourceDetail
    Date        :   17 Mar 2020
    Description :   commment function after discussed with Dharam And NITIN 
    Developer   :   
    */
    // @RemoteAction
    // global static  List<Session_Resource__c > fecthSessionResourceDetail(String resourceId){
    //     String query = 'SELECT id, Resource__r.Name, Session__r.Teacher__r.location__r.Name, Session__r.Teacher__r.Name , Session__r.Class__r.Name , Session__r.Duration__c, Session__r.Duration_Unit__c, Session__r.Session_date__c , Session__r.Start_Time__c  FROM Session_Resource__c  ';
    //     if(String.isNotBlank(resourceId)){
    //         query += 'WHERE Id =: resourceId ';
    //     }
    //     List<Session_Resource__c > sessionList = Database.query(query);
    //     if(sessionList.size() > 0){
    //         return sessionList;
    //     }
    //     return null;
    // }

    /**
    Name        :   getSessionStudent
    Date        :   04 Mar 2020
    Description :   it's use for to get the detail from Student_Session__c based on session id
    Developer   :   
    */
    @RemoteAction
    global static List<Student_Session__c> getSessionStudent(string sessionId){
        List<Student_Session__c> studentList = new List<Student_Session__c>();
        if(String.isNotBlank(sessionId)){
            fieldsApiName = new Set<String>{'Id', 'Status__c', 'Notes__c'};         
            if(FieldPremissionCrudUtility.checkReadPermission('educato__Session__c', new Set<String>{'Id','Name'}, false) &&  FieldPremissionCrudUtility.checkReadPermission('Account', new Set<String>{'Id','Name'}, false) && FieldPremissionCrudUtility.checkReadPermission('educato__Class__c', new Set<String>{'Id','Name'}, false)){
                isStudentSessionAccessible = FieldPremissionCrudUtility.checkReadPermission('educato__Student_Session__c', fieldsApiName, false);
                if(isStudentSessionAccessible){
                    studentList = [SELECT Id, Session__r.Teacher__r.Name, Account__r.Name, Session__r.Class__r.Name, Status__c, Notes__c FROM Student_Session__c WHERE Session__c =: sessionId];
                    if(studentList.size() > 0){
                        return studentList;
                    }
                }
            }        
        }
        return null;
    }
    
    /**
    Name        :   changeStudentStatus
    Date        :   04 Mar 2020
    Description :   it's use for change the status of students
    Developer   :   
    */
    @RemoteAction
    global static void changeStudentStatus(String sessionStudentsId,String status){ 
        List<Student_Session__c> studentList = new List<Student_Session__c>();
        fieldsApiName = new Set<String>{'Status__c'};
        isStudentSessionAccessible = FieldPremissionCrudUtility.checkReadPermission('educato__Student_Session__c', fieldsApiName, true);
        system.debug('isStudentSessionAccessible-->'+isStudentSessionAccessible);
        if(isStudentSessionAccessible){
            if(String.isNotBlank(sessionStudentsId)){
                List<String> ids = sessionStudentsId.split(',');
                for(String strObj : ids){
                    Student_Session__c sessionObj = new Student_Session__c(id = strObj);
                    if(status == 'Completed'){
                        sessionObj.Status__c = 'Attended';
                    }else if(status == 'No-show'){
                        sessionObj.Status__c = 'Not Attended';
                    }  
                    studentList.add(sessionObj);
                }
                if(studentList.size() > 0){
                    try{
                        update studentList;
                    }catch(Exception ex){
                        system.debug('Error -> '+ex.getMessage());                   
                    }
                }
            }
        }
    }
    
    /**
    Name        :   cancelStudentForSession
    Date        :   05 Mar 2020
    Description :   it's use for cancel student session
    Developer   :   
    */
    @RemoteAction
    global static void cancelStudentForSession(String sessionStudentsId){
        fieldsApiName = new Set<String>{'Status__c'};
        isStudentSessionAccessible = FieldPremissionCrudUtility.checkReadPermission('educato__Student_Session__c', fieldsApiName, true);
        if(isStudentSessionAccessible){
            if(String.isNotBlank(sessionStudentsId)){
                Student_Session__c sessionStuObj = new Student_Session__c(id = sessionStudentsId);            
                sessionStuObj.status__c = 'Canceled';
                try{
                    update sessionStuObj;
                }catch(Exception ex){
                    system.debug('Error -> '+ex.getMessage());                   
                }
            }
        }
    }
    
    /**
    Name        :   cancelSession
    Date        :   05 Mar 2020
    Description :   it's use for cancel the session records
    Developer   :   
    */
    @RemoteAction
    global static void cancelSession(String sessionId){
        if(String.isNotBlank(sessionId)){
            Session__c sessionObj = new Session__c(id = sessionId);            
            sessionObj.status__c = 'Canceled';
            try{
                update sessionObj;
            }catch(Exception ex){
                system.debug('Error -> '+ex.getMessage());                   
            }
        }
    }
    
     /**
    Name        :   getSessionHistoryRecords
    Date        :   12 Mar 2020
    Description :   it's use for to get session history
    Developer   :   
    */
    @RemoteAction
    global static List<SessionHistoryModal> getSessionHistoryRecords(String sessionId){

        List<SessionHistoryModal> sessionHistoryModalList = new List<SessionHistoryModal>();       
        fieldsApiName = new Set<String>{'Id', 'ParentId',  'CreatedById', 'CreatedDate', 'Field', 'OldValue', 'NewValue'};
        isHistoryAccessible = FieldPremissionCrudUtility.checkReadPermission('educato__Session__History', fieldsApiName, false); 
        if(isHistoryAccessible){
            if(String.isNotBlank(sessionId)){
                for(Session__History sessionHistoryObj : [SELECT Id, ParentId, CreatedBy.Name, CreatedById, CreatedDate, Field, OldValue, NewValue FROM Session__History WHERE ParentId =: sessionId ORDER BY CreatedDate desc]){
                    SessionHistoryModal sessionModalObj = new SessionHistoryModal();
                    String description = '';
                    sessionModalObj.historyBy = sessionHistoryObj.CreatedBy.Name;
                    sessionModalObj.createdDate = sessionHistoryObj.CreatedDate.format('EEE, MMM dd yyyy h:mm a');
                    Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
                    Schema.SObjectType leadSchema = schemaMap.get('educato__Session__c');
                    Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();                                                                                   
                    description += 'Session ';
                    if(sessionHistoryObj.Field != 'created' && fieldMap.containsKey(sessionHistoryObj.Field)){
                        description +=  fieldMap.get(sessionHistoryObj.Field).getDescribe().getLabel();
                        String[] strTimeSplit;
                        String newTime;
                        description += ' changed from ';                  
                        if(sessionHistoryObj.OldValue instanceOf TIME && sessionHistoryObj.NewValue instanceOf TIME){
                            strTimeSplit = String.valueOf(sessionHistoryObj.OldValue).split(':');
                            newTime = strTimeSplit[0] +':'+strTimeSplit[1] +':00';  
                            description +=  newTime + ' to '; 
                            
                            strTimeSplit = String.valueOf(sessionHistoryObj.NewValue).split(':');
                            newTime = strTimeSplit[0] +':'+strTimeSplit[1] +':00';    
                            description +=  newTime; 
                        }else if(sessionHistoryObj.OldValue instanceOf date && sessionHistoryObj.NewValue instanceOf date){
                            description += Date.valueOf(sessionHistoryObj.OldValue).format()+' to '+Date.valueOf(sessionHistoryObj.NewValue).format();
                        }else{
                            description += sessionHistoryObj.OldValue+' to '+sessionHistoryObj.NewValue;
                        }                   
                    }else{
                        description += sessionHistoryObj.Field;
                    }
                    sessionModalObj.description = description;
                    sessionHistoryModalList.add(sessionModalObj);
                }           
            }
        }
        return sessionHistoryModalList;
    }
    // /**
    // Name        :   
    // Date        :   13 Mar 2020
    // Description :   
    // Developer   :   
    // */
    // @RemoteAction
    // global static List<Account> getStudentRecords(String keywordToSearch){
    //     Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();  
    //     //system.debug('devRecordTypeId '+devRecordTypeId);
    //     String query = 'SELECT Id, Name, PersonEmail, Phone FROM Account WHERE  recordtype.Id =: devRecordTypeId';
    //     if(String.isNotBlank(keywordToSearch)){
    //         query += ' AND Name like  \'%' + keywordToSearch + '%\'';
    //     }else{
    //         query += ' LIMIT 5';
    //     }
    //     //system.debug('query '+query);
    //     List<Account> accList = Database.query(query);
    //     //system.debug('accList->' +accList);
    //     if(accList.size() > 0){
    //         return accList;
    //     }
    //     return null;
    // }
    
    
    global class SessionHistoryModal{
        public String createdDate;           
        public String historyBy;        
        public String description;        
    }
}