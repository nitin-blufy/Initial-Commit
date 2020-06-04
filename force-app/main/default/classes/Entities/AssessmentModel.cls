public class AssessmentModel extends Entity{
    private String am_module;
    private String am_lesson;
    public AssessmentModel(){

    }
    public String Id {
        get{return super.en_id;}
        set{super.en_id = value;}
    }
    public String Name {
        get{return super.en_name;}
        set{super.en_name = value;}
    }
    public String Module {
        get{return this.am_module;}
        set{this.am_module = value;}
    }
    public String Lesson {
        get{return this.am_lesson;}
        set{this.am_lesson = value;}
    }
}