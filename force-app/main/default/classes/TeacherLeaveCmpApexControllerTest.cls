@isTest
public class TeacherLeaveCmpApexControllerTest {
    public static testmethod void validateTeacherLeaveCmpApexController(){
        
        Course__c course  		  = BlufyTestUtil.createCourseRec('Test', 'Active', 'Test');
        insert course;        
         
        Account location      	  = BlufyTestUtil.createLocationRec('Test');
        insert location;
        
        Account tch      		  = BlufyTestUtil.createTeacherRec('Test', location.Id);
        insert tch;
        
        //create class and update
        Class__c cls   			  = BlufyTestUtil.createClassRec('Test', Course.Id, ConstantClass.classType, 
                                                                 ConstantClass.draftStatus, tch.Id, 40, 
                                                                 ConstantClass.ongoingClsType, 21, Date.today()+1,
                                                                 Time.newInstance(4,4,5,6),ConstantClass.minutesDurationPicklist,
                                                                 4, ConstantClass.monthlyFrequency);
		insert cls;
        
        Class__c clsUpdate = new Class__c(Id = cls.Id, Status__c = ConstantClass.clsOpenStatus, Days_of_Week__c = 'Fri;Mon;Tue;Wed;Sat;Thu;Sun',
                                          Frequency__c = ConstantClass.monthlyFrequency, Type__c = ConstantClass.ongoingClsType,
                                          Advance_Scheduling_Unit__c = ConstantClass.schedulingPicklistMonth,
                                          Advance_Scheduling__c = ConstantClass.defaultNextScheDtDiff);
        update clsUpdate;
      
        Teacher_Leave__c tchLeave = new Teacher_Leave__c(Start_Date__c = Date.today()+1, End_Date__c = Date.today()+1,
                                                         Teacher__c = tch.Id, Status__c = 'Requested');
        insert tchLeave;
        
        List<Teacher_Leave__c> listTeacherLeave = [SELECT Id,Teacher__c,End_Date__c,Start_Date__c FROM Teacher_Leave__c 
                                                   WHERE Id =: tchLeave.Id];
        
        List<Session__c	> sessList = [SELECT Id,Name,Session_Date__c,Start_Time__c,End_Time__c,Status__c,Teacher__c,Teacher__r.Name
                                      FROM Session__c WHERE Teacher__c =:tchLeave.Teacher__c AND Status__c !=: ConstantClass.sessionCancel
                                      AND Session_Date__c >=: tchLeave.Start_Date__c AND Session_Date__c <=: tchLeave.End_Date__c];
        Test.startTest();
        TeacherLeaveCmpApexController.doInitApex(tchLeave.Id);
        TeacherLeaveCmpApexController.fillSessionDataWrapper(sessList.get(0));
        TeacherLeaveCmpApexController.doSaveApex(tchLeave.Id,TeacherLeaveCmpApexController.doInitApex(tchLeave.Id));
        System.assertEquals(sessList[0].Teacher__c, tchLeave.Teacher__c);
        Test.stopTest();
    }
}