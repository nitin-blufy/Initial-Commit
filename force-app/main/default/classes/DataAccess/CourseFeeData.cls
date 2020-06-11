public class CourseFeeData{
    private Boolean isAccessible;
    private CourseFee cf_courseFee;

    public CourseFeeData(){
        isAccessible = true;
    }

    public List<CourseFee> getByCourseId(String sId){        
        if (isAccessible){
            List<CourseFee> ls = new List<CourseFee>();
            for(Course_Fee__c crFee: [SELECT Id, Name, Fee__c, Fee__r.Name, Fee__r.Amount__c, Fee__r.Unit_Price__c, Course__c,
                                                Fee__r.Schedule__c, Fee__r.Units__c, Fee__r.Type__c, Fee__r.Frequency__c, 
                                                Fee__r.Required__c, Fee__r.Override__c
                                      FROM Course_Fee__c 
                                      WHERE Course__c =: sId AND Fee__r.Amount__c != null AND Fee__r.Type__c != null]){
                ls.add(fillCourseFee(crFee));
            }
            return ls;
        }
        else{
            return null;
        }        
    }

    public List<CourseFee> getByCourseIdOrType(String sId, String type){        
        if (isAccessible){
            List<CourseFee> ls = new List<CourseFee>();        
            for(Course_Fee__c crFee: [SELECT Id, Name, Fee__c, Fee__r.Name, Fee__r.Amount__c, Fee__r.Unit_Price__c, Course__c,
                                             Fee__r.Schedule__c, Fee__r.Units__c, Fee__r.Type__c, Fee__r.Frequency__c, 
                                             Fee__r.Required__c, Fee__r.Override__c
                                      FROM Course_Fee__c 
                                      WHERE Course__c =: sId AND Fee__r.Amount__c != null AND Fee__r.Type__c =:type]){
                ls.add(fillCourseFee(crFee));
            }
            return ls;
        }
        else{
            return null;
        }        
    }

    private CourseFee fillCourseFee(Course_Fee__c crFee){
        CourseFee cf = new CourseFee();
        cf.Id  = crFee.Fee__c;
        cf.Name = crFee.Fee__r.Name;
        cf.CourseId = crFee.Course__c;
        cf.FeeId = crFee.Fee__c;

        Fee fe 		 = new Fee();
        fe.Id 		 = crFee.Fee__c;
        fe.Name		 = crFee.Fee__r.Name;
        fe.Type  	 = crFee.Fee__r.Type__c;
        fe.Frequency = crFee.Fee__r.Frequency__c;  
        fe.Amount 	 = crFee.Fee__r.Amount__c;
        fe.Schedule  = crFee.Fee__r.Schedule__c;  
        fe.Units  	 = crFee.Fee__r.Units__c;   
        fe.UnitPrice = crFee.Fee__r.Unit_Price__c;
       	fe.Overrid 	 = crFee.Fee__r.Override__c;
        fe.Required  = crFee.Fee__r.Required__c;
        cf.Fee = fe;
        
        return cf;
    }
}