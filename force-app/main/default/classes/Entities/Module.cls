public class Module extends Entity{
    private String mo_description;
    private Decimal mo_duration;
    private List<Lesson> mo_lessons;
    public Module(){

    }
    public String Id {
        get{return super.en_id;}
        set{super.en_id = value;}
    }
    public String Name {
        get{return super.en_name;}
        set{super.en_name = value;}
    }
    public String Description {
        get{return this.mo_description;}
        set{this.mo_description = value;}
    }
    public Decimal Duration {
        get{return this.mo_duration;}
        set{this.mo_duration = value;}
    }
    public List<Lesson> Lessons {
        get{return this.mo_lessons;}
        set{this.mo_lessons = value;}
    }
}