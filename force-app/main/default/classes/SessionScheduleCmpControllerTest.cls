@isTest
public class SessionScheduleCmpControllerTest {
  public static testmethod void validateSessionScheduleCmpController(){
        
        Course__c course  		  = BlufyTestUtil.createCourseRec('Test', 'Active', 'Test');
        insert course;
        
        Account location      	  = BlufyTestUtil.createLocationRec('Test');
        insert location;
        
        Account tch      		  = BlufyTestUtil.createTeacherRec('Test', location.Id);
        insert tch;
        
        // Create class and Update for testing
        Class__c cls   			  = BlufyTestUtil.createClassRec('Test', Course.Id, ConstantClass.classType, 
                                                                 ConstantClass.draftStatus, tch.Id, 40, 
                                                                 ConstantClass.ongoingClsType, 21, Date.today()+1,
                                                                 Time.newInstance(4,4,5,6),ConstantClass.minutesDurationPicklist,
                                                                 4, ConstantClass.termFrequency);
		insert cls;
        
        Class__c clsUpdate = new Class__c(Id = cls.Id, Status__c = ConstantClass.clsOpenStatus, Days_of_Week__c = 'Fri;Mon;Tue;Wed;Sat;Thu;Sun',
                                          Frequency__c = ConstantClass.termFrequency, Type__c = ConstantClass.ongoingClsType, educato__Location__c = location.Id);
        update clsUpdate;
        
        //create term and update for testing
        Term__c trm = new Term__c(Name = 'Test1', Status__c = ConstantClass.draftStatus, Start_Date__c = Date.today()+1,
                    			  End_Date__c = Date.today().addMonths(1), Sessions__c = 21, Sequence__c = 1);        
        insert trm;
        
        Term__c trmUpdate = new Term__c(Id = trm.Id, Status__c = ConstantClass.clsOpenStatus);
        update trmUpdate;
 
        Class_Term__c clsTrm = [select Id, Name, Class__c, Class__r.Name, Class__r.Teacher__c, Class__r.Teacher__r.Name, Start_Date__c,End_Date__c, 
                                Class__r.Start_Time__c, Class__r.End_Time__c, Class__r.Days_of_Week__c, Sessions__c, Class__r.Duration__c,
                                Class__r.Duration_Unit__c, Exclude_Public_Holidays__c, Status__c, Class__r.educato__Location__c
                                FROM Class_Term__c WHERE Class__c =: clsUpdate.Id AND Status__c='Draft' LIMIT 1];
        
        
        Teacher_Leave__c tchLeave = new Teacher_Leave__c(Start_Date__c = Date.today()+1, End_Date__c = Date.today()+1,
                                                         Teacher__c = tch.Id, Status__c = 'Approved');
        insert tchLeave;
        
        Teacher_Working_Hours__c tchHours = new Teacher_Working_Hours__c(Teacher__c = tch.Id, Location__c = location.Id, Active__c = true,
                                                                         Start_Time__c = Time.newInstance(4,4,5,6), Day__c = 'Fri;Mon;Tue;Wed;Sat;Thu;Sun',
                                                                         End_Time__c = Time.newInstance(8,8,8,8));
        insert tchHours;
        
        // Create map for testing purpose
        Map<Date, Teacher_Leave__c> tchrLeaveMap = new Map<Date, Teacher_Leave__c>();
                for(Teacher_Leave__c tchrLv: [SELECT Id, Name, Status__c, Start_Date__c, End_Date__c 
                                              FROM Teacher_Leave__c WHERE Teacher__c =: tch.Id AND 
                                              Start_Date__c != null AND End_Date__c != null AND Status__c != 'Rejected']){     
                                                  for(Date stDt=tchrLv.Start_Date__c; stDt<=tchrLv.End_Date__c; stDt=stDt.addDays(1))
                                                      tchrLeaveMap.put(stDt, tchrLv);
                                              }
        //create list for testing purpose
        List<String> listTeachWorkHour = new List<String>();
                for(Teacher_Working_Hours__c techWrkHour : [SELECT Id,Day__c,End_Time__c,Start_Time__c,Active__c,Teacher__c
                                                            FROM Teacher_Working_Hours__c WHERE Active__c = true AND
                                                            Teacher__c =: tch.Id AND Start_Time__c <=: clsUpdate.Start_Time__c 
                                                            AND End_Time__c >=: clsUpdate.End_Time__c]){
                                                                if(techWrkHour.Day__c.contains(clsUpdate.Days_of_Week__c)){
                                                                    listTeachWorkHour.add(techWrkHour.Teacher__c);
                                                                }
                                                            }
        System.debug('listTeachWorkHour-->'+listTeachWorkHour);
        System.debug('tchrLeaveMap-->'+tchrLeaveMap);
        
        Account studentObj = BlufyTestUtil.createStudentRec('Gates','Test1@gmail.com');
        insert studentObj;
        
        Account customerObj = new Account(LastName = 'lie',personEmail = 'Test1@gmail.com',RecordTypeId =ConstantClass.stuCustomerRecordTypeId);
        insert customerObj;
        
        Enrollment__c enrollObj = BlufyTestUtil.createEnrollment(clsUpdate.Id, Date.newInstance(2020,03,24), location.Id, studentObj.Id, 'Enrolled', true,  Date.newInstance(2020,03,24),customerObj.id);
        insert enrollObj;
        
        Date stdate = clsTrm.Start_Date__c;
        Test.startTest();
        SessionScheduleCmpController.generateSession(clsTrm.Id);
        SessionScheduleCmpController.fillSessWrapper(clsTrm, 1, tchrLeaveMap, listTeachWorkHour, stdate,'Test');
        SessionScheduleCmpController.fillSession(SessionScheduleCmpController.fillSessWrapper(clsTrm, 1, tchrLeaveMap, listTeachWorkHour, stdate,'Test'), clsTrm.Id);
        SessionScheduleCmpController.insertSessions(SessionScheduleCmpController.generateSession(clsTrm.Id), clsTrm.Id);
        List<Session__c> sessList = new List<Session__c>();
        sessList.add(SessionScheduleCmpController.fillSession(SessionScheduleCmpController.fillSessWrapper(clsTrm, 1, tchrLeaveMap, listTeachWorkHour, stdate,'Test'), clsTrm.Id));
        SessionScheduleCmpController.createStudentSessions(sessList);
        System.assertEquals(trm.Start_Date__c,clsTrm.Start_Date__c);
        Test.stopTest();
    }

}