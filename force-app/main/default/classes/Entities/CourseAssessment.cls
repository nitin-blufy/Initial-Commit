public class CourseAssessment extends Entity{
    private List<AssessmentModel> ca_model;
    public CourseAssessment(){

    }
    public String Id {
        get{return super.en_id;}
        set{super.en_id = value;}
    }
    public String Name {
        get{return super.en_name;}
        set{super.en_name = value;}
    }
    public List<AssessmentModel> Models{
        get{return this.ca_model;}
        set{this.ca_model = value;}
    }
}