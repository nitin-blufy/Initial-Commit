public class CourseFeeData{
    private Boolean isAccessible;
    private CourseFee cf_courseFee;

    public CourseFeeData(){
        isAccessible = true;
    }

    public List<CourseFee> getByCourseId(String sId){
        List<CourseFee> ls = new List<CourseFee>();
        if (isAccessible){
            Course cr = new Course();
            for(Course_Fee__c crFee: [SELECT Id, Name, Fee__c, Fee__r.Name, Fee__r.Amount__c, Fee__r.Unit_Price__c, 
                                             Fee__r.Schedule__c, Fee__r.Units__c, Fee__r.Type__c, Fee__r.Frequency__c, 
                                             Fee__r.Required__c, Fee__r.Override__c
                                      FROM Course_Fee__c 
                                      WHERE Course__c =: sId AND Fee__r.Amount__c != null AND Fee__r.Type__c != null])
            {
                CourseFee cf = new CourseFee();
                cf.Id  = crFee.Fee__c;
                cf.Name = crFee.Fee__r.Name;
                cf.CourseId = crFee.Course__c;
                cf.FeeId = crFee.Fee__c;

                Fee f = new Fee();
                f.Id = crFee.Fee__c;
                cf.Fee = f;
                ls.add(cf);
            }
            return ls;
        }
        else{
            return null;
        }        
    }

}
