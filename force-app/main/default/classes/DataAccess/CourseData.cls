public class CourseData{
    private Boolean isAccessible;
    public CourseData(){
        isAccessible = true;
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
