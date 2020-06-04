public class CourseData{
    private Boolean isAccessible;
    private Course cr_course;
    public CourseData(){
        isAccessible = true;
    }
    public CourseData(Course cr){
        isAccessible = true;
        this.cr_course = cr;
    }
    public void setCourse(Course cr){
        this.cr_course = cr;
    }
    
    public List<Course> getFees(){
        List<Course> lsCourse = new List<Course>();   
        if (isAccessible){
            Course cr = new Course();
            for(Course_Fee__c crFee: [SELECT Id, Name, Fee__c, Fee__r.Name, Fee__r.Amount__c, Fee__r.Unit_Price__c, Fee__r.Schedule__c, Fee__r.Units__c, Fee__r.Type__c, Fee__r.Frequency__c, Fee__r.Required__c, Fee__r.Override__c
                                      FROM Course_Fee__c WHERE Course__c =: this.cr_course.Id AND Fee__r.Amount__c != null AND Fee__r.Type__c != null])
            {
                Fee fe = new Fee();
                fe.Id  = crFee.Fee__c;
                fe.Name = crFee.Fee__r.Name;
                fe.Type  = crFee.Fee__r.Type__c;
                fe.Frequency = crFee.Fee__r.Frequency__c;  
                fe.Amount = crFee.Fee__r.Amount__c;
                fe.Schedule  = crFee.Fee__r.Schedule__c;  
                fe.Units  = crFee.Fee__r.Units__c != null ? Integer.valueOf(crFee.Fee__r.Units__c):0;   
                cr.Fees.add(fe);
            }
            lsCourse.add(cr);
            return lsCourse;
        }
        else{
            return null;
        }        
    }
    public List<Fee> getFeesById(String crId){
        List<Fee> lsFee = new List<Fee>();
        if (isAccessible){
            Course cr = new Course();
            for(Course_Fee__c crFee: [SELECT Id, Name, Fee__c, Fee__r.Name, Fee__r.Amount__c, Fee__r.Unit_Price__c, Fee__r.Schedule__c, Fee__r.Units__c, Fee__r.Type__c, Fee__r.Frequency__c, Fee__r.Required__c, Fee__r.Override__c
                                      FROM Course_Fee__c WHERE Course__c =: crId AND Fee__r.Amount__c != null AND Fee__r.Type__c != null])
            {
                Fee fe = new Fee();
                fe.Id  = crFee.Fee__c;
                fe.Name = crFee.Fee__r.Name;
                fe.Type  = crFee.Fee__r.Type__c;
                fe.Frequency = crFee.Fee__r.Frequency__c;  
                fe.Amount = crFee.Fee__r.Amount__c;
                fe.Schedule  = crFee.Fee__r.Schedule__c;  
                fe.Units  = crFee.Fee__r.Units__c != null ? Integer.valueOf(crFee.Fee__r.Units__c):0;   
                lsFee.add(fe);
            }
            return lsFee;
        }
        else{
            return null;
        }        
    }

    public List<Course> getActiveCourses(){
        List<Course> lsCourse = new List<Course>();   
        if (isAccessible){
            for(educato__Course__c crs: [select Id, Name  from Course__c WHERE Status__c =: ConstantClass.activeStatus ORDER BY Name ]){
                Course cr = new Course();
                cr.Id = crs.Id;
                cr.Name = crs.Name; 
                cr.Code = crs.educato__Code__c; 
                cr.Type = crs.educato__Type__c; 
                cr.Level = crs.educato__Level__c; 
                cr.Format = crs.educato__Format__c; 
                cr.Category = crs.educato__Category__c; 
                cr.Status = crs.educato__Status__c; 
                cr.Description = crs.educato__Description__c; 
                cr.Requirements = crs.educato__Requirements__c; 
                cr.Conditions = crs.educato__Conditions__c; 
                cr.Duration = crs.educato__Duration__c; 
                cr.Sequence = crs.educato__Sequence__c; 
                cr.ClassCount = crs.educato__Class_Count__c; 
                lsCourse.add(cr);
            }
            return lsCourse;
        }
        else {
            return null;
        }

    }

    
    public List<Course> getAssessments(){
        List<Course> lsCourse = new List<Course>();   
        if (isAccessible){
            for(educato__Course__c crs: [select Id, Name  from Course__c WHERE Status__c =: ConstantClass.activeStatus ORDER BY Name ]){
                Course cr = new Course();
            }
            return lsCourse;
        }
        else {
            return null;
        }
    }
    
    public List<Course> getCourseById(String id){
        List<Course> lsCourse = new List<Course>();   
        if (isAccessible){
            for(educato__Course__c crs: [select Id, Name  from Course__c WHERE Id =: id ORDER BY Name ]){
                Course cr = new Course();
                cr.Id = crs.Id;
                cr.Name = crs.Name; 
                cr.Code = crs.educato__Code__c; 
                cr.Type = crs.educato__Type__c; 
                cr.Level = crs.educato__Level__c; 
                cr.Format = crs.educato__Format__c; 
                cr.Category = crs.educato__Category__c; 
                cr.Status = crs.educato__Status__c; 
                cr.Description = crs.educato__Description__c; 
                cr.Requirements = crs.educato__Requirements__c; 
                cr.Conditions = crs.educato__Conditions__c; 
                cr.Duration = crs.educato__Duration__c; 
                cr.Sequence = crs.educato__Sequence__c; 
                cr.ClassCount = crs.educato__Class_Count__c; 
                lsCourse.add(cr);
            }
            return lsCourse;
        }
        else {
            return null;
        }
    }

}
