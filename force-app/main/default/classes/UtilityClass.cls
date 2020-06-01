public class UtilityClass {
    //Its used to fill session records
    public static List<Session__c> createSessionRecords(Class__c classRec,Date startDate,Date endDate,Integer sessionNum){
        List<Session__c> listSession = new List<Session__c>();
        while(startDate <= endDate){
            if(classRec.Days_of_Week__c.contains(DateTime.newInstance(startDate.year(), startDate.month(), startDate.day()).format('EEE'))){
                Session__c sess       = new Session__c();
                sess.put('educato__Sequence__c',sessionNum + 1);
                sess.put('educato__Class__c',classRec.Id);
                sess.put('educato__Teacher__c',classRec.Teacher__c);
                sess.put('educato__Session_Date__c',startDate);
                sess.put('educato__Start_Time__c',classRec.Start_Time__c);
                sess.put('educato__Status__c',ConstantClass.ScheduledStatus);
                sess.put('educato__Duration_Unit__c',classRec.Duration_Unit__c);
                sess.put('educato__Duration__c',classRec.Duration__c);
                sess.put('educato__Location__c',classRec.Location__c);
                sess.put('educato__Type__c',ConstantClass.sessionStandardType);
                listSession.add(sess);
                sessionNum += 1;
            }
            startDate = startDate.addDays(1);
        }
        return listSession;
    }
    
    //------- Create Class Term when class Type equals to Term  --------//
    public static Class_Term__c fillClsTerm (Class__c cls, Term__c term){
        Class_Term__c clsTerm  = new Class_Term__c();
        clsTerm.put('Class__c',cls.Id);
        clsTerm.put('Status__c',ConstantClass.draftStatus);
        if(term != null){//Its used when frequency is term based
            clsTerm.put('Name',term.Name);
            clsTerm.put('educato__Sequence__c',term.Sequence__c);
            clsTerm.put('educato__Sessions__c',term.Sessions__c);    
            clsTerm.put('educato__Start_Date__c', term.Start_Date__c);
            clsTerm.put('educato__End_Date__c',term.End_Date__c);    
            clsTerm.put('educato__Term__c', term.Id);
        }else{//Its used when frequency is fixed based classes
            clsTerm.put('Name', 'Term 1');
            clsTerm.put('educato__Sequence__c', 1); 
            clsTerm.put('educato__Sessions__c', cls.Sessions__c);
            clsTerm.put('educato__Start_Date__c',cls.Start_Date__c);
            clsTerm.put('educato__End_Date__c',cls.End_Date__c);
        }
        return clsTerm;
    } 
    
    //This function is used to get dynmically picklist values of the object, In Account billing country code values and label values are diff, So method is used.
    //Used on enrollment process
    public static List<String> getPickValues(String ObjectApi_name, String Field_name){ 
        //Map<String, String> mapPickvals = new Map<String, String>();        
        List<String> lstPickvals = new List<String>();
            
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(ObjectApi_name);//From the Object Api name retrieving the SObject
        Sobject Object_name = targetType.newSObject();
        Schema.sObjectType sobject_type = Object_name.getSObjectType(); //grab the sobject that was passed
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); //describe the sobject
        Map<String, Schema.SObjectField> field_map    = sobject_describe.fields.getMap(); //get a map of fields for the passed sobject
        List<Schema.PicklistEntry> pick_list_values   = field_map.get(Field_name).getDescribe().getPickListValues(); //grab the list of picklist values for the passed field on the sobject
        
        for(Schema.PicklistEntry a : pick_list_values){ //for all values in the picklist list
            //lstPickvals.add(a.getValue());
            //mapPickvals.put(a.getLabel(), a.getValue());
            lstPickvals.add(a.getValue());
        }
        return lstPickvals;
    }
    
    public static Enrollment__c fillEnrollment(String cstmrId, String locId, String clsId, Date stDate, String status){
        Enrollment__c enr = new Enrollment__c();
        enr.Location__c   = locId;
        enr.Class__c      = clsId;
        enr.Start_Date__c = stDate;
        enr.Parent__c     = cstmrId;
        enr.Status__c     = status;
        enr.Enrollment_Date__c = System.today();
        return enr;
    }
    
    public static Invoice__c fillInvoice(String cstmrId, String locId, String subsId, String invType, String status){
        Invoice__c invoice = new Invoice__c();
        invoice.Customer__c= cstmrId;
        invoice.Location__c= locId;
        invoice.Subscription__c = subsId;
        invoice.Status__c       = status;
        invoice.Invoice_Type__c = invType;
        invoice.Invoice_Date__c = System.today();
        return invoice;
    }
    
    public static Invoice_Line_Item__c fillInvLineItem(String invId, String enrId, String subLnItmId, String feeId, String disId, String type, Decimal amount, Boolean isApplyGst){
        Invoice_Line_Item__c invLnItm = new Invoice_Line_Item__c();
        //invLnItm.Invoice__c   = invId;
        invLnItm.put('educato__Invoice__c',invId);
        invLnItm.put('educato__Enrollment__c',enrId);
        //invLnItm.Subscription_Line_Item__c = subLnItmId;
        invLnItm.put('educato__Subscription_Line_Item__c',subLnItmId);
        //invLnItm.Fee__c       = feeId;
        invLnItm.put('educato__Fee__c',feeId);
        invLnItm.put('educato__Discount__c',disId);
        //invLnItm.Type__c      = type;
        invLnItm.put('educato__Type__c',type);
        invLnItm.put('educato__Amount__c',roundOffAmount(amount));
        if(isApplyGst){
            Decimal gstTaxPer = 0;
            try{
                gstTaxPer     = Decimal.valueOf(Label.GST_Rate);
                invLnItm.put('educato__GST_Amount__c',roundOffAmount(amount*(gstTaxPer/100)));
                if(type == ConstantClass.discountType){
                    invLnItm.put('educato__GST_Amount__c',-(invLnItm.GST_Amount__c));
                }
            }catch(Exception e){
                invLnItm.put('educato__GST_Amount__c',0);
            }
        }
            
        return invLnItm;
    }
    
    public static Payment__c fillPayment(String cstmrId, String invId, String status, Decimal amount){
        Payment__c payment = new Payment__c();
        payment.Parent__c  = cstmrId;
        payment.Invoice__c = invId;
        payment.Amount__c  = roundOffAmount(amount);
        payment.Status__c  = status;
        payment.Payment_Date__c = System.today();
        return payment;
    }   
    
    public static Map<String,List<Teacher_Leave__c>> getTeacherLeaves(Set<String> setTeacherId){
        Map<String,List<Teacher_Leave__c>> mapTeacherIdToTeacherLeave = new Map<String,List<Teacher_Leave__c>>();
        for(Teacher_Leave__c tchrLv: [SELECT Id, Name, Status__c, Start_Date__c, End_Date__c,Teacher__c 
                                      FROM Teacher_Leave__c WHERE Teacher__c IN: setTeacherId AND 
                                      Start_Date__c != null AND End_Date__c != null AND Status__c != 'Rejected']){
                                          for(Date stDt=tchrLv.Start_Date__c; stDt<=tchrLv.End_Date__c; stDt=stDt.addDays(1)){
                                              List<Teacher_Leave__c> listTeacherleave = new List<Teacher_Leave__c>();
                                              if(mapTeacherIdToTeacherLeave.containsKey(tchrLv.Teacher__c))
                                                  listTeacherleave = mapTeacherIdToTeacherLeave.get(tchrLv.Teacher__c);
                                              listTeacherleave.add(tchrLv);
                                              mapTeacherIdToTeacherLeave.put(tchrLv.Teacher__c,listTeacherleave);
                                          }                                          
                                      }
        return mapTeacherIdToTeacherLeave;
    }
    
    public static Map<String,List<Teacher_Working_Hours__c>> getTeacherWorkingHour(Set<String> setTeacherId){
        Map<String,List<Teacher_Working_Hours__c>> mapTeacherIdToTechrWrkHour = new Map<String,List<Teacher_Working_Hours__c>>();
        for(Teacher_Working_Hours__c techWrkHour : [SELECT Id,Day__c,End_Time__c,Start_Time__c,Active__c,Teacher__c
                                                    FROM Teacher_Working_Hours__c WHERE Active__c = true AND
                                                    Teacher__c IN: setTeacherId]){
                                                        List<Teacher_Working_Hours__c> listTechrWrkHr = new List<Teacher_Working_Hours__c>();
                                                        if(mapTeacherIdToTechrWrkHour.containsKey(techWrkHour.Teacher__c))
                                                            listTechrWrkHr = mapTeacherIdToTechrWrkHour.get(techWrkHour.Teacher__c);
                                                        listTechrWrkHr.add(techWrkHour);
                                                        mapTeacherIdToTechrWrkHour.put(techWrkHour.Teacher__c,listTechrWrkHr);
                                                    }
        return mapTeacherIdToTechrWrkHour;
    }
    
    public static List<Holiday__c> getHolidays(){
        List<Holiday__c> listOfHolidays = new List<Holiday__c>();
        for (Holiday__c holidays : [Select Id,Start_Date__c,End_Date__c,Start_Time__c,End_Time__c from Holiday__c 
                                    WHERE Start_Date__c != null]){
                                        listOfHolidays.add(holidays);
                                    }
        return listOfHolidays;
    }
    
    public static List<Session__c> getUpdatedSessions(Integer sequnNum,List<Session__c> sessList,Map<String,List<Teacher_Leave__c>> mapTeacherIdToTeacherLeave,Map<String,List<Teacher_Working_Hours__c>> mapTeacherIdToTechrWrkHour,List<Holiday__c> listOfHolidays){
        List<Session__c> listSession = new List<Session__c>();
        List<Integer> listofSkipIndex = new List<Integer>();
        for(Session__c sess : sessList){
            if(ConstantClass.isSkipHolidayForMonthlySess){
                if(listOfHolidays.size() > 0){
                    for(Holiday__c holiday : listOfHolidays){    
                        if((sess.Session_Date__c >= holiday.Start_Date__c && sess.Session_Date__c <= holiday.End_Date__c)){
                            listofSkipIndex.add(sessList.indexOf(sess));
                        }
                    }
                }
            }
            else{
                if(mapTeacherIdToTeacherLeave.keySet().size() > 0){
                    if(mapTeacherIdToTeacherLeave.containsKey(sess.Teacher__c)){
                        if(mapTeacherIdToTeacherLeave.get(sess.Teacher__c) != NULL){
                            List<Teacher_Leave__c> listTeacherLeave = mapTeacherIdToTeacherLeave.get(sess.Teacher__c);
                            for(Teacher_Leave__c techrLv : listTeacherLeave){
                                if(techrLv.Start_Date__c <=  sess.Session_Date__c && techrLv.End_Date__c >= sess.Session_Date__c){                                                
                                    if(techrLv.Status__c == ConstantClass.approvedStatus)
                                        sess.Notes__c = 'Teacher is on Leave';
                                    else if(techrLv.Status__c == 'Requested')
                                        sess.Notes__c = 'Teacher has requested a leave';                                           
                                }  
                            } 
                        }
                    }
                }
                List<String> listTeachrId = new List<String>();
                if(mapTeacherIdToTechrWrkHour.keySet().size() > 0){
                    if(mapTeacherIdToTechrWrkHour.containsKey(sess.Teacher__c)){
                        if(mapTeacherIdToTechrWrkHour.get(sess.Teacher__c) != NULL){
                            List<Teacher_Working_Hours__c> listTchrWrkHr = mapTeacherIdToTechrWrkHour.get(sess.Teacher__c);
                            for(Teacher_Working_Hours__c techrWrkHr : listTchrWrkHr){
                                if(sess.Start_Time__c >= techrWrkHr.Start_Time__c && sess.End_Time__c < techrWrkHr.End_Time__c){
                                    if(techrWrkHr.Day__c.contains(DateTime.newInstance(sess.Session_Date__c.year(),sess.Session_Date__c.month(),sess.Session_Date__c.day()).format('EEE'))){
                                        listTeachrId.add(techrWrkHr.Teacher__c);
                                    }
                                }
                            }
                        }
                    }
                }
                if(!listTeachrId.contains(sess.Teacher__c)){         
                    if(String.isBlank(sess.Notes__c))
                        sess.Notes__c = 'Teacher is not available';
                    else
                        sess.Notes__c += ' Teacher is not available';
                }
                
                if(listOfHolidays.size() > 0){
                    for(Holiday__c holiday : listOfHolidays){                                        
                        if(sess.Session_Date__c >= holiday.Start_Date__c && sess.Session_Date__c <= holiday.End_Date__c){
                            if(String.isBlank(sess.Notes__c))
                                sess.Notes__c = 'It is a Holiday';
                            else
                                sess.Notes__c +=' It is a Holiday';
                        }  
                    }
                }
                if(String.isNotBlank(sess.Notes__c))
                    sess.Type__c = ConstantClass.sessionExceptionType;
            }
        }
        
        if(listofSkipIndex.size() > 0){
            for(Session__c sess : sessList){
                if(!listofSkipIndex.contains(sessList.indexOf(sess))){
                    listSession.add(sess);
                }
            }
            if(listSession.size() > 0){
                for(Integer i = sequnNum ; i< listSession.size(); i++){
                    listSession[i].put('educato__Sequence__c', i + 1);
                } 
            }
            return listSession;
        }
        else
            return sessList;
    }
    
    public static Decimal roundOffAmount(Decimal amount){
        Decimal value = 0;
        if(amount != NULL){
            value = amount.setScale(2,System.RoundingMode.HALF_UP);
        }
        return value;        
    }    
}