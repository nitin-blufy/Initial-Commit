public class Course {
    public Course() {

    }
    private String _name;
    private String _id;	
    private String _code;
    private String _type;
    private String _level;
    private String _format;
    private String _category;
    private String _status;
    private String _description;
    private String _requirements;
    private String _conditions;
    private Decimal _duration;
    private Decimal _sequence;
    private Decimal _classcount;

    public String Name {
        get{return this._name;}
        set{this._name = value;}
    }
    public String Id {
        get{return this._id;}
        set{this._id = value;}
    }
    public String Code {
        get{return this._code;}
        set{this._code = value;}
    }
    public String Type {
        get{return this._type;}
        set{this._type = value;}
    }
    public String Level {
        get{return this._level;}
        set{this._level = value;}
    }
    public String Format {
        get{return this._format;}
        set{this._format = value;}
    }
    public String Category {
        get{return this._category;}
        set{this._category = value;}
    }
    public String Status {
        get{return this._status;}
        set{this._status = value;}
    }
    public String Description {
        get{return this._description;}
        set{this._description = value;}
    }
    public String Requirements {
        get{return this._requirements;}
        set{this._requirements = value;}
    }
    public String Conditions {
        get{return this._conditions;}
        set{this._conditions = value;}
    }
    public Decimal Duration {
        get{return this._duration;}
        set{this._duration = value;}
    }
    public Decimal Sequence {
        get{return this._sequence;}
        set{this._sequence = value;}
    }
    public Decimal ClassCount {
        get{return this._classcount;}
        set{this._classcount = value;}
    }

    public List<Course> getActiveCourses(String id){
        CourseData crsData = new CourseData();
        return crsData.getActiveCourses(id);
    }
}
