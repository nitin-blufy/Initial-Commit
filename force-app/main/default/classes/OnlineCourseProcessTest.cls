@isTest
public class OnlineCourseProcessTest {
	
    @testSetup
    static void testDataSetup(){
        BlufyTestUtil.init();        
    }
    
    @isTest
    static void test1(){
        Account accObj = [SELECT Id FROM Account WHERE RecordType.Name = 'Location' LIMIT 1];
        OnlineCourseFilterApexController obj1 = new OnlineCourseFilterApexController();
        
        CourseWithClassListApexController obj2 = new CourseWithClassListApexController();
    }
}