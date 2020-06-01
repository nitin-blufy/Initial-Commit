@isTest
public class SessionRecordsCreationBatchApexTest {
    
    @testSetup
    static void testDataSetup(){
        BlufyTestUtil.init();        
    }
    
    @isTest
    static void test1(){
        Account teacherObj = [SELECT Id,Name FROM Account WHERE RecordType.Name = 'Teacher' LIMIT 1];
        
        Class__c classObj = [SELECT Id,Type__c,Frequency__c,Last_Session_Date__c,Last_Session_Scheduled_Date__c,Next_Schedule_Date__c
                             FROM Class__c LIMIT 1];
        
        Session__c sessionObj = [SELECT Id FROM Session__c LIMIT 1];
        sessionObj.Sequence__c = 1;
        sessionObj.Class__c = classObj.Id;
        update sessionObj;
        
        classObj.Type__c = ConstantClass.ongoingClsType;
        classObj.Frequency__c = ConstantClass.monthlyFrequency;
        classObj.Last_Session_Date__c = System.today().addMonths(2);
        classObj.Last_Session_Scheduled_Date__c = System.today();
        classObj.Next_Schedule_Date__c = system.today();
        classObj.Advance_Scheduling__c = 3;
        classObj.Teacher__c = teacherObj.Id;
        classObj.Days_of_Week__c = 'Mon';
        update classObj;
        
        Test.startTest();
        SessionRecordsCreationBatchApex obj = new SessionRecordsCreationBatchApex();
        Database.executeBatch(obj);
        Test.stopTest();
        
        Class__c classOb = [SELECT Id,Next_Schedule_Date__c FROM Class__c WHERE Id =:classObj.Id]; 
        System.assertEquals(System.today().addMonths(1),classOb.Next_Schedule_Date__c);
        
    }
    
     @isTest
    static void test2(){
        Account teacherObj = [SELECT Id,Name FROM Account WHERE RecordType.Name = 'Teacher' LIMIT 1];
        
        Class__c classObj = [SELECT Id,Type__c,Frequency__c,Last_Session_Date__c,Last_Session_Scheduled_Date__c,Next_Schedule_Date__c
                             FROM Class__c LIMIT 1];
        
        Session__c sessionObj = [SELECT Id FROM Session__c LIMIT 1];
        sessionObj.Sequence__c = 1;
        sessionObj.Class__c = classObj.Id;
        update sessionObj;
        
        classObj.Type__c = ConstantClass.ongoingClsType;
        classObj.Frequency__c = ConstantClass.monthlyFrequency;
        classObj.Last_Session_Date__c = System.today().addMonths(2);
        classObj.Last_Session_Scheduled_Date__c = System.today();
        classObj.Next_Schedule_Date__c = system.today();
        classObj.Advance_Scheduling__c = 3;
        classObj.Teacher__c = teacherObj.Id;
        update classObj;
        
        Test.startTest();
        SessionRecordsCreationBatchApex obj = new SessionRecordsCreationBatchApex();
        Database.executeBatch(obj);
        Test.stopTest();
        
        Class__c classOb = [SELECT Id,Type__c FROM Class__c WHERE Id =:classObj.Id]; 
        System.assertEquals(ConstantClass.ongoingClsType,classOb.Type__c);
        
    }
}