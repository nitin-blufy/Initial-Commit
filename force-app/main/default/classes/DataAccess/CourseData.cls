public class CourseData{
    private bool isAccessible;
    public CourseData(){
        isAccessible = true;
    }
    public List<Course__c> getActiveCourses(){
        List<Course> lsCourse = new List<Course>();   
        if (isAccessible){
            for(Course__c crs: [select Id, Name  from Course__c WHERE Status__c =: ConstantClass.activeStatus ORDER BY Name ]){
                Course cr = new Course();
                cr.Id = crs.Id;
                cr.Name = crs.Name; 
                cr.Code = crs.Code__c; 
                cr.Type = crs.Type__c; 
                cr.Level = crs.Level__c; 
                cr.Format = crs.Format__c; 
                cr.Category = crs.Category__c; 
                cr.Status = crs.Status__c; 
                cr.Description = crs.Description__c; 
                cr.Requirements = crs.Requirement__c; 
                cr.Conditions = crs.Conditions__c; 
                cr.Duration = crs.Duration__c; 
                cr.Sequence = crs.Sequence__c; 
                cr.ClassCount = crs.Class_Count__c; 
                lsCourse.add(cr);
            }
            return lsCourse;
        }
        else {
            return null;
        }

    }
    public static List<Course> getCourseById(String id){
        List<Course> lsCourse = new List<Course>();   
        if (isAccessible){
            for(Course__c crs: [select Id, Name  from Course__c WHERE Id =: id ORDER BY Name ]){
                Course cr = new Course();
                cr.Id = crs.Id;
                cr.Name = crs.Name; 
                cr.Code = crs.Code__c; 
                cr.Type = crs.Type__c; 
                cr.Level = crs.Level__c; 
                cr.Format = crs.Format__c; 
                cr.Category = crs.Category__c; 
                cr.Status = crs.Status__c; 
                cr.Description = crs.Description__c; 
                cr.Requirements = crs.Requirement__c; 
                cr.Conditions = crs.Conditions__c; 
                cr.Duration = crs.Duration__c; 
                cr.Sequence = crs.Sequence__c; 
                cr.ClassCount = crs.Class_Count__c; 
                lsCourse.add(cr);
            }
            return lsCourse;
        }
        else {
            return null;
        }
    }

}
