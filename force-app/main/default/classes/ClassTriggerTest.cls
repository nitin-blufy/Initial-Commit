@isTest
private class ClassTriggerTest {
    static testmethod void validateTestCreateClsTermOnClass(){
        
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
        
        Class__c clsUpdate = new Class__c(Id = cls.Id, Status__c = ConstantClass.clsOpenStatus, Days_of_Week__c = 'Mon',
                                          Frequency__c = ConstantClass.monthlyFrequency, Type__c = ConstantClass.ongoingClsType,
                                          Advance_Scheduling_Unit__c = ConstantClass.schedulingPicklistMonth,
                                          Advance_Scheduling__c = ConstantClass.defaultNextScheDtDiff);
        update clsUpdate;
        
        
        //class create with frequency term and update
        Class__c clsObj   			  = BlufyTestUtil.createClassRec('Test', Course.Id, ConstantClass.classType, 
                                                                 ConstantClass.draftStatus, tch.Id, 40, 
                                                                 ConstantClass.ongoingClsType, 21, Date.today()+1,
                                                                 Time.newInstance(4,4,5,6),ConstantClass.minutesDurationPicklist,
                                                                 4, ConstantClass.monthlyFrequency);
		insert clsObj;
        
        ConstantClass.isSkipHolidayForMonthlySess=true;
        
        List<Term__c> trmList = new List<Term__c>();
        
        trmList.add(new Term__c(Name = 'Test1', Status__c = ConstantClass.draftStatus, Start_Date__c = Date.today()+1,
                    End_Date__c= Date.today().addMonths(6),Sessions__c = 21, Sequence__c = 1));
        trmList.add(new Term__c(Name = 'Test2', Status__c = ConstantClass.draftStatus, Start_Date__c = Date.today()+1,
                    Sessions__c = 24, Sequence__c = 2));        
        insert trmList;
        
        Term__c trmUpdate = new Term__c(Id = trmList[0].Id, Status__c = ConstantClass.clsOpenStatus); 
        update trmUpdate;
        
        Class__c classUpdate = new Class__c(Id = clsObj.Id, Status__c = ConstantClass.clsOpenStatus, Days_of_Week__c = 'Mon',
                                            Frequency__c = ConstantClass.termFrequency);
        update classUpdate;
        
        Test.startTest();
        Class__c clssObj = [SELECT Id,Advance_Scheduling__c FROM Class__c WHERE Id =: clsUpdate.Id];
        System.assertEquals(ConstantClass.defaultNextScheDtDiff,clssObj.Advance_Scheduling__c);
        UtilityClass.fillClsTerm(classUpdate, trmUpdate);
        List<Class_Term__c> clsTermList = [select Id, Name, Class__c from Class_Term__c where Class__c =: classUpdate.Id];
        System.assertEquals(1,clsTermList.size());  
        Test.stopTest();
    }
}