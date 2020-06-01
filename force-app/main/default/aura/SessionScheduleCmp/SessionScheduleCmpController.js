({
    doInit : function(component,event,helper){
        var recordId = component.get("v.recordId");
        // alert(recordId);
        var action = component.get("c.generateSession");
        action.setParams({
            "clsTermId": recordId
        });
        action.setCallback(this,function(result){
            var res = result.getReturnValue();
           //alert(JSON.stringify(res));
            if(res.length > 0){
                component.set("v.sessionList",res);
            }else{                
                helper.showToast(component,event,"Error","Only draft class term can be schedule.");
                $A.get("e.force:closeQuickAction").fire();
            }
        });
        
        $A.enqueueAction(action);
    },
    handleMyApplicationEvent : function(component, event, helper) {
        var valueId = event.getParam("selectedOption");  
        var value = event.getParam("inputValue");
        var indx = event.getParam("slctIndex");
        
        var sessionList= component.get("v.sessionList");
        sessionList[indx].tchrId = valueId;
        sessionList[indx].tchrName = value;
        console.log(JSON.stringify(sessionList));
        component.set("v.sessionList",sessionList);
    },
    closeQuickActionModel : function(component,event,helper){
        $A.get("e.force:closeQuickAction").fire();
    },    
    saveQuickActionModel : function(component,event,helper){
        var res=component.get("v.sessionList");
        console.log('res-->'+res);
        var artId = component.get("v.recordId");
        
        var action =component.get("c.insertSessions");
        action.setParams({
            "sessList": res,
            "recordId": artId
        });
        action.setCallback(this,function(response){
            var state =  response.getState();
            if(state=='SUCCESS'){
                helper.showToast(component,event,"Success","Class term have been successfully scheduled.");
                $A.get("e.force:closeQuickAction").fire();
            }
        });
        $A.enqueueAction(action);
    },
})